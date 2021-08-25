local io_handler = require('kraftwerk.io_handler')
local sfdx_runner = require('kraftwerk.sfdx_runner')
local util = require('kraftwerk.util')

local M = {}

M.call = function(module_name, command, ...)
    local command_module = require('kraftwerk.'..module_name)[command]
    local command_input = command_module.gather_input(...)
    if util.contains_key(command_input, 'errors') then
        io_handler.output(command_input.errors)
        return
    end
    local sfdx_command, command_callback = command_module.build_command(command_input)
    local orchestrator_callback = function(sfdx_result)
        local command_output = command_callback(sfdx_result)
        io_handler.output(command_output)
    end
    local sfdx_call = command_module.sfdx_call
    sfdx_runner[sfdx_call](sfdx_command, orchestrator_callback)
end

return M
