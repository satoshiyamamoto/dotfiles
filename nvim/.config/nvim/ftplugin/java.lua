local jdtls = require("jdtls")
local mason = vim.fn.stdpath("data") .. "/mason/packages"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. project_name
local bundles = {
  vim.fn.glob(mason .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", 1),
}
vim.list_extend(bundles, vim.split(vim.fn.glob(mason .. "/java-test/extension/server/*.jar", 1), "\n"))

local config = {}

config.cmd = {
  "java", -- or '/path/to/java11_or_newer/bin/java'
  "-Declipse.application=org.eclipse.jdt.ls.core.id1",
  "-Dosgi.bundles.defaultStartLevel=4",
  "-Declipse.product=org.eclipse.jdt.ls.core.product",
  "-Dlog.level=ALL",
  "-Xmx4G",
  "-Xlog:disable",
  "-javaagent:" .. mason .. "/jdtls/lombok.jar",
  "--add-modules=ALL-SYSTEM",
  "--add-opens=java.base/java.lang=ALL-UNNAMED",
  "--add-opens=java.base/java.util=ALL-UNNAMED",
  "-jar",
  vim.fn.glob(mason .. "/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
  "-configuration",
  mason .. "/jdtls/config_mac",
  "-data",
  workspace_dir,
}

config.root_dir = require("jdtls.setup").find_root({ "gradlew", ".git", "mvnw" })

config.settings = {
  java = {
    test = {
      config = {
        vmArgs = table.concat({
          "--add-opens=java.base/java.lang=ALL-UNNAMED",
        }, " "),
      },
    },
  },
}

config.on_attach = function(_, bufnr)
  jdtls.setup_dap({ hotcodereplace = "auto" })
  jdtls.setup.add_commands()

  local opts = function(desc)
    return { silent = true, buffer = bufnr, desc = desc }
  end
  vim.keymap.set("n", "<A-o>", jdtls.organize_imports, opts("Optimize Import"))
  vim.keymap.set("n", "crv", jdtls.extract_variable, opts("Extract Variable"))
  vim.keymap.set("v", "crv", function() jdtls.extract_variable(true) end, opts("Extract Variable"))
  vim.keymap.set("n", "crc", jdtls.extract_constant, opts("Extract Constant"))
  vim.keymap.set("v", "crc", function() jdtls.extract_constant(true) end, opts("Extract Constant"))
  vim.keymap.set("v", "crm", function() jdtls.extract_method(true) end, opts("Extract Method"))
  vim.keymap.set("n", "<leader>df", function() jdtls.test_class(config.settings.java.test) end,
    opts("Test Class (Debug)"))
  vim.keymap.set("n", "<leader>dn", function() jdtls.test_nearest_method(config.settings.java.test) end,
    opts("Test Method (Debug)"))
end

config.handlers = {}
config.handlers["language/status"] = function() end

config.init_options = {
  bundles = bundles,
}
require("jdtls").start_or_attach(config)
