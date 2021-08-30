--[[--
Module for string convenience utilities
@module quickfix
]]

--[[
Does the text start with a given prefix?
@tparam prefix string The prefix to look for
@Tparam text string The text we want to check
@treturn boolean True if the text starts with the prefix, false otherwise
--]]
local function starts_with(prefix, text)
    local function curried_function(str)
        return str:find(prefix, 1, true) == 1
    end
    if text == nil then
        return curried_function
    end
    return curried_function(text)
end

local function trim(text)
    return string.gsub(text, '^%s*(.-)%s*$', '%1')
end

local function is_blank(text)
    return text == nil or trim(text) == ''
end

return {
    starts_with = starts_with,
    is_blank = is_blank,
    trim = trim
}
