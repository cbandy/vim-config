local vim = vim

-- https://rust-analyzer.github.io/book/other_editors.html#vimneovim
require('lspconfig').rust_analyzer.setup({
	settings = {
		['rust-analyzer'] = {
			cargo = {
				buildScripts = { enable = true },
			},
			imports = {
				granularity = { group = 'module' },
				prefix = 'self',
			},
			procMacro = { enable = true },
		}
	},

	on_attach = function(client, bufnr)
		require('completion').on_attach(client)

		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end,
})
