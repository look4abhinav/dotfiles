-- Autocmds

-- Auto-save on focus lost / buffer leave
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
	pattern = "*",
	command = "silent! wall",
})

-- Terminal buffers: hide line numbers and name them "Terminal"
vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("terminal", { clear = true }),
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		pcall(vim.cmd.file, "Terminal")
	end,
})
