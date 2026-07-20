-- rustaceanvim exposes the buffer-local `:RustLsp` command family once
-- rust-analyzer attaches. See :help rustaceanvim.commands
local function rustlsp(...)
  local cmd = { ... }
  return function() vim.cmd.RustLsp(cmd) end
end

local function map(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = true, desc = desc }) end

map("K", rustlsp("hover", "actions"), "Hover Actions (Rust)")
map("<Leader>ra", rustlsp("codeAction"), "Code Action (Rust)")
map("<Leader>rr", rustlsp("runnables"), "Runnables (Rust)")
map("<Leader>rd", rustlsp("debuggables"), "Debuggables (Rust)")
map("<Leader>rt", rustlsp("testables"), "Testables (Rust)")
map("<Leader>rm", rustlsp("expandMacro"), "Expand Macro (Rust)")
map("<Leader>re", rustlsp("explainError"), "Explain Error (Rust)")
map("<Leader>rc", rustlsp("openCargo"), "Open Cargo.toml (Rust)")
map("<Leader>rp", rustlsp("parentModule"), "Parent Module (Rust)")
