vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.laststatus = 3
vim.opt.fillchars:append({ diff = " " })
vim.opt.termguicolors = true
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.shortmess:append({ c = true, I = true })
vim.opt.updatetime = 100
vim.opt.timeoutlen = 300
vim.opt.grepprg = "rg --vimgrep --hidden"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.helplang = "ja,en"
