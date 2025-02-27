" Cucumber
syntax match CucumberResultFailure '\(^|| \)\@<=Failing Scenarios:'
syntax match CucumberResultFailure '\(^|| \)\@<=\d\+ \(scenario\|step\)s\? (\d\+ failed.*'
syntax match CucumberResultPending '\(^|| \)\@<=\d\+ \(scenario\|step\)s\? (\d\+ \(skipped, \d\+ \)\?\(pending\|undefined\).*'
syntax match CucumberResultSuccess '\(^|| \)\@<=\d\+ \(scenario\|step\)s\? (\d\+ passed)'

highlight default link CucumberResultFailure DiagnosticError
highlight default link CucumberResultPending DiagnosticWarn
highlight default link CucumberResultSuccess DiagnosticOk

" Go Test
syntax match GoTestResultFailure '\(^||\s\{} --- \)\@<=FAIL:\@='
syntax match GoTestResultFailure '\(^|| \)\@<=FAIL\s\@='
syntax match GoTestResultSuccess '\(^|| \)\@<=ok\s\@='

highlight default link GoTestResultFailure DiagnosticError
highlight default link GoTestResultSuccess DiagnosticOk

" RSpec
syntax match RSpecResultFailure '\(^|| \)\@<=\d\+ examples\?, [1-9]\+\d* failures\?.*'
syntax match RSpecResultPending '\(^|| \)\@<=\d\+ examples\?, 0 failures, \d\+ pending'
syntax match RSpecResultSuccess '\(^|| \)\@<=\d\+ examples\?, 0 failures\(, \d\+ pending\)\@!'

highlight default link RSpecResultFailure DiagnosticError
highlight default link RSpecResultPending DiagnosticWarn
highlight default link RSpecResultSuccess DiagnosticOk

" shUnit2
syntax match shUnit2ResultFailure '\(^|| \)\@<=ASSERT\(:\)\@='
syntax match shUnit2ResultFailure '\(^|| \)\@<=FAILED\( (failures=\d\+)$\)\@='
syntax match shUnit2ResultSuccess '\(^|| \)\@<=OK$'

highlight default link shUnit2ResultFailure DiagnosticError
highlight default link shUnit2ResultSuccess DiagnosticOk

" Test Anything Protocol
syntax match TAPResultFailure '\(^|| \)\@<=not ok\>'
syntax match TAPResultSuccess '\(^|| \)\@<=ok\>'

highlight default link TAPResultFailure DiagnosticError
highlight default link TAPResultSuccess DiagnosticOk
