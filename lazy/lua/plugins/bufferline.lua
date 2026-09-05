return {
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
}
