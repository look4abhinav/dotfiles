-- Keymaps

-- Format buffer
vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ async = false, lsp_fallback = true })
end, { desc = "Format buffer" })

vim.keymap.set("n", "<leader>q", vim.cmd.q, { desc = "Close window" })
vim.keymap.set("n", "<leader>x", ":bdelete!<CR>", { silent = true, desc = "Close buffer" })
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true, desc = "Toggle file tree" })

-- Buffer navigation (Ctrl+Tab keeps <Tab>/<C-i> jumplist free)
vim.keymap.set("n", "<C-Tab>", ":BufferLineCycleNext<CR>", { silent = true, desc = "Next buffer" })
vim.keymap.set("n", "<C-S-Tab>", ":BufferLineCyclePrev<CR>", { silent = true, desc = "Prev buffer" })

-- Run Python file with uv (<leader>R avoids clash with <leader>rn rename)
vim.keymap.set("n", "<leader>R", function()
	vim.cmd("write")
	vim.cmd("botright 10split")
	vim.cmd("wincmd j")
	vim.cmd("term uv run " .. vim.fn.expand("%"))
	vim.cmd("startinsert")
end, { desc = "Run Python file" })

-- Toggle terminal
local state = { buf = -1 }
local function toggle_terminal()
	if not vim.api.nvim_buf_is_valid(state.buf) then
		for _, b in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_get_name(b):match("Terminal$") then
				vim.api.nvim_buf_delete(b, { force = true })
			end
		end
		vim.cmd("botright 15split | terminal")
		state.buf = vim.api.nvim_get_current_buf()
		vim.api.nvim_buf_set_name(state.buf, "Terminal")
		vim.cmd("startinsert")
	else
		local win = vim.fn.bufwinid(state.buf)
		if win ~= -1 then
			vim.api.nvim_win_close(win, true)
		else
			vim.cmd("botright 15split")
			vim.api.nvim_win_set_buf(0, state.buf)
			vim.cmd("startinsert")
		end
	end
end
vim.keymap.set("n", "<leader>t", toggle_terminal, { desc = "Toggle terminal" })
vim.keymap.set("t", "<leader>t", function()
	vim.cmd("stopinsert")
	toggle_terminal()
end, { desc = "Toggle terminal" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("t", "<leader>x", "<C-\\><C-n>:bdelete!<CR>", { silent = true, desc = "Kill terminal" })

-- Telescope: project search (VSCode-like)
vim.keymap.set("n", "<leader>sf", function()
	require("telescope.builtin").find_files()
end, { desc = "Search files" })
vim.keymap.set("n", "<leader>sg", function()
	require("telescope.builtin").live_grep()
end, { desc = "Search in project (grep)" })
vim.keymap.set("n", "<leader>sw", function()
	require("telescope.builtin").live_grep({
		default_text = vim.fn.expand("<cword>"),
	})
end, { desc = "Search word under cursor" })
vim.keymap.set("n", "<leader>sb", function()
	require("telescope.builtin").buffers()
end, { desc = "Search buffers" })
vim.keymap.set("n", "<leader>sd", function()
	require("telescope.builtin").diagnostics()
end, { desc = "Search diagnostics" })
vim.keymap.set("n", "<leader>ss", function()
	require("telescope.builtin").lsp_document_symbols()
end, { desc = "Search symbols" })
vim.keymap.set("n", "<leader>sk", function()
	require("telescope.builtin").keymaps({ show_plug = false })
end, { desc = "Search keymaps" })

-- Git (gitsigns): blame + hunks
vim.keymap.set("n", "<leader>gb", function()
	require("gitsigns").toggle_current_line_blame()
end, { desc = "Git blame (inline)" })
vim.keymap.set("n", "<leader>gB", function()
	require("gitsigns").toggle_blame_line()
end, { desc = "Git blame (all lines)" })
vim.keymap.set("n", "<leader>gp", function()
	require("gitsigns").preview_hunk()
end, { desc = "Git preview hunk" })
vim.keymap.set("n", "<leader>gs", function()
	require("gitsigns").stage_hunk()
end, { desc = "Git stage hunk" })
vim.keymap.set("n", "<leader>gr", function()
	require("gitsigns").reset_hunk()
end, { desc = "Git reset hunk" })
vim.keymap.set("n", "]h", function()
	require("gitsigns").nav_hunk("next")
end, { desc = "Next git hunk" })
vim.keymap.set("n", "[h", function()
	require("gitsigns").nav_hunk("prev")
end, { desc = "Prev git hunk" })
