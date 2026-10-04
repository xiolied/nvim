return {
  'stevearc/conform.nvim',
  config = function()
  require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		c = { "clang_format" },
		css = { "prettier" },
		html = { "prettier" },
		json = { "prettier" },
		jsonc = { "prettier" },
		yaml = { "prettier" },
		javascript = { "prettier" },
	},
})

vim.keymap.set("n", "<leader>fm", function()
	require("conform").format({ async = true })
end, { desc = "Format file" })
  end,
}
