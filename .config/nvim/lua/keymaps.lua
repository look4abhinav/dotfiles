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
	local file = vim.fn.expand("%")
	if file == "" then
		vim.notify("No file to run", vim.log.levels.WARN)
		return
	end
	vim.cmd("write")
	vim.cmd("botright 10split")
	vim.cmd("wincmd j")
	vim.cmd("term uv run " .. vim.fn.shellescape(file))
	vim.cmd("startinsert")
end, { desc = "Run Python file with uv" })

-- Toggle terminal; tracks its buffer so it can never close other terminals
local term = { buf = -1 }

local function open_terminal(buf)
	vim.cmd("botright 15split")
	if vim.api.nvim_buf_is_valid(buf) then
		vim.api.nvim_win_set_buf(0, buf)
	else
		vim.cmd("terminal")
	end
	vim.cmd("startinsert")
end

local function toggle_terminal()
	if vim.api.nvim_buf_is_valid(term.buf) then
		local win = vim.fn.bufwinid(term.buf)
		if win ~= -1 then
			vim.api.nvim_win_close(win, true)
		else
			open_terminal(term.buf)
		end
	else
		open_terminal(term.buf)
		term.buf = vim.api.nvim_get_current_buf()
	end
end
vim.keymap.set("n", "<leader>t", toggle_terminal, { desc = "Toggle terminal" })
vim.keymap.set("t", "<leader>t", function()
	vim.cmd("stopinsert")
	toggle_terminal()
end, { desc = "Toggle terminal" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("t", "<leader>x", "<C-\\><C-n>:bdelete!<CR>", { silent = true, desc = "Kill terminal" })

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
