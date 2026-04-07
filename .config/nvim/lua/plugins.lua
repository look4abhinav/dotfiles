-- [4] PACKAGE MANAGER (LAZY.NVIM)
-- --------------------------------------------------------------------------
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

-- [5] PLUGINS
-- --------------------------------------------------------------------------
require("lazy").setup({

	-- 5.1 THEME
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			require("catppuccin").setup({
				flavour = "mocha",
				integrations = { cmp = true, native_lsp = true, treesitter = true },
			})
			vim.cmd.colorscheme("catppuccin")
		end,
	},

	-- 5.2 FILE TREE
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

	-- 5.3 TABS
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

	-- 5.4 SYNTAX HIGHLIGHTING
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install({ "python", "markdown", "lua" })
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "python", "lua", "c", "vim" },
				callback = function()
					vim.treesitter.start()
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					vim.wo.foldmethod = "expr"
					vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
				end,
			})
		end,
	},

	-- 5.5 LSP
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- 1. Enables Inline Errors
			vim.diagnostic.config({
				virtual_text = {
					prefix = "●",
				},
				signs = true,
				underline = true,
				update_in_insert = false,
			})
			-- 2. Ty setup
			vim.lsp.config("ty", {
				settings = {
					ty = {
						diagnosticMode = "workspace",
						inlayHints = {
							variableTypes = true,
							callArgumentNames = true,
						},
						completions = {
							autoImport = false,
						},
					},
				},
			})
			vim.lsp.enable("ty")

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local opts = { buffer = args.buf }
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
				end,
			})
		end,
	},

	-- 5.6 AUTOCOMPLETION
	{
		"hrsh7th/nvim-cmp",
		dependencies = { "hrsh7th/cmp-nvim-lsp" },
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				sources = { { name = "nvim_lsp" } },
				mapping = cmp.mapping.preset.insert({
					["<CR>"] = cmp.mapping.confirm({ select = true }),
					["<Tab>"] = cmp.mapping.select_next_item(),
				}),
			})
		end,
	},

	-- 5.7 FORMATTING
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

	-- 5.8 CURSOR TRAIL ANIMATIONS
	{
		"sphamba/smear-cursor.nvim",
		opts = {
			stiffness = 0.9,
			trailing_stiffness = 0.9,
			distance_stop_animating = 0.5,
		},
	},

	-- 5.9 HIGHLIGHT CURRENT WORD
	{
		"echasnovski/mini.cursorword",
		version = "*",
		config = function()
			require("mini.cursorword").setup({
				delay = 100,
			})
		end,
	},
}, {
	rocks = { enabled = false },
})
