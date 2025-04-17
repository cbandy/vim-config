-- https://github.com/redhat-developer/yaml-language-server

local vim = vim

---@param client vim.lsp.Client
---@param bufnr integer
local function buffer_settings(client, bufnr)
	local changes = false
	local settings = client.config.settings or {}
	local tabstop = vim.lsp.util.get_effective_tabstop(bufnr)

	if tabstop ~= vim.tbl_get(settings, 'yaml', 'editor', 'tabSize') then
		changes, settings = true, vim.tbl_deep_extend('force', settings, {
			yaml = { editor = { tabSize = tabstop } },
		})
	end

	-- when there are changes, push configuration to the server
	if changes then
		client.config.settings = settings
		require('local').lsp_notify_configuration(client, bufnr, settings)
	end
end

---@type vim.lsp.Config
return {
	cmd = { 'yaml-language-server', '--stdio' },
	filetypes = { 'yaml' },

	on_attach = function(client, bufnr)
		require('local').lsp_attach(client, bufnr)
		buffer_settings(client, bufnr)

		local group = ('local.lsp.b_%d_option'):format(bufnr)
		local groupnr = vim.api.nvim_create_augroup(group, { clear = true })

		-- The 'OptionSet' event does not fire on any particular buffer.
		-- Instead, check the augroup that triggered the event.
		vim.api.nvim_create_autocmd('OptionSet', {
			group = groupnr,
			callback = function(event)
				if groupnr ~= event.group then return end

				if vim.list_contains({ 'shiftwidth', 'tabstop' }, event.match) then
					buffer_settings(client, event.buf)
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
