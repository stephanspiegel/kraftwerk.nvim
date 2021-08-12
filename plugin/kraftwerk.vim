if exists('g:loaded_kraftwerk') 
    finish " prevent loading file twice
endif

let s:save_cpoptions = &cpoptions " save user coptions
set cpoptions&vim " reset them to defaults

" Convenience command for development of this plugin
command! ReloadKraftwerk call Reload()

function! Reload() abort
	lua for k in pairs(package.loaded) do if k:match("^kraftwerk") then package.loaded[k] = nil end end
	lua require("kraftwerk")
    lua require("kraftwerk.init").setup()
endfunction

lua require("kraftwerk.init").setup()

let &cpoptions = s:save_cpoptions " restore user coptions
unlet s:save_cpoptions
let g:loaded_kraftwerk = 1
