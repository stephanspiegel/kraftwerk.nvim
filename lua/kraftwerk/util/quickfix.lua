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

--[[--
Parse a stack trace line in a way that can be used to build quickfix errors.
Pure function
@tparam stack_trace_line string The line from a stack trace we'd like to parse
@treturn table A table with components useful for building error items
]]
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

--[[--
Build a list oferror items from a compile error resulting from "force:apex:execute".
Will always only contain a single item
Not pure: calls buffer.get_visual_selection_range()
@tparam sfdx_result table The "result" field in the response returned by sfdx
@return table An list of error items ready to pass to quickfix with a single element
]]
local function build_compile_error_items(sfdx_result)
    local selection_line, selection_column, _, _ = buffer.get_visual_selection_range() -- action
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
    return { error_item }
end

--[[--
Build an error item from a "force:source:push" error.
Pure function
@tparam result table  The "result" field in the response returned by sfdx
@tresult table A list of error items ready to pass to quickfix
]]
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

--[[--
Build an error item from a stack trace line.
Not pure: Calls either vim.fn.bufnr() or vim.fn.findfile()
@tparam line string The stack trace line we want to build an error item from
@treturn table An error item ready to pass to quickfix
]]
local function build_error_item_from_stacktrace_line(line)
    local error_item = functor.clone(parse_stack_trace_line(line))
    if text.is_blank(error_item.class_name) then
        error_item.bufnr = vim.fn.bufnr('%') -- action
    else
        error_item.filename = vim.fn.findfile(error_item.class_name .. '.cls', '**') -- action
    end
    error_item.class_name = nil
    error_item.text = '... Continued'
    return error_item
end

local function build_error_items_from_stacktrace_lines(lines, message)
    local split_lines = text.split(lines, '\n')
    local error_items = functor.map(build_error_item_from_stacktrace_line, split_lines) --action
    error_items[1].text = message
    return error_items
end

--[[--
Build a list of error items from a failure result (non-compile issue) of "force:apex:execute".
Not pure: calls build_error_items_from_stacktrace_lines()
@tparam result table  The "result" field in the response returned by sfdx
@treturn table A list of error items ready to pass to quickfix
]]
local function build_execute_anonymous_error_items(result)
    local stacktrace_data = { lines = result.exceptionStackTrace, message = result.exceptionMessage }
    return build_error_items_from_stacktrace_lines(stacktrace_data) --action
end

--[[--
Build a list of error items from a "force:source:push" failure.
Pure function
@tparam result table  The "result" field in the response returned by sfdx
@treturn table A list of error items ready to pass to quickfix
]]
local function build_push_error_items(results)
    return functor.map(build_push_error_item, results)
end

--[[--
Build a list of error items from a unit test failure returned by "force:apex:test:run".
Not pure: calls build_test_error_item()
@tparam result table  The "result" field in the response returned by sfdx
@treturn table A list of error items ready to pass to quickfix
]]
local function build_test_error_items(result)
    local failed_tests = functor.filter(function(x) return x.Outcome == 'Fail' end, result.tests)
    local function build_stacktrace_item(failed_test)
        return { failed_test.StackTrace, failed_test.Message }
    end
    local stacktrace_items = functor.map(build_stacktrace_item, failed_tests)
    local quick_fix_errors = functor.flatmap(build_error_items_from_stacktrace_lines, stacktrace_items) -- action
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
    build_compile_error_items = build_compile_error_items,
    build_execute_anonymous_error_items = build_execute_anonymous_error_items,
    build_push_error_items = build_push_error_items,
    build_test_error_items = build_test_error_items,
    close = close,
    open = open,
    parse_stack_trace_line = parse_stack_trace_line, -- Does this need to be exported?
    show_errors = show_errors,
}
