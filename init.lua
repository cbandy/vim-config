-- vim: set foldcolumn=1 foldmethod=marker :

-- {{{ Imports --

local vim = vim
local vim_directory = vim.fs.dirname(vim.env.MYVIMRC)

-- Disable some built-in features and plugins first.
-- This is Vim script so it can also be used by Vim.
vim.cmd.source(vim.fs.joinpath(vim_directory, 'globals.vim'))

-- Load external plugins. This is a separate file so plugins can be installed
-- without being loaded or configured.
require('plugins')

-- }}} --

-- do not bother with backup files [:help backup]
vim.opt.backup = false
vim.opt.backupcopy = 'auto'
vim.opt.patchmode = ''
vim.opt.writebackup = false

-- use the system clipboard for everything [:help 'clipboard']
--vim.opt.clipboard:append 'unnamedplus'

-- open files completely folded by default [:help fold.txt]
-- filetypes and modelines can set this locally.
vim.opt.foldlevelstart = 0
vim.opt.foldmethod = 'manual'

-- do not use the mouse [:help 'mouse']
vim.opt.mouse = ''
vim.opt.mousefocus = false
vim.opt.mousehide = true

-- show the number of the current line and the distance to other visible lines
-- [:help 'number'] [:help 'cursorline']
vim.opt.cursorlineopt = 'number'
vim.opt.cursorline = true
vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.ruler = true
-- leave room for signs when there are none [:help signs]
vim.opt.signcolumn = 'yes'

-- keep three lines visible above and below the cursor while scrolling
-- [:help 'scrolloff']
vim.opt.scrolloff = 3

-- indent according to tabstop [:help 'tabstop']
vim.opt.shiftwidth = 0

-- use and add to the spelling wordlist committed to this Vim directory
-- show only a few words when suggesting a correction
-- [:help spell]
vim.opt.spellfile = vim.fs.joinpath(vim_directory, 'spell', 'en.utf-8.add')
vim.opt.spelllang = 'en'
vim.opt.spellsuggest = { 'best', 8 }

-- open split windows below or to the right of the current window [:help split]
vim.opt.splitbelow = true
vim.opt.splitright = true

-- redraw the screen one second after entering normal mode [:help 'updatetime']
vim.opt.updatetime = 1000 -- milliseconds

-- ignore some files and directories when globbing [:help 'wildignore']
vim.opt.wildignore:append {'*.DS_Store', '*/.git/*'}
vim.opt.wildignorecase = true

--local lsp = require('lspconfig')
require('nvim-treesitter.configs').setup({
	ensure_installed = {
		'c', 'cpp', 'csv', 'diff', 'editorconfig', 'gotmpl', 'helm', 'json',
		'lua', 'perl', 'php', 'properties', 'psv', 'python', 'ruby', 'rust',
		'sql', 'tsv', 'tsx', 'typescript', 'vhs', 'vim', 'vimdoc', 'xml', 'yaml',
	},

	-- Use syntax highlighting for every supported language except a specific few.
	-- [:help nvim-treesitter-highlight-mod]
	highlight = {
		enable = true, disable = {},
	},

	-- Indentation is experimental; disable it.
	-- [:help nvim-treesitter-indentation-mod]
	indent = { enable = false },
})

require("telescope").setup({ -- [:help telescope.setup]
	defaults = {
		layout_strategy = 'vertical',
		path_display = { shorten = 5 },
		sorting_strategy = 'ascending',
	},
	mappings = {
		n = { ['q'] = require("telescope.actions").close },
	},
})

require('treesitter-context').setup({
	mode = 'topline',
	multiline_threshold = 4,
})


