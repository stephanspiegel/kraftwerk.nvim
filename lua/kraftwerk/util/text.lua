--[[--
Module for string convenience utilities
@module quickfix
]]

--[[
Does the text start with a given prefix?
@tparam prefix string The prefix to look for
@Tparam text string The text we want to check
@treturn boolean True if the text starts with the prefix, false otherwise
]]
local function starts_with(prefix, text)
    local function curried_function(str)
        return str:find(prefix, 1, true) == 1
    end
    if text == nil then
        return curried_function
    end
    return curried_function(text)
end

--[[
Remove any whitespace from the beginning and end of the input.
@tparam text string The string from which to remove whitespace
@treturn string The passed in input with leading and trailing whitespace removed
]]
local function trim(text)
    return string.gsub(text, '^%s*(.-)%s*$', '%1')
end

--[[
Is the input either nil or empty?
@tparam text string The string we want to check
@treturn boolean True if the string is nil or empty string, false otherwise
]]
local function is_nil_or_empty(text)
    return text == nil or text == ''
end

--[[
Is the input either nil, empty or composed of only whitespace?
@tparam text string The string we want to check
@treturn boolean True if the string is nil, empty string or whitespace only, false otherwise
]]
local function is_blank(text)
    return text == nil or trim(text) == ''
end

--[[
Splits a string into a list at the specified separator
@tparam text string The string we want to split
@tparam separator string The separator to use for splitting
@treturn table A list with each split piece of the original string
]]
local function split(text, separator)
    if is_blank(text) then return {} end
    if separator == nil then separator = '%s' end
    local parts = {}
    for str in text:gmatch("([^"..separator.."]+)") do
        table.insert(parts, str)
    end
    return parts
end

local function contains(test_value, text)
    local function curried_function(later_text)
        if is_nil_or_empty(later_text) then return false end
        if is_nil_or_empty(test_value) then return false end
        local result = string.find(later_text, test_value) ~= nil
        return result
    end
    if text == nil then return curried_function
    else return curried_function(text)
    end
end

local function is_newline_delimited(text)
    return contains('\n', trim(text))
end

return {
    contains = contains,
    is_blank = is_blank,
    is_newline_delimited = is_newline_delimited,
    is_nil_or_empty = is_nil_or_empty,
    split = split,
    starts_with = starts_with,
    trim = trim,
}
