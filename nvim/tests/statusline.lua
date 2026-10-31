-- Run from the repository root: nvim --clean --headless -l nvim/tests/statusline.lua
local specs = dofile("nvim/.config/nvim/lua/plugins/ui.lua")
local lualine
for _, spec in ipairs(specs) do
  if spec[1] == "nvim-lualine/lualine.nvim" then
    lualine = spec
  end
end
assert(lualine)

local callback
local refreshes, redraws = 0, 0
vim.ui_attach = function(_, opts, handler)
  assert(opts.ext_messages and opts.set_cmdheight == false)
  callback = handler
end
package.loaded.lualine = {
  refresh = function(opts)
    assert(opts.force and opts.place[1] == "statusline")
    refreshes = refreshes + 1
  end,
}
vim.api.nvim__redraw = function(opts)
  assert(opts.statusline and opts.flush)
  redraws = redraws + 1
end

lualine.init()
vim.api.nvim_exec_autocmds("UIEnter", {})
assert(callback, "UI status subscription missing")
local components = lualine.opts().sections.lualine_x
local function check(command, mode)
  assert(components[1][1]() == command, "pending keys differ")
  assert(components[2][1]() == mode, "recording/mode status differs")
end

check("", "")
assert(callback("msg_showcmd", { { 0, "3" }, { 0, "d" } }) == nil)
check("3d", "")
callback("msg_showmode", { { 0, "recording @a" } })
check("3d", "recording @a")
callback("msg_showcmd", {})
check("", "recording @a")
callback("msg_showmode", {})
check("", "")
callback("msg_showcmd", { { 0, "%" } })
check("%%", "")
callback("msg_show", { { 0, "unrelated" } })
check("%%", "")
assert(refreshes == 5 and redraws == 5, "status updates must redraw immediately")
print("PASS: pending keys, macro recording, clearing, literal %, immediate redraw")
