return {
	{
		"vague-theme/vague.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
		config = function()
			require("vague").setup({
				(vim.cmd.colorscheme("vague")),
			})
		end,
	},
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
		config = function()
			require("tokyonight").setup({
				--(vim.cmd.colorscheme("tokyonight-night")),
			})
		end,
	},
}
