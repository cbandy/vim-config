source ~/.vim/bundles.vim

let c_space_errors = 1
let php_space_errors = 1
let ruby_space_errors = 1

set modelines=3
set number
set relativenumber
set ruler
set spellfile=~/.vim/spell/en.utf-8.add
set switchbuf=useopen

if &t_Co == 256
 colorscheme Tomorrow-Night-Bright
endif
