local functor = require('kraftwerk.util.functor')
local json = require('kraftwerk.util.json')
local config = require('kraftwerk.config')

local function user()
    local alias_config_path = vim.fn.expand(config.get('sfdx_alias_config'))
    local alias_file_contents = table.concat(vim.fn.readfile(alias_config_path))
    local alias_definitions = json.decode(alias_file_contents)
    if not functor.has_key(alias_definitions, 'orgs') then
        return {}
    end
    return functor.keys(alias_definitions.orgs)
end

return {
    user = user
}
