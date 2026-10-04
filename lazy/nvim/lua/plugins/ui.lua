return {
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup({
				options = {
					mode = "buffers",
					always_show_bufferline = false,
					separator_style = { "", "" },
					show_buffer_close_icons = false,
					show_close_icon = false,
					color_icons = true,
					diagnostics = "nvim_lsp",
					indicator = {
						style = "none",
					},
				},
			})

			vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { silent = true, desc = "Next buffer" })
			vim.keymap.set("n", "<S-Tab>", ":BufferLineCyclePrev<CR>", { silent = true, desc = "Prev buffer" })
			vim.keymap.set("n", "<leader>x", ":bdelete<CR>", { silent = true, desc = "Close buffer" })
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			require("lualine").setup({
				options = {
					icons_enabled = true,
					theme = "auto",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						"branch",
						"diff",
						"diagnostics",
						"filename",
					},
					lualine_c = {},
					lualine_x = { "" },
					lualine_y = { "encoding", "fileformat", "filetype", "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
			})
			vim.api.nvim_set_hl(0, "lualine_c_normal", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "lualine_c_insert", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "lualine_c_visual", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "lualine_c_visual-line", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "lualine_c_replace", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "lualine_c_command", { bg = "NONE" })
		end,
	},
	{
		"rcarriga/nvim-notify",
		config = function()
			local notify = require("notify")
			notify.setup({
				background_colour = "#000000",
			})
			vim.notify = notify
		end,
	},
	{
		"nvim-mini/mini.indentscope",
		config = function()
			vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { link = "Comment" })
			require("mini.indentscope").setup({
				draw = {
					delay = 50,
				},
				options = {
					border = "both",
					indent_at_cursor = true,
					n_lines = 10000,
					try_as_border = false,
				},
				symbol = "│",
			})
		end,
	},
}
