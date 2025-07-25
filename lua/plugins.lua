#!/usr/bin/env -S nvim -u
-- vim: set foldcolumn=1 foldmethod=marker :
--
-- https://github.com/junegunn/vim-plug#readme

-- {{{ Setup --

local names = {}
local vim = vim

-- Use a more general shorthand for referencing plugin URLs.
--
-- https://github.com/junegunn/vim-plug#global-options
vim.g.plug_url_format = 'https://git::@%s.git'

local function Plug(short, ...)
	local opts = vim.empty_dict()
	for _, v in ipairs({ ... }) do opts = v end

	-- The "do" and "for" options are Lua keywords and must be enclosed by brackets
	-- in table constructors. This provides alternate names for those options.
	--
	-- https://github.com/junegunn/vim-plug#plug-options
	opts['do'] = opts['after_update']; opts['after_update'] = nil
	opts['for'] = opts['for_filetype']; opts['for_filetype'] = nil
	opts['on'] = opts['load_because']; opts['load_because'] = nil

	-- Empty "for" and "on" options indicate the plugin should not be loaded
	-- at startup and not removed by PlugClean.
	--
	-- https://github.com/junegunn/vim-plug/wiki/tips#conditional-activation
	if opts.enabled == false then
		opts['for'] = {}
		opts['on'] = {}
	end

	-- Ensure plugins with requirements are defined in the correct order.
	for _, dep in ipairs(opts.requires or {}) do
		local exists = vim.g.plugs[names[dep]]
		if not exists then
			error(string.format('cannot load %q before %q', short, dep))
		elseif exists['for'] or exists['on'] then
			error(string.format('cannot load %q when %q is lazy', short, dep))
		end
	end

	for k, v in pairs(opts.globals or {}) do vim.g[k] = v end

	-- 📝 https://github.com/junegunn/vim-plug/wiki/api#autocmds

	vim.call('plug#', short, opts)

	-- Read the name and URL given to the plugin and keep them in a lookup table.
	local name = vim.iter(vim.g.plugs_order):last()
	local url = vim.g.plugs[name].uri
	names[name] = name
	names[short] = name
	names[url] = name

	-- Ensure everything is loaded over HTTP/2 or HTTPS.
	if not url:match('^https://') then
		error(string.format('cannot load %q without https', short))
	end
end

-- }}} --

-- install plugins in Neovim's XDG data directory
vim.call('plug#begin', vim.fs.joinpath(vim.fn.stdpath('data'), 'plugged'))


Plug('github.com/airblade/vim-gitgutter', {
	load_because = { 'GitGutterEnable', 'GitGutterBufferEnable' },
})
Plug('github.com/chrisbra/unicode.vim', {
	after_update = ':DownloadUnicode',
})
Plug('github.com/dense-analysis/ale', {
	commit = '067e74fee8b404d2ab36804943b8dd68c7a38327',
	for_filetype = { 'go', 'gomod', 'sh' },
	globals = {
		-- only use linters that have been enabled
		ale_disable_lsp = true,
		ale_linters_explicit = true,
		-- only run linters after file save
		ale_lint_on_save = true,
		ale_lint_on_insert_leave = false,
		ale_lint_on_text_changed = 'never',
		-- use the quickfix list
		ale_set_loclist = false,
		ale_set_quickfix = true,
		-- https://github.com/dense-analysis/ale/blob/-/autoload/ale/fixers
		ale_fixers = {
			go = { 'gofmt' }, -- gofmt is always available
			gomod = { 'gomod' }, -- gomod is `go mod` and always available
		},
		-- https://github.com/dense-analysis/ale/blob/-/ale_linters
		ale_linters = {
			sh = { 'shell', 'shellcheck' },
		},
	},
})
Plug('github.com/echasnovski/mini.base16')
Plug('github.com/echasnovski/mini.icons')
Plug('github.com/echasnovski/mini.pick')
Plug('github.com/epwalsh/pomo.nvim', { tag = '*' })
Plug('github.com/folke/lazydev.nvim', { tag = '*' })
Plug('github.com/lifepillar/pgsql.vim', {
	for_filetype = { 'sql' },
})
Plug('github.com/neovim/nvim-lspconfig')
Plug('github.com/nvim-tree/nvim-tree.lua', { tag = '*' })
Plug('github.com/nvim-treesitter/nvim-treesitter', {
	-- The 'master' branch is frozen and the 'main' branch leverages the newest LSP features.
	-- https://github.com/nvim-treesitter/nvim-treesitter/issues/4767
	branch = vim.fn.has('nvim-0.11') > 0 and 'main' or 'master',
	after_update = ':TSUpdate',
})
Plug('github.com/nvim-treesitter/nvim-treesitter-context', {
	requires = {
		'github.com/nvim-treesitter/nvim-treesitter',
	},
})
Plug('github.com/vim-test/vim-test', {
	globals = {
		['test#strategy'] = 'dispatch',
		['test#echo_command'] = false,
		['test#enabled_runners'] = {
			'go#gotest', 'go#ginkgo', 'php#phpunit', 'python#pytest',
			'ruby#cucumber', 'ruby#minitest', 'ruby#rspec', 'rust#cargotest',
		},
	},
})

Plug('tpope.io/vim/abolish', {
	load_because = { 'Abolish', 'Subvert', 'S' },
	globals = {
		abolish_no_mappings = true,
	},
})
Plug('tpope.io/vim/dadbod', {
	load_because = { 'DB' },
})
Plug('tpope.io/vim/dispatch', {
	load_because = { 'Dispatch' },
	globals = {
		dispatch_no_maps = true,
		dispatch_tmux_height = 5,
		dispatch_compilers = {
			['bundle exec'] = '',
			['gotestsum'] = 'go',
		},
	},
})
Plug('tpope.io/vim/endwise')
Plug('tpope.io/vim/fugitive')
Plug('tpope.io/vim/projectionist', {
	globals = {
		projectionist_heuristics = {
			['go.mod|go.work'] = {
				['*.go'] = { alternate = '{}_test.go', type = 'source' },
				['*_test.go'] = { alternate = '{}.go', type = 'test' },
			},
		},
	},
})
Plug('tpope.io/vim/surround')


vim.call('plug#end')
-- color schemes can be loaded *after* 'plug#end'
