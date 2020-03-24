" A local copy until Neovim has https://github.com/vim/vim/commit/560979ed4f0216f902a2c247e937f00a27dcb198
" A local copy until Neovim has https://github.com/vim/vim/commit/ebdf3c964a901fc00c9009689f7cfda478342c51

if exists("b:current_syntax")
    finish
endif

syntax include @JSON syntax/json.vim
unlet b:current_syntax

syntax include @Shell syntax/sh.vim
unlet b:current_syntax

syntax case ignore
syntax match dockerfileLinePrefix /\v^\s*(ONBUILD\s+)?\ze\S/ contains=dockerfileKeyword nextgroup=dockerfileInstruction skipwhite
syntax region dockerfileFrom matchgroup=dockerfileKeyword start=/\v^\s*(FROM)\ze(\s|$)/ skip=/\v\\\_./ end=/\v((^|\s)AS(\s|$)|$)/ contains=dockerfileOption

syntax keyword dockerfileKeyword contained ADD ARG CMD COPY ENTRYPOINT ENV EXPOSE HEALTHCHECK LABEL MAINTAINER ONBUILD RUN SHELL STOPSIGNAL USER VOLUME WORKDIR
syntax match dockerfileOption contained /\v(^|\s)\zs--\S+/

syntax match dockerfileInstruction contained /\v<(\S+)>(\s+--\S+)*/             contains=dockerfileKeyword,dockerfileOption skipwhite nextgroup=dockerfileValue
syntax match dockerfileInstruction contained /\v<(ADD|COPY)>(\s+--\S+)*/        contains=dockerfileKeyword,dockerfileOption skipwhite nextgroup=dockerfileJSON
syntax match dockerfileInstruction contained /\v<(HEALTHCHECK)>(\s+--\S+)*/     contains=dockerfileKeyword,dockerfileOption skipwhite nextgroup=dockerfileInstruction
syntax match dockerfileInstruction contained /\v<(CMD|ENTRYPOINT|RUN)>/         contains=dockerfileKeyword skipwhite nextgroup=dockerfileShell
syntax match dockerfileInstruction contained /\v<(CMD|ENTRYPOINT|RUN)>\ze\s+\[/ contains=dockerfileKeyword skipwhite nextgroup=dockerfileJSON
syntax match dockerfileInstruction contained /\v<(SHELL|VOLUME)>/               contains=dockerfileKeyword skipwhite nextgroup=dockerfileJSON

syntax region dockerfileString contained start=/\v"/ skip=/\v\\./ end=/\v"/
syntax region dockerfileJSON   contained keepend start=/\v\[/ skip=/\v\\\_./ end=/\v$/ contains=@JSON
syntax region dockerfileShell  contained keepend start=/\v/ skip=/\v\\\_./ end=/\v$/ contains=@Shell
syntax region dockerfileValue  contained keepend start=/\v/ skip=/\v\\\_./ end=/\v$/ contains=dockerfileString

syntax region dockerfileComment start=/\v^\s*#/ end=/\v$/
set commentstring=#\ %s

hi def link dockerfileString String
hi def link dockerfileKeyword Keyword
hi def link dockerfileComment Comment
hi def link dockerfileOption Special

let b:current_syntax = "dockerfile"
