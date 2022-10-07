local orchestrator = require('kraftwerk.orchestrator')
local functor = require('kraftwerk.util.functor')
local config = require('kraftwerk.config')

_G.kraftwerk = {
    command_completion = {}
}

local commands = {
    -- module, command name
    {'apex', 'execute'},
    {'apex', 'testrun'},
    {'apex', 'unstack'},
    {'data', 'query'},
    {'source', 'push'},
}

local function define_commands()
    functor.map(orchestrator.register, commands)
end

local function setup(user_config)
    define_commands()
    config.setup(user_config)
end

return {
    setup = setup
}
