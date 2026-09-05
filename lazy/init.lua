require("options")
require("keymaps")
require("config.lazy")
vim.cmd.colorscheme('vague')

-- lsp-servers
vim.lsp.enable("lua_ls")
vim.lsp.enable("clangd")
vim.lsp.enable("cssls")
vim.lsp.enable("jsonls")
vim.lsp.enable('rust_analyzer')
