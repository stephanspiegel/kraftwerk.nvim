--[[--
Module for wrapping the force:source commands
@module source
]]
local functor = require("kraftwerk.util.functor")
local quickfix = require("kraftwerk.util.quickfix")
local completion = require('kraftwerk.util.completion')

--[[
Callback for the force:push command
@tparam result table The result received from sfdx as a table
--]]
local function push_callback(result)
    local io_data = { messages = {} }
    if result.status ~= 0 then
        io_data.messages.err = { result.commandName .. ": " .. result.message }
        if functor.contains_key(result, 'result') then
            io_data.quickfix = quickfix.build_push_error_items(result.result)
        end
    else
        local pushedSource = result.result.pushedSource
        if next(pushedSource) == nil then
            io_data.messages.warn = { 'Nothing to push.' }
        else
            local info_messages = {}
            for _, source_item in ipairs(result.result.pushedSource) do
                local report_line = source_item.state .. " " .. source_item.filePath
                table.insert(info_messages, report_line)
            end
            table.insert(info_messages, 'Push succeeded')
            io_data.messages.info = info_messages
        end
    end
    return io_data
end

--[[--
Call sfdx force:source:push.
--]]
local function build_push_command(input)
    local user_clause = ''
    local force_clause = ''
    if functor.contains_key(input, 'user') then
        user_clause = ' --targetusername=' .. input.user
    end
    if input.bang then
        force_clause = ' --forceoverwrite'
    end
    local sfdx_command =  'force:source:push' .. user_clause .. force_clause
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
Call sfdx fource:source:pull.
--]]
local function build_pull_command()
    return 'force:source:pull', pull_callback
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
