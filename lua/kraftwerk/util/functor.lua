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

local function contains_value(tbl, test_value)
    if tbl == nil then return false end
    for _, value in pairs(tbl) do
        if value == test_value then
            return true
        end
    end
    return false
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
        for index, thing in pairs(things) do
            mapped[index] = fn(thing)
        end
        return mapped
    end
    if list == nil then 
        return curried_function
    end
    return curried_function(list)
end

return {
    contains = contains,
    contains_key = contains_key,
    contains_value = contains_value,
    slice = slice,
    map = map
}
