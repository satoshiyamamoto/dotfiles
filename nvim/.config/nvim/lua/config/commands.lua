-- Config
local function config_complete(arg)
  local config = vim.fn.stdpath("config")
  local files = vim.fn.globpath(config .. "/lua", "**/*.lua", false, true)
  return vim.tbl_map(
    function(f) return f:sub(#config + 6) end,
    vim.tbl_filter(function(f) return f:find(arg, 1, true) end, files)
  )
end

vim.api.nvim_create_user_command("Config", function(opts)
  local config = vim.fn.stdpath("config")
  local path = opts.args == "" and config .. "/init.lua" or config .. "/lua/" .. opts.args
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end, { nargs = "?", complete = config_complete })
