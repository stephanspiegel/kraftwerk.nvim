--[[--
Module for working with the quickfix window
@module quickfix
]]
local functor = require("kraftwerk.util.functor")
local text = require('kraftwerk.util.text')
local buffer = require('kraftwerk.util.buffer')

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

local function parse_stack_trace_line(stack_trace_line)
    local patterns = {
        '(Class%.([^.]*)[^:]*): line (%d+), column (%d+).*',
        '(AnonymousBlock)(%.?): line (%d+), column (%d+).*',
        '(Trigger%.([^:]*)): line (%d+), column (%d+).*'
    }
    local function match_line(acc, pattern)
        local matches = { string.match(stack_trace_line, pattern) }
        if functor.is_nil_or_empty(matches) then
            return acc
        end
        return matches
    end
    local pattern_matches = functor.fold(match_line, {}, patterns)
    return {
        module = pattern_matches[1],
        class_name = pattern_matches[2],
        lnum = pattern_matches[3],
        col = pattern_matches[4]
    }
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

local function build_push_error_item(result)
    local function error_item_builder(acc, sfdx_error_field)
        if functor.has_key(result, sfdx_error_field) then
            local vim_field = sfdx_error_to_vim_error[sfdx_error_field]
            acc[vim_field] = result[sfdx_error_field]
            if sfdx_error_field == 'problemType' then
                acc[vim_field] = sfdx_type_to_vim_type[result[sfdx_error_field]]
            end
        end
        return acc
    end
    return functor.fold(error_item_builder, {}, functor.keys(sfdx_error_to_vim_error))
end

local function build_error_item_from_stacktrace_line(line)
    local error_item = parse_stack_trace_line(line)
    if text.is_blank(error_item.class_name) then
        error_item.bufnr = vim.fn.bufnr('%')
    else
        error_item.filename = vim.fn.findfile(error_item.class_name .. '.cls', '**')
    end
    error_item.class_name = nil
    error_item.text = '... Continued'
    return error_item
end

local function build_execute_anonymous_error_item(result)
    local stack_trace_lines = text.split(result.exceptionStackTrace, '\n')
    local error_items = functor.map(build_error_item_from_stacktrace_line, stack_trace_lines)
    error_items[1].text = result.exceptionMessage
    return error_items
end

local function build_test_error_item(failed_test)
    local stack_trace_lines = text.split(failed_test.StackTrace, '\n')
    local error_items = functor.map(build_error_item_from_stacktrace_line, stack_trace_lines)
    error_items[1].text = failed_test.Message
    return error_items
end

local function build_push_error_items(results)
    local quick_fix_errors = functor.map(build_push_error_item, results)
    return quick_fix_errors
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
    build_compile_error_item = build_compile_error_item,
    build_execute_anonymous_error_item = build_execute_anonymous_error_item,
    build_push_error_items = build_push_error_items,
    build_test_error_items = build_test_error_items,
    close = close,
    open = open,
    show_errors = show_errors,
    parse_stack_trace_line = parse_stack_trace_line
}
