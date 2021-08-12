local function stringify(data)
    if type(data) ~= "table" then
        return data
    end
   return table.concat(data, "\n")
end

local function info(message)
    print(stringify(message))
end

local function warn(message)
    message = stringify(message)
    vim.cmd(([[echohl WarningMsg | echomsg "%s" | echohl None]]):format(vim.fn.escape(message, "\"\\")))
end

local function error(message)
    message = stringify(message)
    vim.cmd(([[echohl ErrorMsg | echomsg "%s" | echohl None]]):format(vim.fn.escape(message, "\"\\")))
end

return {
    info = info,
    warn = warn,
    error = error
}
