local functor = require('kraftwerk.util.functor')
local buffer = require('kraftwerk.util.buffer')
local echo = require('kraftwerk.util.echo')
local quickfix = require('kraftwerk.util.quickfix')
local window_handler = require('kraftwerk.util.window_handler')

local function message_handler(message_data)
    echo.multiline(message_data)
end

local handlers = {
    messages = message_handler,
    quickfix = quickfix.show_errors,
    result_buffer = window_handler.open_result_buffer
}

local function output(output_data)
    for key, value in pairs(output_data) do
        if not functor.contains_key(handlers, key) then
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
            if functor.contains_key(arg_definition, 'required') and arg_definition.required == true then
                local err = 'Missing required argument: ' .. arg_definition.name
                return { messages = { err = err }}
            end
            if functor.contains_key(arg_definition, 'default_value') then
                arg_value = arg_definition.default_value
            end
        else
            if functor.contains_key(arg_definition, 'valid_values') then
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

local function gather_content(content, range)
    if not functor.contains_key(content, 'source') then echo.err('"source" is a required field when "content" is specified')
    end
    if content.source == 'range_or_current_line' then
        -- TODO: handle range, line, visual selection or current line <26-08-21, stephan.spiegel> --
        return buffer.get_visual_selection()
    elseif content.source == 'range_or_current_file' then
        -- TODO: handle range, line, visual selection or current line <26-08-21, stephan.spiegel> --
        return buffer.get_visual_selection()
    else
        echo.err('Unknown content source: '..content.source)
    end
end

local function gather_input(expected_input, bang, range, args)
    local input = {}
    if functor.contains_key(expected_input, 'args') then
        input = gather_args(expected_input.args, args)
    end
    if functor.contains_key(expected_input, 'content') then
        input['content'] = gather_content(expected_input.content, range)
    end
    if functor.contains_key(expected_input, 'bang') then
        input.bang = bang
    end
    return input
end

return {
    output = output,
    gather_input = gather_input
}
