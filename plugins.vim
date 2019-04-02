set nocompatible
call plug#begin(fnamemodify(resolve(expand('$MYVIMRC')),':p:h').'/plugged')

Plug 'airblade/vim-gitgutter'
"Plug 'astashov/vim-ruby-debugger'
Plug 'chriskempson/base16-vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'elzr/vim-json'
Plug 'fatih/vim-go', { 'tag': '*', 'do': ':GoInstallBinaries' }
"Plug 'jistr/vim-nerdtree-tabs'
Plug 'juvenn/mustache.vim'
Plug 'leafgarland/typescript-vim'
Plug 'lifepillar/pgsql.vim'
Plug 'rking/ag.vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'tpope/vim-dadbod'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-pathogen'
Plug 'tpope/vim-surround'
Plug 'vim-ruby/vim-ruby'
Plug 'keith/rspec.vim'
"Plug 'OrangeT/vim-csharp'

call plug#end()

silent! execute pathogen#infect()
