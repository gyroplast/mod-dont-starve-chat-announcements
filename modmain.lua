-- this mod is strictly server-side only
if not GLOBAL.TheNet:GetIsServer() then
  return
end

-- propagate vars into environment for imports, specifically lib/const.lua
GLOBAL.modname = modname
GLOBAL.modinfo = modinfo

-- add mod scripts to package path for require() to work as expected
GLOBAL.package.path = GLOBAL.package.path..";"..MODROOT.."/?.lua"

local json = require("json")

local C = require("lib.const")
local util = require("lib.util")
local Log = require("lib.logging").Logging

-- convenient aliases and simple helpers
local _G = GLOBAL
local INCLUDE_DAY = GetModConfigData("include_day")
local INCLUDE_DEATH_LOCATION = GetModConfigData("include_death_location")

-- pseudo-globals for Discord Webhook URL and given name
local webhook_url = nil
local webhook_name = nil

-- obtain effective announcement flags for a prefab, considering a possible "DEFAULT" setting
local function getAnnounceChannels(prefab, event)
  -- get individual setting of prefab for event
  local prefab_setting = GetModConfigData(event.."_"..prefab) or C.AnnounceChannelEnum.DISABLED

  -- if individual setting is DEFAULT, set it to the global event default setting
  if util.FlagIsSet(C.AnnounceChannelEnum.DEFAULT, prefab_setting) then
    prefab_setting = GetModConfigData("announce_"..event) or C.AnnounceChannelEnum.DISABLED
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

-- @todo: shove all Discord code into Class and its own "generic chat plugin" module
local function SetupMissingDiscord()
  Log:Warn([[Could not load webhook URL for Discord announcements!
    Set the URL with the console command CASetDiscordURL(<URL>).

    Make sure the URL is enclosed in double quotes, and ensure you are
    running the command in the "Remote" console instead of "Local".

    You will likely switch to Local unknowingly when pasting the URL with Ctrl-V, so be aware.
    Tap the Ctrl key to switch between Remote and Local.

    Example:
      CASetDiscordURL("https://discord.com/api/webhooks/734950925428326401/3ni3djnasd")]])
end

local function CAGetDiscordWebhookName()
	Log:Info("currently active Discord webhook: %s", (webhook_name or "NOT SET"))
end

local function CASetDiscordURL(url)
  local rc = false -- return success status
  local status_err_msg = "unknown error" -- return error message

  -- URL plausiblity check to prevent sending arbitrary GET requests
	if not (util.starts_with(url, "https://discordapp.com/api/webhooks/") 
          or util.starts_with(url, "https://discord.com/api/webhooks/")) then
    status_err_msg = "a valid Discord webhook URL starts with \"https://discord[app].com/api/webhooks/\"."
    Log:Warn(status_err_msg)
    return rc, status_err_msg
	end

  -- test webhook URI for correctness, see https://discord.com/developers/docs/resources/webhook#get-webhook-with-token
  _G.TheSim:QueryServer(url, function(ret, isSuccessful, resultCode)
      local status, webhook_json = _G.pcall( function() return json.decode(ret) end )

      if isSuccessful and string.len(ret) > 1 and resultCode == 200 then
        -- get name of webhook for reference by parsing the returned JSON
        if status and webhook_json ~= nil then
          webhook_name = webhook_json.name and webhook_json.name or "<unknown>"
        end

        -- save webhook URL to file for automatic restore on next server start
        webhook_url = url
        _G.TheSim:SetPersistentString(C.DISCORD_WEBHOOK_URL_FILE, url, false, nil)

        -- report success
        rc = true
        status_err_msg = "successfully setup Discord webhook: "..tostring(webhook_name)
        Log:Info(status_err_msg)
        CAGetDiscordWebhookName()
      else
        -- print error information
        status_err_msg = string.format("could not setup Discord webhook URL (%s). HTTP %s, error: %s",
          tostring(url),
          tostring(resultCode),
          json.encode(webhook_json or "<none>")
        )
        Log:Warn(status_err_msg)
      end
    end,
		"GET"
  )
  return rc, status_err_msg
end

