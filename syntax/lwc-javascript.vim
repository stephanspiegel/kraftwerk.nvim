" Copied from vim-force.com plugin
"   https://github.com/neowit/vim-force.com
" Author: Andrey Gavrikov 
"
if exists("b:current_syntax")
	unlet b:current_syntax
endif
runtime! syntax/javascript.vim

" exta highlighting for LWC specific keywords
syn match PreProc "@\(api\|track\)\>"
syn match javaScriptStatement "\<\(get\|set\)\>"

