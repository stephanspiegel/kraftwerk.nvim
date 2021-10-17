--[[--
Module for working with the quickfix window
@module quickfix
]]
local functor = require("kraftwerk.util.functor")
local text = require('kraftwerk.util.text')

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

local stack_trace_patterns = {
    '((Trigger%.([^:]+)): line (%d+), column (%d+))',
    '((Class%.([^.:]*)[^:]-): line (%d+), column (%d+))',
    '((AnonymousBlock)(%.?): line (%d+), column (%d+))',
}

--[[--
Does the line contain anything that looks like a stack trace?
@tparam line string The line to test
@treturn boolean True if the passed in string contains a stack trace match, false otherwise
]]
local function is_stack_trace_match(line)
    local function line_matches(pattern)
        return string.match(line, pattern)
    end
    return functor.any(line_matches, stack_trace_patterns)
end

--[[--
Parse a stack trace line in a way that can be used to build quickfix errors.
Pure function
@tparam stack_trace_line string The line from a stack trace we'd like to parse
@treturn table A table with components useful for building error items
]]
local function parse_stack_trace_line(stack_trace_line)
    local function match_line(acc, pattern)
        local matches = { string.match(stack_trace_line, pattern) }
        if functor.is_nil_or_empty(matches) then
            return acc
        end
        return matches
    end
    local pattern_matches = functor.fold(match_line, {}, stack_trace_patterns)
    return {
        module = pattern_matches[2],
        class_name = pattern_matches[3],
        lnum = pattern_matches[4],
        col = pattern_matches[5]
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
        local file_extension = text.starts_with('Trigger', error_item.module)
                and '.trigger'
                or '.cls'
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
    local error_items = functor.map(build_error_item_from_stacktrace_line, split_lines)
    error_items[1].text = stacktrace_data.message
    return error_items
end

--[[--
Given a list of lines, return the index of the first line that represents a stack trace item.
@tparam {string, ...} lines A table of strings representing lines
@treturn integer The index of the first line that is actually a stack trace item
@treturn integer The last index of a set of actual stack trace items following the first line
]]
local function get_actual_stack_trace_lines(lines)
    local first_matching_line = 0
    local last_matching_line = 0
    for index, line in ipairs(lines) do
        if is_stack_trace_match(line) and first_matching_line == 0 then
            first_matching_line = index
            last_matching_line = #lines
        end
        if first_matching_line > 0 and not is_stack_trace_match(line) then
            last_matching_line = index - 1
            return first_matching_line, last_matching_line
        end
    end
    return first_matching_line, last_matching_line
end

--[[--
Given a stack trace text with lines delineated by newlines, return a quickfix message and stack trace lines, ignoring any non-stack trace lines
@tparam string stack_trace The stack trace text containing newlines
@treturn string The message for the quickfix item
@treturn {string, ...} The stack trace lines to be parsed for the quickfix
]]
local function parse_lines_from_newline_delimited(stack_trace)
    local lines = text.split(stack_trace, '\n')
    local first_matching_line, last_matching_line = get_actual_stack_trace_lines(lines)
    if first_matching_line <= 0 then return {} end
    local message = ''
    if first_matching_line > 1 then
        message = lines[first_matching_line - 1]
    end
    lines = table.concat(lines, '\n', first_matching_line, last_matching_line)
    return message, lines
end

--[[--
Given a stack trace text, return the first match of a stack trace item.
@tparam string stack_trace_line The text from which to parse stack trace info
@tparam integer index The position in the stack_trace_line on which to start searching
@treturn {integer, integer, string} The start index, end index and text of the first match found
]]
local function find_first_match_after(stack_trace_line, index)
    local find_pattern = function(acc, pattern)
        local match_start, match_end, whole_match = string.find(stack_trace_line, pattern, index)
        if not match_start then return acc end
        if acc[1] == nil then
            return {match_start, match_end, whole_match}
        end
        if acc[1] > match_start then
            return {match_start, match_end, whole_match}
        end
        return acc
    end
    return functor.fold(find_pattern, {}, stack_trace_patterns)
end

--[[--
Given a stack trace text, find all matching stack trace items in the order they occur.
@tparam stack_trace_line string The text from which to parse stack trace info
@treturn {string, ...} A table of matched stack trace items
]]
local function find_matches_in_order(stack_trace_line)
    local index, result = 1, {}
    while true do
        local match_start, match_end, match = unpack(find_first_match_after(stack_trace_line, index))
        if match_start == nil then
            return result
        end
        index = match_end
        result = functor.append(result, match)
    end
end

--[[--
Parse stack trace text from a single line into a message and stack trace lines.
@tparam stack_trace The stack trace text to parse, in a single line
@treturn string The message for the quickfix item
@treturn string Newline-delimited stack trace lines
]]
local function parse_lines_from_inline_stack_trace(stack_trace)
    local first_index = find_first_match_after(stack_trace, 1)[1]
    if first_index == nil then return {} end
    local message = text.trim(string.sub(stack_trace, 1, first_index-1))
    local lines = table.concat(find_matches_in_order(stack_trace), '\n')
    return message, lines
end

--[[--
Parse stack trace text into quickfix error items.
@tparam stack_trace string The stack trace text to parse. Can contain new-lines or be a single line
@treturn table A list of error items ready to pass to quickfix
]]
local function parse_lines_from_stack_trace(stack_trace)
    if not is_stack_trace_match(stack_trace) then return {} end
    local parse = text.is_newline_delimited(stack_trace)
            and parse_lines_from_newline_delimited
            or parse_lines_from_inline_stack_trace
    local message, lines = parse(stack_trace)
    return build_error_items_from_stacktrace_lines({
        message = message,
        lines = lines
    })
end

--[[--
Build a list of error items from a failure result (non-compile issue) of "force:apex:execute".
Pure function
@tparam result table  The "result" field in the response returned by sfdx
@treturn table A list of error items ready to pass to quickfix
]]
local function build_execute_anonymous_error_items(result)
    local stacktrace_data = { lines = result.exceptionStackTrace, message = result.exceptionMessage }
    return build_error_items_from_stacktrace_lines(stacktrace_data)
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
    local quick_fix_errors = functor.flatmap(build_error_items_from_stacktrace_lines, stacktrace_items)
    return quick_fix_errors
end

return {
    build_compile_error_items = build_compile_error_items,
    build_error_items_from_stacktrace_lines = build_error_items_from_stacktrace_lines,
    build_execute_anonymous_error_items = build_execute_anonymous_error_items,
    build_push_error_items = build_push_error_items,
    build_test_error_items = build_test_error_items,
    parse_lines_from_stack_trace = parse_lines_from_stack_trace,
}
