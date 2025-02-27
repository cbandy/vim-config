-- vim: set foldcolumn=1 foldmethod=marker :

-- {{{ Imports --

local vim = vim

-- Disable some built-in features and plugins first.
-- This is Vim script so it can also be used by Vim.
vim.cmd.source(vim.fs.joinpath(vim.fs.dirname(vim.env.MYVIMRC), 'globals.vim'))

-- Load external plugins. This is a separate file so plugins can be installed
-- without being loaded or configured.
require('plugins')

-- }}} --


-- use the system clipboard for everything [:h 'clipboard']
--vim.opt.clipboard:append 'unnamedplus'

vim.opt.foldlevelstart = 1
vim.opt.mouse = ''
vim.opt.spellfile = vim.fs.joinpath(vim.fs.dirname(vim.env.MYVIMRC), 'spell', 'en.utf-8.add')

-- show the number of the current line and the distance to other visible lines
-- [:h 'number'] [:h 'cursorline']
vim.opt.cursorlineopt = 'number'
vim.opt.cursorline = true
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.ruler = true
-- leave room for signs when there are none [:h signs]
vim.opt.signcolumn = 'yes'

-- keep three lines visible above and below the cursor while scrolling [:h 'scrolloff']
vim.opt.scrolloff = 3

-- indent according to tabstop [:h 'tabstop']
vim.opt.shiftwidth = 0

-- open split windows below or to the right of the current window [:h split]
vim.opt.splitbelow = true
vim.opt.splitright = true

-- redraw the screen one second after entering normal mode [:h 'updatetime']
vim.opt.updatetime = 1000 -- milliseconds

-- ignore some files and directories when globbing [:h 'wildignore']
vim.opt.wildignore:append {'*.DS_Store', '*/.git/*'}
vim.opt.wildignorecase = true

--local lsp = require('lspconfig')
require('nvim-treesitter.configs').setup({
	ensure_installed = {
		'c', 'cpp', 'csv', 'diff', 'editorconfig', 'gotmpl', 'helm', 'json',
		'lua', 'perl', 'php', 'properties', 'psv', 'python', 'ruby', 'rust',
		'sql', 'tsv', 'tsx', 'typescript', 'vhs', 'vim', 'vimdoc', 'xml', 'yaml',
	},
	highlight = {
		enable = true,
		use_languagetree = true,
	},
	indent = {
		enable = true,
	},
})
require('telescope').setup({ -- [:h telescope.setup]
	defaults = {
		layout_strategy = 'vertical',
		path_display = { shorten = 5 },
		sorting_strategy = 'ascending',
	},
	mappings = {
		n = { ['q'] = require('telescope.actions').close },
	},
})


-- {{{ Mappings --

vim.g.mapleader = ','
vim.keymap.set('n', '<space>', 'za', {
	desc = 'Toggle the fold under the cursor [:h fold-commands]',
})
vim.keymap.set('n', '<Leader>nt', ':NERDTreeToggle<CR>', {
	desc = 'Open or Close the NERDTree explorer [:h NERDTree]',
})
vim.keymap.set('n', '<Leader>r', ':Dispatch<CR>', {
	desc = 'Run the compiler defined in b:dispatch [:h :Dispatch]',
})
vim.keymap.set('n', '<Leader>R', ':.Dispatch<CR>', {
	desc = 'Run the compiler defined in b:dispatch on the current line [:h :Dispatch]',
})

-- }}} --

-- "after/ftplugin" files are loaded after any builtin ones. [:h ftplugin-overrule]
-- "before/syntax" files are loaded before builtin ones; the builtin will be
--  skipped if "b:current_syntax" is set. [:h mysyntaxfile-replace]
--
-- [before/syntax/c.lua] C
-- [after/syntax/rspec.vim] RSpec -- https://rspec.info
-- [before/syntax/ruby.lua] Ruby -- https://ruby-lang.org
-- [before/syntax/sh.lua] Shell
-- [before/syntax/xml.lua] XML

