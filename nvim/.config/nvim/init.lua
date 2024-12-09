-- vim:foldmethod=marker

-- # Basics: {{{

vim.g.mapleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.laststatus = 3
vim.opt.fillchars:append({ diff = " " })
vim.opt.termguicolors = true
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.clipboard = "unnamedplus"
vim.opt.shortmess:append({ c = true, I = true })
vim.opt.updatetime = 100
vim.opt.timeoutlen = 300
vim.opt.grepprg = "rg --vimgrep --hidden"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.helplang = "ja,en"

-- }}}

-- # Mappings: {{{

-- Insert
vim.keymap.set("i", "jj", "<Esc>", {})

-- Buffers
vim.keymap.set("n", "[b", "<Cmd>bprevious<CR>", {})
vim.keymap.set("n", "]b", "<Cmd>bnext<CR>", {})
vim.keymap.set("n", "[B", "<Cmd>bfirst<CR>", {})
vim.keymap.set("n", "]B", "<Cmd>blast<CR>", {})

-- Windows
vim.keymap.set("n", "<C-j>", "<C-w>j", {})
vim.keymap.set("n", "<C-k>", "<C-w>k", {})
vim.keymap.set("n", "<C-h>", "<C-w>h", {})
vim.keymap.set("n", "<C-l>", "<C-w>l", {})
vim.keymap.set("n", "<C-Up>", "<Cmd>resize +2<CR>", {})
vim.keymap.set("n", "<C-Down>", "<Cmd>resize -2<CR>", {})
vim.keymap.set("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", {})
vim.keymap.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", {})

-- Diagnostics
vim.keymap.set("n", "[q", "<Cmd>cprevious<CR>", {})
vim.keymap.set("n", "]q", "<Cmd>cnext<CR>", {})
vim.keymap.set("n", "gl", vim.diagnostic.open_float, {})
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, {})
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, {})
vim.keymap.set("n", "<Leader>q", vim.diagnostic.setloclist, {})

-- Terminal
vim.keymap.set("n", "<C-`>", "<Cmd>ToggleTerm<CR>", {})
vim.keymap.set("t", "<C-`>", "<Cmd>ToggleTerm<CR>", {})
vim.keymap.set("t", "<Esc>", "<C-Bslash><C-n>", {})
vim.keymap.set("t", "<C-[>", "<C-Bslash><C-n>", {})

-- }}}

-- # Lazy Plugins: {{{

