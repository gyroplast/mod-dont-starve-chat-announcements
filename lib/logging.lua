local C = require("lib.const")
local M = {}

local Logging = Class()

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

-- exports
M.Logging = Logging
return M
