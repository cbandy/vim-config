-- https://sorbet.org

---@type vim.lsp.Config
return {
	cmd = { 'nice', 'bundle', 'exec', 'srb', 'tc', '--disable-watchman', '--lsp' },
	filetypes = { 'ruby' },
	root_markers = { 'Gemfile' },
}
