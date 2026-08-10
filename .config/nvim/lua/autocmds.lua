-- Autocmds
local augroup = vim.api.nvim_create_augroup("Config", { clear = true })

-- Save the buffer on focus lost / buffer leave
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
	group = augroup,
	callback = function()
		if vim.bo.buftype == "" and vim.bo.modifiable and vim.fn.expand("%") ~= "" then
			vim.cmd("silent write")
		end
	end,
})

-- Terminal buffers: hide line numbers
vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
	end,
})

-- Treesitter indentation and folding
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "python", "lua", "sh", "bash", "json", "yaml", "toml", "markdown" },
	callback = function()
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		vim.wo.foldmethod = "expr"
		vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
	end,
})
