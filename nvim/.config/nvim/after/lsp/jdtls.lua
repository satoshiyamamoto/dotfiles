---@type vim.lsp.Config
-- Adapted from https://github.com/neovim/nvim-lspconfig/blob/master/lsp/jdtls.lua

local function get_jdtls_cache_dir() return vim.fn.stdpath("cache") .. "/jdtls" end

local function get_jdtls_workspace_dir() return get_jdtls_cache_dir() .. "/workspace" end

local function get_jdtls_jvm_args()
  local env = os.getenv("JDTLS_JVM_ARGS")
  local args = {}
  for a in string.gmatch((env or ""), "%S+") do
    local arg = string.format("--jvm-arg=%s", a)
    table.insert(args, arg)
  end
  return unpack(args)
end

local bundles = {
  vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", 1),
}
vim.list_extend(bundles, vim.split(vim.fn.glob(vim.fn.stdpath("data") .. "/mason/packages/java-test/extension/server/*.jar", 1), "\n"))

local test_config = {
  config = { vmArgs = "--add-opens=java.base/java.lang=ALL-UNNAMED" },
}

return {
  ---@param dispatchers? vim.lsp.rpc.Dispatchers
  ---@param config vim.lsp.ClientConfig
  cmd = function(dispatchers, config)
    local workspace_dir = get_jdtls_workspace_dir()
    local data_dir = workspace_dir

    if config.root_dir then
      data_dir = data_dir .. "/" .. vim.fn.fnamemodify(config.root_dir, ":p:h:t")
    end

    local config_cmd = {
      "jdtls",
      "-data",
      data_dir,
      get_jdtls_jvm_args(),
    }

    return vim.lsp.rpc.start(config_cmd, dispatchers, {
      cwd = config.cmd_cwd,
      env = config.cmd_env,
      detached = config.detached,
    })
  end,
  settings = {
    java = {
      signatureHelp = { enabled = true },
      test = test_config,
    },
  },
  init_options = {
    bundles = bundles,
  },
  on_attach = function(_, bufnr)
    local jdtls = require("jdtls")
    jdtls.setup_dap({ hotcodereplace = "auto" })
    jdtls.setup.add_commands()
    vim.keymap.set("n", "<leader>tt", function() jdtls.test_class(test_config) end, { buffer = bufnr, desc = "Test Class (Debug)" })
    vim.keymap.set("n", "<leader>tr", function() jdtls.test_nearest_method(test_config) end, { buffer = bufnr, desc = "Test Method (Debug)" })
  end,
}
