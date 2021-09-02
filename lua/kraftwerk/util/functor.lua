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

local function contains(tbl, test_value)
    if tbl == nil then return false end
    for _, value in ipairs(tbl) do
        if value == test_value then
            return true
        end
    end
    return false
end

local function contains_key(tbl, test_key)
    if tbl == nil then return false end
    for key, _ in pairs(tbl) do
        if key == test_key then
            return true
        end
    end
    return false
end

local function contains_value(list, test_value)
    if list == nil then return false end
    for _, value in pairs(list) do
        if value == test_value then
            return true
        end
    end
    return false
end

local function is_null_or_empty(tbl)
    return tbl == nil or next(tbl) == nil
end

--[[
Given two lists, create a new list by adding the second list to the end of the first list
@tparam list1 table The first list to join
@tparam list2 table The second list to join
@treturn table The result of adding list2 to the end of list1
]]
local function concat(list1, list2)
    local result = deepcopy(list1)
    if is_null_or_empty(result) then
        result = {}
    end
    if is_null_or_empty(list2) then
        return result
    end
    for i=1,#list2 do
        result[#result+1] = list2[i]
    end
    return result
end

local function slice(tbl, start_index, end_index)
    if end_index == nil then
        end_index = #tbl
    end
    if start_index < 0 or end_index < 0 then
        error("slice can't handle negative indexes")
    end
    if start_index > end_index then
        error("slice: start_index must be less than end_index")
    end
    if start_index > #tbl then
        error("slice: start_index " .. start_index .. " is larger than table size "..#tbl)
    end
    if end_index > #tbl then
        error("slice: end_index " .. end_index .. " is larger than table size "..#tbl)
    end
    local slice = {}
    for i = start_index, end_index do
        table.insert(slice, tbl[i])
    end
    return slice
end

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

function flatten(list)
  if type(list) ~= "table" then return {list} end
  local flat_list = {}
  for _, elem in ipairs(list) do
    for _, val in ipairs(flatten(elem)) do
      flat_list[#flat_list + 1] = val
    end
  end
  return flat_list
end

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
local function fold(fn, list_orig, init)
    local list = deepcopy(list_orig)
    if type(list) ~= "table" then
        list = {list}
    end
    local acc = init
    for index, value in ipairs(list) do
        if 1 == index and not init then
            acc = value
        else
            acc = fn(acc, value)
        end
    end
    return acc
end

--[[
Add an element to the end of a list. Wraps table.insert() in order to not modify original list in-place.
@tparam list table The list to which to append something
@tparam any element The element to add to the end of the list
]]
local function append(list, element)
    local tbl = deepcopy(list)
    table.insert(tbl, element)
    return tbl
end

local function flatmap(fn, list)
    if is_null_or_empty(list) then
        return {}
    end
    local flatmap_folder = function(acc, element)
        element = fn(element)
        --[[ if type(element) ~= 'table' then
            acc = append(acc, element)
        else ]]
            acc = fold(append, element, acc)
        -- end
        return acc
    end
    local result = fold(flatmap_folder, list, {})
    return result
end

--[[
Given a list and an item, put the item in between each element of the list
@param item The item to intersperse into the list
@param list table The list we want to interleave
@treturn table A new list with the item interspersed between each list item
]]
local function intersperse(item, list)
    local result = deepcopy(list)
    if is_null_or_empty(result) then
        return {}
    end
    if #result == 1 then
        return result
    end
    return concat({result[1], item}, intersperse(item, slice(result, 2)))
end

local function filter(predicate, list)
    local function filter_folder(acc_orig, x)
        local acc = deepcopy(acc_orig)
        if predicate(x) then
            table.insert(acc, x)
        end
        return acc
    end
    return fold(filter_folder, list, {})
end

return {
    append = append,
    concat = concat,
    contains = contains,
    contains_key = contains_key,
    contains_value = contains_value,
    deepcopy = deepcopy,
    filter = filter,
    flatmap = flatmap,
    fold = fold,
    intersperse = intersperse,
    is_null_or_empty = is_null_or_empty,
    keys = keys,
    map = map,
    slice = slice,
}
