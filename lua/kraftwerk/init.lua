local orchestrator = require('kraftwerk.orchestrator')

local function define_commands()
    orchestrator.register('data', 'query')
    orchestrator.register('source', 'push')
end

local function setup()
    define_commands()
end

return {
    setup = setup
}
