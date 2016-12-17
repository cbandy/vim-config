if exists("b:current_syntax")
 finish
endif

syn match PgTAPFailure '^not ok'
syn match PgTAPSuccess '^ok'

highlight default link PgTAPFailure Error
highlight default PgTAPSuccess ctermfg=Green

let b:current_syntax = "pgtap-result"
