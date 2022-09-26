local functor = require("kraftwerk.util.functor")
local formatting = require("kraftwerk.util.formatting")
local completion = require('kraftwerk.util.completion')

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

local function build_query_command(input)
    local query_string = input.content
    local format = input.format
    local sfdx_command = 'force:data:soql:query'
    sfdx_command = sfdx_command .. ' --query "' .. query_string .. '"'
    local result_config = result_configs[format]
    local result_format = format
    if functor.has_key(result_config, "format") then
        result_format = result_config.format
    end
    local file_type = result_config.filetype
    local processor
    if functor.has_key(result_config, "processor") then
        processor = result_config.processor
    end
    local result_format_clause = "  --resultformat=" .. result_format
    local user_clause = ''
    if functor.has_key(input, 'user') then
        user_clause = ' --targetusername=' .. input.user
    end
    local tooling_api_clause = ''
    if input.bang then
        tooling_api_clause = ' --usetoolingapi'
    end
    sfdx_command = sfdx_command .. result_format_clause .. user_clause .. tooling_api_clause
    local function query_callback(result)
        -- todo: add markdown table handling
        if processor ~= nil then
            result = processor(result)
        end
        return {
            result_buffer = {
                content = result,
                file_type = file_type,
                title = "__Query_Result__"
            }
        }
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

local expected_query_input = {
    args = {
        {
            name = 'format',
            valid_values = { 'human', 'csv', 'json', 'table'},
            default_value = 'human',
            required = false
        },
        {
            name = 'user',
            required = false,
            complete = completion.user
        }
    },
    bang = true,
    content = {
        source = 'range_or_current_line',
        format = 'text',
        required = true
    }
}

local query_command = {
    meta = {
        module = 'data',
        name = 'query',
        command_name = 'ForceDataSoqlQuery'
    },
    expected_input = expected_query_input,
    build_command = build_query_command,
    sfdx_call = 'call_sfdx_raw'
}

return {
    query = query_command
}
