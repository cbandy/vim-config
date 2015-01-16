if exists("b:current_syntax")
  finish
endif

syn match RSpecResultFailure '^\d\+ examples\?, [1-9]\+\d* failures\?.*'
syn match RSpecResultPending '^\d\+ examples\?, 0 failures, \d\+ pending'
syn match RSpecResultSuccess '^\d\+ examples\?, 0 failures\(, \d\+ pending\)\@!'

highlight default link RSpecResultFailure Error
highlight default RSpecResultPending ctermfg=Yellow
highlight default RSpecResultSuccess ctermfg=Green

let b:current_syntax = "rspec-result"
