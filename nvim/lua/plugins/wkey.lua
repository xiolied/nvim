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
