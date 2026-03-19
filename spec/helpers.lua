local vim = vim
local M = {}

local luassert = {
	a = require('luassert'),
	n = require('luassert.namespaces'),
	u = require('luassert.util'),
	m = require('say'),
}

-- Most built-in assertions take an actual value followed by an optional message:
-- @type fun(actual: any, message: string?)
--
-- These assertions take an expected value, the actual value, and an optional message:
-- @type fun(expected: any, actual: any, message: string?)
luassert.expected = vim.iter({ 'equals', 'error_matches', 'matches', 'same' })
		:map(function(token) return luassert.n.assertion[token].callback end)
		:totable()

---@param actual any
function M.expect(actual)
	local matcher = luassert.a.state()
	local meta = getmetatable(matcher)
	local prior = { call = meta.__call }

	-- Detect when an assertion is called (after modifiers)
	meta.__call = function(self, ...)
		-- Most assertions are one or two words; try a quick lookup before resorting to `extract_keys`.
		local t = self.tokens
		local assertion =
				(#t > 2 and luassert.n.assertion[t[#t - 2] .. '_' .. t[#t - 1] .. '_' .. t[#t]]) or
				(#t > 1 and luassert.n.assertion[t[#t - 1] .. '_' .. t[#t]]) or
				(#t > 0 and luassert.n.assertion[t[#t]]) or
				vim.iter(luassert.u.extract_keys('assertion', t))
				:map(function(token) return luassert.n.assertion[token] end)
				:next()

		-- When asserting, put the `actual` value in the correct position and go away.
		if assertion then
			meta.__call = prior.call
			local pos = vim.list_contains(luassert.expected, assertion.callback) and 2 or 1
			local args = luassert.u.make_arglist(...)
			luassert.u.tinsert(args, pos, actual)
			return prior.call(self, unpack(args))
		else
			return prior.call(self, ...)
		end
	end

	return matcher
end

function M.test()
	local undefined = function(name) return function() error(('no "%s" defined'):format(name), 2) end end
	local skip = _G['pending'] or (_G['MiniTest'] and _G['MiniTest'].skip)

	---@class local.TestHelper: local.Busted
	---@field assert table<string, fun(...: any)>
	---@field expect fun(actual: any): table<string, fun(...: any)>
	---@field skip fun(message: string?)
	---@field skip_if fun(condition: any, message: string?)
	---@field skip_unless fun(condition: any, message: string?)
	return {
		context = _G['context'] or _G['describe'] or undefined('describe'),
		describe = _G['describe'] or undefined('describe'),
		pending = skip or undefined('pending'),
		skip = skip or undefined('skip'),
		skip_if = skip and function(when, message) if when then skip(message) end end or undefined('skip'),
		skip_unless = skip and function(when, message) if not when then skip(message) end end or undefined('skip'),

		it = _G['it'] or undefined('it'),
		spec = _G['spec'] or _G['it'] or undefined('it'),
		test = _G['test'] or _G['it'] or undefined('it'),

		setup = _G['setup'] or undefined('setup'),
		before_each = _G['before_each'] or undefined('before_each'),
		after_each = _G['after_each'] or undefined('after_each'),
		teardown = _G['teardown'] or undefined('teardown'),

		assert = luassert.a,
		expect = M.expect,
	}
end

local function assert_contains(_, arguments)
	local actual, expected = arguments[1], arguments[2]

	if type(actual) == 'string' then return string.find(actual, expected, 1, true) end
	if vim.islist(actual) then return vim.list_contains(actual, expected) end
	return actual[expected] and true or false
end

local function assert_satisfies(state, arguments)
	local actual, fn = arguments[1], arguments[2]
	local ok, result = pcall(fn, actual)

	if ok then
		-- Vim functions often use zero to inidicate FALSE.
		if type(result) == 'number' then return result ~= 0 end
		return result and true or false
	end

	state.failure_message = result
end

local function assert_zero(_, arguments)
	local actual = arguments[1]

	if type(actual) == 'string' then return #actual == 0 end
	if type(actual) == 'table' then return vim.tbl_isempty(actual) and getmetatable(actual) == nil end
	return actual == 0
end

luassert.m:set_namespace('en')
vim.iter({
	{
		assert_contains, 2, { 'contain', 'contains' }, 'assertion.contains',
		'Expected %s to contain %s',
		'Expected %s to not contain %s',
	},
	{
		assert_satisfies, 2, { 'satisfy', 'satisfies' }, 'assertion.satisfies',
		'Expected %s to satisfy %s',
		'Expected %s to not satisfy %s',
	},
	{
		assert_zero, 1, { 'zero' }, 'assertion.zero',
		'Expected %s to be zero',
		'Expected %s to not be zero',
	},
}):map(unpack):each(function(fn, nargs, words, msg_ns, msg_p, msg_n)
	local guard = function(...)
		local a, b = select(2, ...)
		luassert.a(a.n >= nargs, luassert.m('assertion.internal.argtolittle', { words[#words], nargs, tostring(a.n) }), b)
		return fn(...)
	end

	luassert.m:set(msg_ns .. '.positive', msg_p)
	luassert.m:set(msg_ns .. '.negative', msg_n)
	for _, word in ipairs(words) do
		luassert.a:register('assertion', word, guard, msg_ns .. '.positive', msg_ns .. '.negative')
	end
end)

return M
