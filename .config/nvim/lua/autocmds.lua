-- Autocmds
local augroup = vim.api.nvim_create_augroup("Config", { clear = true })

-- Save the buffer on focus lost / buffer leave
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave" }, {
	group = augroup,
	callback = function(args)
		local buf = args.buf
		local bo = vim.bo[buf]
		if not bo.modified or bo.readonly or bo.buftype ~= "" or not bo.modifiable then
			return
		end
		if vim.api.nvim_buf_get_name(buf) == "" then
			return
		end
		vim.api.nvim_buf_call(buf, function()
			vim.cmd("silent write")
		end)
	end,
})

-- Terminal buffers: hide line numbers
vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup,
	callback = function(args)
		local win = vim.fn.bufwinid(args.buf)
		if win == -1 then
			return
		end
		vim.wo[win].number = false
		vim.wo[win].relativenumber = false
	end,
})

-- Treesitter highlighting, indentation and folding
local treesitter_filetypes = {
	bash = true,
	json = true,
	lua = true,
	markdown = true,
	python = true,
	sh = true,
	toml = true,
	yaml = true,
}

local treesitter_foldexpr = "v:lua.vim.treesitter.foldexpr()"
local treesitter_indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

local function setup_treesitter_window(buf)
	local enabled = treesitter_filetypes[vim.bo[buf].filetype] == true
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		if enabled then
			vim.wo[win].foldmethod = "expr"
			vim.wo[win].foldexpr = treesitter_foldexpr
		elseif vim.wo[win].foldexpr == treesitter_foldexpr then
			vim.wo[win].foldmethod = "manual"
			vim.wo[win].foldexpr = ""
		end
	end
end

local function setup_treesitter(args)
	local buf = args.buf
	if treesitter_filetypes[vim.bo[buf].filetype] then
		pcall(vim.treesitter.start, buf)
		vim.bo[buf].indentexpr = treesitter_indentexpr
	elseif vim.bo[buf].indentexpr == treesitter_indentexpr then
		vim.bo[buf].indentexpr = ""
	end
	setup_treesitter_window(buf)
end

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
	group = augroup,
	callback = setup_treesitter,
})
