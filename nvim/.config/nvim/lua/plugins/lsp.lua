return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Global configuration for all LSP servers
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })

      -- Configure lua_ls with specific settings
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      -- Configure ts_ls to prefer path aliases (e.g. @/) over relative paths
      vim.lsp.config("ts_ls", {
        init_options = {
          preferences = {
            importModuleSpecifierPreference = "non-relative",
          },
        },
      })

      -- Enable LSP servers
      vim.lsp.enable("html")
      vim.lsp.enable("cssls")
      vim.lsp.enable("pyright")
      vim.lsp.enable("gopls")
      vim.lsp.enable("ts_ls")
      vim.lsp.enable("terraformls")
      vim.lsp.enable("tailwindcss")
      vim.lsp.enable("ruff")
      vim.lsp.enable("rust_analyzer")
      vim.lsp.enable("lua_ls")

      -- Use LspAttach autocommand to only map the following keys
      -- after the language server attaches to the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          -- Enable completion triggered by <c-x><c-o>
          vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

          local opts = function(desc)
            return { buffer = ev.buf, desc = desc }
          end
          -- Go to
          vim.keymap.set("n", "gd", function()
            Snacks.picker.lsp_definitions()
          end, opts("Go to Definition"))
          vim.keymap.set("n", "gD", function()
            Snacks.picker.lsp_declarations()
          end, opts("Go to Declaration"))
          vim.keymap.set("n", "gI", function()
            Snacks.picker.lsp_implementations()
          end, opts("Go to Implementation"))
          vim.keymap.set("n", "gy", function()
            Snacks.picker.lsp_type_definitions()
          end, opts("Go to Type Definition"))
          vim.keymap.set("n", "gr", function()
            Snacks.picker.lsp_references()
          end, opts("Find References"))
          -- Actions
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover Documentation"))
          vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, opts("Signature Help"))
          vim.keymap.set({ "n", "v" }, "<Leader>ca", vim.lsp.buf.code_action, opts("Code Action"))
          vim.keymap.set("n", "<Leader>cr", vim.lsp.buf.rename, opts("Rename Symbol"))
          -- Calls
          vim.keymap.set("n", "gai", function()
            Snacks.picker.lsp_incoming_calls()
          end, opts("Incoming Calls"))
          vim.keymap.set("n", "gao", function()
            Snacks.picker.lsp_outgoing_calls()
          end, opts("Outgoing Calls"))
        end,
      })

      vim.api.nvim_create_autocmd("BufNewFile", {
        group = vim.api.nvim_create_augroup("LspStarting", {}),
        callback = function()
          vim.cmd("LspStart")
        end,
      })

      -- Fix filetype detection for $MYVIMRC
      vim.api.nvim_create_autocmd("BufRead", {
        pattern = vim.fn.expand("$MYVIMRC"),
        callback = function()
          vim.bo.filetype = "lua"
        end,
      })
    end,
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
    },
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("lint").linters_by_ft = {
        go = { "staticcheck" },
        javascript = { "eslint" },
        javascriptreact = { "eslint" },
        typescript = { "eslint" },
        typescriptreact = { "eslint" },
        sql = { "sqlfluff" },
      }

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = { "VeryLazy" },
    opts = {
      ensure_installed = {
        "cssls",
        "gopls",
        "html",
        "jdtls",
        "lua_ls",
        "pyright",
        "rust_analyzer",
        "tailwindcss",
        "terraformls",
        "ts_ls",
      },
    },
    dependencies = {
      { "neovim/nvim-lspconfig" },
      { "mason-org/mason.nvim", opts = {} },
      {
        "jay-babu/mason-nvim-dap.nvim",
        opts = {
          automatic_installation = true,
          ensure_installed = {
            "debugpy",
            "delve",
            "javadbg",
            "javatest",
            "js",
          },
        },
      },
    },
  },

  {
    "linux-cultist/venv-selector.nvim",
    keys = {
      { ",v", "<Cmd>VenvSelect<CR>", desc = "Open VenvSelector to pick a venv" },
    },
    ft = "python",
    opts = {
      search = {},
      options = {},
    },
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap-python",
    },
  },
}
