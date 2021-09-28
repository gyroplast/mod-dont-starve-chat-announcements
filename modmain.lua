-- server-only mod, exit early on client
if not GLOBAL.TheNet:GetIsServer() then do return end end

-- add mod scripts to package path for require() to work as expected
GLOBAL.package.path = GLOBAL.package.path..";"..MODROOT.."/?.lua"
-- raise self-awareness of imported modules
GLOBAL.modname = modname

local json = require("json")

local C = require("lib.const")
local util = require("lib.util")
local Log = require("lib.logging")()
local DiscordClient = require("client.discord")()

-- convenient aliases and simple helpers
local _G = GLOBAL
local TheNet = _G.TheNet

-- configuration options
local CFG_INCLUDE_DAY = GetModConfigData("include_day")
local CFG_INCLUDE_DEATH_LOCATION = GetModConfigData("include_death_location")

-- wrapper function to display arbitrary messages, word-wrapped.
local function print_to_player(msg)
  if type(msg) == "table" then msg = table.concat(msg, "\n") else msg = tostring(msg) end
  TheNet:SystemMessage(util.reflow(msg, 88))
end

local function getConfigNameForPrefab(prefab)
  return C.ANNOUNCE_MOBS_TO_CONFIG_NAME_MAP[prefab] or prefab
end

-- obtain effective announcement flags for a prefab, considering a possible "DEFAULT" setting
local function getAnnounceChannels(prefab, event)
  -- map multiple prefab variants to single config name, f. ex. koalefant_summer/_winter to just koalefant
  local config_name = getConfigNameForPrefab(prefab) or prefab
  -- get individual setting of prefab for event
  local prefab_setting = GetModConfigData(tostring(event).."_"..tostring(config_name)) or C.AnnounceChannelEnum.DISABLED

  -- if individual setting is DEFAULT, set it to the global event default setting
  if util.FlagIsSet(C.AnnounceChannelEnum.DEFAULT, prefab_setting) then
    prefab_setting = GetModConfigData("announce_"..tostring(event)) or C.AnnounceChannelEnum.DISABLED
  end
  return prefab_setting
end

-- construct list of enabled announcement channels
local function announceChannelList(announce_channels)
  if not announce_channels then return {} end
  local channelList = {}
  for k, v in pairs(C.AnnounceChannelEnum) do
    if util.FlagIsSet(v, announce_channels) then
      table.insert(channelList, k)
    end
  end
  return channelList
end

local function CATest()
  local msg = ("This is a test message from the %s mod for Don't Starve Together!"):format(_G.GetModFancyName(modname))
  if TheNet then
    TheNet:Announce(msg, nil, nil, "mod")
  else
    local error = "TheNet not initialized, cannot announce test message on server."
    Log:Warn("CATest() "..error)
    print_to_player(error)
  end
  if DiscordClient.ok and DiscordClient.webhook then
    msg = msg.." Using Discord Webhook `"..tostring(DiscordClient.webhook.name).."`."
    DiscordClient:Announce(msg, C.CHARACTER_ICON[(_G.ThePlayer and _G.ThePlayer.prefab or "unknown")])
  else
    local error = "DiscordClient not initialized, cannot announce test message on Discord."
    Log:Warn("CATest() "..error)
    print_to_player(error)
  end
end

local function CAHelp()
  local msg = {
    "Set a Discord Webhook URL for the current shard with CASetDiscordURL(<URL>).",
    "Make sure the URL is enclosed in double quotes, and you are running the command in the Remote console instead of Local.",
    "Tap the Ctrl key to switch between Remote and Local console input.",
    "Example:",
    "CASetDiscordURL(\"https://discord.com/api/webhooks/734950925428326401/3ni3djnasd\")"
  }
  print_to_player(msg)
end

