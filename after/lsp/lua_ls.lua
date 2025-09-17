-- https://github.com/luals/lua-language-server#readme

local vim = vim

---@type vim.lsp.Config
return {
	cmd = { vim.env.LUA_LS or 'lua-language-server' },
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
