#!/usr/bin/env -S nvim -u
-- vim: set foldcolumn=2 foldmethod=marker noexpandtab shiftwidth=0 tabstop=2 :
--
-- https://github.com/junegunn/vim-plug#readme

-- {{{ Setup --

local vim = vim

local function Plug(url, ...)
	local opts = vim.empty_dict()
	for _, v in ipairs({...}) do opts = v end

	-- Use a different shorthand for referencing plugin URLs.
	-- This could also be done with "g:plug_url_format".
	--
	-- https://github.com/junegunn/vim-plug#global-options
	if not url:match('^https://') then
		url = 'https://git::@' .. url .. '.git/'
	end

	-- The "do" and "for" options are Lua keywords and must be enclosed by brackets
	-- in table constructors. This provides alternate names for those options.
	--
	-- https://github.com/junegunn/vim-plug#plug-options
	opts['do']  = opts['after_update']; opts['after_update'] = nil
	opts['for'] = opts['for_filetype']; opts['for_filetype'] = nil

	-- https://github.com/junegunn/vim-plug/wiki/tips#conditional-activation
	if opts.enabled == false then
		opts['for'] = {}
		opts['on'] = {}
	end

	for k, v in pairs(opts.globals or {}) do vim.g[k] = v end

	-- :memo: https://github.com/junegunn/vim-plug/wiki/api#autocmds

	vim.call('plug#', url, opts)
end

-- }}} --

-- install plugins in Neovim's XDG data directory
vim.call('plug#begin', vim.fs.joinpath(vim.fn.stdpath('data'), 'plugged'))


Plug('github.com/airblade/vim-gitgutter', {
	on = {'GitGutterEnable', 'GitGutterBufferEnable'},
})
Plug('github.com/chrisbra/unicode.vim', {
	after_update = ':DownloadUnicode',
})
Plug('github.com/ctrlpvim/ctrlp.vim', {
	on = {'CtrlP'},
})
Plug('github.com/fatih/vim-go', {
	after_update = ':GoUpdateBinaries',
	for_filetype = {'go'},
})
Plug('github.com/junegunn/fzf', {
	after_update = function() vim.call('fzf#install') end,
})
Plug('github.com/junegunn/fzf.vim')
Plug('github.com/lifepillar/pgsql.vim', {
	for_filetype = {'sql'},
})
Plug('github.com/neovim/nvim-lspconfig')
Plug('github.com/nvim-lua/plenary.nvim')
Plug('github.com/nvim-telescope/telescope.nvim', { -- requires 'plenary.nvim'
	-- use release branch: https://github.com/nvim-telescope/telescope.nvim#installation
	branch = '0.1.x',
})
Plug('github.com/nvim-treesitter/nvim-treesitter', {
	after_update = ':TSUpdate',
})
Plug('github.com/nvim-treesitter/nvim-treesitter-textobjects')
Plug('github.com/preservim/nerdtree', {
	on = {'NERDTree', 'NERDTreeMirror', 'NERDTreeToggle'},
	globals = {
		-- these affect the 'nerdtree' syntax
		NERDTreeDirArrowCollapsible = '~',
		NERDTreeDirArrowExpandable  = '+',
	},
})

--Plug('github.com/ray-x/go.nvim', {
--	for_filetype = {'go'},
--})
Plug('github.com/chriskempson/base16-vim')
--Plug('github.com/tinted-theming/tinted-vim') -- Try again after https://www.github.com/tinted-theming/tinted-vim/pull/102

--Plug('github.com/stevearc/conform.nvim')

Plug('tpope.io/vim/abolish')
Plug('tpope.io/vim/dadbod')
Plug('tpope.io/vim/dispatch')
Plug('tpope.io/vim/endwise')
Plug('tpope.io/vim/fugitive')
Plug('tpope.io/vim/surround')

-- Plug('https://github.com/stevearc/overseer.nvim.git')

-- "Plug 'astashov/vim-ruby-debugger'
-- "Plug 'chriskempson/base16-vim'
-- "Plug 'JoosepAlviste/nvim-ts-context-commentstring'
-- "Plug 'mhinz/vim-signify'

-- Plug 'https://tpope.io/vim/pathogen.git'
-- Plug 'OrangeT/vim-csharp'


vim.call('plug#end')
-- color schemes can be loaded *after* 'plug#end'
