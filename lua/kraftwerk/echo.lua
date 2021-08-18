local function stringify(data)
    if type(data) ~= "table" then
        return data
    end
   return table.concat(data, "\n")
end

local function echo_with_highlight(data, highlight_group)
    if highlight_group == nil then
        vim.api.nvim_echo({{stringify(data)}}, true, {})
    else
        vim.api.nvim_echo({{stringify(data), highlight_group}}, true, {})
    end
end

local function info(data)
    echo_with_highlight(data)
end

local function warn(data)
    echo_with_highlight(data, "WarningMsg")
end

local function err(message)
    echo_with_highlight(message, "ErrorMsg")
end

return {
    info = info,
    warn = warn,
    err = err
}
