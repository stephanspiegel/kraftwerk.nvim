local orchestrator = require('kraftwerk.orchestrator')

_G.kraftwerk = {
    command_completion = {}
}

local function define_commands()
    orchestrator.register('data', 'query')
    orchestrator.register('source', 'push')
    orchestrator.register('apex', 'testrun')
    orchestrator.register('apex', 'execute')
end

local function define_globals()
    vim.g.kraftwerk_sfdx_alias_config = '$HOME/.sfdx/alias.json'
end

local function setup()
    define_commands()
    define_globals()
end

return {
    setup = setup
}
