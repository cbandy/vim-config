-- https://github.com/luals/lua-language-server#readme

local vim = vim

return {
	cmd = { vim.fs.joinpath(vim.env.HOME, '.local', 'luals', 'bin', 'lua-language-server') },
	filetypes = { 'lua' },

	-- https://luals.github.io/wiki/settings
	settings = {
		Lua = {
			-- https://luals.github.io/wiki/diagnostics
			['diagnostics.disable'] = {},
			['diagnostics.globals'] = {},
		}
	},
}
