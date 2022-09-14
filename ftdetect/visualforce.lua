local ft_commands = -- { pattern, filteype }
{ { "*/src/pages/*.page", "visualforce" }
, { "*/force-app/**/pages/*.page", "visualforce" }
}

vim.api.nvim_command("augroup visualforce")
vim.api.nvim_command "autocmd!"
for _, def in ipairs(ft_commands) do
    local pattern = def[1]
    local filetype = def[2]
    local command = "autocmd BufNewFile,BufRead " .. pattern .. " set filetype=" ..filetype
    vim.api.nvim_command(command)
end
vim.api.nvim_command "augroup END"
