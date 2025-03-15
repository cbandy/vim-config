local vim = vim

vim.opt_local.tabstop = 2
vim.opt_local.formatoptions:append({
	-- continue comments when hitting <Enter> in Insert mode [:help fo-r]
	r = true,
	-- continue comments when appending lines in Normal mode [:help fo-o]
	o = true,
})

-- [:help b:dispatch]
vim.b.dispatch = 'go test %' ..
	-- Get the directory of the relative file path then prepend ./ if it does not already start with dot.
	[[:.:h:s#^[.]\@!#./#]] ..
	-- The variable "l#" evaluates to the line number (range) invoked on :Dispatch.
	-- See: https://www.github.com/tpope/vim-dispatch/commit/1e9bd0cdbe6975916fa4
	--
	-- Append the test name when focused.
	-- search()
	--   "b" backward "n" without moving the cursor,
	--   "W" stop at the beginning of the file, and
	--   "c" allow a match on the current line
	-- matchstr() to grab the entire function name, and
	-- pass it to "-run" with anchors at both ends
	[[:s/$/\=exists("l#") ? " -v -run ''^".matchstr(getline(search("^func Test", "bcnW")), "Test[a-zA-Z0-9_]*")."$''" : ""/]]

vim.api.nvim_buf_create_user_command(0,
	'GoTestSum', ':Dispatch gotestsum --watch --format-icons=default -- --count=1', {
		desc = 'Have `gotestsum` watch the entire project for changes',
	})
vim.keymap.set('n', '<Leader>r', '<Plug>(go-diagnostics)', { buffer = true })
vim.keymap.set('n', '<Leader>R', ':GoTest!<CR>', { buffer = true })
vim.keymap.set('n', '<Leader>T', ':GoTestFunc!<CR>', { buffer = true })
