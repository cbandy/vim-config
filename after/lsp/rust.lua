-- https://rust-analyzer.github.io
local math, vim = math, vim

-- rust-analyzer looks at CPU cores for its default thread count.
-- That doesn't consider any differences between them (P, E, etc.), so allocate only ¼ of those instead.
local threads = tonumber(vim.env.OMP_NUM_THREADS) or vim.uv.available_parallelism()
if threads > 4 then threads = math.floor(threads / 4) end

---@type vim.lsp.Config
return {
	cmd = { 'nice', 'rust-analyzer' },
	filetypes = { 'rust' },

	-- Indicate any rust-analyzer is acceptable for files in CARGO_HOME and RUSTUP_HOME.
	-- It would be nicer to use "reuse_client" maybe, but the default implementation is inaccessible.
	root_dir = function(bufnr, yield)
		local filepath = vim.api.nvim_buf_get_name(bufnr)
		local home = vim.fs.normalize(vim.env.HOME)
		local cargo = vim.env.CARGO_HOME or vim.fs.joinpath(home, '.cargo')
		local rustup = vim.env.RUSTUP_HOME or vim.fs.joinpath(home, '.rustup')

		for _, dir in ipairs({
			vim.fs.joinpath(rustup, 'toolchains'),
			vim.fs.joinpath(cargo, 'registry', 'src'),
			vim.fs.joinpath(cargo, 'git', 'checkouts'),
		}) do
			if vim.startswith(filepath, dir) then
				for _, client in ipairs(vim.lsp.get_clients({ name = 'rust' })) do
					return yield(client.config.root_dir)
				end
			end
		end

		-- Use "workspace_root" defined in the crate, if any.
		local crate = vim.fs.root(bufnr, { 'Cargo.toml' })
		local metadata = crate and vim.system({
			'cargo', 'metadata', '--no-deps', '--format-version=1',
			'--manifest-path', vim.fs.joinpath(crate, 'Cargo.toml'),
		}, { stderr = false, text = true }):wait()

		local workspace = (metadata and metadata.code == 0) and metadata.stdout or nil
		workspace = workspace and vim.json.decode(workspace)
		workspace = workspace and workspace['workspace_root']

		-- Same as "root_markers" when none of the above.
		-- https://rust-analyzer.github.io/book/non_cargo_based_projects.html
		yield(workspace or crate or vim.fs.root(bufnr, { 'rust-project.json' }))
	end,

	-- https://rust-analyzer.github.io/book/configuration.html
	before_init = function(params, config)
		params.initializationOptions = config.settings['rust-analyzer']
	end,

	settings = {
		['rust-analyzer'] = {
			numThreads = threads,
			cachePriming = { enable = false },
			lru = { capacity = 64 },
		},
	},
}
