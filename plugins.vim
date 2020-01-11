set nocompatible
call plug#begin(fnamemodify(resolve(expand('$MYVIMRC')),':p:h').'/plugged')

Plug 'airblade/vim-gitgutter'
"Plug 'astashov/vim-ruby-debugger'
Plug 'chrisbra/unicode.vim'
Plug 'chriskempson/base16-vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'fatih/vim-go', { 'tag': '*', 'do': ':GoInstallBinaries' }
"Plug 'jistr/vim-nerdtree-tabs'
Plug 'rking/ag.vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-dadbod'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-pathogen'
Plug 'tpope/vim-surround'
"Plug 'OrangeT/vim-csharp'

call plug#end()

silent! execute pathogen#infect()
