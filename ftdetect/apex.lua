local ft_commands = -- { pattern, filteype }
{ { "*/src/classes/*.cls", "apexcode" }
, { "*/src/triggers/*.trigger", "apexcode" }
, { "*/force-app/main/default/classes/*.cls", "apexcode" }
, { "*/force-app/main/default/triggers/*.trigger", "apexcode" }
, { "*.apex", "apexcode" }
, { "*.soql", "soql" }
, { "*.apexcode", "apexcode" }
}

vim.api.nvim_command("augroup apex")
vim.api.nvim_command "autocmd!"
for _, def in ipairs(ft_commands) do
    local pattern = def[1]
    local filetype = def[2]
    local command = "autocmd BufNewFile,BufRead " .. pattern .. " set filetype=" ..filetype
    vim.api.nvim_command(command)
end
vim.api.nvim_command "augroup END"

