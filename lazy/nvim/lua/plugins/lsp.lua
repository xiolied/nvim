return {
	{
		"mason-org/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities({
				textDocument = {
					completion = {
						completionItem = {
							snippetSupport = false,
						},
					},
				},
			})

			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			local web_capabilities = require("blink.cmp").get_lsp_capabilities()

			for _, server in ipairs({ "html", "cssls", "ts_ls"}) do
				vim.lsp.config(server, { capabilities = web_capabilities })
			end
		end,
	},

	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = {
			"mason-org/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({})
		end,
	},

	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"lua-language-server",
					"clangd",
					"css-lsp",
					"html-lsp",
					"json-lsp",
					"rust-analyzer",
					"typescript-language-server",
					"bash-language-server",
					"vim-language-server",
					"stylua",
					"shellcheck",
					"editorconfig-checker",
					"luacheck",
				},
			})
		end,
	},
}
