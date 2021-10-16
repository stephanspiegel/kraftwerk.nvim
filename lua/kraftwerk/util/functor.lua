--[[
Make a copy of a table or primitive, making copies of any children recursively.
@tparam orig any The table or primitive to copy
@treturn any A copy of the original passed in value
]]
local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--[[
Make a shallow copy of a table or primitive value
@tparam tbl any The table or primitive value to copy
@treturn any A shallow copy of the table or primitive value; if table, the child elements are passed by reference
]]
local function clone(data)
    if type(data) == 'table' then
        local copy = {}
        for orig_key, orig_value in next, data, nil do
            copy[orig_key] = orig_value
        end
        return copy
    else -- number, string, boolean, etc
        return data
    end
end

--[[
Does a list contain a given value?
@tparam list The list to test for containment
@test_value The value we want to check is contained in the list
@treturn boolean True if the list contains the value, false otherwise
]]
local function contains(list, test_value)
    if list == nil then return false end
    if type(list) ~= "table" then return false end
    for _, value in ipairs(list) do
        if value == test_value then
            return true
        end
    end
    return false
end

--[[
Does a given (key-value) table contain a given key?
@tparam tbl The table to investigate
@tparam test_key The value for which we'd like to know if it's a key of table
@treturn boolean True if the table has the key, false otherwise
]]
local function has_key(tbl, test_key)
    if tbl == nil then return false end
    if type(tbl) ~= "table" then return false end
    for key, _ in pairs(tbl) do
        if key == test_key then
            return true
        end
    end
    return false
end

--[[
Does a given (key-value or list) table contain a given value?
@tparam tbl table The table to investigate
@tparam test_value any The value for which we'd like to know if it's a value of table
@treturn boolean True if the table has the value, false otherwise
]]
local function contains_value(tbl, test_value)
    if tbl == nil then return false end
    if type(tbl) ~= "table" then return false end
    for _, value in pairs(tbl) do
        if value == test_value then
            return true
        end
    end
    return false
end

--[[
Is a list either nil, or empty of elements?
@tparam list table The table to check
@treturn boolean True if the table is nil, true if the table is empty, false otherwise
]]
local function is_nil_or_empty(tbl)
    return tbl == nil or next(tbl) == nil
end

