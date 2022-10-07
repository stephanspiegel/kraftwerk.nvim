local functor = require('kraftwerk.util.functor')
local default_config = require('kraftwerk.defaults')

local final_config = {}
local is_setup_done = false

local setup = function(user_config)
    if is_setup_done then return end
    user_config = user_config or {}
    for key, value in pairs(default_config) do
        if functor.has_key(user_config, key) then
            final_config[key] = user_config[key]
        else
            final_config[key] = value.value
        end
    end
    is_setup_done = true
end

local get = function(key)
    if not functor.has_key(final_config, key) then
        vim.notify('kraftwerk: key not found in config: '..key)
    end
    return final_config[key]
end

return {
    setup = setup,
    get = get,
}
