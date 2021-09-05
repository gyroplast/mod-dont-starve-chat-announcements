local C = require("lib.const")
local M = {}

local Logging = Class()

-- log formatted DEBUG message to stdout, prefixed with verbose modname.
function Logging:Debug(msg, ...)
  if C.MOD_DEBUG then
    print(string.format("Mod: %s\t[DEBUG] "..msg, C.LONG_MODNAME, ...))
  end
end

-- log formatted INFO message to stdout, prefixed with verbose modname.
function Logging:Info(msg, ...)
  print(string.format("Mod: %s\t[INFO ] "..msg, C.LONG_MODNAME, ...))
end

-- log formatted WARNING message to stdout, prefixed with verbose modname.
function Logging:Warn(msg, ...)
  print(string.format("Mod: %s\t[WARN ] "..msg, C.LONG_MODNAME, ...))
end

-- log critical, unrecoverable ERROR and exit mod.
function Logging:Error(msg, ...)
  moderror(msg)
end

-- exports
M.Logging = Logging
return M