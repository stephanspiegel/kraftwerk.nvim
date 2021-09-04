--[[--
Module for working with the quickfix window
@module quickfix
]]
local functor = require("kraftwerk.util.functor")
local text = require('kraftwerk.util.text')
local buffer = require('kraftwerk.util.buffer')

--[[
Build a table that contains a list of quickfix errors, ready to send to quickfix window.
@tparam sfdx_result table The result received from sfdx as a table
@treturn {error_item, error_item, ...} A list of quickfix error items ready for the quickfix window
--]]
local function build_push_error_items(result)
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
    for _, result in ipairs(result) do
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

local function build_compile_error_item(sfdx_result)
    local selection_line, selection_column, _, _ = buffer.get_visual_selection_range()
    local line = selection_line + sfdx_result.line -1
    local column = selection_column + sfdx_result.column -1
    local error_item = {
        lnum = line,
        col = column,
        text = sfdx_result.compileProblem,
        bufnr = vim.fn.bufnr('%'),
        module = 'AnonymousBlock',
        problemType = 'E'
    }
    return error_item
end

local function build_execute_anonymous_error_item(result)
    local stack_trace_lines = text.split(result.exceptionStackTrace, '\n')
    local stack_trace_pattern = '(Class%.([^.]*)[^:]*): line (%d+), column (%d+)'
    local error_text = ''
    local error_items = {}
    for _, line in ipairs(stack_trace_lines) do
        local module_text, class_name, line_number, column_number = line:match(stack_trace_pattern)
        local file_name, buffer_number
        if class_name ~= nil then
            file_name = vim.fn.findfile(class_name .. '.cls', '**')
        else
            module_text, line_number, column_number = line:match('(AnonymousBlock): line (%d+), column (%d+)')
            buffer_number = vim.fn.bufnr('%')
        end
        if text.is_blank(error_text) then
            error_text = result.exceptionMessage
        else
            error_text = '... Continued'
        end
        local error_item = {
                lnum = line_number,
                col = column_number,
                text = error_text,
                module = module_text
            }
        if file_name ~= nil then
            error_item.filename = file_name
        elseif buffer_number ~= nil then
            error_item.bufnr = buffer_number
        end
        error_items = functor.append(error_items, error_item)
    end
    return error_items
end

local function build_test_error_item(failed_test)
    local stack_trace_lines = text.split(failed_test.StackTrace, '\n')
    local stack_trace_pattern = '(Class%.([^.]*)[^:]*): line (%d+), column (%d+)'
    local error_text = ''
    local error_items = {}
    for _, line in ipairs(stack_trace_lines) do
        local module_text, class_name, line_number, column_number = line:match(stack_trace_pattern)
        local file_name = vim.fn.findfile(class_name .. '.cls', '**')
        if text.is_blank(error_text) then
            error_text = failed_test.Message
        else
            error_text = '... Continued'
        end
        table.insert(error_items, {
                lnum = line_number,
                col = column_number,
                filename = file_name,
                text = error_text,
                module = module_text
            })
    end
    return error_items
end

local function build_test_error_items(result)
    local failed_tests = functor.filter(function(x) return x.Outcome == 'Fail' end, result.tests)
    local quick_fix_errors = functor.flatmap(build_test_error_item, failed_tests)
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
    build_push_error_items = build_push_error_items,
    build_test_error_items = build_test_error_items,
    build_compile_error_item = build_compile_error_item,
    open = open,
    close = close,
    build_execute_anonymous_error_item = build_execute_anonymous_error_item
}
