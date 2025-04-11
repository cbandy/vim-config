-- https://github.com/redhat-developer/yaml-language-server

local vim = vim

---@type vim.lsp.Config
return {
	cmd = { 'yaml-language-server', '--stdio' },
	filetypes = { 'yaml' },

	on_attach = function(client, bufnr)
		require('local').lsp_attach(client, bufnr)

		local group = ('local.lsp.b_%d_option'):format(bufnr)
		local groupnr = vim.api.nvim_create_augroup(group, { clear = true })

		-- The 'OptionSet' event does not fire on any particular buffer.
		-- Instead, check the augroup that triggered the event.
		vim.api.nvim_create_autocmd('OptionSet', {
			group = groupnr,
			callback = function(event)
				if groupnr == event.group
						and vim.list_contains({ 'shiftwidth', 'tabstop' }, event.match)
				then
					local tabstop = vim.lsp.util.get_effective_tabstop(event.buf)

					client:notify('workspace/didChangeConfiguration', {
						settings = vim.tbl_deep_extend('force', client.config.settings, {
							yaml = { editor = { tabSize = tabstop } },
						}),
					})
				end
			end,
		})
	end,

	settings = {
		-- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
		redhat = { telemetry = { enabled = false } },
		yaml = {
			-- the formatting provided is rather limited, so disable it
			-- https://github.com/redhat-developer/yaml-language-server/issues/933
			format = { enable = false },
			completion = true,
			hover = true,
			validate = true,
		},
	},
}
