require("oil").setup({
    default_file_explorer = true,
    view_options = {
        show_hidden = true,
    },
    keymaps = {
        ["-"] = "actions.parent",
    },
})

vim.keymap.set('n', '<leader>pv', ':Oil<CR>', { silent = true, desc = "Open file explorer" })
