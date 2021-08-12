local util = require("kraftwerk.util")
local sfdx = require("kraftwerk.sfdx_runner")
local echo = require("kraftwerk.echo")
local window_handler = require("kraftwerk.window_handler")

local result_formats = {
    "csv",
    "human",
    "json"
}

--[[--
Sends a SOQL query to sfdx.
@param range Should either be 0 (no range included in command), 1 (":10ForceDataSoqlQuery, or 2 (a ":15,29ForceDataSoqlQuery" style range or visual selection)
@param startline The line where the range for the command starts
@param endline The line where the range for the command ends
@param format The format of the result to return: "csv", "human", "json"

]]
local function query(range, startline, endline, format)
    local function query_callback(result)
        window_handler.open_result_buffer("__Query_Result__", result, format)
        dump(result)
    end
    local query_string = util.get_visual_selection()
    local sfdx_command = 'force:data:soql:query'
    sfdx_command = sfdx_command .. ' --query "' .. query_string .. '"'
    if format == nil or format == "" then
        format = "human"
    end
    if not util.contains(result_formats, format) then
        echo.error("Unknown query result format: " .. format)
        return
    end
    sfdx_command = sfdx_command .. "  --resultformat=" .. format
    sfdx.call_sfdx_raw(sfdx_command, query_callback)
end

return {
    query = query
}
