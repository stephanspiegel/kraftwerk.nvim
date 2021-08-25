local util = require('kraftwerk.util')
local echo = require('kraftwerk.echo')
local quickfix = require('kraftwerk.quickfix')
local window_handler = require('kraftwerk.window_handler')

local function message_handler(message_data)
    for type, message in pairs(message_data) do
       echo[type](message)
    end
end

local handlers = {
    messages = message_handler,
    quickfix = quickfix.show_errors,
    result_buffer = window_handler.open_result_buffer
}

local function output(output_data)
    for key, value in pairs(output_data) do
        if not util.contains_key(handlers, key) then
            echo.err('io_handler received unknown key: '..key)
            return
        end
        handlers[key](value)
    end
end

return {
    output = output
}
