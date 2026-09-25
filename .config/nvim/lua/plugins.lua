-- Plugins (Lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},

	{
		"nvim-tree/nvim-tree.lua",
		dependencies = "nvim-tree/nvim-web-devicons",
		cmd = { "NvimTreeToggle" },
		config = function()
			require("nvim-tree").setup({
				sort = { sorter = "case_sensitive" },
				view = { width = 30, side = "right" },
				renderer = { group_empty = true },
				filters = { dotfiles = false },
			})
		end,
	},

	{
		"akinsho/bufferline.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		cmd = { "BufferLineCycleNext", "BufferLineCyclePrev" },
		config = function()
			require("bufferline").setup({
				options = {
					mode = "buffers",
					numbers = "none",
					show_buffer_close_icons = true,
					show_close_icon = true,
					close_command = "confirm bdelete %d",
					right_mouse_command = "confirm bdelete %d",
					separator_style = "thin",
				},
			})
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			local treesitter = require("nvim-treesitter")
			local parsers = {
				"python",
				"lua",
				"bash",
				"json",
				"yaml",
				"toml",
				"markdown",
				"markdown_inline",
			}
			local installed = treesitter.get_installed("parsers")
			local missing = vim.tbl_filter(function(parser)
				return not vim.list_contains(installed, parser)
			end, parsers)

			if #missing > 0 then
				local ok, result = treesitter.install(missing, { summary = true }):pwait(60000)
				if not ok or not result then
					vim.notify("nvim-treesitter parser installation failed: " .. tostring(result), vim.log.levels.ERROR)
				end
			end
		end,
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			vim.lsp.config("ty", {
				settings = {
					ty = {
						diagnosticMode = "workspace",
						inlayHints = {
							variableTypes = true,
							callArgumentNames = true,
						},
						completions = { autoImport = false },
					},
				},
			})
			vim.lsp.enable("ty")

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local function map(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
					end
					map("gd", vim.lsp.buf.definition, "Go to definition")
					map("gr", function()
						require("telescope.builtin").lsp_references()
					end, "Find references")
					map("K", vim.lsp.buf.hover, "Hover documentation")
					map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
					map("<leader>ca", vim.lsp.buf.code_action, "Code action")
					map("[d", function()
						vim.diagnostic.jump({ count = -1, float = true })
					end, "Prev diagnostic")
					map("]d", function()
						vim.diagnostic.jump({ count = 1, float = true })
					end, "Next diagnostic")
					vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
					require("mini.clue").ensure_buf_triggers(args.buf)
				end,
			})
		end,
	},

	{
		"saghen/blink.cmp",
		-- main is v2, which needs saghen/blink.lib plus a rust build; track the release instead
		version = "*",
		opts = {
			sources = { default = { "lsp", "path", "buffer" } },
			signature = {
				enabled = true,
				window = { border = "rounded", show_documentation = true },
			},
			keymap = {
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide", "fallback" },
			},
			completion = { documentation = { auto_show = true } },
		},
	},

	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		opts = {
			formatters_by_ft = {
				python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
				lua = { "stylua" },
				toml = { "taplo" },
				yaml = { "yamlfmt" },
				sh = { "shfmt" },
				bash = { "shfmt" },
			},
			format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
		},
	},

	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufWritePost" },
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				sh = { "shellcheck" },
				bash = { "shellcheck" },
			}
			vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
				callback = function(args)
					-- lint.try_lint() targets the current buffer, so run it in the event buffer
					vim.api.nvim_buf_call(args.buf, function()
						lint.try_lint()
					end)
				end,
			})
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
		keys = {
			{ "<leader>sf", "<cmd>Telescope find_files<CR>", desc = "Search files" },
			{ "<leader>sg", "<cmd>Telescope live_grep<CR>", desc = "Search in project (grep)" },
			{
				"<leader>sw",
				function()
					require("telescope.builtin").live_grep({
						default_text = vim.fn.expand("<cword>"),
					})
				end,
				desc = "Search word under cursor",
			},
			{ "<leader>sb", "<cmd>Telescope buffers<CR>", desc = "Search buffers" },
			{ "<leader>sd", "<cmd>Telescope diagnostics<CR>", desc = "Search diagnostics" },
			{ "<leader>ss", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Search symbols" },
			{ "<leader>sk", "<cmd>Telescope keymaps show_plug=false<CR>", desc = "Search keymaps" },
		},
		config = function()
			require("telescope").setup({
				defaults = {
					path_display = { "truncate" },
					file_ignore_patterns = { "node_modules", ".git/", "__pycache__", ".venv" },
					sorting_strategy = "ascending",
					layout_config = { prompt_position = "top" },
					mappings = {
						i = {
							["<C-j>"] = "move_selection_next",
							["<C-k>"] = "move_selection_previous",
							["<Esc>"] = "close",
						},
					},
				},
				pickers = {
					find_files = { hidden = true },
					live_grep = { additional_args = { "--hidden", "--glob=!.git/*" } },
				},
			})
		end,
	},

	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("gitsigns").setup({
				current_line_blame = true,
				current_line_blame_opts = { delay = 250 },
			})
		end,
	},

	{
		"sphamba/smear-cursor.nvim",
		opts = {
			stiffness = 0.9,
			trailing_stiffness = 0.9,
			distance_stop_animating = 0.5,
		},
	},

	{
		"nvim-mini/mini.cursorword",
		opts = {},
	},

	{
		"nvim-mini/mini.comment",
		opts = {},
	},

	{
		"nvim-mini/mini.surround",
		opts = {},
	},

	{
		"nvim-mini/mini.clue",
		opts = function()
			local clue = require("mini.clue")
			return {
				triggers = {
					{ mode = { "n", "x" }, keys = "<Leader>" },
					{ mode = { "n", "x" }, keys = "g" },
					{ mode = { "n", "x" }, keys = "z" },
					{ mode = "n", keys = "[" },
					{ mode = "n", keys = "]" },
					{ mode = "n", keys = "<C-w>" },
				},
				clues = {
					clue.gen_clues.g(),
					clue.gen_clues.z(),
					clue.gen_clues.windows(),
				},
			}
		end,
	},

	{ "christoomey/vim-tmux-navigator", lazy = false },

	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
		ft = { "markdown" },
		opts = {},
	},
}, {
	rocks = { enabled = false },
})