local group = vim.api.nvim_create_augroup('mine', { clear = true })
for _, args in pairs({
	-- Highlighting
	{{'BufNewFile','BufRead'}, 'Dockerfile.*', [[ setfiletype dockerfile ]]},
	{{'BufNewFile','BufReadPost'}, '*', function()
		if vim.call('FugitiveGitDir') then
			vim.cmd('GitGutterBufferEnable')
		end
	end},

	-- Indentation
	{'FileType', {'cucumber', 'ruby', 'sql'}, { tabstop = 2, expandtab = true }},
	{'FileType', {'toml', 'yaml', 'yaml.*'}, { tabstop = 2, expandtab = true }},
	{'FileType', {'python'}, { tabstop = 4, expandtab = true }},
	{'FileType', {'go', 'php', 'sh', 'sh.*'}, { tabstop = 4 }},
	{'FileType', {'javascript'}, { tabstop = 2 }},

	-- Spelling
	{'FileType', {'gitcommit', 'markdown'}, { spell = true }},
	{'Syntax', {'rspec'}, { spell = true }},

	-- Whitespace
	{'ColorScheme', '*', [[
		highlight default link ExtraWhitespace DiagnosticError
	]] },
	{'FileType', {'sh', 'sh.*'}, [[
		syntax match ExtraWhitespace /\s\+$/
	]] },
	{'FileType', {'sql'}, [[
		syntax match ExtraWhitespace /\s\+\%#\@<!$\| \+\ze\t/ containedin=ALL
	]] },
	{'FileType', {'markdown', 'yaml', 'yaml.*'}, {
		list = true, listchars = 'trail:·',
	}},

	-- Wrapping
	{'FileType', 'gitcommit', { colorcolumn = '50,+0' }},
	{'FileType', 'markdown', { linebreak = true }},
	{'FileType', 'go', function()
		vim.opt_local.formatoptions:append {
			-- continue comments when hitting <Enter> in Insert mode [:h fo-r]
			r = true,
			-- continue comments when appending lines in Normal mode [:h fo-o]
			o = true,
		}
	end},

	-- Theme Adjustments
	--{'ColorScheme', 'base16-tomorrow-night', [[ highlight! link Identifier Delimiter ]] },

	-- Dispatch and Tests
	{'FileType', 'cucumber', function()
		vim.b.dispatch = 'cucumber %' ..
			-- Place arguments ahead of the filename. Show the scenario steps when focused.
			[[:s/^/\=exists("l#") ? "--format pretty " : "--format progress "/]] ..
			-- Append the line number when focused.
			[[:s/$/\=exists("l#") ? ":".l# : ""/]]
	end},
	{'FileType', 'go', function()
		vim.keymap.set('n', '<Leader>r', '<Plug>(go-diagnostics)', { buffer = true })
		vim.keymap.set('n', '<Leader>R', '<Plug>(go-test)', { buffer = true })
		vim.keymap.set('n', '<Leader>T', '<Plug>(go-test-func)', { buffer = true })
	end},
	{'FileType', 'php', function()
		if string.match(vim.fn.expand('%'), '[Tt]est[.]php$') then
			vim.b.dispatch = 'phpunit %'
		end
	end},
	{'FileType', 'python', function()
		vim.b.dispatch = 'pytest %'
	end},
	{'Syntax', 'rspec', function()
		vim.b.dispatch = 'rspec %' ..
			-- Append the line number when focused.
			[[:s/$/\=exists("l#") ? ":".l# : ""/]]
	end},
	{'FileType', 'sh', function()
		if string.match(vim.fn.expand('%'), 'test[.]sh$') then
			vim.b.dispatch = '%' ..
				-- Prepend ./ to the filename.
				[[:s#^#./#]] ..
				-- Append the test function name when focused.
				[[:s/$/\=exists("l#") ? " -- ''".matchstr(getline(search("^test", "bcnW")), "test[a-zA-Z0-9_]*")."''" : ""/]]
		end
	end},
	{'FileType', 'sql', function()
		vim.b.dispatch = 'psql -Atqf %'
	end},
}) do
	-- {{{
	local opts = { group = group, pattern = args[2] }

	if type(args[3]) == 'string' then
		opts['command'] = args[3]:match([[^%s*(.-)%s*$]])
	elseif type(args[3]) == 'function' then
		opts['callback'] = args[3]
	else
		opts['callback'] = function()
			for k,v in pairs(args[3]) do
				vim.opt_local[k] = v
			end
		end
	end

	vim.api.nvim_create_autocmd(args[1], opts)
	-- }}}
end
