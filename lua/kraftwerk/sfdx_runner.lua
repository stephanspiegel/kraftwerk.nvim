local echo = require("kraftwerk.echo")

local function jsondecode(json_string)
    if json_string == "" or json_string == nil then
        return ""
    end
    return vim.fn.json_decode(json_string)
end

local function build_command(command)
    local user_parameter = ""
    if(vim.g.kraftwerk_user ~= nil) then
        user_parameter = " -u " .. vim.g.kraftwerk_user
    end
    local sfdx_executable = 'sfdx'
    if vim.g.kraftwerk_sfdx_executable ~= null then
        sfdx_executable = vim.g.kraftwerk_sfdx_executable
    end
    local command = sfdx_executable .. " " .. command .. user_parameter
    return command
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

    local function on_exit(_, exitcode, _)
        local nextError = next(errors)
        if exitcode > 0 then
            if nextError ~= nil and errors[nextError] ~= '' then
                -- sfdx may return with exitcode 1 but having sent all output to stdout instead of stdout, meaning we won't have any errors. We only handle errors sent to stderr here, let the calling code deal with error messages sent to stdout
                echo.err(errors)
                return
            end
        end
        print('calling callback')
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
Calls sfdx asynchronously. Only use if the calling context doesn't support callbacks
]]
local function call_sfdx_sync_raw(command)
    local result = vim.fn.systemlist(build_command(command))
    return result
end

local function json_decoder(data)
    local json = table.concat(data, "\n")
    local result = jsondecode(json)
    return result
end

--[[--
Calls sfdx asynchronously with the "--json" switch, and returns result as a table. Only use if the calling context doesn't support callbacks
]]
local function call_sfdx_sync(command)
    local result = call_sfdx_sync_raw(command .. " --json")
    return json_decoder(result)
end

--[[--
Calls sfdx with the "--json" switch, the calls "callback" with the result as a table.
@param command The sfdx command to call, ie. "force:source:push"
@param callback Will be called with the result of running the sfdx command, as a table
]]
local function call_sfdx(command, callback)
    local function json_callback(data)
        callback(json_decoder(data))
    end
    call_sfdx_raw(command .. " --json", json_callback)
end

return {
    jsondecode = jsondecode,
    call_sfdx = call_sfdx,
    call_sfdx_raw = call_sfdx_raw,
    call_sfdx_sync = call_sfdx_sync
}
