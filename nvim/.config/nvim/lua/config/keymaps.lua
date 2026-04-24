-- Buffers
vim.keymap.set("n", "[b", "<Cmd>bprevious<CR>", {})
vim.keymap.set("n", "]b", "<Cmd>bnext<CR>", {})
vim.keymap.set("n", "[B", "<Cmd>bfirst<CR>", {})
vim.keymap.set("n", "]B", "<Cmd>blast<CR>", {})
vim.keymap.set("n", "<Leader>bd", "<Cmd>bp | bd #<CR>", {})

-- Undotree
vim.keymap.set('n', '<Leader>u', '<Cmd>Undotree<CR>', { desc = 'Undotree' })

-- Terminal
vim.keymap.set("t", "<Esc>", "<C-Bslash><C-n>", {})
vim.keymap.set("t", "<C-[>", "<C-Bslash><C-n>", {})
vim.keymap.set("t", "<C-w>", "<C-Bslash><C-n><C-w>", {})
