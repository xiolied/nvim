--o plugins install
vim.pack.add({
	{ src = "https://github.com/vague-theme/vague.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/saghen/blink.cmp", build = 'nix-shell -p cargo --run "cargo build --release"' },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/windwp/nvim-autopairs" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/akinsho/bufferline.nvim" },
	{ src = "https://github.com/xiyaowong/transparent.nvim" },
	{ src = "https://github.com/rcarriga/nvim-notify" },
	{ src = "https://github.com/brenoprata10/nvim-highlight-colors" },
	{ src = "https://github.com/j-hui/fidget.nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	--{src = ''},
	-- dependecies
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/saghen/blink.lib",
})
-- pluigins add and configuration
require("options")
require("remaps")
require("plugins.colors")
require("plugins.lsp")
require("plugins.cmp")
require("plugins.oil")
require("nvim-autopairs").setup()
require("plugins.formatting")
require("plugins.bufferline")
require('nvim-highlight-colors').setup()
require("plugins.wkey")
require("plugins.lualine")
require("plugins.nixd")
require("fidget").setup()
require("plugins.packui")


