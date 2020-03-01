let g:ansible_template_syntaxes = {'*.json.j2': 'json', '*.sh.j2': 'sh', '*.yaml.j2': 'yaml'}
let g:c_space_errors = 1
let g:dispatch_compilers = {'bundle exec': ''}
let g:go_fmt_command = 'goimports'
let g:go_fmt_fail_silently = 1
let g:NERDTreeDirArrowCollapsible = '~'
let g:NERDTreeDirArrowExpandable  = '+'
let g:pgsql_pl = ['python', 'r', 'ruby']
let g:php_space_errors = 1
let g:polyglot_disabled = ['go', 'yaml']
let g:ruby_space_errors = 1
let g:sh_fold_enabled = 7 " function, heredoc, and control folding
let g:sql_type_default = 'pgsql'
let g:xml_syntax_folding = 1

execute 'source '.fnamemodify(resolve(expand('$MYVIMRC')),':p:h').'/plugins.vim'

augroup mine
 autocmd!

 " Dispatch
 autocmd FileType cucumber |
  \ let b:dispatch = 'cucumber %'
  \ . ':s/^/\=exists("l#") ? "-f pretty " : "-f progress "/'
  \ . ':s/$/\=exists("l#") ? ":".l# : ""/'
 autocmd FileType go |
  \ let b:dispatch = 'go test %'
  \ . ':.:h:s#^[.]\@!#./#'
  \ . ':s/$/\=exists("l#") ? " -v -run ''^".matchstr(getline(search("^func Test", "bcnW")), "Test[a-zA-Z0-9_]*")."$''" : ""/'
 autocmd FileType php |
  \ if expand('%') =~# '[Tt]est[.]php$' |
  \  let b:dispatch = 'phpunit %' |
  \ endif
 autocmd FileType python |
  \ let b:dispatch = 'pytest %'
 autocmd Syntax rspec |
  \ let b:dispatch = 'rspec %'
  \ . ':s/$/\=exists("l#") ? ":".l# : ""/'
 autocmd FileType sh |
  \ if expand('%') =~# 'test[.]sh$' |
  \  let b:dispatch = '%:s#^#./#'
  \  . ':s/$/\=exists("l#") ? " -- ''".matchstr(getline(search("^test", "bcnW")), "test[a-zA-Z0-9_]*")."''" : ""/' |
  \ endif
 autocmd FileType sql |
  \ let b:dispatch = 'psql -Atqf %'

 " Indentation
 autocmd FileType cucumber    setlocal expandtab shiftwidth=2 tabstop=2
 autocmd FileType javascript  setlocal expandtab shiftwidth=2 tabstop=2
 autocmd FileType python      setlocal expandtab shiftwidth=4 tabstop=4
 autocmd FileType go          setlocal           shiftwidth=2 tabstop=2
 autocmd FileType php         setlocal           shiftwidth=4 tabstop=4
 autocmd FileType ruby        setlocal expandtab shiftwidth=2 tabstop=2
 autocmd FileType sh,sh.*     setlocal           shiftwidth=0 tabstop=4
 autocmd FileType sql         setlocal expandtab shiftwidth=2 tabstop=2
 autocmd FileType yaml,yaml.* setlocal expandtab shiftwidth=2 tabstop=2

 " https://git.postgresql.org/gitweb/?p=postgresql.git;a=blob;f=src/tools/editors/vim.samples
 autocmd BufNewFile,BufRead $HOME/postgresql/*.[ch] setlocal cindent cinoptions=(0 shiftwidth=4 tabstop=4

 " Spelling
 autocmd FileType gitcommit setlocal spell
 autocmd FileType markdown setlocal spell
 autocmd Syntax rspec setlocal spell

 " Whitespace
 autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
 autocmd FileType markdown setlocal list listchars=trail:·
 autocmd FileType sh,sh.* syn match ExtraWhitespace /\s\+$/
 autocmd FileType sql syn match ExtraWhitespace /\s\+\%#\@<!$\| \+\ze\t/ containedin=ALL
 autocmd FileType yaml,yaml.* setlocal list listchars=trail:·
augroup END

set modeline modelines=3
set number
set relativenumber
set ruler
set spellfile=~/.vim/spell/en.utf-8.add
set switchbuf=useopen
set updatetime=1000

if &t_Co == 256
 set termguicolors
 colorscheme base16-tomorrow-night
endif

let mapleader = ","
nmap <Leader>nt :NERDTreeToggle<CR>
nnoremap <Leader>r :Dispatch<CR>
nnoremap <Leader>R :.Dispatch<CR>

"nmap <C-j> <Plug>(go-info)
