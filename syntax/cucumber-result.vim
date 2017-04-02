if exists("b:current_syntax")
 finish
endif

syn match CucumberResultFailure '^Failing Scenarios:'
syn match CucumberResultFailure '^\d\+ \(scenario\|step\)s\? (\d\+ failed.*'
syn match CucumberResultPending '^\d\+ \(scenario\|step\)s\? (\d\+ \(skipped, \d\+ \)\?\(pending\|undefined\).*'
syn match CucumberResultSuccess '^\d\+ \(scenario\|step\)s\? (\d\+ passed)'

highlight default link CucumberResultFailure Error
highlight default CucumberResultPending ctermfg=Yellow
highlight default CucumberResultSuccess ctermfg=Green

let b:current_syntax = "cucumber-result"
