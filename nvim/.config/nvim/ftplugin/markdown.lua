vim.b.snacks_indent = false

-- Treesitter highlights (Glow glamour dark.json colors)
-- https://github.com/charmbracelet/glamour/blob/master/styles/dark.json

local ns = vim.api.nvim_create_namespace("markdown_normal")
-- Text: document.color 252
vim.api.nvim_set_hl(ns, "Normal", { fg = "#D0D0D0", bg = "NONE" })
-- Heading: heading.color 39 / h1: 228/63 / h6: 35
vim.api.nvim_set_hl(ns, "@markup.heading.markdown", { link = "Normal" }) -- fallback for table header cells
vim.api.nvim_set_hl(ns, "@markup.heading.1.markdown", { fg = "#FFFF87", bg = "#5F5FFF", bold = true })
vim.api.nvim_set_hl(ns, "@markup.heading.2.markdown", { fg = "#00AFFF", bold = true })
vim.api.nvim_set_hl(ns, "@markup.heading.3.markdown", { fg = "#00AFFF", bold = true })
vim.api.nvim_set_hl(ns, "@markup.heading.4.markdown", { fg = "#00AFFF", bold = true })
vim.api.nvim_set_hl(ns, "@markup.heading.5.markdown", { fg = "#00AFFF", bold = true })
vim.api.nvim_set_hl(ns, "@markup.heading.6.markdown", { fg = "#00AF5F" })
-- List
vim.api.nvim_set_hl(ns, "@markup.list.markdown", { link = "Normal" })
-- Code: code.color 203/236 / code_block.chroma.text #C4C4C4
vim.api.nvim_set_hl(ns, "@markup.raw.markdown_inline", { link = "RenderMarkdownCodeInline" })
vim.api.nvim_set_hl(ns, "@markup.raw.block.markdown", { fg = "#C4C4C4" })

vim.api.nvim_win_set_hl_ns(0, ns)
