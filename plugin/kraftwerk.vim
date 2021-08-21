if exists('g:loaded_kraftwerk') 
    finish " prevent loading file twice
endif

let s:save_cpoptions = &cpoptions " save user coptions
set cpoptions&vim " reset them to defaults

lua require("kraftwerk.init").setup()

let &cpoptions = s:save_cpoptions " restore user coptions
unlet s:save_cpoptions
let g:loaded_kraftwerk = 1
