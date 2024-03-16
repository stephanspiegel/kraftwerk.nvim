--[[--
Module for wrapping the force:source commands
@module source
]]
local functor = require("kraftwerk.util.functor")
local quickfix = require("kraftwerk.util.quickfix")
local completion = require('kraftwerk.util.completion')

--[[
Callback for the force:push command
@tparam result table The result received from sf as a table
--]]
local function push_callback(result)
    local io_data = { messages = {} }
    if result.status ~= 0 then
        io_data.messages.err = { result.commandName .. ": " .. result.message }
        if functor.has_key(result, 'result') then
            io_data.quickfix = quickfix.build_push_error_items(result.result)
        end
    else
        local status = result.result.status
        if status == 'Nothing to deploy' then
            io_data.messages.warn = { status }
        else
            local info_messages = {}
            table.insert(info_messages, 'Deploy succeeded')
            for _, source_item in ipairs(result.result.files) do
                local report_line = source_item.state .. " " .. source_item.fullName
                table.insert(info_messages, report_line)
            end
            io_data.messages.info = info_messages
        end
    end
    return io_data
end

--[[--
Call sf project deploy start.
--]]
local function build_push_command(input)
    local sfdx_command = { 'project', 'deploy', 'start' }
    if functor.has_key(input, 'user') then
        table.insert(sfdx_command, '--target-org=' .. input.user)
    end
    if input.bang then
        table.insert(sfdx_command, '--ignore-conflicts')
    end
    return sfdx_command, push_callback
end

local expected_push_input = {
    args = {
        {
            complete = completion.user,
            name = 'user',
            required = false
        }
    },
    bang = true
}

local function pull_callback(result)
end

--[[
Call sfdx project retrieve start.
--]]
local function build_pull_command()
    return { 'project', 'retrieve', 'start' }, pull_callback
end

local pull_command = {
    meta = {
        module = 'source',
        name = 'pull',
        command_name = 'ForceSourcePull'
    },
    build_command = build_pull_command,
    gather_input = function() return {} end,
    sfdx_call = 'call_sfdx'
}

local push_command  = {
    meta = {
        module = 'source',
        name = 'push',
        command_name = 'ForceSourcePush'
    },
    expected_input = expected_push_input,
    build_command = build_push_command,
    validate_input = function() end,
    sfdx_call = 'call_sfdx'
}

return {
    push = push_command,
    pull = pull_command
}
