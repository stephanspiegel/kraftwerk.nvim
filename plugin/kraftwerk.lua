if vim.g.loaded_kraftwerk == 1 then
  return --[[ prevent loading file twice ]]
end
vim.g.loaded_kraftwerk = 1

-- save user cpoptions
local user_cpoptions =  vim.api.nvim_get_option_value('cpoptions', {})
local default_cpoptions = vim.api.nvim_get_option_info('cpoptions').default
-- set the default cpoptions
vim.api.nvim_set_option_value('cpoptions', default_cpoptions, {})

-- call setup for our plugin
require("kraftwerk.init").setup()

-- restore user cpoptions
vim.api.nvim_set_option_value('cpoptions', user_cpoptions, {})
