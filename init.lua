-- vim: set foldcolumn=1 foldmethod=marker :

-- {{{ Imports --

local function apply(...)
	local args = { ... }; local fn = table.remove(args); fn(unpack(args))
end
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
vim.opt.wildignore:append { '*.DS_Store', '*/.git/*' }
vim.opt.wildignorecase = true

-- [:help vim.diagnostic.Opts]
vim.diagnostic.config({
	virtual_text = true,
})

-- [:help lsp-config]
vim.lsp.config('*', {
	root_markers = { '.git' },

	-- [:help vim.lsp.Client]
	on_attach = function(client, bufnr)
		if client:supports_method('textDocument/definition') then
			local opts = { desc = 'vim.lsp.buf.definition()', buffer = bufnr }
			vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
			vim.keymap.set('n', '<C-]>', vim.lsp.buf.definition, opts)
		end
		if client:supports_method('textDocument/foldingRange') then
			vim.wo[0][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
		end
		if client:supports_method('textDocument/formatting') and
				not client:supports_method('textDocument/willSaveWaitUntil')
		then
			vim.api.nvim_create_autocmd('BufWritePre', {
				group = vim.api.nvim_create_augroup('local.lsp', { clear = false }),
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({ bufnr = bufnr, id = client.id })
				end,
			})
		end
		if client:supports_method('textDocument/typeDefinition') then
			vim.keymap.set('n', 'gD', vim.lsp.buf.type_definition, {
				desc = 'vim.lsp.buf.type_definition()', buffer = bufnr,
			})
		end
	end,
})
vim.lsp.enable({
	'ltexls', -- lsp/ltexls.lua
	'lua_ls', -- lsp/lua_ls.lua -- 'lazydev' requires this to be named 'lua_ls'
})

-- Explain Neovim workspace to LuaLS
require('lazydev').setup({
	debug = false,
	integrations = { lspconfig = true },
})

-- Configure builtin and popular highlights using a Base16 palette.
-- (Not technically a colorscheme.)
apply(require('local').palettes['tomorrow-night'], function(palette)
	require('mini.base16').setup({ palette = palette })

	-- These guides suggest Identifier be Red, base08:
	-- https://github.com/chriskempson/base16/blob/-/styling.md
	-- https://github.com/tinted-theming/home/blob/-/styling.md
	-- https://github.com/tinted-theming/base24/blob/-/styling.md
	--
	-- This sets it to Foreground, base05.
	vim.api.nvim_set_hl(0, 'Identifier', { fg = palette.base05 })
end)

require('nvim-tree').setup({
	diagnostics = {
		enable = true,
		icons = { hint = '!', info = 'ℹ', warning = '⚠', error = '🔥' },
	},
	renderer = {
		add_trailing = true,
		full_name = true,
		group_empty = true,
		highlight_git = 'icon',
		indent_markers = { enable = true },
		icons = {
			show = { file = false, folder = false, modified = false },
			symlink_arrow = ' 🡪  ',
			git_placement = 'after',
			glyphs = {
				bookmark = '🞉',
				folder = { arrow_closed = '⏵', arrow_open = '◼' },
				git = { deleted = '⊟', staged = '🗹', unmerged = '⦹', unstaged = '⍻', untracked = '✷' },
			},
		},
	},
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

require('local').treesitter_setup({
	['nvim-treesitter'] = {
		ensure_install = {
			-- config and data
			'csv', 'json', 'pem', 'properties', 'psv', 'toml', 'tsv', 'xml', 'yaml',
			-- editing
			'diff', 'editorconfig', 'vim', 'vimdoc',
			-- interpreted
			'bash', 'dockerfile', 'helm', 'javascript', 'lua', 'luap', 'perl',
			'php_only', 'python', 'ruby', 'sql', 'vhs',
			-- compiled
			'c', 'cpp', 'go', 'gomod', 'rust', 'typescript',
			-- presentation
			'asciidoc', 'asciidoc_inline', 'css', 'gotmpl', 'html',
			'markdown', 'markdown_inline', 'rst', 'tsx',
		},
	},
	['nvim-treesitter-context'] = {
		mode = 'topline',
		multiline_threshold = 4,
	},
	['nvim-treesitter.parsers'] = {
		asciidoc = {
			install_info = {
				url = 'https://github.com/cathaysia/tree-sitter-asciidoc',
				location = 'tree-sitter-asciidoc',
				files = { 'src/parser.c', 'src/scanner.c' },
			},
		},
		asciidoc_inline = {
			install_info = {
				url = 'https://github.com/cathaysia/tree-sitter-asciidoc',
				location = 'tree-sitter-asciidoc_inline',
				files = { 'src/parser.c', 'src/scanner.c' },
			},
		},
		jq = {
			install_info = {
				url = 'https://github.com/nverno/tree-sitter-jq',
				files = { 'src/parser.c' },
			},
		},
		make = {
			install_info = {
				url = 'https://github.com/tree-sitter-grammars/tree-sitter-make',
				files = { 'src/parser.c' },
			},
		},
	},
})

vim.g.mapleader = ','
vim.keymap.set('n', '<space>', 'za', {
	desc = 'toggle the fold under the cursor [:help fold-commands]',
	silent = true,
})
vim.keymap.set('n', '<Leader>nt', require("nvim-tree.api").tree.toggle, {
	desc = 'open or close the file explorer [:help nvim-tree]',
})
vim.keymap.set('n', '<Leader>r', ':TestFile<CR>', { silent = true })
vim.keymap.set('n', '<Leader>R', ':TestNearest<CR>', { silent = true })

-- Other LSP functions are mapped to "gr*" too. [:help lsp-defaults]
vim.keymap.set('n', 'grq', vim.diagnostic.setqflist, { desc = 'vim.diagnostic.setqflist()' })

-- "after/ftplugin" files are loaded after any builtin ones.
-- "before/syntax" files are loaded before builtin ones; the builtin will be
--  skipped if "b:current_syntax" is set.
-- [:help ftplugin-overrule] [:help mysyntaxfile-replace]
-- [:help syntax-loading] [:help scriptnames]
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
	{ 'FileType', { 'lua', 'vim' }, function()
		if string.match(vim.fn.expand('%:p'), '^' .. string.gsub(vim_directory, '([^%w])', '%%%1'))
		then
			-- letters, numbers, colon, hyphen, dot, underscore
			vim.opt_local.iskeyword = '@,48-57,:,45,46,_'
			vim.opt_local.keywordprg = ':help'
		end
	end },

	{ { 'BufNewFile', 'BufReadPost' }, '*', function()
		-- enable Git signs only when there is a Git directory
		if vim.call('FugitiveGitDir') ~= '' then
			vim.cmd('GitGutterBufferEnable')
		end
	end },

	-- Indentation
	{ 'FileType', { 'cucumber', 'ruby', 'sql' }, { tabstop = 2, expandtab = true } },
	{ 'FileType', { 'toml', 'yaml', 'yaml.*' },  { tabstop = 2, expandtab = true } },
	{ 'FileType', { 'python' },                  { tabstop = 4, expandtab = true } },
	{ 'FileType', { 'php', 'sh', 'sh.*' },       { tabstop = 4 } },
	{ 'FileType', { 'javascript' },              { tabstop = 2 } },

	-- Spelling
	{ 'Syntax',   { 'rspec' },                   { spell = true } },

	-- Whitespace
	{ 'ColorScheme', '*', [[
		highlight default link ExtraWhitespace DiagnosticError
	]] },
	{ 'FileType', { 'sh', 'sh.*' }, [[
		syntax match ExtraWhitespace /\s\+$/
	]] },
	{ 'FileType', { 'sql' }, [[
		syntax match ExtraWhitespace /\s\+\%#\@<!$\| \+\ze\t/ containedin=ALL
	]] },
	{ 'FileType', { 'markdown', 'yaml', 'yaml.*' }, {
		list = true, listchars = 'trail:·',
	} },

	-- Dispatch and Tests
	--
	-- The variable "l#" evaluates to the line number (range) invoked on :Dispatch.
	-- See: https://www.github.com/tpope/vim-dispatch/commit/1e9bd0cdbe6975916fa4
	{ 'FileType', 'sh', function()
		if string.match(vim.fn.expand('%'), 'test[.]sh$') then
			vim.b.dispatch = '%' ..
					-- Prepend ./ to the filename.
					[[:s#^#./#]] ..
					-- Append the test function name when focused.
					-- search()
					--   "b" backward "n" without moving the cursor,
					--   "W" stop at the beginning of the file, and
					--   "c" allow a match on the current line
					-- matchstr() to grab the entire function name
					[[:s/$/\=exists("l#") ? " -- ''".matchstr(getline(search("^test", "bcnW")), "test[a-zA-Z0-9_]*")."''" : ""/]]
		end
	end },
	{ 'FileType', 'sql', function()
		vim.b.dispatch = 'psql -Atqf %'
	end },
}) do
	-- {{{
	local opts = { group = group, pattern = args[2] }

	if type(args[3]) == 'string' then
		opts['command'] = args[3]:match([[^%s*(.-)%s*$]])
	elseif type(args[3]) == 'function' then
		opts['callback'] = args[3]
	else
		assert(type(args[3]) == 'table')
		opts['callback'] = function()
			for k, v in pairs(args[3]) do
				vim.opt_local[k] = v
			end
		end
	end

	vim.api.nvim_create_autocmd(args[1], opts)
	-- }}}
end
