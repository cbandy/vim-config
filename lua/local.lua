local vim = vim
local M = {}

-- https://github.com/nvim-treesitter/nvim-treesitter/tree/main#supported-features
function M.treesitter_enable(features)
	for k, v in pairs(features) do
		if type(k) == 'number' then k, v = v, true end
		if vim.startswith(k, 'fold') and v then vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()' end
		if vim.startswith(k, 'highlight') and v then vim.treesitter.start() end
	end
end

function M.treesitter_setup(config)
	require('nvim-treesitter').setup(config['nvim-treesitter'])
	require('treesitter-context').setup(config['nvim-treesitter-context'])

	-- https://github.com/nvim-treesitter/nvim-treesitter/tree/main#adding-parsers
	vim.api.nvim_create_autocmd('User', {
		pattern = 'TSUpdate',
		callback = function()
			local parsers = require('nvim-treesitter.parsers')
			for k, v in pairs(config['nvim-treesitter.parsers']) do
				parsers[k] = vim.tbl_extend('force', { tier = 2 }, v)
			end
		end
	})
end

M['palettes'] = {
	-- https://github.com/chriskempson/tomorrow-theme
	--
	-- Tomorrow Theme is released under the MIT License:
	-- Copyright (C) 2011 [Chris Kempson](https://github.com/chriskempson)
	['tomorrow'] = {
		base00 = '#ffffff', -- Background
		base01 = '#e0e0e0', -- Current Line
		base02 = '#d6d6d6', -- Selection
		base03 = '#8e908c', -- Comment
		base04 = '#969896',
		base05 = '#4d4d4c', -- Foreground
		base06 = '#282a2e',
		base07 = '#1d1f21',
		base08 = '#c82829', -- Red
		base09 = '#f5871f', -- Orange
		base0A = '#eab700', -- Yellow
		base0B = '#718c00', -- Green
		base0C = '#3e999f', -- Aqua
		base0D = '#4271ae', -- Blue
		base0E = '#8959a8', -- Purple
		base0F = '#a3685a',
	},
	['tomorrow-night'] = {
		base00 = '#1d1f21', -- Background
		base01 = '#282a2e', -- Current Line
		base02 = '#373b41', -- Selection
		base03 = '#969896', -- Comment
		base04 = '#b4b7b4',
		base05 = '#c5c8c6', -- Foreground
		base06 = '#e0e0e0',
		base07 = '#ffffff',
		base08 = '#cc6666', -- Red
		base09 = '#de935f', -- Orange
		base0A = '#f0c674', -- Yellow
		base0B = '#b5bd68', -- Green
		base0C = '#8abeb7', -- Aqua
		base0D = '#81a2be', -- Blue
		base0E = '#b294bb', -- Purple
		base0F = '#a3685a',
	},
}

return M
