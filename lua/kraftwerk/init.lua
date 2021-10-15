local orchestrator = require('kraftwerk.orchestrator')
local defaults = require('kraftwerk.defaults')
local functor = require('kraftwerk.util.functor')

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

local function define_globals()
    for key, value in pairs(defaults.globals) do
        vim.g[key] = vim.g[key] or value
    end
end

local function setup()
    define_commands()
    define_globals()
end

return {
    setup = setup
}
