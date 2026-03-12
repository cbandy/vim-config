local vim, io = vim, io
local home = vim.fs.abspath(vim.fn.expand('~'))
local M = {}

---@fallible -- https://github.com/LuaLS/lua-language-server/issues/2400
---@return table<string, string> | string
function M.env()
	local exec = vim.system({ vim.env.GO or 'go', 'env', '-json' }, { timeout = 1000 }):wait()
	if exec.code ~= 0 then
		error(exec.stderr)
	else
		return vim.json.decode(exec.stdout)
	end
end

M.packages = setmetatable({}, {
	__call = function(t)
		M.packages = setmetatable({}, getmetatable(t))
		return M.packages
	end,
})

---@class (exact) go.Buffer
---@field module { file: string?, name: string?, root: string? } | fun()
---@field package go.Package
---@field project { root: string } | fun()
---@field workspace { file: string?, root: string? } | fun()
---
---@param bufnr integer
---@return go.Buffer
function M.Buffer(bufnr)
	local readonly = function() error('readonly', 2) end
	local loader = function(t, k)
		if not getmetatable(t).loaded then t() end
		return rawget(t, k)
	end

	local meta = { __index = loader, __newindex = readonly, loaded = false }
	local self = {
		module = setmetatable({}, vim.deepcopy(meta, true)),
		project = setmetatable({}, vim.deepcopy(meta, true)),
		workspace = setmetatable({}, vim.deepcopy(meta, true)),
	}

	getmetatable(self.module).__call = function(t)
		getmetatable(t).loaded = true
		rawset(t, 'root', vim.fs.root(bufnr, 'go.mod'))
		rawset(t, 'file', t.root and vim.fs.joinpath(t.root, 'go.mod'))
		rawset(t, 'name', t.root and M.Package(t.root).path)
		return t
	end
	getmetatable(self.project).__call = function(t)
		getmetatable(t).loaded = true
		rawset(t, 'root', self.workspace.root or self.module.root or vim.fs.root(bufnr, '.git') or vim.uv.cwd())
		return t
	end
	getmetatable(self.workspace).__call = function(t)
		getmetatable(t).loaded = true
		rawset(t, 'root', vim.fs.root(bufnr, 'go.work'))
		rawset(t, 'file', t.root and vim.fs.joinpath(t.root, 'go.work'))
		return t
	end

	return setmetatable(self, {
		__newindex = readonly,
		__call = function(t)
			rawset(t, 'package', nil)
			return t
		end,
		__index = function(t, k)
			if k == 'package' then rawset(t, k, M.Package(vim.api.nvim_buf_get_name(bufnr))) end
			return rawget(t, k)
		end,
	})
end

---@class (exact) go.Package
---@field path string `Package.ImportPath`
---@field root string `Package.Dir`, absolute path on the filesystem
---
---@param path string path to a Go file or its directory
---@return go.Package?
function M.Package(path)
	local pkgd = vim.fs.abspath((vim.fn.isdirectory(path) ~= 0) and path or vim.fs.dirname(path))
	local pkgp = M.packages[pkgd]
	if pkgp then return { path = pkgp, root = pkgd } end

	-- read the module name from `go.mod`, if it exists.
	local modf = vim.fs.joinpath(path, 'go.mod')
	if vim.fn.filereadable(modf) ~= 0 then
		local modp = vim.iter(io.lines(modf))
				:take(20):map(function(line) return line:match('^module%s+(.+)$') end)
				:next()
		if modp then
			M.packages[pkgd] = modp; return { path = modp, root = pkgd }
		end
	end

	-- try one directory above here
	local pkgdn = vim.fs.basename(pkgd)
	local nextd = vim.fs.dirname(pkgd)
	local nextp = (nextd ~= home) and M.Package(nextd) or nil
	if nextp then
		pkgd = vim.fs.joinpath(nextd, pkgdn)
		pkgp = { path = nextp.path .. '/' .. pkgdn, root = pkgd }
		M.packages[pkgd] = pkgp
		return pkgp
	end
end

return M
