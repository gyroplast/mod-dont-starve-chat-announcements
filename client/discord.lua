-- bring externally provided globals into local env explicitly
local _G = GLOBAL
local TheSim = _G.TheSim
local TheNet = _G.TheNet

-- file name to persist Discord webhook URL, all lower-case as per quasi-convention.
local DISCORD_WEBHOOK_URL_FILE = "discord_webhook_url.txt"
-- file name used by "Discord Death Announcements" mod
local DISCORD_WEBHOOK_URL_FILE_COMPAT = "Discord_Webhook_URL.txt"
-- configuration option value
local CFG_DISCORD_WEBHOOK_URL = GetModConfigData("discord_webhook_url", modname)

local json = require("json")

local DiscordWebhook = Class(function(self, url, name)
  self.url = url and util.trim(url) or ""
  self.name = name and util.trim(name) or ""
end)

DiscordClient = Class(function(self)
  self.webhook = DiscordWebhook()
  self.ok = false  -- true when Discord webhook is initialized
end)

function DiscordClient:Init(callback)
  Log:Info("initializing DiscordClient")

  self:LoadWebhookURL(function(error, webhook)
    if not error and webhook then
      self.webhook = webhook
      self:PersistWebhookURL(webhook.url, function(persist_error)
        if not persist_error then
          Log:Info("DiscordClient:Init() FINISHED, using webhook %s", self.webhook.name)

          -- initialization finished successfully, we're up and running!
          if type(callback) == "function" then callback(nil) end
        else
          local errmsg = "DiscordClient:Init() FAILED to save webhook to disk, check server logs!"
          Log:Warn(errmsg)
          if type(callback) == "function" then callback(errmsg) end
        end
      end)
    else
      local errmsg = "DiscordClient:Init() FAILED to load a webhook, verify configuration!"
      Log:Warn(errmsg)
      -- propagate error message
      if type(callback) == "function" then callback(errmsg) end
    end
  end)
end

function DiscordClient:SetWebhookURL(url, callback)
  Log:Trace("DiscordClient:SetWebhookURL() START setting webhook URL: `%s`", url)
  self:PersistWebhookURL(url, callback)
end

function DiscordClient:PersistWebhookURL(url, callback)
  local error = "unknown error"

  if type(url) ~= "string" then
    error = ("invalid argument, url must be string, is %s"):format(type(url))
    Log:Warn("DiscordClient:PersistWebhookURL() "..error)
    if type(callback) == "function" then do callback(error); return end end
  end
  if not TheSim then
    error = "TheSim is not initialized, cannot persist webhook URLs."
    Log:Warn("DiscordClient:PersistWebhookURL() "..error)
    if type(callback) == "function" then do callback(error); return end end
  end

  url = util.trim(url)
  Log:Trace("DiscordClient:PersistWebhookURL() START persisting webhook URL: `%s`", url)

  -- syntax check given URL
  if not self:isWebhookURL(url) then
    error = "FAILED syntax checking webhook URL, must start with `https://discord[app].com/api/webhooks/`"
    Log:Trace("DiscordClient:PersistWebhookURL() %s: `%s`", error, url)
    if type(callback) == "function" then callback(error) end
  else
    -- syntax ok, validate URL against Discord server
    Log:Debug("DiscordClient:PersistWebhookURL() SUCCESS syntax checking webhook URL")

    self:isValidWebhookURL(url, function(validity_error, webhook)
      if not validity_error then
        -- supplied URL is valid, persist to cache file
        Log:Debug("DiscordClient:PersistWebhookURL() SUCCESS validating webhook URL, persisting to file")
        -- no need to encode the contents, and we don't care about a callback - best effort basis applies.
        TheSim:SetPersistentString(DISCORD_WEBHOOK_URL_FILE, url, false, nil)
        self.webhook = webhook
        self.ok = true

        if type(callback) == "function" then callback(nil) end
      else
        local errmsg = "FAILED webhook URL validation: "..tostring(validity_error)
        Log:Warn("DiscordClient:PersistWebhookURL() "..errmsg)
        if type(callback) == "function" then callback(errmsg) end
      end
    end)
  end
end

