" Copied from vim-force.com plugin
"   https://github.com/neowit/vim-force.com
" Author: Andrey Gavrikov 
"
if exists("b:current_syntax")
	unlet b:current_syntax
endif
runtime! syntax/html.vim

" higihlight web component tags as html tags
syn match htmlTagName "\<\([a-z]\+[A-Za-z]*\(-[a-z]\+[A-Za-z]*\)*\)" contained
"syn match htmlTagName "\(lightning\|ltng\)-[a-z]\+[A-Za-z]*" contained


