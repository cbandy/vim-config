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

return M
