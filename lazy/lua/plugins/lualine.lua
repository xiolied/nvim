return {
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
}
