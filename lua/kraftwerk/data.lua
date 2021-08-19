local util = require("kraftwerk.util")
local sfdx = require("kraftwerk.sfdx_runner")
local echo = require("kraftwerk.echo")
local window_handler = require("kraftwerk.window_handler")

local formatting = require("kraftwerk.formatting")

local result_configs = {
    csv = { filetype = "csv" },
    human = { filetype = "text" },
    json = { filetype = "json" },
    ['table'] = {
        filetype = "markdown",
        format = "json",
        processor = formatting.build_table
    }
}

local function build_query_command(query_string, format)
    local sfdx_command = 'force:data:soql:query'
    sfdx_command = sfdx_command .. ' --query "' .. query_string .. '"'
    if format == nil or format == "" then
        format = "human"
    end
    if not util.contains_key(result_configs, format) then
        error("Unknown query result format: " .. format, 0)
    end
    local result_config = result_configs[format]
    local result_format = format
    if util.contains_key(result_config, "format") then
        result_format = result_config.format
    end
    local file_type = result_config.filetype
    local processor
    if util.contains_key(result_config, "processor") then
        processor = result_config.processor
    end
    sfdx_command = sfdx_command .. "  --resultformat=" .. result_format
    local function query_callback(result)
        -- todo: add markdown table handling
        if processor ~= nil then
            result = processor(result)
        end
        window_handler.open_result_buffer("__Query_Result__", result, file_type)
    end
    return sfdx_command, query_callback
end
--[[--
Sends a SOQL query to sfdx.
@param range Should either be 0 (no range included in command), 1 (":10ForceDataSoqlQuery, or 2 (a ":15,29ForceDataSoqlQuery" style range or visual selection)
@param startline The line where the range for the command starts
@param endline The line where the range for the command ends
@param format The format of the result to return: "csv", "human", "json"
@todo implement explicit line ranges (multi and single line)

]]
local function query(range, startline, endline, format)
    local query_string = util.get_visual_selection()
    local ok, response, callback = pcall(build_query_command, query_string, format)
    if ok then
        sfdx.call_sfdx_raw(response, callback)
    else
        echo.err(response)
    end
end

return {
    query = query,
    build_query_command = build_query_command

}
