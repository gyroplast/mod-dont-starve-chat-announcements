-- available log levels in increasing severity
local LOGLEVEL = { TRACE = 1, DEBUG = 2, INFO = 3, WARN = 4, WARNING = 4, ERR = 5, ERROR = 5 }

-- log message format string with mod name and severity/level placeholders
local LOGMSG_FMT = "Mod: %s [%-5s] "
local DEFAULT_LOG_LEVEL = LOGLEVEL.INFO

local Logging = Class(function(self)
	self.log_level = DEFAULT_LOG_LEVEL
  self.modinfoname = ModInfoname(_G.modname)

  -- set loglevel to configuration option choice, keep default setting if invalid.
  self:SetLogLevel(GetModConfigData("log_level", modname and tostring(modname) or ""))
end)

function Logging:LogLevelToString(numeric_log_level)
  if type(numeric_log_level) ~= "number" then return nil end
  for name,number in pairs(LOGLEVEL) do
    if number == numeric_log_level then return name end
  end
end

function Logging:GetLogLevel()
  return Logging:LogLevelToString(self.log_level)
end

function Logging:SetLogLevel(loglevel)
  loglevel = type(loglevel) == "number" and Logging:LogLevelToString(loglevel) or loglevel
  self.log_level = type(loglevel) == "string" and LOGLEVEL[loglevel] or self.log_level
end

-- log formatted TRACE message to stdout
function Logging:Trace(msg, ...)
  if self.log_level <= LOGLEVEL.TRACE then
    print(string.format(LOGMSG_FMT..msg, self.modinfoname, "TRACE", ...))
  end
end

-- log formatted DEBUG message to stdout
function Logging:Debug(msg, ...)
  if self.log_level <= LOGLEVEL.DEBUG then
    print(string.format(LOGMSG_FMT..msg, self.modinfoname, "DEBUG", ...))
  end
end

-- log formatted INFO message to stdout
function Logging:Info(msg, ...)
  if self.log_level <= LOGLEVEL.INFO then
    print(string.format(LOGMSG_FMT..msg, self.modinfoname, "INFO", ...))
  end
end

-- log formatted WARNING message to stdout
function Logging:Warn(msg, ...)
  if self.log_level <= LOGLEVEL.WARN then
    print(string.format(LOGMSG_FMT..msg, self.modinfoname, "WARN", ...))
  end
end

-- log critical, unrecoverable ERROR and exit mod.
function Logging:Error(msg, ...)
  if self.log_level <= LOGLEVEL.ERROR then
    moderror(msg)
  end
end

return Logging()