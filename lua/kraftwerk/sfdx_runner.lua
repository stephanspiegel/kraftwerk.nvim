local echo = require("kraftwerk.echo")

local function jsondecode(json_string)
    if json_string == "" or json_string == nil then
        return ""
    end
    return vim.fn.json_decode(json_string)
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
        if exitcode > 0 then
            echo.error("Error: sfdx call unsuccessful")
            echo.error(errors)
            return
        end
        callback(result)
    end

    local user_parameter = ""
    if(vim.g.kraftwerk_user ~= nil) then
        user_parameter = " -u " .. vim.g.kraftwerk_user
    end

    local job_id = vim.fn.jobstart(
        "sfdx " .. command .. user_parameter,
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
Calls sfdx with the "--json" switch and returns the result as a table.
]]
local function call_sfdx(command, callback)
    local function json_callback(data)
        dump(data)
        local json = table.concat(data, "\n")
        local result = jsondecode(json)
        callback(result)
    end
    call_sfdx_raw(command .. " --json", json_callback)
end

return {
    jsondecode = jsondecode,
    call_sfdx = call_sfdx,
    call_sfdx_raw = call_sfdx_raw
}


