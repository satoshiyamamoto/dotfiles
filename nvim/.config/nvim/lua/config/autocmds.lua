-- Autocmds are defined inside each plugin's config function (see lua/plugins/)

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*/git/config.*",
  callback = function() vim.bo.filetype = "gitconfig" end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "json",
  callback = function() vim.opt_local.formatprg = "jq ." end,
})
