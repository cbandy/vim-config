local vim = vim

vim.keymap.set('n', '<Leader>r', function() MiniTest.run() end, {
	buffer = true,
	desc = 'run all tests found by MiniTest',
})

vim.keymap.set('n', '<Leader>R', function() MiniTest.run_at_location() end, {
	buffer = true,
	desc = 'run the nearest test through MiniTest',
})
