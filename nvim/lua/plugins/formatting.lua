require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		nix = { "alejandra" },
		c = { "clang_format" },
		css = { "prettier" },
		html = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		yaml = { "prettier" },
		javascript = { "prettier" },
		rust = { "rustfmt" },
	},
})

vim.keymap.set("n", "<leader>fm", function()
	require("conform").format({ async = true })
end, { desc = "Format file" })