-- {{{ Mappings --

vim.g.mapleader = ','
vim.keymap.set('n', '<space>', 'za', {
	desc = 'Toggle the fold under the cursor [:help fold-commands]',
})
vim.keymap.set('n', '<Leader>nt', ':NERDTreeToggle<CR>', {
	desc = 'Open or Close the NERDTree explorer [:help NERDTree]',
})
vim.keymap.set('n', '<Leader>r', ':Dispatch<CR>', {
	desc = 'Run the compiler defined in b:dispatch [:help :Dispatch]',
})
vim.keymap.set('n', '<Leader>R', ':.Dispatch<CR>', {
	desc = 'Run the compiler defined in b:dispatch on the current line [:help :Dispatch]',
})

-- }}} --

-- "after/ftplugin" files are loaded after any builtin ones.
-- "before/syntax" files are loaded before builtin ones; the builtin will be
--  skipped if "b:current_syntax" is set.
-- [:help ftplugin-overrule] [:help mysyntaxfile-replace]
--
-- [cols="~,~,~"]
-- |===
--
-- | C | before/syntax/c.lua
--
-- | Git | after/ftplugin/gitcommit.lua
-- | https://git-scm.com
--
-- | Go | after/ftplugin/go.lua
-- | https://go.dev
--
-- | Markdown | after/ftplugin/markdown.lua
-- | https://commonmark.org
--
-- | MDX | after/ftplugin/mdx.lua
-- | https://mdxjs.com
--
-- | RSpec | after/syntax/rspec.vim
-- | https://rspec.info
--
-- | Ruby | before/syntax/ruby.lua
-- | https://ruby-lang.org
--
-- | Shell | before/syntax/sh.lua
--
-- | XML | before/syntax/xml.lua
--
-- |===

vim.filetype.add({
	extension = {
		-- https://docs.docker.com/build/concepts/context/#filename-and-location
		['dockerignore'] = 'gitignore',
		['mdx'] = 'markdown',
	},
})

local group = vim.api.nvim_create_augroup('mine', { clear = true })
for _, args in pairs({
	-- Use the ":help" command when editing files in my Vim directory.
	-- Escape the path in the pattern by prepending "%" to non-alphanumeric characters.
	{'FileType', {'lua', 'vim'}, function()
		if string.match(
			vim.fn.expand('%:p'),
			'^' .. string.gsub(vim.fs.dirname(vim.env.MYVIMRC), '([^%w])', '%%%1')
		) then
			-- letters, numbers, apostrophe/quote, colon, hyphen, dot, underscore
			vim.opt_local.iskeyword = '@,48-57,39,:,45,46,_'
			vim.opt_local.keywordprg = ':help'
		end
	end},

	-- Highlighting
	{{'BufNewFile','BufReadPost'}, '*', function()
		if vim.call('FugitiveGitDir') then
			vim.cmd('GitGutterBufferEnable')
		end
	end},

	-- Indentation
	{'FileType', {'cucumber', 'ruby', 'sql'}, { tabstop = 2, expandtab = true }},
	{'FileType', {'toml', 'yaml', 'yaml.*'}, { tabstop = 2, expandtab = true }},
	{'FileType', {'python'}, { tabstop = 4, expandtab = true }},
	{'FileType', {'php', 'sh', 'sh.*'}, { tabstop = 4 }},
	{'FileType', {'javascript'}, { tabstop = 2 }},

	-- Spelling
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

	-- Theme Adjustments
	--{'ColorScheme', 'base16-tomorrow-night', [[ highlight! link Identifier Delimiter ]] },

	-- Dispatch and Tests
	--
	-- The variable "l#" evaluates to the line number (range) invoked on :Dispatch.
	-- See: https://www.github.com/tpope/vim-dispatch/commit/1e9bd0cdbe6975916fa4
	{'FileType', 'cucumber', function()
		vim.b.dispatch = 'cucumber %' ..
			-- Place arguments ahead of the filename. Show the scenario steps when focused.
			[[:s/^/\=exists("l#") ? "--format pretty " : "--format progress "/]] ..
			-- Append the line number when focused.
			[[:s/$/\=exists("l#") ? ":".l# : ""/]]
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
