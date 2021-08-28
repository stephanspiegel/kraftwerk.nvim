local util = require("kraftwerk.util")
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

local function build_query_command(input)
    local query_string = input.content
    local format = input.format
    local sfdx_command = 'force:data:soql:query'
    sfdx_command = sfdx_command .. ' --query "' .. query_string .. '"'
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
    local result_format_clause = "  --resultformat=" .. result_format
    local user_clause = ''
    if util.contains_key(input, 'user') then
        user_clause = ' --targetusername=' .. input.user
    end
    sfdx_command = sfdx_command .. result_format_clause .. user_clause
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

local function validate_query_input(input)
    local query_string = util.get_visual_selection()
    if format == nil or format == "" then
        format = "human"
    end
    if not util.contains_key(result_configs, format) then
        return { errors =
            { messages =
                { err = "Unknown query result format: " .. format }
            }
        }
    end
    return { content = query_string, format = format }
end

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
            complete = function() end
        }
    },
    content = {
        source = 'range_or_current_line',
        format = 'text',
        required = true
    }
}

local query_command = {
    expected_input = expected_query_input,
    build_command = build_query_command,
    validate_input = validate_query_input,
    sfdx_call = 'call_sfdx_raw'
}

return {
    query = query_command
}
