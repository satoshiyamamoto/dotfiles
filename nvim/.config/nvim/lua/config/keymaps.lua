-- Buffers
vim.keymap.set("n", "[b", "<Cmd>bprevious<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "]b", "<Cmd>bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "[B", "<Cmd>bfirst<CR>", { desc = "First buffer" })
vim.keymap.set("n", "]B", "<Cmd>blast<CR>", { desc = "Last buffer" })

-- Search (moved off <C-l> since that now aliases <C-w>l for window nav)
vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlight" })

-- Windows (plugin-free aliases for the built-in <C-w>h/j/k/l)
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Terminal
vim.keymap.set("t", "<Esc>", "<C-Bslash><C-n>", {})
vim.keymap.set("t", "<C-[>", "<C-Bslash><C-n>", {})
vim.keymap.set("t", "<C-w>", "<C-Bslash><C-n><C-w>", {})

-- IME
vim.keymap.set("i", "<C-S-J>", "<Nop>", {})
vim.keymap.set("i", "<C-S-;>", "<Nop>", {})
