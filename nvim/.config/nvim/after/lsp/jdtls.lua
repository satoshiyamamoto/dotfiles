---@type vim.lsp.Config
local mason = vim.fn.stdpath("data") .. "/mason/packages"
local bundles = {
  vim.fn.glob(mason .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", 1),
}
vim.list_extend(bundles, vim.split(vim.fn.glob(mason .. "/java-test/extension/server/*.jar", 1), "\n"))

local test_config = {
  config = { vmArgs = "--add-opens=java.base/java.lang=ALL-UNNAMED" },
}

-- Adapted from https://github.com/neovim/nvim-lspconfig/blob/master/lsp/jdtls.lua
local function get_jdtls_jvm_args()
  local args = {}
  for a in string.gmatch(os.getenv("JDTLS_JVM_ARGS") or "", "%S+") do
    table.insert(args, string.format("--jvm-arg=%s", a))
  end
  return unpack(args)
end

return {
  -- Override nvim-jdtls's cmd = {"jdtls"} which ignores JVM args.
  -- after/lsp/ is loaded last in rtp, so this wins over all lsp/jdtls.lua files.
  ---@param dispatchers? vim.lsp.rpc.Dispatchers
  ---@param config vim.lsp.ClientConfig
  cmd = function(dispatchers, config)
    local data_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace"
    if config.root_dir then
      data_dir = data_dir .. "/" .. vim.fn.fnamemodify(config.root_dir, ":p:h:t")
    end
    return vim.lsp.rpc.start({
      "jdtls", "-data", data_dir, get_jdtls_jvm_args(),
    }, dispatchers, { cwd = config.cmd_cwd, env = config.cmd_env, detached = config.detached })
  end,
  settings = {
    java = {
      signatureHelp = { enabled = true },
      test = test_config,
    },
  },
  init_options = { bundles = bundles },
  handlers = { ["language/status"] = function() end },
  on_attach = function(_, bufnr)
    local jdtls = require("jdtls")
    jdtls.setup_dap({ hotcodereplace = "auto" })
    jdtls.setup.add_commands()
    local opts = function(desc) return { silent = true, buffer = bufnr, desc = desc } end
    vim.keymap.set("n", "<leader>tt", function() jdtls.test_class(test_config) end, opts("Test Class (Debug)"))
    vim.keymap.set("n", "<leader>tr", function() jdtls.test_nearest_method(test_config) end, opts("Test Method (Debug)"))
  end,
}
