local vim = vim
local root = vim.fs.root(0, { 'go.mod', 'go.work' }) or vim.fn.getcwd()

vim.opt_local.tabstop = 2
vim.opt_local.formatoptions:append({
	-- continue comments when hitting <Enter> in Insert mode [:help fo-r]
	r = true,
	-- continue comments when appending lines in Normal mode [:help fo-o]
	o = true,
})

-- use tree-sitter
require('local').treesitter_enable({ 'folds', highlighting = false })

-- format on save, and use golangci-lint only if it is configured
vim.b.ale_fix_on_save = true
if
		vim.uv.fs_stat(vim.fs.joinpath(root, '.golangci.yml')) or
		vim.uv.fs_stat(vim.fs.joinpath(root, '.golangci.yaml')) or
		vim.uv.fs_stat(vim.fs.joinpath(root, '.golangci.toml')) or
		vim.uv.fs_stat(vim.fs.joinpath(root, '.golangci.json'))
then
	vim.b.ale_fixers = { 'goimports', 'golangci_lint' }
	vim.b.ale_linters = { 'golangci_lint' }
end

vim.api.nvim_buf_create_user_command(0, 'GoTestSum', function(details)
	local wd = details.bang and root or vim.fn.expand('%:p:h')
	vim.cmd.Dispatch('-dir=' .. wd, 'gotestsum', '--format-icons=default', '--watch', '--', '--count=1')
end, {
	bang = true, desc = 'have `gotestsum` watch a directory for changes',
})

vim.keymap.set('n', '<Leader>r', function()
	-- use "-dir" with "dispatch.vim" to populate the quickfix list with proper paths.
	-- https://github.com/vim-test/vim-test/issues/617
	vim.cmd.Dispatch('-dir=' .. vim.fn.expand('%:p:h'), vim.env.GO or 'go', 'test', '.')
end, {
	buffer = true,
	desc = 'run all tests in this package',
})

vim.keymap.set('n', '<Leader>R', function()
	-- use "test.vim" to find the nearest test function, suite, etc.
	-- the first item in the returned list is the "-run" flag and value.
	local cursor = vim.api.nvim_win_get_cursor(0)
	local position = { file = vim.fn.expand('%:p'), line = cursor[1], col = cursor[2] }
	local args = vim.fn['test#go#gotest#build_position']('nearest', position)

	-- use "-dir" with "dispatch.vim" to populate the quickfix list with proper paths.
	-- https://github.com/vim-test/vim-test/issues/617
	vim.cmd.Dispatch('-dir=' .. vim.fn.expand('%:p:h'), vim.env.GO or 'go', 'test', args[1], '.')
end, {
	buffer = true,
	desc = 'run the nearest test',
})
