---@meta
error 'meta'

---@alias local.Busted.Block fun(description: string, block: fun())
---@alias local.Busted.Hook fun(block: fun())

--- The interface provided by Busted for organizing tests; emulated by many frameworks.
---
--- https://lunarmodules.github.io/busted
--- https://nvim-mini.org/mini.nvim/TESTING
--- https://github.com/nvim-lua/plenary.nvim/blob/-/TESTS_README.md
---
---@class (exact) local.Busted
---
---@field pending  fun(description: string, ...: any) Placeholder that does not execute
---@field context  local.Busted.Block A group of related tests; can contain setup, teardown, before_each, and after_each
---@field describe local.Busted.Block A group of related tests; can contain setup, teardown, before_each, and after_each
---
---@field it   local.Busted.Block A test; should contain assertions
---@field spec local.Busted.Block A test; should contain assertions
---@field test local.Busted.Block A test; should contain assertions
---
---@field setup       local.Busted.Hook Runs once, first, before all tests in a group
---@field before_each local.Busted.Hook Runs before each test in a group
---@field after_each  local.Busted.Hook Runs after each test in a group
---@field teardown    local.Busted.Hook Runs once, last, after all tests in a group

---@see luassert.assert:register()
---@see luassert.namespaces
---
---@class (exact) local.Luassert.Registration
---@field name string
---@field callback fun(...: any): any
---@field negative_message string
---@field positive_message string

---@class local.Luassert.State
---@field mod boolean
---@field failure_message any?
---@field tokens string[] The list of underscore-delimited words used to assert/match
