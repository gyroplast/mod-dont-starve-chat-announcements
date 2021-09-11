-- [[ generic utilities ]] --
local M = {}
local json = require("json")

-- remove leading and trailing whitespace from a string
function M.trim(s) return s:gsub("^%s*(.-)%s*$", "%1") end

-- round a number to the nearest decimal places
function M.round(val, decimal)
    if (decimal) then
        return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
    else
        return math.floor(val + 0.5)
    end
end

-- return true iff a bit flag is set in a value; Lua 5.1 doesn't know bitwise operators.
function M.FlagIsSet(flag, value) return (value / flag) % 2 >= 1 end

-- return true iff str starts with start, without other preceding characters
function M.starts_with(str, start) return str:sub(1, #start) == start end

-- pretty-print table only one level deep
function M.table2str(t)
    if type(t) ~= "table" then return tostring(t) end
    local buf = {}
    for k, v in pairs(t) do
        buf[k] = type(v) == "table" and tostring(v) or v
    end
    return json.encode(buf)
end

return M
