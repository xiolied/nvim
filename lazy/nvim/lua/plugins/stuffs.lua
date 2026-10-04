return {
	-- nvim-autopairs
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup()
		end,
	},
	-- lazydev
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	-- transparent
	{
		"xiyaowong/transparent.nvim",
		config = function()
			require("transparent").setup({
				enable = true,
				extra_groups = {
					"SnacksNormal",
					"SnacksNormalNC",
					"SnacksDashboardHeader",
					"SnacksDashboardDesc",
					"SnacksDashboardKey",
					"SnacksDashboardIcon",
					"SnacksDashboardFooter",
					"SnacksDashboardSpecial",
					"SnacksNotifier",
					"SnacksNotifierBorder",
				},
			})
		end,
	},
	-- which-key
	{
		"folke/which-key.nvim",
		config = function()
			require("which-key").setup({
				layout = {
					width = { min = 20 },
					spacing = 3,
					align = "right",
				},
				win = {
					width = { min = 20, max = 0.9 },
				},
			})
			require("which-key").add({
				{ "<leader>h", group = "Harpoon" },
			})
		end,
	},
	-- modicators
	{
		"mawkler/modicator.nvim",
		dependencies = "vague-theme/vague.nvim",
		opts = {
			show_warnings = true,
		},
	},
	-- highlight lens
	{
		"kevinhwang91/nvim-hlslens",
		config = function()
			require("hlslens").setup({})
		end,
	},
	-- tabout
	{
		"abecodes/tabout.nvim",
		config = function()
			require("tabout").setup()
		end,
	},
	-- fidget
	{
		"j-hui/fidget.nvim",
		config = function()
			require("fidget").setup()
		end,
	},
	-- live-server
	{
		"selimacerbas/live-server.nvim",
		cmd = { "LiveServerStart", "LiveServerStop", "LiveServerToggleLive" },
		keys = {
			{ "<leader>ls", "<cmd>LiveServerStart<cr>", desc = "Start Live Server" },
			{ "<leader>lx", "<cmd>LiveServerStop<cr>", desc = "Stop Live Server" },
		},
		opts = {
			open_on_start = true,
		},
	},
	-- nvim-ts-autotag
	{
		"windwp/nvim-ts-autotag",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {
			opts = {
				enable_close = true, -- <div>  ->  <div></div>
				enable_rename = true, -- rename the closing tag when you edit the opening one
				enable_close_on_slash = false, -- set true to also complete when typing </
			},
		},
	},
}
