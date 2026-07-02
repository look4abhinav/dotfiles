-- Settings
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

vim.g.mapleader = " "

vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 250
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.virtualedit = "onemore"
vim.opt.guicursor =
	"n-v-c:block-blinkwait300-blinkon200-blinkoff150,i-ci-ve:ver25-blinkwait300-blinkon200-blinkoff150,r-cr:hor20-blinkwait300-blinkon200-blinkoff150,o:hor50-blinkwait300-blinkon200-blinkoff150"

-- Clipboard over OSC 52 (works through SSH)
vim.g.clipboard = {
	name = "OSC 52",
	copy = {
		["+"] = require("vim.ui.clipboard.osc52").copy("+"),
		["*"] = require("vim.ui.clipboard.osc52").copy("*"),
	},
	paste = {
		["+"] = require("vim.ui.clipboard.osc52").paste("+"),
		["*"] = require("vim.ui.clipboard.osc52").paste("*"),
	},
}
vim.opt.clipboard = "unnamedplus"

vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 4 },
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})
