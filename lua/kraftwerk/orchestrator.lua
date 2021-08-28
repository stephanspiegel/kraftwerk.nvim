local io_handler = require('kraftwerk.io_handler')
local sfdx_runner = require('kraftwerk.sfdx_runner')
local util = require('kraftwerk.util')

local M = {}

M.call = function(module_name, command, ...)
    local command_args = {...}
    local range, args
    if #command_args == 4 then -- range command, first 3 arguments are about the range
        range = util.slice(command_args, 1, 3)
        args = vim.split(command_args[4], '%s+')
    else -- not a range command, any args are user-entered 
        range = {}
        args = vim.split(command_args[1], '%s+')
    end
    local command_module = require('kraftwerk.'..module_name)[command]
    local expected_input = command_module.expected_input
    local input_result = io_handler.gather_input(expected_input, range, args)
    if util.contains_key(input_result, 'messages') then
        local messages = input_result.messages
        io_handler.output({ messages = messages })
        if util.contains_key(messages, 'err') then
            return
        end
    end
    local sfdx_command, command_callback = command_module.build_command(input_result)
    local orchestrator_callback = function(sfdx_result)
        local command_output = command_callback(sfdx_result)
        io_handler.output(command_output)
    end
    local sfdx_call = command_module.sfdx_call
    sfdx_runner[sfdx_call](sfdx_command, orchestrator_callback)
end

return M