local function CAStatus()
  local msg = {
    "Current Configuration Status",
    ("Append Day is %s  --  Append Location is %s"):format(
      CFG_INCLUDE_DAY and "ENABLED" or "DISABLED",
      CFG_INCLUDE_DEATH_LOCATION and "ENABLED" or "DISABLED"
    )
  }

  if DiscordClient.ok and DiscordClient.webhook then
    msg[#msg+1] = ("Discord is configured on this shard, using webhook `%s`."):format(
      tostring(DiscordClient.webhook.name)
    )
  else
    msg[#msg+1] = "Discord is NOT configured on this shard. Run CAHelp() for instructions."
  end

  print_to_player(msg)
end

local function CASetDiscordURL(webhook_url)
  if type(webhook_url) ~= "string" then
    local msg = "CASetDiscordURL() called without required URL argument."
    Log:Warn(msg)
    print_to_player("ERROR "..msg)
    return
  end

  webhook_url = util.trim(webhook_url)
  Log:Trace("CASetDiscordURL() setting Discord Webhook URL: `%s'", webhook_url)

  DiscordClient:SetWebhookURL(webhook_url, function(error)
    local msg = {}
    if error then
      msg = "ERROR "..tostring(error)
      Log:Warn("CASetDiscordURL() "..msg:gsub("\n","\\n"))
    else
      msg = {"SUCCESS setting Discord Webhook URL"}
      if DiscordClient.ok and DiscordClient.webhook then
          Log:Trace("CASetDiscordURL() successfully set webhook url: DiscordClient = %s - ok = %s - webhook = %s",
          tostring(DiscordClient),
          tostring(DiscordClient.ok),
          util.table2str(DiscordClient.webhook)
        )
        msg[#msg+1] = ("Discord is set up to announce to Webhook `%s` on this shard."):format(DiscordClient.webhook.name)

        if type(msg) == "table" then msg = table.concat(msg, "\n") else msg = tostring(msg) end
        Log:Info("CASetDiscordURL() "..msg:gsub("\n","\\n"))
      else
        msg = "ERROR setting Discord Webhook URL, state is inconsistent. Things might still work, though."

        Log:Warn("CASetDiscordURL() successfully set webhook url, but DiscordClient is not set accordingly: DiscordClient = %s - ok = %s - webhook = %s",
          tostring(DiscordClient),
          tostring(DiscordClient.ok),
          util.table2str(DiscordClient.webhook)
        )
      end
    end

    print_to_player(msg)
  end)
end

local function health_override(instance)
  local function decorated_health_DoDelta(f)
    local function func(...)
      local args = {...}
      --[[ store last hit information on health component, iff damage is not caused by oldager_component ]]
      local inst = args[1]
      local amount = args[2]
      local cause = args[4]
      local afflicter = args[6]

      if inst and cause ~= "oldager_component" then
        inst.CA_lasthit = { amount = amount, cause = cause, afflicter = afflicter, time = _G.GetTime() }
        Log:Trace("stored last hit info: "..util.table2str(inst.CA_lasthit))
      end
      f(...)
    end
    return func
  end

  if instance.components.health then
    instance.components.health.DoDelta = decorated_health_DoDelta(instance.components.health.DoDelta)
  end
end

-- attached to all configured monster death events, and player death
local function death_handler(instance)
  instance:ListenForEvent("death", function(inst, data)
    --[[ Overwrite death cause and afflicter by who attacked the entity within the last 5 seconds
         to count as the actual killer. Also take any lasthit cause/afflicter not older than 5 seconds
         if oldager_component was the death cause, to display the actual _cause_ for aging to death.
         This is applied to all deaths now, as it is quite nice to see what _really_ killed an entity,
         but in particular works around Wanda always dying to "passage of time", independent of who or
         what dealt fatal damage.
    --]]
    local lasthit = inst.components and inst.components.health.CA_lasthit or nil
    local last_attacker = inst.components and inst.components.combat and inst.components.combat.lastattacker or nil
    local last_attacked_time = inst.components and inst.components.combat and inst.components.combat.lastwasattackedtime or 0

    Log:Trace("death_handler dmg info: "..util.table2str({lasthit=util.table2str(lasthit), last_attacker=last_attacker, last_attacked_time=last_attacked_time, gettime=_G.GetTime()}))
    if last_attacker and _G.GetTime() < last_attacked_time + 5 then
      data.afflicter = last_attacker or data.afflicter
      data.cause = tostring(last_attacker.prefab)
      Log:Trace(string.format("death_handler setting last attacker afflicter %s, cause %s",
        tostring(data.afflicter),
        tostring(data.cause)
      ))
    elseif data.cause == "oldager_component" and lasthit and _G.GetTime() < lasthit.time + 5 then
      data.afflicter = lasthit.afflicter or data.afflicter
      data.cause = lasthit.afflicter and tostring(lasthit.afflicter.prefab) or (lasthit.cause and lasthit.cause or data.cause)
      Log:Trace(string.format("death_handler setting last hit afflicter %s, cause %s",
        tostring(data.afflicter),
        tostring(data.cause)
      ))
    end

    -- code for announcement string yoinked from scripts/player_common_extensions.lua:134
    inst.deathcause = data ~= nil and data.cause or "unknown"
    if data == nil or data.afflicter == nil then
      inst.deathpkname = nil
    elseif data.afflicter.overridepkname ~= nil then
      inst.deathpkname = data.afflicter.overridepkname
      inst.deathbypet = data.afflicter.overridepkpet
    else
      local killer = data.afflicter.components.follower ~= nil and data.afflicter.components.follower:GetLeader() or nil
      if killer ~= nil and
        killer.components.petleash ~= nil and
        killer.components.petleash:IsPet(data.afflicter) then
        inst.deathbypet = true
      else
        killer = data.afflicter
      end
      inst.deathpkname = killer:HasTag("player") and killer:GetDisplayName() or nil
    end

    local announcement_string = _G.GetNewDeathAnnouncementString(inst, inst.deathcause, inst.deathpkname, inst.deathbypet)

    -- if requested, add location of death to announcement
    if CFG_INCLUDE_DEATH_LOCATION and _G.TheWorld then
      local location = _G.TheWorld:HasTag("cave") and "Caves" or "Overworld"
      announcement_string = announcement_string.." Died in the "..location.."."
    end

    -- if requested, add cycle counter with decimal remainder of day to announcement
    if CFG_INCLUDE_DAY and _G.TheWorld then
      local day = util.round(1 + _G.TheWorld.state.cycles + _G.TheWorld.state.time, 2)
      announcement_string = announcement_string.." (Day "..day..")"
    end

    -- use the "virtual" prefab name "player" if the killed instance was any player character, instead of its specific name like "wes".
    local selected_announce_channels = getAnnounceChannels(inst:HasTag("player") and "player" or inst.prefab, C.AnnounceEventsEnum.DEATH)

    -- @todo: convert conditionals to command table
    if util.FlagIsSet(C.AnnounceChannelEnum.SERVER, selected_announce_channels) then
      Log:Info("announcing %s death on server: %s",
        inst.prefab,
        announcement_string
      )
      TheNet:Announce(announcement_string, nil, nil, "death")
    end

    if util.FlagIsSet(C.AnnounceChannelEnum.DISCORD, selected_announce_channels) then
      local icon_name = inst.prefab or "unknown"
      -- special handling of individual icons for shadow_FOO_level1-3 prefabs
      if inst.level then icon_name = inst.prefab.."_level"..inst.level end
      DiscordClient:Announce(announcement_string, C.CHARACTER_ICON[icon_name])
    end
  end)
end

-- auto settings for debugging and testing
local function debugsettings(player)
  player.components.combat.damagemultiplier = 2000
  _G.c_supergodmode(player)
end

local function main()
  Log:Info("starting initialization")
  -- DDD apply player settings for testing, remove before release
  -- AddPlayerPostInit(debugsettings)

  -- [[ initialize chat applications ]] --

  AddGamePostInit(DiscordClient:Init())

  -- [[ install event handlers ]] --

  -- monster death announcements
  Log:Info("installing monster death announcement handlers")
  for _,mob in pairs(C.ANNOUNCE_MOBS) do
    local selected_announce_channels = getAnnounceChannels(mob, C.AnnounceEventsEnum.DEATH)
    -- skip handler installation if particular mob death announcement is disabled
    if util.FlagIsSet(C.AnnounceChannelEnum.DISABLED, selected_announce_channels) then
      Log:Debug("not announcing %s death", mob)
    else
      Log:Debug("announce %s death on %s",
          mob,
          table.concat(announceChannelList(selected_announce_channels), ", ")
      )
      AddPrefabPostInit(mob, death_handler)
    end
  end

  -- player death announcement
  Log:Info("installing player death announcement handler")
  do
    local selected_announce_channels = getAnnounceChannels("player", C.AnnounceEventsEnum.DEATH)
    if util.FlagIsSet(C.AnnounceChannelEnum.DISABLED, selected_announce_channels) then
        Log:Debug("not announcing player death")
      else
        Log:Debug("announce player death on %s",
            table.concat(announceChannelList(selected_announce_channels), ", ")
        )
        AddPlayerPostInit(death_handler)
        AddPlayerPostInit(health_override)
    end
  end

  -- @todo: add monster spawn announcement handler
  -- @todo: add monster despawn announcement handler
  -- @todo: add player resurrect announcement handler

  Log:Info("finished initialization")
end

-- export callables to console
_G.CAHelp = CAHelp -- display help message for setup
_G.CASetDiscordURL = CASetDiscordURL -- set Discord webhook URL on current shard
_G.CAStatus = CAStatus -- display current configuration and Discord setup status
_G.CATest = CATest  -- send test message on all possible channels

main()