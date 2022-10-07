local echo = require("kraftwerk.util.echo")
local functor = require("kraftwerk.util.functor")
local json = require('kraftwerk.util.json')
local text = require('kraftwerk.util.text')
local config = require('kraftwerk.config')

local function build_command(command)
    local sfdx_executable = config.get('sfdx_executable') or 'sfdx'
    local sfdx_command = sfdx_executable .. " " .. command
    return sfdx_command
end

--[[--
Calls sfdx without appending "--json".
Calling code is responsible for parsing result.
Returns a table with an entry for each line
]]
local function call_sfdx_raw(command, callback)
    local errors = {}
    local result = {}

    local function on_stdout(_, data, _)
        if data then
            for _, value in ipairs(data) do
                table.insert(result, value)
            end
        end
    end

    local function on_stderr(_, data, _)
        if data then
            for _, value in ipairs(data) do
                table.insert(errors, value)
            end
        end
    end

    local function on_exit(_, _, _)
        local nextError = next(errors)
        if nextError ~= nil and not text.is_blank(errors[nextError]) then
            echo.err(errors)
        end
        if(result == nil or #result == 0) then
            -- if we got no results -- maybe all we got was errors --, don't process them
            return
        end
        callback(result)
    end

    local job_id = vim.fn.jobstart(
        build_command(command),
        {
            on_stderr = on_stderr,
            on_stdout = on_stdout,
            on_exit = on_exit,
            stdout_buffered = true,
            stderr_buffered = true,
        }
    )
end

--[[--
Calls sfdx synchronously. Only use if the calling context doesn't support callbacks
]]
local function call_sfdx_sync_raw(command)
    local result = vim.fn.systemlist(build_command(command))
    return result
end

local function json_decode(data)
    local preamble_lines = {}
    local i, line = next(data, nil)
    local starts_with_bracket = '^{'
    while line:find(starts_with_bracket) == nil do
        preamble_lines = functor.append(preamble_lines, line)
        i, line = next(data, i)
    end
    local json_lines = functor.slice(data, i)
    local json_data = table.concat(json_lines, "\n")
    local result = json.decode(json_data)
    if not functor.is_nil_or_empty(preamble_lines) then
        result['preamble'] = table.concat(preamble_lines, "\n")
    end
    return result
end

--[[--
Calls sfdx synchronously with the "--json" switch, and returns result as a table.
Only use if the calling context doesn't support callbacks
]]
local function call_sfdx_sync(command)
    local result = call_sfdx_sync_raw(command .. " --json")
    local decode_succeeded, decoded_result =  pcall(json_decode, result)
    if not decode_succeeded then
        vim.notify('kraftwerk: error decoding json for command '..command..': '..vim.inspect(result))
        return {}
    end
    return json_decode(result)
end

--[[--
Calls sfdx with the "--json" switch, the calls "callback" with the result as a table.
@param command The sfdx command to call, ie. "force:source:push"
@param callback Will be called with the result of running the sfdx command, as a table
]]
local function call_sfdx(command, callback)
    local function json_callback(data)
        callback(json_decode(data))
    end
    call_sfdx_raw(command .. " --json", json_callback)
end

--[[
Doesn't call sfdx at all; instead just invokes the callback directly.
Used for commands that don't wrap any sfdx-cli functionality. Assumes
that the callback contains the "input" data from the build_command
call as a closure, if it needs it
@tparam command Not needed
@tparam callback The callback that will be invoked immediately
]]
local function none(command, callback)
    callback()
end

return {
    call_sfdx = call_sfdx,
    call_sfdx_raw = call_sfdx_raw,
    call_sfdx_sync = call_sfdx_sync,
    none = none
}
