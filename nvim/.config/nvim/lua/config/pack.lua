require("vim._core.ui2").enable({
  msg = { targets = { progress = "msg", lsp_message = "msg" } },
})

vim.cmd.packadd("cfilter")
vim.cmd.packadd("nvim.difftool")
vim.cmd.packadd("nvim.undotree")
vim.keymap.set("n", "<Leader>u", "<Cmd>Undotree<CR>", { desc = "Undotree" })
