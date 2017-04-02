source ~/.vim/plugins.vim

augroup indentation
 autocmd!
 autocmd FileType cucumber   setlocal expandtab shiftwidth=2 tabstop=2
 autocmd FileType javascript setlocal expandtab shiftwidth=2 tabstop=2
 autocmd FileType go   setlocal shiftwidth=2 tabstop=2
 autocmd FileType php  setlocal shiftwidth=4 tabstop=4
 autocmd FileType ruby setlocal expandtab shiftwidth=2 tabstop=2
 autocmd FileType sql  setlocal expandtab shiftwidth=2 tabstop=2
 autocmd FileType yaml setlocal expandtab shiftwidth=2 tabstop=2
augroup END

augroup spellcheck
 autocmd!
 autocmd FileType gitcommit setlocal spell
 autocmd FileType markdown setlocal spell
 autocmd Syntax rspec setlocal spell
augroup END

augroup whitespace
 autocmd!
 autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
 autocmd FileType markdown setlocal list listchars=trail:·
 autocmd FileType sql syn match ExtraWhitespace /\s\+\%#\@<!$\| \+\ze\t/ containedin=ALL
augroup END

let c_space_errors = 1
let go_fmt_command = 'goimports'
let go_fmt_fail_silently = 1
let php_space_errors = 1
let ruby_space_errors = 1
let sql_type_default = 'pgsql'
let xml_syntax_folding = 1

set modeline modelines=3
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
nmap <Leader>r :call RunTestFile(expand('%:.'))<CR>
nmap <Leader>R :call RunTestFile(expand('%:.'), line('.'))<CR>

"nmap <C-j> <Plug>(go-info)

function! s:RunInSplitWindow(type, cmd)
 let winnr = bufwinnr('^' . a:type . '$')
 silent! execute winnr < 0 ? 'botright new ' . a:type : winnr . 'wincmd w'
 setlocal bufhidden=wipe buftype=nofile modifiable nobuflisted noswapfile
 silent! execute 'setlocal filetype=' . a:type
 silent! execute 'silent %!' . join(map(split(a:cmd), 'expand(v:val)'))
 silent! execute '%substitute/^.*\r//e | :1'
 silent! execute 'resize ' . line('$')
 silent! execute 'nnoremap <silent> <buffer> q :q!<CR>'
 setlocal nomodifiable
endfunction

function! RunTestFile(file, ...)
 let file = a:file
 let line = a:0 > 0 ? a:1 : 0

 if match(file, '[.]feature$') != -1
  call s:RunInSplitWindow('cucumber-result',
   \ 'cucumber ' . (line > 0 ? '-f pretty ' . file . ':' . line : '-f progress ' . file))

 elseif match(file, '[.]go$') != -1
  call s:RunInSplitWindow('go-test-result',
   \ 'go test '
   \ . (file == expand('%:.') ? expand('%:.:h:s#^[.]\@!#./#') : file)
   \ . (line > 0 ? ' -v -run "^' . matchstr(getline(search('^func Test', 'bcnW')), 'Test[a-zA-Z0-9_]*') . '$"' : ''))

 elseif match(file, '[Tt]est[.]php$') != -1
  call s:RunInSplitWindow('',
   \ 'phpunit ' . file)

 elseif match(file, '[Ss]pec[.]rb$') != -1
  call s:RunInSplitWindow('rspec-result',
   \ 'rspec ' . (line > 0 ? file . ':' . line : file))

 elseif match(file, '[.]sql$') != -1
  call s:RunInSplitWindow('pgtap-result',
   \ 'psql -Atqf ' . file)

 elseif match(file, 'test[.]sh$') != -1
  call s:RunInSplitWindow('shell-test-result',
   \ file)

 endif
endfunction
