vim.o.number = true
vim.o.relativenumber = true

vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true

vim.o.termguicolors = true

vim.o.cursorline = true

vim.o.scrolloff = 8
vim.o.signcolumn = "yes"
vim.o.colorcolumn = "110"

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

