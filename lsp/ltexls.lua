-- https://ltex-plus.github.io/ltex-plus

local vim = vim

return {
	-- https://ltex-plus.github.io/ltex-plus/ltex-ls-plus/server-usage.html
	cmd = { vim.fs.joinpath(vim.env.HOME, '.local', 'ltex-ls-plus', 'bin', 'ltex-ls-plus') },
	cmd_env = {},
	filetypes = { 'asciidoc', 'gitcommit', 'html', 'markdown', 'mdx', 'rst', 'text', 'xhtml' },

	get_language_id = function(_, filetype)
		return require('local').vscode_language(filetype)
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
