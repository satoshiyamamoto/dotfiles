-- vim:foldmethod=marker

-- # Basics: {{{

vim.g.mapleader = " "
vim.g.loaded_netrw = true
vim.g.loaded_netrwPlugin = true

vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.laststatus = 3
vim.opt.termguicolors = true
vim.opt.confirm = true
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.clipboard:append({ "unnamedplus" })
vim.opt.shortmess:append({ c = true, I = true })
vim.opt.updatetime = 100
vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
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
vim.keymap.set("n", "<C-Up>", "<Cmd>resize -2<CR>", {})
vim.keymap.set("n", "<C-Down>", "<Cmd>resize +2<CR>", {})
vim.keymap.set("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", {})
vim.keymap.set("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", {})

-- Diagnostics
vim.keymap.set("n", "]q", "<Cmd>cnext<CR>", {})
vim.keymap.set("n", "[q", "<Cmd>cprev<CR>", {})
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
        "go",
        "gomod",
        "hcl",
        "html",
        "java",
        "javascript",
        "json",
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
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "#161b22" })
    end,
    dependencies = {
      { "nvim-treesitter" },
      { "github-nvim-theme" },
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
      { "nvim-treesitter" },
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
        lua = { "stylua" },
        go = { "goimports", "gofmt" },
        java = { "google-java-format" },
        javascript = { { "prettierd", "prettier" } },
        proto = { "clang-format" },
        python = { "isort", "black" },
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
          { name = "copilot" },
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "vsnip" }, -- For vsnip users.
          { name = "buffer" },
          { name = "path" },
          -- { name = "copilot" },
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

      -- Mappings
      vim.cmd([[
       imap <expr> <C-j>   vsnip#expandable() ? "<Plug>(vsnip-expand)"         : "<C-j>"
       smap <expr> <C-j>   vsnip#expandable() ? "<Plug>(vsnip-expand)"         : "<C-j>"
       imap <expr> <C-l>   vsnip#available(1) ? "<Plug>(vsnip-expand-or-jump)" : "<C-l>"
       smap <expr> <C-l>   vsnip#available(1) ? "<Plug>(vsnip-expand-or-jump)" : "<C-l>"
       imap <expr> <Tab>   vsnip#jumpable(1)  ? "<Plug>(vsnip-jump-next)"      : "<Tab>"
       smap <expr> <Tab>   vsnip#jumpable(1)  ? "<Plug>(vsnip-jump-next)"      : "<Tab>"
       imap <expr> <S-Tab> vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)"      : "<S-Tab>"
       smap <expr> <S-Tab> vsnip#jumpable(-1) ? "<Plug>(vsnip-jump-prev)"      : "<S-Tab>"
       ]])
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
      lspconfig.bufls.setup({ capabilities = capabilities })
      lspconfig.gopls.setup({ capabilities = capabilities })
      lspconfig.pyright.setup({ capabilities = capabilities })
      lspconfig.tsserver.setup({ capabilities = capabilities })
      lspconfig.terraformls.setup({ capabilities = capabilities })
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
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<Space>wa", vim.lsp.buf.add_workspace_folder, opts)
          vim.keymap.set("n", "<Space>wr", vim.lsp.buf.remove_workspace_folder, opts)
          vim.keymap.set("n", "<Space>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, opts)
          vim.keymap.set("n", "<Space>D", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<Space>lf", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
          vim.keymap.set("n", "gh", "<Cmd>Lspsaga lsp_finder<CR>")
          vim.keymap.set({ "n", "v" }, "<Space>ca", "<Cmd>Lspsaga code_action<CR>")
          vim.keymap.set("n", "<Space>rn", "<Cmd>Lspsaga rename<CR>")
          vim.keymap.set("n", "gp", "<Cmd>Lspsaga peek_definition<CR>")
          vim.keymap.set("n", "gt", "<Cmd>Lspsaga goto_type_definition<CR>")
          vim.keymap.set("n", "<Space>o", "<Cmd>Lspsaga outline<CR>")
          vim.keymap.set("n", "K", "<Cmd>Lspsaga hover_doc<CR>")
          vim.keymap.set("n", "<Space>ci", "<Cmd>Lspsaga incoming_calls<CR>")
          vim.keymap.set("n", "<Space>co", "<Cmd>Lspsaga outgoing_calls<CR>")
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
        javascript = { "eslint_d" },
        python = { "flake8", "mypy" },
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
          "bufls",
          "gopls",
          "jdtls",
          "lua_ls",
          "pyright",
          "rust_analyzer",
          "terraformls",
          "tsserver",
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
    "folke/trouble.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TroubleToggle" },
    keys = {
      { "<Leader>xx", "<Cmd>TroubleToggle<CR>" },
      { "<Leader>xw", "<Cmd>TroubleToggle workspace_diagnostics<CR>" },
      { "<Leader>xd", "<Cmd>TroubleToggle document_diagnostics<CR>" },
      { "<Leader>xl", "<Cmd>TroubleToggle loclist<CR>" },
      { "<Leader>xq", "<Cmd>TroubleToggle quickfix<CR>" },
      { "gR", "<Cmd>TroubleToggle lsp_references<CR>" },
    },
    config = function()
      require("trouble").setup()

      local signs = {
        Error = "󰅚 ",
        Warn = "󰀪 ",
        Hint = "󰌶 ",
        Info = " ",
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
    "nvimdev/lspsaga.nvim",
    config = function()
      require("lspsaga").setup({
        lightbulb = {
          enable = false,
        },
      })
    end,
    event = { "LspAttach" },
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

      vim.keymap.set("n", "<F5>", dap.continue, {})
      vim.keymap.set("n", "<F17>", dap.terminate, {})
      vim.keymap.set("n", "<F10>", dap.step_over, {})
      vim.keymap.set("n", "<F11>", dap.step_into, {})
      vim.keymap.set("n", "<F23>", dap.step_out, {})
      vim.keymap.set("n", "<Leader>b", dap.toggle_breakpoint, {})
      vim.keymap.set("n", "<Leader>B", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, {})
      vim.keymap.set("n", "<Leader>lp", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      end, {})
      vim.keymap.set("n", "<Leader>du", dapui.toggle, {})
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "ErrorMsg" })
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
    "vim-test/vim-test",
    cmd = { "TestFile", "TestNearest" },
    keys = {
      { "<Leader>df", "<Cmd>TestFile<CR>" },
      { "<Leader>dn", "<Cmd>TestNearest<CR>" },
    },
  },

  -- }}}

  -- ## Finders: {{{
  {
    "nvim-telescope/telescope.nvim",
    cmd = { "Telescope" },
    keys = {
      { "<C-p>", "<Cmd>Telescope find_files<CR>" },
      { "<Leader>ff", "<Cmd>Telescope find_files<CR>" },
      { "<Leader>fg", "<Cmd>Telescope live_grep<CR>" },
      { "<Leader>fb", "<Cmd>Telescope buffers<CR>" },
      { "<Leader>fr", "<Cmd>Telescope oldfiles<CR>" },
      { "<Leader>fh", "<Cmd>Telescope help_tags<CR>" },
      { "<Leader>fs", "<Cmd>Telescope lsp_document_symbols<CR>" },
      { "<Leader>fS", "<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>" },
      { "<Leader>fd", "<Cmd>Telescope dap configurations<CR>" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          path_display = { truncate = 0 },
          file_ignore_patterns = {
            "node_modules",
            "build/",
            "%.class",
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
      telescope.load_extension("ui-select")
      telescope.load_extension("dap")
    end,
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-telescope/telescope-dap.nvim" },
    },
  },

  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
  },

  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle" },
    keys = {
      { "<Leader>e", "<Cmd>NvimTreeToggle<CR>" },
    },
    opts = {
      sort_by = "case_sensitive",
      renderer = {
        group_empty = true,
        root_folder_label = function(path)
          return vim.fn.fnamemodify(path, ":t") .. "/.."
        end,
      },
      filters = {
        dotfiles = true,
      },
    },
    dependencies = {
      { "nvim-tree/nvim-web-devicons", opt = true },
    },
  },

  {
    "phaazon/hop.nvim",
    branch = "v2",
    cmd = { "HopWord" },
    keys = {
      { "ff", "<Cmd>HopWord<CR>" },
    },
    config = function()
      require("hop").setup()
    end,
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
          require("toggleterm.terminal").Terminal
            :new({
              cmd = "lazygit",
              direction = "float",
              hidden = true,
              count = 0,
            })
            :toggle()
        end,
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
      vim.api.nvim_set_hl(0, "VertSplit", { fg = "#161b22", bg = "None" })
      vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#161b22", bg = "None" })
      vim.api.nvim_set_hl(0, "@property.json", { fg = "#6bc46d", bg = "None" })
      vim.api.nvim_set_hl(0, "@property.yaml", { fg = "#6bc46d", bg = "None" })
    end,
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        styles = {
          functions = {},
        },
        sidebars = { "qf", "vista_kind", "terminal", "packer" },
        on_colors = function() end,
      })
      -- vim.cmd("colorscheme tokyonight")
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = { "VeryLazy" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
        },
        sections = {
          lualine_x = {
            {
              require("noice").api.status.command.get,
              cond = require("noice").api.status.command.has,
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
      { "github-nvim-theme" },
    },
  },

  {
    "folke/noice.nvim",
    event = { "VeryLazy" },
    init = function()
      vim.keymap.set({ "n", "i", "s" }, "<C-f>", function()
        if not require("noice.lsp").scroll(4) then
          return "<C-f>"
        end
      end, { silent = true, expr = true })
      vim.keymap.set({ "n", "i", "s" }, "<C-b>", function()
        if not require("noice.lsp").scroll(-4) then
          return "<C-b>"
        end
      end, { silent = true, expr = true })
    end,
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = {
          bottom_search = true,
          command_palette = true,
          long_message_to_split = false,
          inc_rename = false,
          lsp_doc_border = true,
        },
      })
      require("notify").setup({
        render = "default",
        background_colour = "#000000",
      })
    end,
    dependencies = {
      { "MunifTanjim/nui.nvim" },
      { "rcarriga/nvim-notify" },
    },
  },

  {
    "folke/which-key.nvim",
    event = { "VeryLazy" },
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {},
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
            filetype = "NvimTree",
            text = "Explorer",
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
      dashboard.section.header.val = {
        [[                               __                ]],
        [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
        [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
        [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
        [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
        [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
      }
      dashboard.section.header.opts.hl = "Constant"
      dashboard.section.buttons.val = {
        dashboard.button("f", "󰈞  Find file", "<Cmd>Telescope find_files<CR>"),
        dashboard.button("e", "  New file", "<Cmd>enew <BAR> startinsert <CR>"),
        dashboard.button("r", "  Recent files", "<Cmd>Telescope oldfiles<CR>"),
        dashboard.button("g", "󰊄  Find Text", "<Cmd>Telescope live_grep<CR>"),
        dashboard.button("c", "  Configuration", "<Cmd>edit $MYVIMRC<CR>"),
        dashboard.button("q", "󰅖  Quit", "<Cmd>qall<CR>"),
      }
      dashboard.config = {
        layout = {
          { type = "padding", val = 2 },
          dashboard.section.header,
          { type = "padding", val = 4 },
          dashboard.section.buttons,
          dashboard.section.footer,
        },
        opts = {
          margin = 5,
        },
      }
      alpha.setup(dashboard.config)
    end,
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
  },

  {
    "wfxr/minimap.vim",
    build = "cargo install --locked code-minimap",
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
