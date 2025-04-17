local vim = vim
local module = vim.fs.root(0, { 'go.mod', 'go.work' })
local project = vim.fs.root(0, '.git') or vim.fn.getcwd()

vim.opt_local.tabstop = 2
vim.opt_local.formatoptions:append({
	-- continue comments when hitting <Enter> in Insert mode [:help fo-r]
	r = true,
	-- continue comments when appending lines in Normal mode [:help fo-o]
	o = true,
})

-- gopls formats on save, but also use golangci-lint when it is configured
if
		vim.iter({ module, project, }):any(function(dir)
			return vim.iter({
				'.golangci.yml', '.golangci.yaml', '.golangci.toml', '.golangci.json',
			}):any(function(name)
				return nil ~= vim.uv.fs_stat(vim.fs.joinpath(dir, name))
			end)
		end)
then
	-- https://github.com/dense-analysis/ale/issues/4951
	vim.b.ale_fix_on_save = false
	vim.b.ale_fixers = { 'golangci_lint' }
	vim.b.ale_linters = { 'golangci_lint' }
end

vim.api.nvim_buf_create_user_command(0, 'GoTestSum', function(details)
	local wd = details.bang and (module or project) or vim.fn.expand('%:p:h')
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
