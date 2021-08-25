local cmd = vim.cmd

local function define_commands()
    cmd("command! -range=% -nargs=? ForceDataSoqlQuery lua require'kraftwerk.orchestrator'.call('data', 'query', <range>, <line1>, <line2>, <q-args>)")
    cmd("command! ForceSourcePush lua require'kraftwerk.orchestrator'.call('source', 'push')")
end

local function setup()
    define_commands()
end

return {
    setup = setup
}
