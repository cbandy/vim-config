set nocompatible
filetype on	" Workaround for OS X, https://github.com/gmarik/Vundle.vim/wiki#mac
filetype off

set rtp+=~/.vim/bundle/Vundle.vim/
call vundle#begin()

Plugin 'gmarik/Vundle.vim'

Plugin 'airblade/vim-gitgutter'
"Plugin 'astashov/vim-ruby-debugger'
Plugin 'chriskempson/vim-tomorrow-theme'
Plugin 'elzr/vim-json'
Plugin 'exu/pgsql.vim'
Plugin 'fatih/vim-go'
"Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'juvenn/mustache.vim'
Plugin 'kien/ctrlp.vim'
Plugin 'rking/ag.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'tpope/vim-endwise'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-surround'
Plugin 'vim-ruby/vim-ruby'
Plugin 'Keithbsmiley/rspec.vim'
"Plugin 'OrangeT/vim-csharp'

call vundle#end()
filetype plugin indent on
