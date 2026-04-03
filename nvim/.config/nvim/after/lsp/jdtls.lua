---@type vim.lsp.Config
-- Adapted from https://github.com/neovim/nvim-lspconfig/blob/master/lsp/jdtls.lua

local function jar_path(package) return vim.fn.stdpath("data") .. "/mason/packages/" .. package .. "/extension/server/" end

-- java-debug-adapter
local bundles = {
  vim.fn.glob(jar_path("java-debug-adapter") .. "com.microsoft.java.debug.plugin-*.jar", true),
}

-- vscode-java-test
local java_test_bundles = vim.split(vim.fn.glob(jar_path("java-test") .. "*.jar", true), "\n")
local excluded = {
  "com.microsoft.java.test.runner-jar-with-dependencies.jar",
  "jacocoagent.jar",
}
for _, java_test_jar in ipairs(java_test_bundles) do
  local fname = vim.fn.fnamemodify(java_test_jar, ":t")
  if not vim.tbl_contains(excluded, fname) then
    table.insert(bundles, java_test_jar)
  end
end

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
      test = { config_overrides = { vmArgs = "--add-opens=java.base/java.lang=ALL-UNNAMED" } },
    },
  },
  init_options = {
    bundles = bundles,
  },
  on_attach = function(_, bufnr)
    local jdtls = require("jdtls")
    jdtls.setup_dap({ hotcodereplace = "auto" })
    jdtls.setup.add_commands()
    vim.keymap.set("n", "<leader>tt", function() jdtls.test_class() end, { buffer = bufnr, desc = "Test Class (Debug)" })
    vim.keymap.set("n", "<leader>tr", function() jdtls.test_nearest_method() end, { buffer = bufnr, desc = "Test Method (Debug)" })
  end,
}