-- Returns the Discord webhook URL for the current shard, if available.
-- There are multiple sources for a shard's Discord webhook URL, listed
-- here in order of precedence:
-- 
--  - PersistentString in `DISCORD_WEBHOOK_URL_FILE`
--  - PersistentString in `DISCORD_WEBHOOK_URL_FILE_COMPAT`
--  - module configuration option `discord_webhook_url`
-- 
-- The intention is for the `DISCORD_WEBHOOK_URL_FILE` to serve as the eventual
-- source of truth, also taking into account runtime (re-)configuration.
-- If, and only if, the `DISCORD_WEBHOOK_URL_FILE` does not exist, or includes an
-- invalid URL, reading the `DISCORD_WEBHOOK_URL_FILE_COMPAT` will be attempted
-- to allow the mod to serve as a drop-in replacement for an already configured
-- "Discord Death Announcements" mod by re-using its existing webhook file.
-- 
-- If, and only if, the `DISCORD_WEBHOOK_URL_FILE_COMPAT` does not exist, either,
-- or includes an invalid URL, then the module configuration option named
-- `discord_webhook_url` will be used.
-- Unfortunately, the mod configuration does not allow entering arbitrary
-- strings like URLs in the game's mod configuration GUI, but setting this
-- option directly in a shard's `modoverrides.lua` *will* be accepted and used
-- as expected, thus making the in-game setting of the URL unnecessary.
function DiscordClient:LoadWebhookURL(callback)

  local function OnCheckedConfigWebhook(error, webhook)
    if not error and webhook then
      -- configured webhook is valid, we're done folks!
      Log:Debug("DiscordClient:OnCheckedConfigWebhook() FINISHED returning valid configured webhook: `%s`", tostring(webhook.name))
      Log:Trace("                                                  validated configured webhook URL: `%s`", tostring(webhook.url))
      -- exit out to caller with the valid webhook obtained from the configuration option
      if type(callback) == "function" then callback(nil, webhook) end
    else
      -- configured webhook is NOT valid, we're out of options.
      Log:Debug("DiscordClient:OnCheckedCompatWebhook() FAILED validating configured webhook URL")
      if type(callback) == "function" then callback(error, nil) end
    end
  end

  local function OnCheckedCompatWebhook(error, webhook)
    if not error and webhook then
      -- cached compat webhook is valid, we're done folks!
      Log:Debug("DiscordClient:OnCheckedCompatWebhook() FINISHED returning valid compat webhook: `%s`", tostring(webhook.name))
      Log:Trace("                                                  validated compat webhook URL: `%s`", tostring(webhook.url))
      -- exit out to caller with the valid webhook loaded from the compat file
      if type(callback) == "function" then callback(nil, webhook) end
    else
      -- cached compat webhook is NOT valid, try config option
      Log:Debug("DiscordClient:OnCheckedCompatWebhook() FAILED validating compat webhook URL, trying config option")
      if self:isWebhookURL(CFG_DISCORD_WEBHOOK_URL) then
        Log:Debug("DiscordClient:OnCheckedCompatWebhook() SUCCESS loading webhook URL from config")
        Log:Trace("                                                        configured webhook URL: `%s`", CFG_DISCORD_WEBHOOK_URL)
        self:isValidWebhookURL(CFG_DISCORD_WEBHOOK_URL, OnCheckedConfigWebhook)
      else
        -- no valid config option URL can be loaded, we're out of options.
        local errmsg = "FAILED loading webhook URL from config option `discord_webhook_url`"
        Log:Debug("DiscordClient:OnCheckedCompatWebhook() "..errmsg)
        if type(callback) == "function" then callback(errmsg, nil) end
      end
    end
  end

  local function OnLoadCompatWebhookURL(error, url)
    -- if cached, syntactically valid compat webhook URL can be retrieved, check its validity
    if not error and type(url) == "string" and #url > 1 then
      Log:Debug("DiscordClient:OnLoadCompatWebhookURL() SUCCESS loading compat webhook URL")
      Log:Trace("                                                loaded compat webhook URL: `%s`", url)
      self:isValidWebhookURL(url, OnCheckedCompatWebhook)
    else
      -- there is no syntactically valid compat Discord Webhook URL cached, try the config option
      Log:Debug("DiscordClient:OnLoadCompatWebhookURL() FAILED loading compat webhook URL, trying config option")
      if self:isWebhookURL(CFG_DISCORD_WEBHOOK_URL) then
        Log:Debug("DiscordClient:OnLoadCompatWebhookURL() SUCCESS loading webhook URL from config")
        Log:Trace("                                                        configured webhook URL: `%s`", CFG_DISCORD_WEBHOOK_URL)
        self:isValidWebhookURL(CFG_DISCORD_WEBHOOK_URL, OnCheckedConfigWebhook)
      else
        -- no valid config option URL can be loaded, we're out of options.
        local errmsg = "FAILED loading webhook URL from config option `discord_webhook_url`"
        Log:Debug("DiscordClient:OnLoadCompatWebhookURL() "..errmsg)
        if type(callback) == "function" then callback(errmsg, nil) end
      end
    end
  end

  local function OnCheckedWebhook(error, webhook)
    if not error and webhook then
      -- cached primary webhook is valid, we're done folks!
      Log:Debug("DiscordClient:OnCheckedWebhook() FINISHED returning valid primary webhook: `%s`", tostring(webhook.name))
      Log:Trace("                                            validated primary webhook URL: `%s`", tostring(webhook.url))
      -- exit out to caller with the valid webhook loaded from the primary file
      if type(callback) == "function" then callback(nil, webhook) end
    else
      -- cached primary webhook is NOT valid, attempt to load url from the compat file
      Log:Debug("DiscordClient:OnCheckedWebhook() FAILED validating primary webhook URL, trying compat file")
      self:GetPersistentURL(DISCORD_WEBHOOK_URL_FILE_COMPAT, OnLoadCompatWebhookURL)
    end
  end

  local function OnLoadWebhookURL(error, url)
    -- if cached, syntactically valid primary webhook URL can be retrieved, check its validity
    if not error and type(url) == "string" and #url > 1 then
      Log:Debug("DiscordClient:OnLoadWebhookURL() SUCCESS loading primary webhook URL")
      Log:Trace("                                          loaded primary webhook URL: `%s`", url)
      self:isValidWebhookURL(url, OnCheckedWebhook)
    else
      -- there is no syntactically valid primary Discord Webhook URL cached, try the compat file
      Log:Debug("DiscordClient:OnLoadWebhookURL() FAILED loading primary webhook URL, trying compat file")
      self:GetPersistentURL(DISCORD_WEBHOOK_URL_FILE_COMPAT, OnLoadCompatWebhookURL)
    end
  end

  -- START: attempt to restore PersistentString from `DISCORD_WEBHOOK_URL_FILE`.
  Log:Debug("DiscordClient:LoadWebhookURL() START loading primary webhook URL")
  self:GetPersistentURL(DISCORD_WEBHOOK_URL_FILE, OnLoadWebhookURL)
