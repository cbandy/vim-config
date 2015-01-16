source ~/.vim/bundles.vim

augroup indentation
 autocmd!
 autocmd FileType go setlocal shiftwidth=2 tabstop=2
 autocmd FileType php setlocal shiftwidth=4 tabstop=4
 autocmd FileType ruby setlocal expandtab shiftwidth=2 tabstop=2
 autocmd FileType yaml setlocal expandtab shiftwidth=2 tabstop=2
augroup END

augroup spellcheck
 autocmd!
 autocmd FileType gitcommit setlocal spell
 autocmd FileType markdown setlocal spell
 autocmd Syntax rspec setlocal spell
augroup END

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

let mapleader = ","
nmap <Leader>nt :NERDTreeToggle<CR>
