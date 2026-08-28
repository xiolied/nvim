local cmp = require('blink.cmp')
cmp.build():pwait()
cmp.setup({
    keymap = {
        ['<Tab>'] = { 'select_next', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
    },
})
 
