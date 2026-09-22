-- rustaceanvim exposes the buffer-local `:RustLsp` command family once
-- rust-analyzer attaches. See :help rustaceanvim.commands
local function rustlsp(...)
  local cmd = { ... }
  return function() vim.cmd.RustLsp(cmd) end
end

vim.keymap.set("n", "K", rustlsp("hover", "actions"), { buffer = true, desc = "Hover Actions (Rust)" })
vim.keymap.set("n", "<Leader>ra", rustlsp("codeAction"), { buffer = true, desc = "Code Action (Rust)" })
vim.keymap.set("n", "<Leader>rr", rustlsp("runnables"), { buffer = true, desc = "Runnables (Rust)" })
vim.keymap.set("n", "<Leader>rd", rustlsp("debuggables"), { buffer = true, desc = "Debuggables (Rust)" })
vim.keymap.set("n", "<Leader>rt", rustlsp("testables"), { buffer = true, desc = "Testables (Rust)" })
vim.keymap.set("n", "<Leader>rm", rustlsp("expandMacro"), { buffer = true, desc = "Expand Macro (Rust)" })
vim.keymap.set("n", "<Leader>re", rustlsp("explainError"), { buffer = true, desc = "Explain Error (Rust)" })
vim.keymap.set("n", "<Leader>rc", rustlsp("openCargo"), { buffer = true, desc = "Open Cargo.toml (Rust)" })
vim.keymap.set("n", "<Leader>rp", rustlsp("parentModule"), { buffer = true, desc = "Parent Module (Rust)" })