--[[
Given two lists, create a new list by adding the second list to the end of the first list.
@tparam list1 table The first list to join
@tparam list2 table The second list to join
@treturn table The result of adding list2 to the end of list1
]]
local function concat(list1, list2)
    local result = clone(list1)
    if is_nil_or_empty(result) then
        result = {}
    end
    if is_nil_or_empty(list2) then
        return result
    end
    for i=1,#list2 do
        result[#result+1] = list2[i]
    end
    return result
end

--[[
Given a list, a start index and and end index, return a new list extracted (shallow copied) from the original.
@tparam list table The original list from which we'll extract a new list
@tparam start_index number The index of the element in the original list to start the extraction
@tparam end_index number The index of the last element in the original list to include in the extraction. If not supplied, defaults to end of original list
]]
local function slice(list, start_index, end_index)
    if start_index > #list then return {} end
    if end_index == nil then
        end_index = #list
    end
    if start_index == 0 then start_index = 1 end
    if start_index < 1 then start_index = #list + start_index + 1 end
    if end_index == 0 then end_index = 1 end
    if end_index < 1 then end_index = #list + end_index + 1 end
    if start_index > end_index then
        local orig_start = start_index
        start_index = end_index
        end_index = orig_start
    end
    if end_index > #list then end_index = #list end
    local result = {}
    for i = start_index, end_index do
        table.insert(result, list[i])
    end
    return result
end

--[[
Creates a new list populated with the results of calling a provided function on every element in the supplied list.
@tparam fn function The function to call with each element of the list
@tparam list table The list over which to iterate. If not supplied, returns a curried function
@treturn any A new list with the results of calling the function for each element of the original list, or, if no list was supplied, a curried function that accepts the list to map over
]]
local function map(fn, list)
    local function curried_function(things)
        local mapped = {}
        for index, thing in ipairs(things) do
            mapped[index] = fn(thing)
        end
        return mapped
    end
    if list == nil then
        return curried_function
    end
    return curried_function(list)
end

--[[
Creates a new list with all sub-list elements concatenated into it recursively.
]]
local function flatten(list)
  if type(list) ~= "table" then return {list} end
  local flat_list = {}
  for _, elem in ipairs(list) do
    for _, val in ipairs(flatten(elem)) do
      flat_list[#flat_list + 1] = val
    end
  end
  return flat_list
end

--[[
Returns a list of keys for a given table.
@tparam tbl table The table from which to extract the keys
@treturn table The list of keys for that table
]]
local function keys(tbl)
    local table_keys = {}
    for key, _ in pairs(tbl) do
        table.insert(table_keys, key)
    end
    return table_keys
end

--[[
Iterates over a list, passing an "accumulator" and each element to the supplied function. For the first iteration, the accumulator is either init or, if not supplied, the first element of the list
@tparam fn function In the form fn(acc, element), gets called once for each element of the list
@tparam list table The list over which to iterate
@tparam init any The initial value for the accumulator; if nil, use the first element of the list instead
]]
local function fold(fn, init, list)
    local function curried_function(later_list_orig)
        local later_list = clone(later_list_orig)
        if type(later_list) ~= "table" then
            later_list = {later_list}
        end
        local acc = init
        for index, value in ipairs(later_list) do
            if 1 == index and not init then
                acc = value
            else
                acc = fn(acc, value)
            end
        end
        return acc
    end
    if list == nil then
        return curried_function
    else
        return curried_function(list)
    end
end

--[[
Add an element to the end of a list. Wraps table.insert() in order to not modify original list in-place.
@tparam list table The list to which to append something
@tparam any element The element to add to the end of the list
]]
local function append(list, element)
    local tbl = clone(list)
    if tbl == nil then tbl = {} end
    table.insert(tbl, element)
    return tbl
end

--[[
Returns a new list formed by applying a given callback function to each element of a passed in list, and then flattening the result by one level.
@tparam fn function Will be called once with each element of the passed in list
@tparam list table The list over wich to iterate. If not provided, returns curried function
@treturn any If a list was provided, returns the results of passing each list element to the function. If the function returns a list itself, this will be flattened by one level. If no list was provided, returns a curried function that can be applied to a list
]]
local function flatmap(fn, list)
    local function curried_flatmap(later_list)
        if is_nil_or_empty(later_list) then
            return {}
        end
        local flatmap_folder = function(acc, element)
            element = fn(element)
            acc = fold(append, acc, element)
            return acc
        end
        local result = fold(flatmap_folder, {}, later_list)
        return result
    end
    if list == nil then
        return curried_flatmap
    else
        return curried_flatmap(list)
    end
end

--[[
Given a list and an item, put the item in between each element of the list
@param item The item to intersperse into the list
@param list table The list we want to interleave
@treturn table A new list with the item interspersed between each list item
]]
local function intersperse(item, list)
    local result = clone(list)
    if is_nil_or_empty(result) then
        return {}
    end
    if #result == 1 then
        return result
    end
    return concat({result[1], item}, intersperse(item, slice(result, 2)))
end

--[[
Creates a new array with all elements that pass the test implemented by the provided function.
]]
local function filter(predicate, list)
    local function curried_function(later_list)
        local function filter_folder(acc_orig, x)
            local acc = clone(acc_orig)
            if predicate(x) then
                table.insert(acc, x)
            end
            return acc
        end
        return fold(filter_folder, {}, later_list)
    end
    if list == nil then
        return curried_function
    else
        return curried_function(list)
    end
end

local function any(predicate, list)
    local function curried_function(later_list)
        for _, value in ipairs(later_list) do
            if predicate(value) then return true end
        end
        return false
    end
    if list == nil then
        return curried_function
    else
        return curried_function(list)
    end
end

return {
    any = any,
    append = append,
    clone = clone,
    concat = concat,
    contains = contains,
    contains_value = contains_value,
    deepcopy = deepcopy,
    filter = filter,
    flatmap = flatmap,
    fold = fold,
    has_key = has_key,
    intersperse = intersperse,
    is_nil_or_empty = is_nil_or_empty,
    keys = keys,
    map = map,
    slice = slice,
}
