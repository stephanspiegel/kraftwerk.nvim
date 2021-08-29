--[[--
Module for wrapping the force:source commands
@module source
]]
local util = require("kraftwerk.util")
local quickfix = require("kraftwerk.quickfix")

--[[
Callback for the force:push command
@tparam result table The result received from sfdx as a table
--]]
local function push_callback(result)
    local io_data = { messages = {} }
    if result.status ~= 0 then
        io_data.messages.err = { result.commandName .. ": " .. result.message }
        if util.contains_key(result, 'result') then
            io_data.quickfix = quickfix.build_error_items(result)
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
    if util.contains_key(input, 'user') then
        user_clause = ' --targetusername=' .. input.user
    end
    local sfdx_command =  'force:source:push' .. user_clause
    return sfdx_command, push_callback
end

local expected_push_input = {
    args = {
        {
            name = 'user',
            required = false,
            complete = function() end
        }
    }
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
    build_command = build_pull_command,
    gather_input = function() return {} end,
    sfdx_call = 'call_sfdx'
}

local push_command  = {
    expected_input = expected_push_input,
    build_command = build_push_command,
    validate_input = function() end,
    sfdx_call = 'call_sfdx'
}

return {
    push = push_command,
    pull = pull_command
}
