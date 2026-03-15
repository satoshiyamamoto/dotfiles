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

          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = function(desc)
            return { buffer = ev.buf, desc = desc }
          end
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts("Go to Declaration"))
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts("Go to Definition"))
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts("Go to Implementations"))
          vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, opts("Show Signature help"))
          vim.keymap.set("n", "<Leader>wa", vim.lsp.buf.add_workspace_folder, opts("Add Workspace folder"))
          vim.keymap.set("n", "<Leader>wr", vim.lsp.buf.remove_workspace_folder, opts("Remove Workspace folder"))
          vim.keymap.set("n", "<Leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts("List Workspace folders"))
          vim.keymap.set("n", "<Leader>D", vim.lsp.buf.type_definition, opts("Go to Type Definition"))
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts("Find All References"))
          vim.keymap.set("n", "<Leader>lf", function()
            vim.lsp.buf.format({ async = true })
          end, opts("Format Document"))
          vim.keymap.set("n", "gh", "<Cmd>Lspsaga lsp_finder<CR>", opts("Find LSP Symbols (Lspsaga)"))
          vim.keymap.set({ "n", "v" }, "<Leader>ca", "<Cmd>Lspsaga code_action<CR>", opts("Execute Code Action"))
          vim.keymap.set("n", "<Leader>rn", "<Cmd>Lspsaga rename<CR>", opts("Rename Symbol (Lspsaga)"))
          vim.keymap.set("n", "gp", "<Cmd>Lspsaga peek_definition<CR>", opts("Peek Definition (Lspsaga)"))
          vim.keymap.set("n", "gt", "<Cmd>Lspsaga goto_type_definition<CR>", opts("Go to Type Definition (Lspsaga)"))
          vim.keymap.set("n", "<Leader>o", "<Cmd>Lspsaga outline<CR>", opts("Show Outline (Lspsaga)"))
          vim.keymap.set("n", "K", "<Cmd>Lspsaga hover_doc<CR>", opts("Show Hover Documentation (Lspsaga)"))
          vim.keymap.set("n", "<Leader>ci", "<Cmd>Lspsaga incoming_calls<CR>", opts("Show Incoming Calls (Lspsaga)"))
          vim.keymap.set("n", "<Leader>co", "<Cmd>Lspsaga outgoing_calls<CR>", opts("Show Outgoing Calls (Lspsaga)"))
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
      "nvim-telescope/telescope.nvim",
      "mfussenegger/nvim-dap-python",
    },
  },

  {
    "nvimdev/lspsaga.nvim",
    event = { "LspAttach" },
    config = function()
      require("lspsaga").setup({
        lightbulb = {
          enable = false,
        },
      })
    end,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
      { "nvim-tree/nvim-web-devicons" },
    },
  },
}