end

function DiscordClient:GetPersistentURL(file_name, callback)
  local error = "unknown error"

  if type(file_name) ~= "string" then
    error = ("invalid argument, file_name must be string, is %s, value: %s"):format(
      type(file_name),
      tostring(file_name)
    )
    Log:Warn("DiscordClient:GetPersistentURL() "..error)
    if type(callback) == "function" then do callback(error, nil); return end end
  end
  if not TheSim then
    error = "TheSim is not initialized, cannot get webhook URLs from files."
    Log:Warn("DiscordClient:GetPersistentURL() "..error)
    if type(callback) == "function" then do callback(error, nil); return end end
  end

  TheSim:GetPersistentString(file_name, function(load_success, data)
    if load_success and data then
      local url = util.trim(data)
      Log:Debug("DiscordClient:GetPersistentURL() SUCCESS loading webhook URL from file: `%s`", file_name)
      Log:Trace("                                                    loaded webhook URL: `%s`", url)

      -- check loaded URL for syntactical validity
      if self:isWebhookURL(url) then
        Log:Debug("DiscordClient:GetPersistentURL() SUCCESS loaded webhook URL is syntactically valid")
        if type(callback) == "function" then callback(nil, url) end
      else
        error = "FAILED syntax check for webhook URL, must start with `https://discord[app].com/api/webhooks/`"
        Log:Warn("DiscordClient:GetPersistentURL() "..error)
        if type(callback) == "function" then callback(error, url) end
      end
    else
      error = ("FAILED loading webhook URL from file: `%s`"):format(file_name)
      Log:Debug("DiscordClient:GetPersistentURL() "..error)
      if type(callback) == "function" then callback(error, nil) end
    end
  end)
