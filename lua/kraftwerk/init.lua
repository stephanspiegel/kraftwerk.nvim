local cmd = vim.cmd

local function define_commands()
    cmd("command! CheckVersion lua require'kraftwerk.system'.check_sfdx_version()")
    cmd("command! -range=% -nargs=? ForceDataSoqlQuery lua require'kraftwerk.data'.query(<range>, <line1>, <line2>, <q-args>)")
    cmd("command! -range=% Test lua print(require'kraftwerk.util'.get_visual_selection())")
end

local function setup()
    define_commands()
end

function _G.dump(...)
    local objects = vim.tbl_map(vim.inspect, {...})
    print(unpack(objects))
    return ...
end

return {
    setup = setup
}
