-- Run from the repository root: nvim --clean --headless -l nvim/tests/hover_background.lua
package.preload["blink.cmp"] = function()
  return {
    get_lsp_capabilities = function()
      return {}
    end,
  }
end
dofile("nvim/.config/nvim/lua/plugins/lsp.lua")[1].config()

for _, focus_id in ipairs({ "textDocument/hover", "rust-analyzer-hover-actions", "textDocument/signatureHelp" }) do
  local _, win = vim.lsp.util.open_floating_preview({ "Documentation" }, "text", { focus_id = focus_id })
  local is_hover = focus_id ~= "textDocument/signatureHelp"
  assert((vim.wo[win].winhighlight:find("NormalNC:LspHover", 1, true) ~= nil) == is_hover)
  assert(vim.wo[win].winblend == (is_hover and 10 or 0))
  vim.api.nvim_win_close(win, true)
end
print("PASS: hover background mappings apply only to native/Rust hover")
