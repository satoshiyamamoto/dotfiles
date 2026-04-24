vim.g.mapleader = " "

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.commands")
require("config.lazy")

vim.cmd('packadd nvim.difftool')
vim.cmd('packadd nvim.undotree')
