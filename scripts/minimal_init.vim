set rtp+=.
set rtp+=~/.config/nvim/bundle/plenary.nvim
runtime! ~/.config/nvim/bundle/plenary.nvim
lua require("kraftwerk.init").setup()
