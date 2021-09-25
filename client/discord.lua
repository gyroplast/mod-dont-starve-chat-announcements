-- bring externally provided globals into local env explicitly
local modname = _G.modname
local TheSim = _G.TheSim

-- file name to persist Discord webhook URL, all lower-case as per quasi-convention.
local DISCORD_WEBHOOK_URL_FILE = "discord_webhook_url.txt"
-- file name used by "Discord Death Announcements" mod
local DISCORD_WEBHOOK_URL_FILE_COMPAT = "Discord_Webhook_URL.txt"
-- configuration option value
local CFG_DISCORD_WEBHOOK_URL = GetModConfigData("discord_webhook_url", modname)

local json = require("json")
local util = require("lib.util")
local Log = require("lib.logging")

local DiscordClient = Class(function(self)
  self.webhook = {}
end)

function DiscordClient:Init()
  Log:Debug("initializing Discord")
  local url, name = self:LoadCachedWebhookURL()
  self.webhook = {url = tostring(url), name = tostring(name)}
  Log:Trace("DiscordClient:Init() using cached webhook %s -> %s", self.webhook.name, self.webhook.url)
end

-- Returns the cached Discord webhook URL for the current shard, if available.
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
--
-- @return string, Discord webhook URL for the current shard.
--
-- @return nil, if no URL is configured for the current shard.
function DiscordClient:LoadCachedWebhookURL()
  local discord_webhook_url = nil  -- return value
  local success, err_msg, webhook_name = false, "unknown error", nil

  -- Attempt to restore PersistentString from `DISCORD_WEBHOOK_URL_FILE`.
  discord_webhook_url = self:GetPersistentURL(DISCORD_WEBHOOK_URL_FILE)
  Log:Trace("DiscordClient:LoadCachedWebhookURL() GetPersistentURL(FILE) result: `%s`", tostring(discord_webhook_url))
  if discord_webhook_url then
    success, err_msg, webhook_name = self:isValidWebhookURL(discord_webhook_url)
    Log:Trace("DiscordClient:LoadCachedWebhookURL() isValidWebhookURL(%s) successful %s, hook %s, err: %s",
      tostring(discord_webhook_url),
      tostring(success),
      tostring(webhook_name),
      tostring(err_msg)
    )
  end

  discord_webhook_url = self:GetPersistentURL(DISCORD_WEBHOOK_URL_FILE_COMPAT)
  Log:Trace("DiscordClient:LoadCachedWebhookURL() GetPersistentURL(COMPAT) result: `%s`", tostring(discord_webhook_url))
  if discord_webhook_url then
    success, err_msg, webhook_name = self:isValidWebhookURL(discord_webhook_url)
    Log:Trace("DiscordClient:LoadCachedWebhookURL() isValidWebhookURL(%s) successful %s, hook %s, err: %s",
      tostring(discord_webhook_url),
      tostring(success),
      tostring(webhook_name),
      tostring(err_msg)
    )
  end
  -- do a comprehensive check for Webhook URL validity - caution, uses asynchronous web request!
  return discord_webhook_url, webhook_name
end

function DiscordClient:GetPersistentURL(file_name)
  local ret = nil

  if type(file_name) ~= "string" then
    Log:Warn("DiscordClient:GetPersistentURL(): invalid argument, file_name must be string, is %s, value: %s",
      type(file_name),
      tostring(file_name)
    )
    return ret
  end
  if not TheSim then
    Log:Warn("DiscordClient:GetPersistentURL(): TheSim is not initialized, cannot get Discord Webhook URL from files.")
    return ret
  end

  TheSim:GetPersistentString(file_name, function(load_success, data)
    if load_success and data then
      local url = util.trim(data)
      Log:Trace("DiscordClient:GetPersistentURL(): loaded Discord Webhook URL from file `%s`: `%s`",
        file_name,
        url
      )
      if not self:isWebhookURL(url) then
        Log:Warn("DiscordClient:GetPersistentURL(): URL is invalid, must start with `https://discord[app].com/api/webhooks/`: `%s`", url)
      else
        ret = url
      end
    else
      Log:Debug("DiscordClient:GetPersistentURL(): failed loading Discord Webhook URL from file `%s`", file_name)
    end
  end)

  Log:Trace("DiscordClient:GetPersistentURL(): returning `%s`", tostring(ret))
  return ret
end

function DiscordClient:isWebhookURL(url)
  Log:Trace(("DiscordClient:isWebhookURL(url: %s = %s)"):format(type(url), tostring(url)))
  -- URL plausiblity check to prevent sending arbitrary GET requests
  return util.starts_with(url, "https://discord.com/api/webhooks/") or
         util.starts_with(url, "https://discordapp.com/api/webhooks/")
end

-- Test webhook URI for validity, see https://discord.com/developers/docs/resources/webhook#get-webhook-with-token
function DiscordClient:isValidWebhookURL(url)
  local rc = false -- return success status
  local status_err_msg = "unknown error" -- return error message
  local webhook_name = nil

  if type(url) ~= "string" then
    status_err_msg = string.format("DiscordClient:isValidWebhookURL(url): invalid argument, url must be string, is %s, value: %s",
      type(url),
      tostring(url)
    )
    Log.Warn(status_err_msg)
    return rc, status_err_msg, webhook_name
  end
  if not TheSim then
    status_err_msg = "DiscordClient:isValidWebhookURL(): TheSim is not initialized, cannot validate Discord Webhook URL"
    Log.Warn(status_err_msg)
    return rc, status_err_msg, webhook_name
  end

  TheSim:QueryServer(url, function(ret, isSuccessful, resultCode)
    local status, webhook_json = _G.pcall( function() return json.decode(ret) end )

    if isSuccessful and string.len(ret) > 1 and resultCode == 200 then
      -- get name of webhook for reference by parsing the returned JSON
      webhook_name = status and webhook_json and webhook_json.name or "<unknown>"

      -- report success
      rc = true
      status_err_msg = "successfully validated Discord Webhook: "..tostring(webhook_name)
      Log:Info(status_err_msg)
    else
      -- print error information
      status_err_msg = string.format("invalid Discord Webhook URL (%s). HTTP %s, error: %s",
        tostring(url),
        tostring(resultCode),
        json.encode(webhook_json or "<none>")
      )
      Log:Trace(status_err_msg)
    end
  end,
  "GET"
  )

  return rc, status_err_msg, webhook_name
end

return DiscordClient()