-- https://github.com/standardrb/standard

---@type vim.lsp.Config
return {
	cmd = { 'bundle', 'exec', 'standardrb', '--lsp' },
	filetypes = { 'ruby' },
	root_markers = { 'Gemfile' },
}
