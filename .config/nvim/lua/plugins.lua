-- Plugins (Lazy.nvim)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- Theme
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				integrations = { native_lsp = true, treesitter = true },
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},

	-- File tree
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("nvim-tree").setup({
				sort_by = "case_sensitive",
				view = { width = 30, side = "right" },
				renderer = { group_empty = true },
				filters = { dotfiles = false },
			})
		end,
	},

	-- Tabs / buffers
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup({
				options = {
					mode = "buffers",
					numbers = "none",
					show_buffer_close_icons = true,
					show_close_icon = true,
					separator_style = "thin",
				},
			})
		end,
	},

	-- Syntax highlighting (Treesitter)
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install({
				"python",
				"lua",
				"bash",
				"json",
				"yaml",
				"toml",
				"markdown",
				"markdown_inline",
			})
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "python", "lua", "bash", "json", "yaml", "toml", "markdown" },
				callback = function()
					vim.treesitter.start()
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					vim.wo.foldmethod = "expr"
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				end,
			})
		end,
	},

	-- LSP (ty: Python type-checker)
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
					map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")
					map("]d", vim.diagnostic.goto_next, "Next diagnostic")
				end,
			})
		end,
	},

	-- Completion (blink.cmp)
	{
		"saghen/blink.cmp",
		version = "*",
		opts = {
			sources = { default = { "lsp", "path", "buffer" } },
			keymap = {
				["<CR>"] = { "accept", "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
				["<C-e>"] = { "hide" },
			},
			completion = { documentation = { auto_show = true } },
		},
	},

	-- Formatting (conform.nvim)
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		opts = {
			formatters_by_ft = {
				python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
				lua = { "stylua" },
				toml = { "taplo" },
				yaml = { "yamlfmt" },
			},
			format_on_save = { timeout_ms = 500, lsp_fallback = true },
		},
	},

	-- Fuzzy finder (Telescope)
	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
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

	-- Git (gitsigns): inline blame + hunk navigation
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

	-- Cursor trail animation
	{
		"sphamba/smear-cursor.nvim",
		opts = {
			stiffness = 0.9,
			trailing_stiffness = 0.9,
			distance_stop_animating = 0.5,
		},
	},

	-- Highlight current word
	{
		"echasnovski/mini.cursorword",
		version = "*",
		config = function()
			require("mini.cursorword").setup({})
		end,
	},

	-- Seamless pane nav: Ctrl-h/j/k/l crosses nvim splits ↔ tmux panes
	{ "christoomey/vim-tmux-navigator", lazy = false },
}, {
	rocks = { enabled = false },
})
