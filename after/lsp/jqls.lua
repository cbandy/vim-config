-- https://jqlang.org
-- https://pkg.go.dev/github.com/wader/jq-lsp

local vim = vim

---@type vim.lsp.Config
return {
	cmd = { 'nice', vim.env.GO or 'go', 'run', 'github.com/wader/jq-lsp@latest' },
	filetypes = { 'jq' },
}
