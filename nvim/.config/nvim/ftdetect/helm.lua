vim.filetype.add({
  pattern = {
    [".*/templates/.*%.yaml"] = "gotmpl",
    [".*/templates/.*%.tpl"] = "gotmpl",
  },
})
