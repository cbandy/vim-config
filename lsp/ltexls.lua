-- https://ltex-plus.github.io/ltex-plus

local vim = vim

---@type vim.lsp.Config
return {
	-- https://ltex-plus.github.io/ltex-plus/ltex-ls-plus/server-usage.html
	cmd = { vim.env.LTEX_LS_PLUS or 'ltex-ls-plus' },
	-- Disable an AArch64 extension due to a bug in Java and macOS.
	-- https://bugs.openjdk.org/browse/JDK-8345296
	-- https://stackoverflow.com/a/79461774
	cmd_env = { JAVA_OPTS = '-XX:UseSVE=0' },
	filetypes = { 'asciidoc', 'gitcommit', 'html', 'markdown', 'mdx', 'rst', 'text', 'xhtml' },

	-- https://ltex-plus.github.io/ltex-plus/supported-languages.html
	get_language_id = function(_, filetype)
		return ({
			gitcommit = 'plaintext',
		})[filetype] or require('local').vscode_language(filetype)
	end,

	-- https://ltex-plus.github.io/ltex-plus/settings.html
	settings = {
		ltex = {
			enabled = true,
			java = {
				initialHeapSize = 64,
				maximumHeapSize = 1024,
			},

			language = 'en-US',
			dictionary = {
				['en-US'] = require('local').spellfile_good_words('en'):totable(),
			},
		}
	},
}
