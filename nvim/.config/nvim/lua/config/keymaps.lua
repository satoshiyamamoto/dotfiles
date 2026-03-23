-- Buffers
vim.keymap.set("n", "[b", "<Cmd>bprevious<CR>", {})
vim.keymap.set("n", "]b", "<Cmd>bnext<CR>", {})
vim.keymap.set("n", "[B", "<Cmd>bfirst<CR>", {})
vim.keymap.set("n", "]B", "<Cmd>blast<CR>", {})
vim.keymap.set("n", "<Leader>bd", "<Cmd>bp | bd #<CR>", {})

-- Diagnostics
vim.keymap.set("n", "[q", "<Cmd>cprevious<CR>", {})
vim.keymap.set("n", "]q", "<Cmd>cnext<CR>", {})
vim.keymap.set("n", "gl", vim.diagnostic.open_float, {})
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, {})
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, {})
vim.keymap.set("n", "<Leader>q", vim.diagnostic.setloclist, {})

-- Terminal
vim.keymap.set("t", "<Esc>", "<C-Bslash><C-n>", {})
vim.keymap.set("t", "<C-[>", "<C-Bslash><C-n>", {})
vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>", {})
