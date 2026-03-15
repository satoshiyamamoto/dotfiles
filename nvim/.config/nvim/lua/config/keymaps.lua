-- Buffers
vim.keymap.set("n", "[b", "<Cmd>bprevious<CR>", {})
vim.keymap.set("n", "]b", "<Cmd>bnext<CR>", {})
vim.keymap.set("n", "[B", "<Cmd>bfirst<CR>", {})
vim.keymap.set("n", "]B", "<Cmd>blast<CR>", {})
vim.keymap.set("n", "<Leader>bd", "<Cmd>bp | bd #<CR>", {})

-- Windows
vim.keymap.set("n", "<C-j>", "<C-w>j", {})
vim.keymap.set("n", "<C-k>", "<C-w>k", {})
vim.keymap.set("n", "<C-h>", "<C-w>h", {})
vim.keymap.set("n", "<C-l>", "<C-w>l", {})
vim.keymap.set("t", "<C-w>", "<C-\\><C-n><C-w>", {})

vim.keymap.set("n", "<C-Up>", "<Cmd>resize +2<CR>", {})
vim.keymap.set("n", "<C-Down>", "<Cmd>resize -2<CR>", {})
vim.keymap.set("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", {})
vim.keymap.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", {})

-- Diagnostics
vim.keymap.set("n", "[q", "<Cmd>cprevious<CR>", {})
vim.keymap.set("n", "]q", "<Cmd>cnext<CR>", {})
vim.keymap.set("n", "gl", vim.diagnostic.open_float, {})
vim.keymap.set("n", "[d", function()
  vim.diagnostic.jump({ count = -1 })
end, {})
vim.keymap.set("n", "]d", function()
  vim.diagnostic.jump({ count = 1 })
end, {})
vim.keymap.set("n", "<Leader>q", vim.diagnostic.setloclist, {})

-- Terminal
vim.keymap.set({ "n", "t" }, "<C-\\>", "<Cmd>ToggleTerm<CR>", {})
vim.keymap.set("t", "<Esc>", "<C-Bslash><C-n>", {})
vim.keymap.set("t", "<C-[>", "<C-Bslash><C-n>", {})
