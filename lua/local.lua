local vim = vim
local M = {}

-- This returns an iterator over all the lines in the files of &spellfile.
function M.spellfile_lines(lang2)
	return vim.iter(vim.split(vim.o.spellfile, ',', {
		plain = true, trimempty = true,
	})):map(function(fn)
		if vim.fs.basename(fn):sub(1, 2) == lang2 then
			return vim.iter(io.lines(fn)):totable()
		end
		return nil
	end):flatten()
end

-- This returns an iterator over all the good words in the files of &spellfile.
function M.spellfile_good_words(lang2)
	return M.spellfile_lines(lang2):map(function(line)
		if line:match('^[^#/]') then
			local suffix = line:match('/[=?!1-9]*$') or ''
			if not suffix:match('!') then
				return line:sub(1, #line - #suffix)
			end
		end
		return nil
	end)
end

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

-- This converts a Vim filetype to a VSCode language identifier.
-- https://code.visualstudio.com/docs/languages/identifiers
function M.vscode_language(filetype)
	return ({
		gitcommit = 'git-commit',
		sh = 'shellscript',
		text = 'plaintext',
	})[filetype] or filetype
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
