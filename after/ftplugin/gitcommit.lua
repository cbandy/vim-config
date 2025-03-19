local vim = vim

-- The builtin "gitcommit" syntax highlights characters that extend beyond
-- this length on the first line. [$VIMRUNTIME/syntax/gitcommit.vim]
--
-- The DISCUSSION section of git-commit(1) recommends that the first line
-- of a commit message be a "short (less than 50 character)" summary.
--
-- The builtin "gitcommit" plugin sets 'textwidth' so highlight both of
-- these columns by default. [$VIMRUNTIME/ftplugin/gitcommit.vim]
vim.g.gitcommit_summary_length = 50
vim.opt_local['colorcolumn'] = vim.g.gitcommit_summary_length .. ',+0'

-- highlight misspelled words
vim.opt_local['spell'] = true
