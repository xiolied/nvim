require("packui").setup({
  -- border = "rounded",
  -- keymaps = { ... },
})

vim.api.nvim_create_user_command("PackUI", function()
  require("packui").open()
end, { desc = "Open the packui dashboard for vim.pack" })

-- optional: quick keymap to open it, e.g. <leader>pu
vim.keymap.set("n", "<leader>pu", "<cmd>PackUI<CR>", { desc = "Plugin dashboard (packui)" })
