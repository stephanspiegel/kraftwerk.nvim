local cmd = vim.cmd

local function define_commands()
    cmd("command! -range=% -nargs=? ForceDataSoqlQuery lua require'kraftwerk.data'.query(<range>, <line1>, <line2>, <q-args>)")
end

local function setup()
    define_commands()
end

return {
    setup = setup
}
