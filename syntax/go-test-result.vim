if exists("b:current_syntax")
 finish
endif

syn match GoTestResultFailure '\(^--- \)\@<=FAIL:\@='
syn match GoTestResultFailure '^FAIL\t\@='
syn match GoTestResultSuccess '^ok'

highlight default link GoTestResultFailure Error
highlight default GoTestResultSuccess ctermfg=Green

let b:current_syntax = "go-test-result"
