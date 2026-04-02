---@type vim.lsp.Config
local mason = vim.fn.stdpath("data") .. "/mason/packages"
local bundles = {
  vim.fn.glob(mason .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", 1),
}
vim.list_extend(bundles, vim.split(vim.fn.glob(mason .. "/java-test/extension/server/*.jar", 1), "\n"))

vim.env.JDTLS_JVM_ARGS = table.concat({
  "-Xmx4G",
  "-Xlog:disable",
  "-javaagent:" .. mason .. "/jdtls/lombok.jar",
}, " ")

local test_config = {
  config = { vmArgs = "--add-opens=java.base/java.lang=ALL-UNNAMED" },
}

return {
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
