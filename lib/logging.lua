local C = require("lib.const")
local M = {}

local Logging = Class()

function Logging:LogLevelToString(numeric_log_level)
  if type(numeric_log_level) ~= "number" then return nil end
  for name,number in pairs(C.LOGLEVEL) do
    if number == numeric_log_level then return name end
  end
end

function Logging:GetLogLevel()
  return Logging:LogLevelToString(C.MOD_LOGLEVEL)
end

function Logging:SetLogLevel(loglevel)
  loglevel = type(loglevel) == "number" and Logging:LogLevelToString(loglevel) or loglevel
  C.MOD_LOGLEVEL = type(loglevel) == "string" and C.LOGLEVEL[loglevel] or C.MOD_LOGLEVEL
end

-- log formatted TRACE message to stdout, prefixed with verbose modname.
function Logging:Trace(msg, ...)
  if C.MOD_LOGLEVEL <= C.LOGLEVEL.TRACE then
    print(string.format("Mod: %s\t[TRACE] "..msg, C.LONG_MODNAME, ...))
  end
end

-- log formatted DEBUG message to stdout, prefixed with verbose modname.
function Logging:Debug(msg, ...)
  if C.MOD_LOGLEVEL <= C.LOGLEVEL.DEBUG then
    print(string.format("Mod: %s\t[DEBUG] "..msg, C.LONG_MODNAME, ...))
  end
end

-- log formatted INFO message to stdout, prefixed with verbose modname.
function Logging:Info(msg, ...)
  if C.MOD_LOGLEVEL <= C.LOGLEVEL.INFO then
    print(string.format("Mod: %s\t[INFO ] "..msg, C.LONG_MODNAME, ...))
  end
end

-- log formatted WARNING message to stdout, prefixed with verbose modname.
function Logging:Warn(msg, ...)
  if C.MOD_LOGLEVEL <= C.LOGLEVEL.WARN then
    print(string.format("Mod: %s\t[WARN ] "..msg, C.LONG_MODNAME, ...))
  end
end

-- log critical, unrecoverable ERROR and exit mod.
function Logging:Error(msg, ...)
  if C.MOD_LOGLEVEL <= C.LOGLEVEL.ERROR then
    moderror(msg)
  end
end

-- set loglevel to configuration option choice. Uses MOD_LOGLEVEL constant as default.
Logging:SetLogLevel(GetModConfigData("log_level", _G.modname))

-- exports
M.Logging = Logging
return M
