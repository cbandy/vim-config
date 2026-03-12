local T = require('spec.helpers').test()

T.describe('"local.go" module', function()
	T.teardown(function() package.loaded['local.go'] = nil end)

	T.it('creates no globals', function()
		T.skip_if(package.loaded['local.go'], 'requires "local.go" not be loaded')

		local before = vim.tbl_keys(_G)
		T.expect(require('local.go')).is_table()

		local after = vim.tbl_keys(_G)
		package.loaded['local.go'] = nil

		table.sort(after)
		table.sort(before)

		T.expect(after).is_same(before)
	end)

	T.describe('env()', function()
		T.skip_unless(vim.fn.executable(vim.env.GO or 'go') ~= 0, 'requires `go` on $PATH')

		local saved
		T.before_each(function() saved = vim.env.GO end)
		T.after_each(function() vim.env.GO = saved end)

		T.it('returns information about Go', function()
			local info = require('local.go').env()
			T.expect(info).is_table()
			T.expect(info.GOROOT).satisfies(vim.fn.isabsolutepath)
		end)

		T.it('panics when `go env` fails', function()
			vim.env.GO = 'false'
			local ok, actual = pcall(require('local.go').env)
			T.expect(ok).is_false()
			T.expect(actual).is_string()
		end)
	end)

	T.context('with Go module file', function()
		local dir

		T.setup(function()
			local tmp, err = vim.uv.os_tmpdir()
			T.assert.is_nil(err)

			dir, err = vim.uv.fs_mkdtemp(vim.fs.joinpath(tmp, 'neovim_local.go_spec-XXXXXX'));
			T.assert.is_nil(err)
			T.assert.is_zero(vim.fn.writefile(
				{ 'module example.com/base', 'go 1.25' }, vim.fs.joinpath(dir, 'go.mod')
			))
			T.assert.is_not_zero(vim.fn.mkdir(vim.fs.joinpath(dir, 'app', 'db'), 'p'))
			T.assert.is_not_zero(vim.fn.mkdir(vim.fs.joinpath(dir, 'lib', 'util'), 'p'))
		end)

		T.teardown(function()
			if dir then vim.fs.rm(dir, { force = true, recursive = true }) end
		end)

		T.it('describes packages', function()
			local one = require('local.go').Package(vim.fs.joinpath(dir, 'app', 'db', 'sql.go'))
			T.expect(one).is_table()
			T.expect(one.path).equals('example.com/base/app/db')
			T.expect(one.root).equals(vim.fs.joinpath(dir, 'app', 'db'))
			T.expect(one.root).satisfies(vim.fn.isabsolutepath)

			local two = require('local.go').Package(vim.fs.joinpath(dir, 'lib', 'util'))
			T.expect(two.path).equals('example.com/base/lib/util')
			T.expect(two.root).equals(vim.fs.joinpath(dir, 'lib', 'util'))
			T.expect(two.root).satisfies(vim.fn.isabsolutepath)
		end)

		T.it('caches results', function()
			local go = require('local.go')
			local path = go.Package(vim.fs.joinpath(dir, 'app', 'db')).root

			T.expect(go.packages).contains(path)
			T.expect(go.packages).contains(dir)

			-- call clears the cache
			go.packages()
			T.expect(go.packages).satisfies(vim.tbl_isempty)
		end)
	end)
end)
