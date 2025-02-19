" vim: expandtab shiftwidth=0 tabstop=1 :
" Get the absolute path to the configuration directory.
let s:dir = fnamemodify(resolve(expand('$MYVIMRC')),':p:h')

" Disable some built-in Vim features and plugins.
execute 'source '.s:dir.'/globals.vim'

" Describe some plugins, but do not assume they are installed.
call plug#begin(s:dir.'/plugged')
 Plug 'https://git::@github.com/chriskempson/base16-vim.git'
call plug#end()

" The Vim default color scheme is difficult to read.
" Use another scheme when the terminal supports modern colors.
if &t_Co == 256 || &termguicolors
 " Assume that a terminal reporting support for 256 colors can do more.
 set termguicolors

 " vim-plug does not emit User events for plugins that lack a 'plugin'
 " directory. Search for the 'base16-vim' schemes instead.
 if len(globpath(&runtimepath, 'colors/base16-tomorrow-night.vim', 0, 1))
  colorscheme base16-tomorrow-night
 else
  colorscheme evening
 endif
endif

set number
set relativenumber
set ruler
set shiftwidth=0 " Follow 'tabstop'
