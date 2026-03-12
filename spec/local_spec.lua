local T = require('spec.helpers').test()

T.describe('"local" module', function()
	T.teardown(function()
		package.loaded['local'] = nil
		package.loaded['local.go'] = nil
	end)

	T.describe('go', function()
		T.it('shares env', function()
			T.skip_unless(vim.fn.executable(vim.env.GO or 'go') ~= 0, 'requires `go` on $PATH')

			local go = require('local').go
			T.expect(go.env).satisfies(vim.tbl_isempty)
			T.expect(go[0].env).satisfies(vim.tbl_isempty)

			go.env()

			T.expect(go.env).does_not_satisfy(vim.tbl_isempty)
			T.expect(go[0].env).does_not_satisfy(vim.tbl_isempty)
			T.expect(go[0].env).is_same(go.env)
		end)
	end)
end)