local function InitDiscord()

  Log:Info("initializing Discord")

  if not _G.TheSim then
    Log:Debug("TheSimulation is not initialized, cannot get webhook URL from file.")
    return
  end

  _G.TheSim:GetPersistentString(C.DISCORD_WEBHOOK_URL_FILE, function(isSuccessful, url)
    if isSuccessful and CASetDiscordURL(util.trim(url)) then
      Log:Info("loaded URL for Discord Webhook %s from file %s",
          (webhook_name and tostring(webhook_name) or "<unknown>"),
          C.DISCORD_WEBHOOK_URL_FILE
      )
    end
  end)
end

local function AnnounceDiscord(msg, character)
	if not webhook_url then
    InitDiscord()
  end

  if not webhook_url then
		SetupMissingDiscord()
		return
	end

	_G.TheSim:QueryServer(webhook_url, function(ret, isSuccessful, resultCode)
      if isSuccessful and resultCode >= 200 and resultCode <= 299 then
        Log:Debug("announcing on Discord via webhook %s: %s",
          (webhook_name and tostring(webhook_name) or "<unknown>"),
          msg
        )
      else
        -- print error information
        local status, webhook_json = _G.pcall( function() return json.decode(ret) end )

        local status_err_msg = string.format("could not announce via Discord webhook %s. HTTP %s, error: %s",
          (webhook_name and tostring(webhook_name) or "<unknown>"),
          tostring(resultCode),
          status and json.encode(webhook_json or "<unknown>") or "<unknown>"
        )
        Log:Warn(status_err_msg)
      end
		end,
		"POST",
		json.encode({
			username = string.gsub(_G.TheNet:GetServerName(),"'","’"),
			embeds = {
				{
					author = {
						name = string.gsub(msg,"'","’"),
						icon_url = C.CHARACTER_ICON[character] or C.CHARACTER_ICON.unknown
					}
				}
			}
		})
	)
end

local function CATest()
  local test_message = "This is a test message from the "..C.PRETTY_MODNAME.." mod for Don't Starve Together!"
  if _G.TheNet then
    _G.TheNet:Announce(test_message)
  end
  AnnounceDiscord(test_message, (_G.ThePlayer and _G.ThePlayer.prefab or "unknown"))
end


local function health_override(inst)
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
        Log:Trace("lasthit info: "..util.table2str(inst.CA_lasthit))
      end
      f(...)
    end
    return func
  end

  if inst.components.health then
    inst.components.health.DoDelta = decorated_health_DoDelta(inst.components.health.DoDelta)
  end
end


-- attached to all configured monster death events, and player death
local function death_handler(inst)
	inst:ListenForEvent("death", function(inst, data)
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
    if INCLUDE_DEATH_LOCATION and _G.TheWorld then
      local location = _G.TheWorld:HasTag("cave") and "Caves" or "Overworld"
      announcement_string = announcement_string.." Died in the "..location.."."
    end

    -- if requested, add cycle counter with decimal remainder of day to announcement
    if INCLUDE_DAY and _G.TheWorld then
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
      _G.TheNet:Announce(announcement_string)
    end

    if util.FlagIsSet(C.AnnounceChannelEnum.DISCORD, selected_announce_channels) then
      local icon_name = inst.prefab
      -- special handling of individual icons for shadow_FOO_level1-3 prefabs
      if inst.level then icon_name = inst.prefab.."_level"..inst.level end
      Log:Info("announcing %s death on Discord (%s): %s",
        inst.prefab,
        (webhook_name and tostring(webhook_name) or "<unknown>"),
        announcement_string
      )
      AnnounceDiscord(announcement_string, icon_name)
    end
	end)
end

local function main()
  Log:Info("starting initialization")

  -- [[ initialize chat applications ]] --

  -- Discord
  AddGamePostInit(InitDiscord)

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

  Log:Info("finished initialization")
end

-- export callables to console
_G.CATest = CATest  -- send test message on all possible channels
_G.CAGetDiscordWebhookName = CAGetDiscordWebhookName  -- get name of currently configured Discord Webhook
_G.CASetDiscordURL = CASetDiscordURL  -- set URL to Discord Webhook to use

main()
