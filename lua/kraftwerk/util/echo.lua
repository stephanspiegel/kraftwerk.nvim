local vim_echo = vim.api.nvim_echo
local functor = require('kraftwerk.util.functor')

local function stringify(data)
    if type(data) ~= "table" then
        return data
    end
   return table.concat(data, "\n")
end

local highlight_group_by_type = {
    info = '',
    warn = 'WarningMsg',
    err = 'ErrorMsg'
}

local function build_echo_string(data, highlight_group)
    if data == nil or data == '' then
        return {}
    end
    if highlight_group == nil then
        return {stringify(data)}
    else
        return {stringify(data), highlight_group}
    end
end

local function echo_multiline(data)
    local echo_lines = {}
    for type, message in pairs(data) do
        local highlight = highlight_group_by_type[type]
        table.insert(echo_lines, 1, build_echo_string(message, highlight))
    end
    local new_line_terminated_lines = functor.intersperse({'\n'}, echo_lines)
    vim_echo(new_line_terminated_lines, true, {})
end

local function info(data)
    echo_multiline({ info = data })
end

local function warn(data)
    echo_multiline({ warn = data })
end

local function err(message)
    echo_multiline({ err = message })
end

return {
    info = info,
    warn = warn,
    err = err,
    multiline = echo_multiline
}