end

-- URL plausiblity check to prevent sending arbitrary GET requests
function DiscordClient:isWebhookURL(url)
  Log:Trace(("DiscordClient:isWebhookURL() called, url:%s = %s"):format(type(url), tostring(url)))
  return util.starts_with(url, "https://discord.com/api/webhooks/") or
         util.starts_with(url, "https://discordapp.com/api/webhooks/")
end

-- Test webhook URI for validity, see https://discord.com/developers/docs/resources/webhook#get-webhook-with-token
function DiscordClient:isValidWebhookURL(url, callback)
  local error = "unknown error"

  if type(url) ~= "string" then
    error = ("invalid argument, file_name must be string, is %s"):format(type(url))
    Log:Warn("DiscordClient:GetPersistentURL() "..error)
    if type(callback) == "function" then do callback(error, nil); return end end
  end
  if not TheSim then
    error = "TheSim is not initialized, cannot get webhook URLs from files."
    Log:Warn("DiscordClient:GetPersistentURL() "..error)
    if type(callback) == "function" then do callback(error, nil); return end end
  end

  url = util.trim(url)
  local webhook = DiscordWebhook(url)

  Log:Trace("DiscordClient:isValidWebhookURL() START validation of webhook URL: `%s`", url)

  TheSim:QueryServer(url, function(ret, isSuccessful, resultCode)
    local status, webhook_json = _G.pcall( function() return json.decode(ret) end )

    if isSuccessful and string.len(ret) > 1 and resultCode == 200 then
      -- get name of webhook by parsing the returned JSON
      webhook.name = status and webhook_json and util.trim(webhook_json.name) or "<unknown>"

      -- validation successful!
      Log:Debug("DiscordClient:isValidWebhookURL() SUCCESS validated webhook: `%s`", webhook.name)
      if type(callback) == "function" then callback(nil, webhook) end
    else
      -- validation failed, print error information
      error = ("HTTP %s - %s"):format(
        tostring(resultCode),
        ret and tostring(ret) or "<no error message>"
      )
      Log:Warn("DiscordClient:isValidWebhookURL() FAILED validation of webhook: "..error)
      if type(callback) == "function" then callback(error, webhook) end
    end
  end,
  "GET")
end

function DiscordClient:Announce(msg, icon_url, callback)
  if type(msg) ~= "string" then
    Log:Warn("DiscordClient:Announce() invalid argument, msg must be string, is %s, value: %s",
      type(msg),
      tostring(msg)
    )
    if type(callback) == "function" then do callback("cannot announce invalid message on Discord"); return end end
  end
  if not TheSim or not TheNet then
    Log:Warn("DiscordClient:Announce() TheSim or TheNet is not initialized, cannot announce on Discord.")
    if type(callback) == "function" then do callback("internal error, network functions not available"); return end end
  end

  TheSim:QueryServer(self.webhook.url, function(ret, isSuccessful, resultCode)
    if isSuccessful and resultCode >= 200 and resultCode <= 299 then
      Log:Info("announcing on Discord via webhook %s: %s",
        (self.webhook.name and tostring(self.webhook.name) or "<unknown>"),
        msg
      )
      if type(callback) == "function" then callback(nil) end
    else
      -- POSTing to webhook failed
      local status, webhook_json = _G.pcall( function() return json.decode(ret) end )

      local errmsg = string.format("could not announce via Discord webhook %s. HTTP %s - %s",
        (self.webhook.name and tostring(self.webhook.name) or "<unknown>"),
        tostring(resultCode),
        ret and tostring(ret) or "<no error message>"
      )
      Log:Warn(errmsg)
      if type(callback) == "function" then callback(errmsg) end
    end
  end,
  "POST",
  json.encode({
    username = string.gsub(TheNet:GetServerName(),"'","’"),
    embeds = {
      {
        author = {
          name = string.gsub(msg,"'","’"),
          icon_url = icon_url and tostring(icon_url) or ""
        }
      }
    }
  }) or "{}"
)
end

return DiscordClient