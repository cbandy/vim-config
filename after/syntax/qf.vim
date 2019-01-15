" Cucumber
syn match CucumberResultFailure '\(^|| \)\@<=Failing Scenarios:'
syn match CucumberResultFailure '\(^|| \)\@<=\d\+ \(scenario\|step\)s\? (\d\+ failed.*'
syn match CucumberResultPending '\(^|| \)\@<=\d\+ \(scenario\|step\)s\? (\d\+ \(skipped, \d\+ \)\?\(pending\|undefined\).*'
syn match CucumberResultSuccess '\(^|| \)\@<=\d\+ \(scenario\|step\)s\? (\d\+ passed)'

highlight default link CucumberResultFailure Error
highlight default CucumberResultPending ctermfg=Yellow
highlight default CucumberResultSuccess ctermfg=Green

" Go Test
syn match GoTestResultFailure '\(^|| --- \)\@<=FAIL:\@='
syn match GoTestResultFailure '\(^|| \)\@<=FAIL\t\@='
syn match GoTestResultSuccess '\(^|| \)\@<=ok\t\@='

highlight default link GoTestResultFailure Error
highlight default GoTestResultSuccess ctermfg=Green

" RSpec
syn match RSpecResultFailure '\(^|| \)\@<=\d\+ examples\?, [1-9]\+\d* failures\?.*'
syn match RSpecResultPending '\(^|| \)\@<=\d\+ examples\?, 0 failures, \d\+ pending'
syn match RSpecResultSuccess '\(^|| \)\@<=\d\+ examples\?, 0 failures\(, \d\+ pending\)\@!'

highlight default link RSpecResultFailure Error
highlight default RSpecResultPending ctermfg=Yellow
highlight default RSpecResultSuccess ctermfg=Green

" shUnit2
syn match shUnit2ResultFailure '\(^|| \)\@<=ASSERT\(:\)\@='
syn match shUnit2ResultFailure '\(^|| \)\@<=FAILED\( (failures=\d\+)$\)\@='
syn match shUnit2ResultSuccess '\(^|| \)\@<=OK$'

highlight default link shUnit2ResultFailure Error
highlight default shUnit2ResultSuccess ctermfg=Green

" Test Anything Protocol
syn match TAPResultFailure '\(^|| \)\@<=not ok\>'
syn match TAPResultSuccess '\(^|| \)\@<=ok\>'

highlight default link TAPResultFailure Error
highlight default TAPResultSuccess ctermfg=Green
