-- The built-in `go` compiler has an `errorformat` that works for `go build`
-- and basic `go test` output. This `gotest` compiler is for `go test` results.
--
-- [:h error-file-format]
--
-- https://github.com/vim-test/vim-test/issues/617
-- https://github.com/fatih/vim-go/blob/v1.29/autoload/go/test.vim#L157

local indent_once = '%\\\\%(    %\\\\)'       -- one non-capturing group of four spaces
local indent_many = indent_once .. '%#'       -- repeat zero or more times
local indent_some = indent_once .. '%\\\\+'   -- repeat one or more times
local any, tab = '%.%#', '%\\\\t'             -- any number of any character
local fileline = '%\\\\f%\\\\+:%*\\\\d'       -- non-capturing file-like characters and line number
local goroot = require('local').go.env.GOROOT -- TODO: fallback

vim.opt_local.makeprg = 'go test'
vim.opt_local.errorformat = '' ..

		-- match failed tests; ignore passing and skipped tests
		'%-G' .. indent_many .. '--- %\\\\%(PASS%\\\\|SKIP%\\\\): ' .. any ..
		',%G' .. indent_many .. '--- %m' ..

		-- match running tests to attribute logs and errors in verbose mode
		',%-G=== %\\\\%(PAUSE%\\\\|CONT %\\\\) ' .. any ..
		',%G=== %m' .. -- `=== RUN `

		-- match verbose multi-line log messages; these have the file and line between colons
		',%A' .. indent_some .. '%[^:]%\\\\+: %f:%l: %m' ..
		',%A' .. indent_some .. '%[^:]%\\\\+: %f:%l: ' ..

		-- match multi-line log messages; use %G to kinda preserve newlines
		',%A' .. indent_some .. '%f:%l: %m' ..
		',%A' .. indent_some .. '%f:%l: ' ..
		',%G' .. indent_once .. indent_some .. '%m' ..

		-- match panics; capture the first address outside stdlib and ignore the rest
		',%+Gpanic: test timed out ' .. any .. ',%+Grunning tests:,%+Apanic: ' .. any ..
		',%-Cgoroutine %*\\\\d [running]:,%-C' .. tab .. goroot .. fileline .. ' +0x%*\\\\x' ..
		',%Z' .. tab .. '%f:%l +0x%*\\\\x,%-G' .. tab .. fileline .. ' +0x%*\\\\x' ..
		',%-Cexit status %*\\\\d,%-CFAIL' .. tab .. any ..

		-- match multi-line compile errors; use %G to kinda preserve newlines
		',%A%f:%l:%c: %m,%A%f:%l: %m,%-C' .. tab .. 'panic: ' .. any .. ',%G' .. tab .. '%m' ..

		-- ignore everything else
		',%-C' .. any .. ',%-G' .. any
