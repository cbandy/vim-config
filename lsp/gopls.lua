-- https://pkg.go.dev/golang.org/x/tools/gopls#readme
-- https://github.com/golang/tools/blob/-/gopls/doc/features

local vim = vim

-- Replace go_env with the results of `go env` the first time it is accessed.
local go_env = {}
setmetatable(go_env, {
	__index = function(_, key)
		go_env = vim.json.decode(vim.fn.system({ vim.env.GO or 'go', 'env', '-json' }))
		return go_env[key]
	end,
})

---@type vim.lsp.Config
return {
	-- https://github.com/golang/tools/blob/-/gopls/doc/daemon.md
	cmd = { 'gopls', '--remote=auto', '--remote.listen.timeout=15s' },
	filetypes = { 'go', 'gomod', 'gotmpl', 'gowork' },

	-- Indicate any LSP client is acceptable for files in GOMODCACHE.
	-- It would be nicer to use "reuse_client" maybe, but the default implementation is inaccessible.
	-- https://github.com/neovim/nvim-lspconfig/issues/804
	-- https://github.com/neovim/nvim-lspconfig/pull/2661
	root_dir = function(bufnr, yield)
		local filepath = vim.api.nvim_buf_get_name(bufnr)
		local modcache = go_env['GOMODCACHE']

		if vim.startswith(filepath, modcache) then
			for _, client in ipairs(vim.lsp.get_clients({ name = 'gopls' })) do
				return yield(client.config.root_dir)
			end
		end

		-- Same as "root_markers" when not in GOMODCACHE.
		yield(vim.fs.root(bufnr, { 'go.mod', 'go.work' }))
	end,

	-- https://github.com/golang/tools/blob/-/gopls/doc/settings.md
	settings = {
		gopls = {
			-- https://github.com/golang/tools/blob/-/gopls/doc/analyzers.md
			analyses = {
				shadow = true,
			},
			-- https://github.com/golang/tools/blob/-/gopls/doc/codelenses.md
			codelenses = {
				vulncheck = true,
			},
			-- https://github.com/golang/tools/blob/-/gopls/doc/inlayHints.md
			hints = {
				constantValues = true,
				parameterNames = true,
			},

			gofumpt = true,
			symbolScope = 'workspace',
			usePlaceholders = true,
		}
	},
}
