local jdtls = require("jdtls")
local mason = vim.fn.stdpath("data") .. "/mason/packages"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. project_name
local bundles = {
  vim.fn.glob(mason .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", 1),
}
vim.list_extend(bundles, vim.split(vim.fn.glob(mason .. "/java-test/extension/server/*.jar", 1), "\n"))

local config = {}
config.on_attach = function(_, bufnr)
  jdtls.setup_dap({
    hotcodereplace = "auto",
    config_overrides = {
      console = "internalConsole",
    },
  })
  jdtls.setup.add_commands()

  local opts = { silent = true, buffer = bufnr }
  vim.keymap.set("n", "<A-o>", jdtls.organize_imports, opts)
  vim.keymap.set("n", "crv", jdtls.extract_variable, opts)
  vim.keymap.set("v", "crv", function()
    jdtls.extract_variable(true)
  end, opts)
  vim.keymap.set("n", "crc", jdtls.extract_constant, opts)
  vim.keymap.set("v", "crc", function()
    jdtls.extract_constant(true)
  end, opts)
  vim.keymap.set("v", "crm", function()
    jdtls.extract_method(true)
  end, opts)
  vim.keymap.set("n", "<leader>df", jdtls.test_class, opts)
  vim.keymap.set("n", "<leader>dn", jdtls.test_nearest_method, opts)
end

config.cmd = {
  "java", -- or '/path/to/java11_or_newer/bin/java'
  "-Declipse.application=org.eclipse.jdt.ls.core.id1",
  "-Dosgi.bundles.defaultStartLevel=4",
  "-Declipse.product=org.eclipse.jdt.ls.core.product",
  "-Dlog.protocol=true",
  "-Dlog.level=ALL",
  "-Xms1g",
  "-javaagent:" .. mason .. "/jdtls/lombok.jar",
  "--add-modules=ALL-SYSTEM",
  "--add-opens",
  "java.base/java.util=ALL-UNNAMED",
  "--add-opens",
  "java.base/java.lang=ALL-UNNAMED",
  "-jar",
  mason .. "/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar",
  "-configuration",
  mason .. "/jdtls/config_mac",
  "-data",
  workspace_dir,
}

config.root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" })

config.settings = {
  java = {
    signatureHelp = { enabled = true },
    contentProvider = { preferred = "fernflower" },
    completion = {
      favoriteStaticMembers = {
        "org.hamcrest.MatcherAssert.assertThat",
        "org.hamcrest.Matchers.*",
        "org.hamcrest.CoreMatchers.*",
        "org.junit.jupiter.api.Assertions.*",
        "java.util.Objects.requireNonNull",
        "java.util.Objects.requireNonNullElse",
        "org.mockito.Mockito.*",
      },
      filteredTypes = {
        "com.sun.*",
        "io.micrometer.shaded.*",
        "java.awt.*",
        "jdk.*",
        "sun.*",
      },
    },
    sources = {
      organizeImports = {
        starThreshold = 9999,
        staticStarThreshold = 9999,
      },
    },
    codeGeneration = {
      toString = {
        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
      },
      hashCodeEquals = {
        useJava7Objects = true,
      },
      useBlocks = true,
    },
  },
}

config.handlers = {}
config.handlers["language/status"] = function()
end

config.init_options = {
  bundles = bundles,
}

require("jdtls").start_or_attach(config)
