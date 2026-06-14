-- Buffers
vim.keymap.set("n", "[b", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "]b", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "[B", "<Cmd>bfirst<CR>", { desc = "First buffer" })
vim.keymap.set("n", "]B", "<Cmd>blast<CR>", { desc = "Last buffer" })
vim.keymap.set("n", "<Leader>bd", function() Snacks.bufdelete() end, { desc = "Delete buffer (keep layout)" })
vim.keymap.set("n", "<Leader>bo", "<Cmd>BufferLineCloseOthers<CR>", { desc = "Close other buffers" })
vim.keymap.set("n", "<Leader>bp", "<Cmd>BufferLinePick<CR>", { desc = "Pick buffer" })
-- Jump to buffer by ordinal position (matches the numbers shown in bufferline)
for i = 1, 9 do
  vim.keymap.set("n", "<Leader>" .. i, "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "Go to buffer " .. i })
end
vim.keymap.set("n", "<Leader>0", "<Cmd>BufferLineGoToBuffer -1<CR>", { desc = "Go to last buffer" })

-- Undotree
vim.keymap.set("n", "<Leader>u", "<Cmd>Undotree<CR>", { desc = "Undotree" })

-- Terminal
vim.keymap.set("t", "<Esc>", "<C-Bslash><C-n>", {})
vim.keymap.set("t", "<C-[>", "<C-Bslash><C-n>", {})
vim.keymap.set("t", "<C-w>", "<C-Bslash><C-n><C-w>", {})

-- IME
vim.keymap.set("i", "<C-S-J>", "<Nop>", {})
vim.keymap.set("i", "<C-S-;>", "<Nop>", {})
