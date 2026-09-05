return {
  "saghen/blink.cmp",
  version = "*",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  opts = {
    snippets = { preset = "default" },
    keymap = {
      preset = "none",
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
  },
}