local plugins = {

  -- }}}

  -- ## Syntaxeis: {{{

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        "bash",
        "csv",
        "go",
        "gomod",
        "hcl",
        "html",
        "java",
        "javascript",
        "json",
        "kdl",
        "lua",
        "markdown",
        "markdown_inline",
        "pug",
        "proto",
        "python",
        "query",
        "regex",
        "rust",
        "sql",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
        disable = { "yaml" },
      },
      autotag = {
        enable = true,
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
      vim.treesitter.language.register("hcl", { "terraform" })
    end,
    dependencies = {
      { "windwp/nvim-ts-autotag" },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      enable = true,
    },
    config = function()
      vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "None" })
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "#000000" })
    end,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
      { "folke/tokyonight.nvim" },
      { "projekt0n/github-nvim-theme" },
    },
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    config = function()
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
        languages = {
          typescript = "// %s",
        },
      })
    end,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
    },
  },

  {
    "iloginow/vim-stylus",
    event = { "BufReadPost", "BufNewFile" },
  },

  {
    "stevearc/conform.nvim",
    event = { "BufWritePre", "BufNewFile" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<Leader>f",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofmt" },
        java = { "google-java-format" },
        javascript = { "prettier" },
        lua = { "stylua" },
        proto = { "buf" },
        python = { "ruff_format" },
        rust = { "rustfmt" },
        sql = { "sqlfluff" },
        yaml = { "yamlfmt" },
      },
      -- format_on_save = {
      --   timeout_ms = 500,
      --   lsp_fallback = true,
      -- },
    },
  },

  -- }}}

  -- ## Completions: {{{

  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter" },
    keys = {
      {
        "<C-j>",
        function()
          return vim.fn["vsnip#expandable()"] and "<Plug>(vsnip-expand)" or "<C-j>"
        end,
        mode = { "i", "s" },
        expr = true,
        silent = true,
      },
      {
        "<C-l>",
        function()
          return vim.fn["vsnip#available(1)"] and "<Plug>(vsnip-expand-or-jump)" or "<C-l>"
        end,
        'vsnip#available(1) ? "<Plug>(vsnip-expand-or-jump)" : "<C-l>"',
        mode = { "i", "s" },
        expr = true,
        silent = true,
      },
      {
        "<Tab>",
        function()
          return vim.fn["vsnip#jumpable(1)"] and "<Plug>(vsnip-jump-next)" or "<Tab>"
        end,
        mode = { "i", "s" },
        expr = true,
        silent = true,
      },
      {
        "<S-Tab>",
        function()
          return vim.fn["vsnip#jumpable(-1)"] and "<Plug>(vsnip-jump-prev)" or "<S-Tab>"
        end,
        mode = { "i", "s" },
        expr = true,
        silent = true,
      },
    },
    config = function()
      local cmp = require("cmp")
      local lspkind = require("lspkind")

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = {
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.close(),
          ["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "vsnip" }, -- For vsnip users.
          { name = "buffer" },
          { name = "path" },
          { name = "copilot" },
        }),
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            symbol_map = { Copilot = "" },
            preset = "default",
          }),
        },
        experimental = { ghost_text = true },
      })

      -- Use buffer source for `/`
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "nvim_lsp_document_symbol" },
        }, {
          { name = "buffer" },
        }),
      })

      -- Use cmdline & path source for ":"
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })

      -- Complete the bracket with "CR"
      cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
    end,
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lsp-signature-help" },
      { "hrsh7th/cmp-nvim-lsp-document-symbol" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-cmdline" },
      { "hrsh7th/cmp-vsnip" },
      { "hrsh7th/vim-vsnip" },
      { "hrsh7th/vim-vsnip-integ" },
      { "zbirenbaum/copilot.lua" },
      { "zbirenbaum/copilot-cmp" },
      { "onsails/lspkind.nvim" },
      { "rafamadriz/friendly-snippets" },
    },
  },

  -- Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = { "Copilot" },
    event = { "InsertEnter" },
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
  },

  { "golang/vscode-go", event = { "InsertEnter" } },

  -- }}}

  -- ## Snippets: {{{

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  { "tpope/vim-unimpaired", event = { "BufReadPost" } },
  { "tpope/vim-fugitive", event = { "BufReadPost" } },
  { "tpope/vim-surround", event = { "BufReadPost" } },
  { "tpope/vim-commentary", event = { "BufReadPost" } },
  { "mattn/emmet-vim", event = { "InsertEnter" } },

  -- }}}

  -- ## LSPs: {{{

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local disable_formatting = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end

      -- Language servers
      local lspconfig = require("lspconfig")
      lspconfig.buf_ls.setup({ capabilities = capabilities })
      lspconfig.gopls.setup({ capabilities = capabilities })
      lspconfig.pyright.setup({
        capabilities = capabilities,
        settings = {
          pyright = {
            -- Using Ruff's import organizer
            disableOrganizeImports = true,
          },
          python = {
            analysis = {
              -- Ignore all files for analysis to exclusively use Ruff for linting
              ignore = { "*" },
            },
          },
        },
      })
      lspconfig.ts_ls.setup({ capabilities = capabilities })
      lspconfig.terraformls.setup({ capabilities = capabilities })
      lspconfig.ruff.setup({ capabilities = capabilities })
      lspconfig.rust_analyzer.setup({ capabilities = capabilities })
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        on_attach = disable_formatting,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim", "require" },
            },
          },
        },
      })

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
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = {
      "Mason",
      "MasonInstall",
      "MasonUninstall",
      "MasonUninstallAll",
      "MasonLog",
      "MasonUpdate",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          -- LSP
          "gopls",
          "jdtls",
          "lua_ls",
          "pyright",
          "rust_analyzer",
          "terraformls",
          "ts_ls",
        },
      })
      require("mason-nvim-dap").setup({
        automatic_installation = true,
        ensure_installed = {
          -- DAP
          "debugpy",
          "delve",
          "javadbg",
          "javatest",
          "js",
        },
      })
    end,
    dependencies = {
      { "williamboman/mason-lspconfig.nvim" },
      { "jay-babu/mason-nvim-dap.nvim" },
    },
  },

  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    keys = {
      { ",v", "<Cmd>VenvSelect<CR>", desc = "Open VenvSelector to pick a venv" },
    },
    config = function()
      require("venv-selector").setup()
    end,
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

  -- }}}

  -- ## DAPs: {{{

  {
    "mfussenegger/nvim-dap",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      local mason = require("mason-registry")
      require("dapui").setup()
      require("dap-go").setup()
      require("dap-python").setup(mason.get_package("debugpy"):get_install_path() .. "/venv/bin/python")
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "js-debug-adapter",
          args = { "${port}" },
        },
      }
      for _, language in ipairs({ "typescript", "javascript", "javascriptreact", "typescriptreact" }) do
        require("dap").configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
          },
        }
      end

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Continue (Debug)" })
      vim.keymap.set("n", "<F17>", dap.terminate, { desc = "Treminate (Debug)" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step Over (Debug)" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step Into (Debug)" })
      vim.keymap.set("n", "<F23>", dap.step_out, { desc = "Step Out (Debug)" })
      vim.keymap.set("n", "<Leader>b", dap.toggle_breakpoint, { desc = "Toggle Brakepoint (Debug)" })
      vim.keymap.set("n", "<Leader>B", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Brakepoint Condition (Debug)" })
      vim.keymap.set("n", "<Leader>lp", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      end, { desc = "Brakepoint Log point message (Debug)" })
      vim.keymap.set("n", "<Leader>du", dapui.toggle, { desc = "Toggle Debugger UI (Debug)" })
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapLogPoint", { text = "", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapStopped", { text = "", texthl = "WarningMsg" })
    end,
    dependencies = {
      { "mfussenegger/nvim-dap-python" },
      { "mfussenegger/nvim-jdtls" },
      { "leoluz/nvim-dap-go" },
      { "nvim-neotest/nvim-nio" },
      { "rcarriga/nvim-dap-ui" },
      { "theHamsta/nvim-dap-virtual-text" },
    },
  },

  {
    "nvim-neotest/neotest",
    keys = {
      {
        "<Leader>df",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Test File",
      },
      {
        "<Leader>dn",
        function()
          require("neotest").run.run()
        end,
        desc = "Test Nearest",
      },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-golang"),
        },
      })
    end,
    dependencies = {
      { "nvim-neotest/nvim-nio" },
      { "nvim-lua/plenary.nvim" },
      { "antoinemadec/FixCursorHold.nvim" },
      { "nvim-treesitter/nvim-treesitter" },
      { "fredrikaverpil/neotest-golang" },
      { "rcasia/neotest-java" },
    },
  },

  -- }}}

  -- ## Finders: {{{
  {
    "nvim-telescope/telescope.nvim",
    cmd = { "Telescope" },
    event = { "BufReadPost", "BufNewFile" },
    keys = {
      { "<C-p>", "<Cmd>Telescope find_files<CR>", desc = "Find Files" },
      { "<Leader>ff", "<Cmd>Telescope find_files<CR>", desc = "Find Files" },
      { "<Leader>fg", "<Cmd>Telescope live_grep<CR>", desc = "Search with Live Grep" },
      { "<Leader>fb", "<Cmd>Telescope buffers<CR>", desc = "List Buffers" },
      { "<Leader>fr", "<Cmd>Telescope oldfiles<CR>", desc = "Open Recent Files" },
      { '<Leader>f"', "<Cmd>Telescope registers<CR>", desc = "Search Registers" },
      { "<Leader>fh", "<Cmd>Telescope help_tags<CR>", desc = "Search Help Tags" },
      { "<Leader>fs", "<Cmd>Telescope lsp_document_symbols<CR>", desc = "Search Document Symbols" },
      { "<Leader>fS", "<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>", desc = "Search Workspace Symbols" },
      { "<Leader>fd", "<Cmd>Telescope dap configurations<CR>", desc = "Debug Configurations (Debug)" },
      { "<Leader>fn", "<Cmd>Telescope noice<CR>", desc = "Search Noice Messages" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local stop_insert_on_select = function(prompt_bufnr)
        actions.select_default(prompt_bufnr)
        vim.cmd("stopinsert")
      end
      local stop_insert_on_close = function(prompt_bufnr)
        actions.close(prompt_bufnr)
        vim.cmd("stopinsert")
      end

      telescope.setup({
        defaults = {
          mappings = {
            i = {
              ["<CR>"] = stop_insert_on_select,
              ["<Esc>"] = stop_insert_on_close,
              ["<C-c>"] = stop_insert_on_close,
            },
          },
          path_display = { truncate = 0 },
          file_ignore_patterns = {
            "%.git/",
            "node%_modules/",
            "target/",
          },
        },
        pickers = {
          find_files = {
            hidden = true,
          },
          grep_string = {
            additional_args = { "--hidden" },
          },
          live_grep = {
            additional_args = { "--hidden" },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("dap")
      telescope.load_extension("ui-select")
      telescope.load_extension("noice")
    end,
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-telescope/telescope-dap.nvim" },
    },
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = { "Neotree" },
    keys = {
      { "<Leader>e", "<Cmd>Neotree toggle<CR>", desc = "File Explorer (Neo-tree)" },
      { "<Leader>be", "<Cmd>Neotree buffers<CR>", desc = "Buffers Explorer (Neo-tree)" },
      { "<Leader>ge", "<Cmd>Neotree git_status<CR>", desc = "Git Explorer (Neo-tree)" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_by_name = {
            "node_modules",
          },
          never_show = {
            ".DS_Store",
            "thumbs.db",
          },
        },
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
      },
      buffers = {
        follow_current_file = {
          enabled = true,
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
  },

  {
    "smoka7/hop.nvim",
    version = "v2.*",
    cmd = {
      "HopWord",
      "HopChar2",
      "HopLine",
    },
    keys = {
      { "s", "<Cmd>HopChar2<CR>", desc = "Hop to 2 Characters" },
      { "S", "<Cmd>HopWord<CR>", desc = "Hop to Word" },
    },
    config = function()
      require("hop").setup()
    end,
  },

  -- }}}

  -- ## Informations: {{{

  {
    "folke/noice.nvim",
    event = { "VeryLazy" },
    keys = {
      {
        "<Leader>nl",
        function()
          require("noice").cmd("last")
        end,
        desc = "Noice Last Message",
      },
      {
        "<Leader>nh",
        function()
          require("noice").cmd("history")
        end,
        desc = "Noice History",
      },
      {
        "<Leader>nd",
        function()
          require("noice").cmd("dismiss")
        end,
        desc = "Noice Dismiss",
      },
      {
        "<C-f>",
        function()
          if not require("noice.lsp").scroll(4) then
            return "<c-f>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Lsp Hover Doc Scroll Forward",
        mode = { "i", "n", "s" },
      },
      {
        "<C-b>",
        function()
          if not require("noice.lsp").scroll(-4) then
            return "<c-b>"
          end
        end,
        silent = true,
        expr = true,
        desc = "Lsp Hover Doc Scroll Backward",
        mode = { "i", "n", "s" },
      },
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["vim.ui.select"] = false,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          opts = { skip = true },
        },
      },
      views = {
        cmdline_popup = {
          position = {
            row = "50%", -- Center the cmdline pop-up
          },
        },
      },
    },
    dependencies = {
      { "MunifTanjim/nui.nvim" },
      { "rcarriga/nvim-notify" },
    },
  },

  {
    "folke/trouble.nvim",
    event = { "VeryLazy" },
    keys = {
      { "<Leader>xx", "<Cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
      { "<Leader>xX", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer Diagnostics (Trouble)" },
      { "<Leader>cs", "<Cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols (Trouble)" },
      {
        "<Leader>cl",
        "<Cmd>Trouble lsp toggle focus=false win.position=right<CR>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      { "<Leader>xL", "<Cmd>Trouble loclist toggle<CR>", desc = "Location List (Trouble)" },
      { "<Leader>xQ", "<Cmd>Trouble qflist toggle<CR>", desc = "Quickfix List (Trouble)" },
    },
    config = function()
      require("trouble").setup()

      local signs = {
        Error = "",
        Warn = "",
        Hint = "",
        Info = "",
      }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end
    end,
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
  },

  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
  },

  {
    "folke/which-key.nvim",
    event = { "VeryLazy" },
    opts = {},
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },

  -- }}}

  -- ## Terminals: {{{

  {
    "akinsho/toggleterm.nvim",
    version = "v2.*",
    cmd = { "ToggleTerm", "TermOpen", "TermExec" },
    keys = {
      { "<C-\\>" },
      {
        "<Leader>lg",
        function()
          require("toggleterm.terminal").Terminal:new({ cmd = "lazygit", direction = "float", count = 0 }):toggle()
        end,
        desc = "Show Lazygit (Git)",
      },
      {
        "<Leader>lzd",
        function()
          require("toggleterm.terminal").Terminal:new({ cmd = "lazydocker", direction = "float", count = 0 }):toggle()
        end,
        desc = "Show Lazydocker (Docker)",
      },
    },
    opts = {
      open_mapping = [[<C-\>]],
      insert_mappings = true,
    },
  },

  -- }}}

  -- ## Themes: {{{

  {
    "projekt0n/github-nvim-theme",
    version = "v1.*",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
      require("github-theme").setup({
        options = {
          modules = {
            notify = false,
          },
          styles = {
            functions = "italic",
          },
          transparent = true,
        },
      })
      vim.cmd("colorscheme github_dark_high_contrast")
      vim.api.nvim_set_hl(0, "VertSplit", { fg = "#161b22" })
      vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#161b22" })
      vim.api.nvim_set_hl(0, "@property.json", { fg = "#6bc46d" })
      vim.api.nvim_set_hl(0, "@property.json", { fg = "#6bc46d" })
      require("notify").setup({
        render = "default",
        background_colour = "#000000",
      })
    end,
    dependencies = {
      { "rcarriga/nvim-notify" },
    },
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    enabled = true,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        transparent = true,
        styles = {
          -- Style to be applied to different syntax groups
          -- Value is any valid attr-list value for `:help nvim_set_hl`
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
          -- Background styles. Can be "dark", "transparent" or "normal"
          sidebars = "transparent", -- style for sidebars, see below
          floats = "transparent", -- style for floating windows
        },
        sidebars = { "qf", "vista_kind", "terminal", "packer" },
        on_colors = function() end,
      })
      vim.cmd("colorscheme tokyonight")
      vim.api.nvim_set_hl(0, "VertSplit", { fg = "#000000" })
      vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#000000" })
      vim.api.nvim_set_hl(0, "@property.json", { fg = "#7aa2f7" })
      vim.api.nvim_set_hl(0, "@property.yaml", { fg = "#f7768e" })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = { "VeryLazy" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_x = {
            {
              require("noice").api.status.command.get,
              cond = require("noice").api.status.command.has,
              color = { fg = "#ff9e64" },
            },
            {
              require("noice").api.status.mode.get,
              cond = require("noice").api.status.mode.has,
              color = { fg = "#ff9e64" },
            },
            {
              require("noice").api.status.search.get,
              cond = require("noice").api.status.search.has,
              color = { fg = "#ff9e64" },
            },
            "encoding",
            "fileformat",
            "filetype",
          },
        },
      })
    end,
    dependencies = {
      { "noice.nvim" },
      { "folke/tokyonight.nvim" },
      { "projekt0n/github-nvim-theme" },
    },
  },

  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
  },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      options = {
        offsets = {
          {
            filetype = "neo-tree",
            text = "Neo-tree Sidebar",
            separator = true,
          },
        },
      },
    },
    config = true,
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterBlue",
          "RainbowDelimiterGreen",
          "RainbowDelimiterYellow",
          "RainbowDelimiterOrange",
          "RainbowDelimiterRed",
          "RainbowDelimiterViolet",
        },
      }
    end,
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local highlight = {
        "RainbowBlue",
        "RainbowGreen",
        "RainbowYellow",
        "RainbowOrange",
        "RainbowRed",
        "RainbowViolet",
      }
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
      end)
      vim.api.nvim_set_hl(0, "IblIndent", { fg = "#383a3e" })
      vim.g.rainbow_delimiters = { highlight = highlight }
      require("ibl").setup({
        indent = {
          char = "▏",
        },
        scope = {
          char = "▏",
          highlight = highlight,
        },
      })
      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    end,
    dependencies = {
      { "HiPhish/rainbow-delimiters.nvim" },
    },
  },

  {
    "norcalli/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      "*",
      "!toggleterm",
      "!packer",
      "!help",
    },
  },

  {
    "lukas-reineke/virt-column.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      char = "▕",
      virtcolumn = "+1",
      highlight = "VirtColumn",
    },
    config = function(_, opts)
      require("virt-column").setup(opts)
    end,
  },

  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewFileHistory",
    },
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.keymap.set("n", "]c", "<Cmd>Gitsigns next_hunk<CR>", {})
      vim.keymap.set("n", "[c", "<Cmd>Gitsigns prev_hunk<CR>", {})
    end,
    config = function()
      require("gitsigns").setup()
    end,
  },

  {
    "goolord/alpha-nvim",
    event = { "VimEnter" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- helper function for utf8 chars
      local function getCharLen(s, pos)
        local byte = string.byte(s, pos)
        if not byte then
          return nil
        end
        return (byte < 0x80 and 1) or (byte < 0xE0 and 2) or (byte < 0xF0 and 3) or (byte < 0xF8 and 4) or 1
      end

      local function applyColors(logo, colors, logoColors)
        dashboard.section.header.val = logo

        for key, color in pairs(colors) do
          local name = "Alpha" .. key
          vim.api.nvim_set_hl(0, name, color)
          colors[key] = name
        end

        dashboard.section.header.opts.hl = {}
        for i, line in ipairs(logoColors) do
          local highlights = {}
          local pos = 0

          for j = 1, #line do
            local opos = pos
            pos = pos + getCharLen(logo[i], opos + 1)

            local color_name = colors[line:sub(j, j)]
            if color_name then
              table.insert(highlights, { color_name, opos, pos })
            end
          end

          table.insert(dashboard.section.header.opts.hl, highlights)
        end

        dashboard.section.buttons.val = {
          dashboard.button("e", "  New File", "<Cmd>enew <BAR> startinsert <CR>"),
          dashboard.button("f", "  Find File", "<Cmd>Telescope find_files<CR>"),
          dashboard.button("g", "  Find Text", "<Cmd>Telescope live_grep<CR>"),
          dashboard.button("d", "  Source Control", function()
            require("toggleterm.terminal").Terminal:new({ cmd = "lazygit", direction = "tab", count = 0 }):toggle()
          end),
          dashboard.button("r", "  Recent Files", "<Cmd>Telescope oldfiles<CR>"),
          dashboard.button("c", "  Configuration", "<Cmd>edit $MYVIMRC<CR>"),
          dashboard.button("q", "  Quit", "<Cmd>qall<CR>"),
        }
        for _, button in ipairs(dashboard.section.buttons.val) do
          button.opts.hl = "AlphaButtons"
          button.opts.hl_shortcut = "AlphaShortcut"
        end

        dashboard.section.footer.val = "   Press any key to Start. "
        dashboard.section.footer.opts.hl = "AlphaFooter"

        return dashboard.opts
      end

      alpha.setup(applyColors({
        [[  ███       ███  ]],
        [[  ████      ████ ]],
        [[  ████     █████ ]],
        [[ █ ████    █████ ]],
        [[ ██ ████   █████ ]],
        [[ ███ ████  █████ ]],
        [[ ████ ████ ████ ]],
        [[ █████  ████████ ]],
        [[ █████   ███████ ]],
        [[ █████    ██████ ]],
        [[ █████     █████ ]],
        [[ ████      ████ ]],
        [[  ███       ███  ]],
        [[                    ]],
        [[  N  E  O  V  I  M  ]],
      }, {
        ["b"] = { fg = "#3399ff", ctermfg = 33 },
        ["a"] = { fg = "#53C670", ctermfg = 35 },
        ["g"] = { fg = "#39ac56", ctermfg = 29 },
        ["h"] = { fg = "#33994d", ctermfg = 23 },
        ["i"] = { fg = "#33994d", bg = "#39ac56", ctermfg = 23, ctermbg = 29 },
        ["j"] = { fg = "#53C670", bg = "#33994d", ctermfg = 35, ctermbg = 23 },
        ["k"] = { fg = "#30A572", ctermfg = 36 },
      }, {
        [[  kkkka       gggg  ]],
        [[  kkkkaa      ggggg ]],
        [[ b kkkaaa     ggggg ]],
        [[ bb kkaaaa    ggggg ]],
        [[ bbb kaaaaa   ggggg ]],
        [[ bbbb aaaaaa  ggggg ]],
        [[ bbbbb aaaaaa igggg ]],
        [[ bbbbb  aaaaaahiggg ]],
        [[ bbbbb   aaaaajhigg ]],
        [[ bbbbb    aaaaajhig ]],
        [[ bbbbb     aaaaajhi ]],
        [[ bbbbb      aaaaajh ]],
        [[  bbbb       aaaaa  ]],
        [[                    ]],
        [[  a  a  a  b  b  b  ]],
      }))
    end,
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
  },

  {
    "wfxr/minimap.vim",
    build = "cargo install --locked code-minimap",
    cmd = {
      "Minimap",
      "MinimapToggle",
    },
    config = function()
      vim.cmd("let g:minimap_width = 10")
      vim.cmd("let g:minimap_auto_start = 0")
      vim.cmd("let g:minimap_auto_start_win_enter = 0")
    end,
  },

  --- }}}

  -- ## Miscellaneous: {{{

  {
    "vim-jp/vimdoc-ja",
    keys = {
      { "h", mode = "c" },
    },
    build = "git restore doc/tags-ja",
  },

  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
  },

  -- }}}

  -- ## Ends: {{{
}

-- }}}

-- # Lazy Options: {{{

local opts = {
  defaults = {
    lazy = true,
  },
  performance = {
    cache = {
      enabled = true,
    },
  },
}

-- }}}

-- # Lazy Setup: {{{
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup(plugins, opts)

-- }}}
