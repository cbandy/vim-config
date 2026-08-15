-- https://github.com/luals/lua-language-server#readme

local vim = vim

---@type vim.lsp.Config
return {
	name = 'lua_ls', -- 'lazydev' requires this to be named 'lua_ls'
	cmd = { 'nice', vim.env.LUA_LS or 'lua-language-server' },
	filetypes = { 'lua' },

	-- https://luals.github.io/wiki/settings
	settings = {
		Lua = {
			-- https://luals.github.io/wiki/diagnostics
			['diagnostics.disable'] = {},
			['diagnostics.globals'] = {},
		},
	},
}
