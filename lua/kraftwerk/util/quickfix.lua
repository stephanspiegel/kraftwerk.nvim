--[[--
Module for working with the quickfix window
@module quickfix
]]
local functor = require("kraftwerk.util.functor")

--[[
Build a table that contains a list of quickfix errors, ready to send to quickfix window.
@tparam sfdx_result table The result received from sfdx as a table
@treturn {error_item, error_item, ...} A list of quickfix error items ready for the quickfix window
--]]
local function build_error_items(sfdx_result)
    local sfdx_error_to_vim_error = {
        lineNumber = 'lnum',
        columnNumber = 'col',
        error = 'text',
        filePath = 'filename',
        problemType = 'type'
    }
    local sfdx_type_to_vim_type = {
        Error = 'E',
        Warning = 'W'
    }
    local quick_fix_errors = {}
    for _, result in ipairs(sfdx_result.result) do
        local error_item = {}
        for sfdx_field, vim_field in pairs(sfdx_error_to_vim_error) do
            if functor.contains_key(result, sfdx_field) then
                error_item[vim_field] = result[sfdx_field]
                if sfdx_field == 'problemType' then
                    error_item[vim_field] = sfdx_type_to_vim_type[result[sfdx_field]]
                end
            end
        end
        table.insert(quick_fix_errors, error_item)
    end
    return quick_fix_errors
end

--[[
Open the quickfix window.
--]]
local function open()
    vim.cmd('copen')
end

--[[
Close the quickfix window.
--]]
local function close()
    vim.cmd('cclose')
end

--[[
Parse errors from what sfdx returned, and display them in the quickfix window.
@tparam sfdx_result table The result received from sfdx as a table
--]]
local function show_errors(quickfix_items)
    if next(quickfix_items) == nil then
        return
    end
    vim.call('setqflist', quickfix_items)
    open()
end

return {
    show_errors = show_errors,
    build_error_items = build_error_items,
    open = open,
    close = close
}
