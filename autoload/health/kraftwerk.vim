function! health#kraftwerk#check() abort
    lua require("kraftwerk.system").check_health()
endfunction

