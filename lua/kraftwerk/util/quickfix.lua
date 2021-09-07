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
Pure function
@tparam sfdx_result table The "result" field in the response returned by sfdx
@return table An list of error items ready to pass to quickfix with a single element
]]
local function build_compile_error_items(sfdx_result)
    local line = '${selection_start_line_plus:' .. sfdx_result.line - 1 .. '}'
    local column = '${selection_start_col_plus:' .. sfdx_result.column - 1 .. '}'
    local error_item = {
        lnum = line,
        col = column,
        text = sfdx_result.compileProblem,
        bufnr = '${current_buffer_number}',
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
Pure function
@tparam line string The stack trace line we want to build an error item from
@treturn table An error item ready to pass to quickfix
]]
local function build_error_item_from_stacktrace_line(line)
    local error_item = functor.clone(parse_stack_trace_line(line))
    if text.is_blank(error_item.class_name) then
        error_item.bufnr = '${current_buffer_number}'
    else
        local file_extension = '.cls'
        if text.starts_with('Trigger', error_item.module) then
            file_extension = '.trigger'
        end
        local file_name = error_item.class_name .. file_extension
        error_item.filename = '${file_path_to:'.. file_name ..'}'
    end
    error_item.class_name = nil
    error_item.text = '    ... Continued'
    return error_item
end

--[[--
Given a string containing one or more stacktrace lines, build error items for quickfix.
Pure function
@tparam stacktrace_data string New-line separated stacktrace lines
@treturn table A list of error items ready for quickfix
]]
local function build_error_items_from_stacktrace_lines(stacktrace_data)
    local split_lines = text.split(stacktrace_data.lines, '\n')
    local error_items = functor.map(build_error_item_from_stacktrace_line, split_lines) --action
    error_items[1].text = stacktrace_data.message
    return error_items
end

--[[--
Build a list of error items from a failure result (non-compile issue) of "force:apex:execute".
Pure function
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
@tparam results table  The "result" field in the response returned by sfdx
@treturn table A list of error items ready to pass to quickfix
]]
local function build_push_error_items(results)
    return functor.map(build_push_error_item, results)
end

--[[--
Build a list of error items from a unit test failure returned by "force:apex:test:run".
Pure function
@tparam result table  The "result" field in the response returned by sfdx
@treturn table A list of error items ready to pass to quickfix
]]
local function build_test_error_items(result)
    local failed_tests = functor.filter(function(x) return x.Outcome == 'Fail' end, result.tests)
    local function build_stacktrace_item(failed_test)
        return { lines = failed_test.StackTrace, message = failed_test.Message }
    end
    local stacktrace_items = functor.map(build_stacktrace_item, failed_tests)
    local quick_fix_errors = functor.flatmap(build_error_items_from_stacktrace_lines, stacktrace_items) -- action
    return quick_fix_errors
end

return {
    build_compile_error_items = build_compile_error_items,
    build_execute_anonymous_error_items = build_execute_anonymous_error_items,
    build_push_error_items = build_push_error_items,
    build_test_error_items = build_test_error_items,
}
