-- https://pkg.go.dev/golang.org/x/tools/gopls#readme
-- https://github.com/golang/tools/blob/-/gopls/doc/features

local append = table.insert
local join = table.concat
local vim = vim

-- Replace go_env with the results of `go env` the first time it is accessed.
local go_env = {}
setmetatable(go_env, {
	__index = function(_, key)
		go_env = vim.json.decode(vim.fn.system({ vim.env.GO or 'go', 'env', '-json' }))
		return go_env[key]
	end,
})

---@param flags string[] Go build flags
---@return string[] # build flags other than -tags
---@return string   # comma-separated build tags
local function extract_build_tags(flags)
	local tags = {}

	flags = vim.iter(flags):map(function(flag)
		local arg, matches = flag:gsub('^-tags[ =]', '', 1)
		if matches > 0 then
			for _, tag in ipairs(vim.split(arg, ',', { plain = true, trimempty = true })) do
				tags[tag] = tag
			end
			return nil
		else
			return flag
		end
	end):totable()

	tags = vim.iter(pairs(tags)):fold({}, function(out, k, _)
		table.insert(out, k); return out;
	end)

	return flags, join(tags, ',')
end

---@param client vim.lsp.Client
---@param bufnr integer
---@param replace boolean
---@param flags string[] Go build flags
local function update_build_flags(client, bufnr, replace, flags)
	local settings = vim.tbl_get(client.config.settings, 'gopls') or {}

	-- https://github.com/golang/tools/blob/-/gopls/doc/settings.md#buildflags-string
	if replace and #flags == 0 then
		settings.buildFlags = nil
	elseif replace then
		settings.buildFlags = flags
	else
		local new = settings.buildFlags or {}
		vim.list_extend(new, flags)
		settings.buildFlags = new
	end

	-- when replacing or extending, tell the server to pull configuration
	if replace or #flags > 0 then
		client.config.settings = { gopls = settings }
		require('local').lsp_notify_configuration(client, bufnr, {})
	end
end

---@type vim.lsp.Config
return {
	-- https://github.com/golang/tools/blob/-/gopls/doc/daemon.md
	cmd = {
		vim.env.GO or 'go', 'run', 'golang.org/x/tools/gopls@latest',
		'--remote=auto', '--remote.listen.timeout=15s',
	},
	filetypes = { 'go', 'gomod', 'gotmpl', 'gowork' },

	offset_encoding = 'utf-8',
	on_attach = function(client, bufnr)
		require('local').lsp_attach(client, bufnr)

		-- https://github.com/golang/tools/blob/-/gopls/doc/settings.md#buildflags-string
		vim.api.nvim_buf_create_user_command(bufnr, 'GoBuildFlags', function(details)
			update_build_flags(client, bufnr, details.bang, details.fargs)
		end, {
			bang = true, nargs = '*', desc = 'view, add, or replace Go build flags',
		})

		-- https://github.com/golang/tools/blob/-/gopls/doc/settings.md#buildflags-string
		vim.api.nvim_buf_create_user_command(bufnr, 'GoBuildTags', function(details)
			local flags = vim.tbl_get(client.config.settings, 'gopls', 'buildFlags') or {}
			local tags = join(details.fargs, ',')

			if details.bang and #details.args == 0 then
				flags, _ = extract_build_tags(flags)
				tags = ''
			elseif details.bang then
				flags, _ = extract_build_tags(flags)
				append(flags, '-tags=' .. tags)
			elseif #details.args > 0 then
				append(flags, '-tags=' .. tags)
				flags, tags = extract_build_tags(flags)
				append(flags, '-tags=' .. tags)
			end

			-- update when replacing or extending
			if details.bang or #details.args > 0 then
				update_build_flags(client, bufnr, true, flags)
			end

			vim.notify(('Tags: %q'):format(tags), vim.log.levels.INFO)
		end, {
			bang = true, nargs = '*', desc = 'view, add, or replace Go build tags',
		})
	end,

	-- Indicate any gopls is acceptable for files in GOMODCACHE.
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

			-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md#formatting
			gofumpt = false,

			-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md#ui
			semanticTokens = true,
			-- use the tree-sitter colors for "return" and constants
			semanticTokenTypes = { keyword = false, variable = false },

			-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md#completion
			usePlaceholders = true,
		}
	},
}
