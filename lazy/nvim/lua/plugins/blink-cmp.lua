return {
	"saghen/blink.cmp",
	version = "*",
	opts = {
		keymap = {
			preset = "none",
			["<C-b>"] = { "select_next", "fallback" },
			["<C-h>"] = { "select_prev", "fallback" },
			["<C-n>"] = { "accept", "fallback" },
			["<C-space>"] = { "show", "fallback" },
		},
		completion = {
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
				treesitter_highlighting = true,
			},
			menu = {
				draw = {
					columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
				},
			},
		},
		sources = {
			default = { "lsp", "path", "buffer" },
			per_filetype = {
				lua = { "lazydev", "lsp", "path", "buffer" },
			},
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					score_offset = 100,
				},
			},
		},
	},
}
