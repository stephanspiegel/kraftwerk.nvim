local functor = require('kraftwerk.util.functor')
local buffer = require('kraftwerk.util.buffer')
local echo = require('kraftwerk.util.echo')
local window_handler = require('kraftwerk.util.window_handler')
local text = require('kraftwerk.util.text')

local function message_handler(message_data)
    echo.multiline(message_data)
end

local function offset_line_number_from_selection(line_offset)
    local selection_start_line, _, _, _ = buffer.get_visual_selection_range()
    return selection_start_line + line_offset
end

local function offset_column_number_from_selection(column_offset)
    local _, selection_start_column, _, _ = buffer.get_visual_selection_range()
    return selection_start_column + column_offset
end

local function find_file(file_name)
    return vim.fn.findfile(file_name, '**')
end

local interpolators = {
    ['selection_start_line_plus:%s*(%d+)'] = offset_line_number_from_selection,
    ['selection_start_col_plus:%s*(%d+)'] = offset_column_number_from_selection,
    ['file_path_to:%s*(.*)'] = find_file,
    current_buffer_number = function() return vim.fn.bufnr('%') end,
}

local function interpolate(source_string)
    if not text.starts_with('${', source_string) then
        return source_string
    end
    local interpolation_key = string.match(source_string, '${([^}]*)}')
    local function interpolate_keys(acc, pattern)
        local data = string.match(interpolation_key, pattern)
        if data ~= nil then
            acc = interpolators[pattern](data)
        end
        return acc
    end
    return functor.fold(interpolate_keys, {}, functor.keys(interpolators))
end

--[[
Open the quickfix window.
--]]
local function quickfix_open()
    vim.cmd('copen')
end

--[[
Close the quickfix window.
--]]
local function quickfix_close()
    vim.cmd('cclose')
end

--[[
Parse errors from what sfdx returned, and display them in the quickfix window.
@tparam sfdx_result table The result received from sfdx as a table
--]]
local function show_quickfix(quickfix_items)
    if next(quickfix_items) == nil then
        return
    end
    vim.call('setqflist', quickfix_items) -- action
    quickfix_open()
end

local function quickfix_handler(quickfix_items)
    local function perform_string_interpolation(quickfix_item)
        local new_item = {}
        for key, value in pairs(quickfix_item) do
            new_item[key] = interpolate(value)
        end
        return new_item
    end
    local processed_items = functor.map(perform_string_interpolation, quickfix_items)
    show_quickfix(processed_items)
end

local handlers = {
    messages = message_handler,
    quickfix = quickfix_handler,
    result_buffer = window_handler.open_result_buffer
}

local function output(output_data)
    for key, value in pairs(output_data) do
        if not functor.has_key(handlers, key) then
            echo.err('io_handler received unknown key: '..key)
            return
        end
        handlers[key](value)
    end
end

local function gather_args(expected_args, args)
    if args == nil then args = {} end
    for index, arg_definition in ipairs(expected_args) do
        local arg_value = args[index]
        if arg_value == nil then
            if functor.has_key(arg_definition, 'required') and arg_definition.required == true then
                local err = 'Missing required argument: ' .. arg_definition.name
                return { messages = { err = err }}
            end
            if functor.has_key(arg_definition, 'default_value') then
                arg_value = arg_definition.default_value
            end
        else
            if functor.has_key(arg_definition, 'valid_values') then
                if not functor.contains_value(arg_definition.valid_values, arg_value) then
                    local err = '"' ..arg_value .. '" is not a valid value for ' .. arg_definition.name
                    return { messages = { err = err }}
                end
            end
        end
        if arg_value ~= nil then
            args[arg_definition.name] = arg_value
        end
    end
    return args
end

local function write_temp_file_from(content)
    local temp_file_name = vim.fn.tempname()
    local content_list = text.split(content, '\n')
    vim.fn.writefile(content_list, temp_file_name)
    return temp_file_name
end

local function gather_content(expected_content, range)
    if not functor.has_key(expected_content, 'source') then echo.err('"source" is a required field when "content" is specified')
    end
    local content
    if expected_content.source == 'range_or_current_line' then
        -- TODO: handle range, line, visual selection or current line <26-08-21, stephan.spiegel> --
        content = buffer.get_visual_selection()
    elseif expected_content.source == 'range_or_current_file' then
        -- TODO: handle range, line, visual selection or current file <26-08-21, stephan.spiegel> --
        content = buffer.get_visual_selection()
    else
        echo.err('Unknown content source: '..expected_content.source)
    end
    if expected_content.format == 'temp_file' then
        local file_name = write_temp_file_from(content)
        return 'temp_file_path', file_name
    else
        return 'content', content
    end
end

local function gather_input(expected_input, bang, range, args)
    local input = {}
    if functor.has_key(expected_input, 'args') then
        input = gather_args(expected_input.args, args)
    end
    if functor.has_key(expected_input, 'content') then
        local field, content = gather_content(expected_input.content, range)
        input[field] = content
    end
    if functor.has_key(expected_input, 'bang') then
        input.bang = bang
    end
    return input
end

return {
    output = output,
    gather_input = gather_input
}
