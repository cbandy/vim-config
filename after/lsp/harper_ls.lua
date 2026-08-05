-- https://writewithharper.com/docs/integrations/language-server
-- https://writewithharper.com/docs/integrations/neovim

---@type vim.lsp.Config
return {
	cmd = { 'nice', 'harper-ls', '--stdio' },
	filetypes = { 'asciidoc', 'gitcommit', 'go', 'html', 'lua', 'markdown', 'python', 'ruby', 'rust', 'text', 'toml' },
	root_markers = { '.git', '.harper-dictionary.txt' },

	-- https://writewithharper.com/docs/integrations/language-server#Configuration
	settings = {
		['harper-ls'] = {
			diagnosticSeverity = 'hint',
			dialect = 'American',

			-- https://writewithharper.com/docs/rules
			linters = {},
		},
	},
}
