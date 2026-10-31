-- Run from the repository root: nvim --clean --headless -l nvim/tests/progress.lua
dofile("nvim/.config/nvim/lua/config/autocmds.lua")
local messages = {}
local echo = vim.api.nvim_echo
vim.api.nvim_echo = function(chunks, history, opts)
  assert(not history and opts.kind == "progress" and opts.source == "vim.lsp")
  messages[#messages + 1] = { text = chunks[1][1], opts = opts }
end
local function emit(client_id, value)
  vim.api.nvim_exec_autocmds("LspProgress", {
    pattern = type(value) == "table" and value.kind or "report",
    data = { client_id = client_id, params = { token = "index", value = value } },
  })
end

emit(1, { kind = "begin", title = "Indexing", percentage = 0 })
assert(messages[1].text == "Indexing" and messages[1].opts.status == "running")
emit(1, { kind = "report", message = "Loading files", percentage = 50 })
assert(messages[2].text == "Loading files" and messages[2].opts.percent == 50)
assert(messages[1].opts.id == messages[2].opts.id)
emit(2, { kind = "begin", title = "Other server" })
assert(messages[3].opts.id ~= messages[1].opts.id)
emit(1, { kind = "end" })
assert(messages[4].text == "Done" and messages[4].opts.status == "success")
assert(messages[4].opts.percent == 100 and messages[4].opts.id == messages[1].opts.id)
emit(1, 50)
assert(#messages == 4)
vim.api.nvim_echo = echo
print("PASS: native progress begin/report/end, client isolation, custom progress ignored")

local get_client = vim.lsp.get_client_by_id
vim.lsp.get_client_by_id = function(id)
  return id == 1 and { name = "jdtls" } or nil
end
local notifications = {}
vim.api.nvim_echo = function(chunks, history, opts)
  assert(history and opts.kind == "lsp_message")
  notifications[#notifications + 1] = chunks[1]
end
for level = 1, 4 do
  vim.lsp.handlers["window/showMessage"](nil, { type = level, message = "server message" }, { client_id = 1 })
end
assert(notifications[1][1] == "LSP[jdtls] server message")
assert(notifications[1][2] == "ErrorMsg" and notifications[2][2] == "WarningMsg")
assert(notifications[3][2] == "Normal" and notifications[4][2] == "Normal")
vim.lsp.handlers["window/showMessage"](nil, { type = 3, message = "stopped" }, { client_id = 99 })
assert(notifications[5][1] == "LSP[99] stopped")
vim.api.nvim_echo = echo
vim.lsp.get_client_by_id = get_client
print("PASS: LSP server notifications preserve severity, text and message history")
