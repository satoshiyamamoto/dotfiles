local jdtls = require('jdtls')
local jdtls_version = '1.6.400.v20210924-0641'
local jdtls_install_location = vim.fn.stdpath('data') .. '/lsp_servers/jdtls'

-- If you started neovim within `~/dev/xy/project-1` this would resolve to `project-1`
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace_dir = vim.env.WORKSPACE .. project_name

local opts = { noremap = true, silent = true }
local on_attach = function(client, bufnr)
  local option = vim.api.nvim_buf_set_option
  local keymap = vim.api.nvim_buf_set_keymap
  -- Enable completion triggered by <c-x><c-o>
  option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings for nvim-jdtls.
  keymap(bufnr, 'n', '<A-o>', "<Cmd>lua require'jdtls'.organize_imports()<CR>", opts)
  keymap(bufnr, 'n', 'crv', "<Cmd>lua require('jdtls').extract_variable()<CR>", opts)
  keymap(bufnr, 'v', 'crv', "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", opts)
  keymap(bufnr, 'n', 'crc', "<Cmd>lua require('jdtls').extract_constant()<CR>", opts)
  keymap(bufnr, 'v', 'crc', "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", opts)
  keymap(bufnr, 'v', 'crm', "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", opts)

  -- If using nvim-dap
  -- This requires java-debug and vscode-java-test bundles, see install steps in this README further below.
  keymap(bufnr, 'n', '<leader>df', "<Cmd>lua require'jdtls'.test_class()<CR>", opts)
  keymap(bufnr, 'n', '<leader>dn', "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", opts)

  -- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
  -- you make during a debug session immediately.
  -- Remove the option if you do not want that.
  jdtls.setup_dap({ hotcodereplace = 'auto' })
  jdtls.setup.add_commands()
end

-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
  -- The command that starts the language server
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  cmd = {
    'java', -- or '/path/to/java11_or_newer/bin/java'
    '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    '-Dosgi.bundles.defaultStartLevel=4',
    '-Declipse.product=org.eclipse.jdt.ls.core.product',
    '-Dlog.protocol=true',
    '-Dlog.level=ALL',
    '-Xms1g',
    '-javaagent:' .. jdtls_install_location .. '/lombok.jar',
    '--add-modules=ALL-SYSTEM',
    '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    '-jar', jdtls_install_location .. '/plugins/org.eclipse.equinox.launcher_' .. jdtls_version .. '.jar',
    '-configuration', jdtls_install_location .. '/config_mac',
    '-data', workspace_dir,
  },

  -- This is the default if not provided, you can remove it. Or adjust as needed.
  -- One dedicated LSP server & client will be started per unique root_dir
  root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' }),

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
  settings = {
    java = {
      signatureHelp = { enabled = true };
      contentProvider = { preferred = 'fernflower' };
      completion = {
        favoriteStaticMembers = {
          "org.hamcrest.MatcherAssert.assertThat",
          "org.hamcrest.Matchers.*",
          "org.hamcrest.CoreMatchers.*",
          "org.junit.jupiter.api.Assertions.*",
          "java.util.Objects.requireNonNull",
          "java.util.Objects.requireNonNullElse",
          "org.mockito.Mockito.*"
        },
        filteredTypes = {
          "com.sun.*",
          "io.micrometer.shaded.*",
          "java.awt.*",
          "jdk.*",
          "sun.*",
        },
      };
      sources = {
        organizeImports = {
          starThreshold = 9999;
          staticStarThreshold = 9999;
        };
      };
      codeGeneration = {
        toString = {
          template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
        },
        hashCodeEquals = {
          useJava7Objects = true,
        },
        useBlocks = true,
      };
    }
  },

  -- Language server `initializationOptions`
  -- You need to extend the `bundles` with paths to jar files
  -- if you want to use additional eclipse.jdt.ls plugins.
  --
  -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
  --
  -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
  init_options = {
    bundles = {
      vim.fn.glob(vim.env.GOPATH .. '/src/github.com/microsoft/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar')
    };
  },

  on_attach = on_attach
}
-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
require('jdtls').start_or_attach(config)
