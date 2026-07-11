-- Buffers
vim.keymap.set("n", "[b", "<Cmd>bprevious<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "]b", "<Cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "[B", "<Cmd>bfirst<CR>", { desc = "First buffer" })
vim.keymap.set("n", "]B", "<Cmd>blast<CR>", { desc = "Last buffer" })

-- Search (moved off <C-l> since that now aliases <C-w>l for window nav)
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlight" })

-- Terminal
vim.keymap.set("t", "<Esc>", "<C-Bslash><C-n>", {})
vim.keymap.set("t", "<C-[>", "<C-Bslash><C-n>", {})
vim.keymap.set("t", "<C-w>", "<C-Bslash><C-n><C-w>", {})

-- IME
vim.keymap.set("i", "<C-S-J>", "<Nop>", {})
vim.keymap.set("i", "<C-S-;>", "<Nop>", {})
