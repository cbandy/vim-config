local vim = vim
local root = vim.fs.root(0, { 'go.mod', 'go.work' })

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
		vim.uv.fs_access(vim.fs.joinpath(root, '.golangci.yml'), 'r') or
		vim.uv.fs_access(vim.fs.joinpath(root, '.golangci.yaml'), 'r') or
		vim.uv.fs_access(vim.fs.joinpath(root, '.golangci.toml'), 'r') or
		vim.uv.fs_access(vim.fs.joinpath(root, '.golangci.json'), 'r')
then
	vim.b.ale_fixers = { 'goimports', 'golangci_lint' }
	vim.b.ale_linters = { 'golangci_lint' }
end

vim.api.nvim_buf_create_user_command(0, 'GoTestSum', function(details)
	local wd = details.bang and root or vim.fn.expand('%:h')
	vim.cmd.Dispatch('-dir=' .. wd, 'gotestsum', '--format-icons=default', '--watch', '--', '--count=1')
end, {
	bang = true, desc = 'have `gotestsum` watch a directory for changes',
})

-- vim-go does a great job parsing Go test errors and failures.
-- https://github.com/vim-test/vim-test/issues/617
vim.keymap.set('n', '<Leader>r', '<Plug>(go-test)', { buffer = true, silent = true })
vim.keymap.set('n', '<Leader>R', '<Plug>(go-test-func)', { buffer = true, silent = true })

vim.iter({
	'GoInstall', 'GoPlay', 'GoReportGitHubIssue', 'GoRun',
	'GoCoverageBrowser', 'GoCoverageOverlay', 'GoLSPDebugBrowser',

	-- use ALE for linting and formatting
	'GoAsmFmtAutoSaveToggle', 'GoFmt', 'GoFmtAutoSaveToggle', 'GoImports', 'GoModFmt',
	'GoErrCheck', 'GoLint', 'GoMetaLinter', 'GoMetaLinterAutoSaveToggle', 'GoVet',

	-- these have toggle commands that suffice
	'GoCoverage', 'GoCoverageClear',
	'GoSameIds', 'GoSameIdsClear',

	-- unnecessary
	'GoDeps', 'GoDiagnostics', 'GoDrop', 'GoFiles', 'GoIfErr',
	'GoTemplateAutoCreateToggle', 'GoToggleTermCloseOnExit',
})
		:each(vim.api.nvim_del_user_command)
