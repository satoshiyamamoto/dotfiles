-- vim:foldmethod=marker

-- Basic: {{{

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
vim.opt.colorcolumn = "+1"
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.clipboard:append({ "unnamedplus" })
vim.opt.shortmess:append({ c = true, I = true })
vim.opt.updatetime = 100
vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"

-- }}}

-- Mappings: {{{

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

-- Plugins: {{{

local ensure_packer = function()
  local fn = vim.fn
  local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require("packer").startup(function(use)
  use({ "wbthomason/packer.nvim" })
  use({ "dstein64/vim-startuptime", cmd = { "StartupTime" } })

  -- }}}

  -- Syntax: {{{

  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
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
          "python",
          "query",
          "regex",
          "rust",
          "sql",
          "tsx",
          "typescript",
          "vim",
          "yaml",
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "yaml" },
        },
        autotag = {
          enable = true,
        },
        context_commentstring = {
          enable = true,
        },
      })

      -- TODO:Use after v0.10 'vim.treesitter.language.register'
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreeSitterRegister", {}),
        pattern = { "xml" },
        callback = function()
          require("nvim-treesitter.parsers").filetype_to_parsername.xml = "html"
        end,
      })
    end,
    requires = {
      { "windwp/nvim-ts-autotag",                      opt = true },
      { "JoosepAlviste/nvim-ts-context-commentstring", opt = true },
    },
  })

  use({
    "nvim-treesitter/nvim-treesitter-context",
    config = function()
      require("treesitter-context").setup({
        enable = true,
      })
    end,
    after = "nvim-treesitter",
  })

  use({
    "HiPhish/nvim-ts-rainbow2",
    config = function()
      require("nvim-treesitter.configs").setup({
        rainbow = {
          enable = true,
          disable = { "jsx", "html" },
          query = "rainbow-parens",
          strategy = require("ts-rainbow").strategy.global,
        },
      })
    end,
    after = "nvim-treesitter",
  })

  use({
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup({
        use_treesitter = true,
        show_current_context = true,
        show_current_context_start = true,
        char = "▏",
        context_char = "▏",
        context_highlight_list = {
          "IndentBlanklineIndent1",
          "IndentBlanklineIndent2",
          "IndentBlanklineIndent3",
          "IndentBlanklineIndent4",
          "IndentBlanklineIndent5",
          "IndentBlanklineIndent6",
          "IndentBlanklineIndent7",
        },
      })
      vim.api.nvim_set_hl(0, "IndentBlanklineContextStart", { sp = "#b16286", underline = true })
      vim.api.nvim_set_hl(0, "IndentBlanklineIndent1", { fg = "#b16286", nocombine = true })
      vim.api.nvim_set_hl(0, "IndentBlanklineIndent2", { fg = "#689d6a", nocombine = true })
      vim.api.nvim_set_hl(0, "IndentBlanklineIndent3", { fg = "#458588", nocombine = true })
      vim.api.nvim_set_hl(0, "IndentBlanklineIndent4", { fg = "#a89984", nocombine = true })
      vim.api.nvim_set_hl(0, "IndentBlanklineIndent5", { fg = "#d79921", nocombine = true })
      vim.api.nvim_set_hl(0, "IndentBlanklineIndent6", { fg = "#d65d0e", nocombine = true })
      vim.api.nvim_set_hl(0, "IndentBlanklineIndent7", { fg = "#cc241d", nocombine = true })
    end,
    after = "nvim-treesitter",
  })

  use({
    "iloginow/vim-stylus",
    event = { "BufReadPost", "BufNewFile" },
  })

  -- }}}

  -- Completions: {{{

  use({
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")

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
          -- { name = "copilot" },
        }),
        formatting = {
          format = require("lspkind").cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            preset = "default",
          }),
        },
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
    requires = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lsp-signature-help" },
      { "hrsh7th/cmp-nvim-lsp-document-symbol" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-cmdline" },
      { "hrsh7th/cmp-copilot" },
      { "hrsh7th/cmp-vsnip" },
      { "hrsh7th/vim-vsnip" },
      { "hrsh7th/vim-vsnip-integ" },
    },
  })

  use({ "github/copilot.vim" })
  use({ "onsails/lspkind-nvim" })
  use({ "golang/vscode-go" })

  -- }}}

  -- Snippets: {{{

  use({
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end,
  })

  use({ "rafamadriz/friendly-snippets" })
  use({ "tpope/vim-unimpaired" })
  use({ "tpope/vim-fugitive" })
  use({ "tpope/vim-surround" })
  use({ "tpope/vim-commentary" })
  use({ "mattn/emmet-vim" })

  -- }}}

  -- LSP: {{{

  use({
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Language servers
      local lspconfig = require("lspconfig")
      lspconfig["gopls"].setup({ capabilities = capabilities })
      lspconfig["pyright"].setup({ capabilities = capabilities })
      lspconfig["tsserver"].setup({ capabilities = capabilities })
      lspconfig["terraformls"].setup({ capabilities = capabilities })
      lspconfig["rust_analyzer"].setup({ capabilities = capabilities })
      lspconfig["lua_ls"].setup({
        capabilities = capabilities,
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
    end,
    requires = {
      { "hrsh7th/cmp-nvim-lsp" },
    },
  })

  use({
    "williamboman/mason.nvim",
    run = ":MasonUpdate",
    cmd = { "Mason" },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "gopls",
          "jdtls",
          "lua_ls",
          "pyright",
          "rust_analyzer",
          "tsserver",
          "terraformls",
        },
      })
      require("mason-nvim-dap").setup({
        ensure_installed = {
          "delve",
          "javadbg",
          "javatest",
          "js",
          "python",
        },
      })
      require("mason-null-ls").setup({
        ensure_installed = {
          "black",
          "flake8",
          "goimports",
          "isort",
          "mypy",
          "prettier",
          "staticcheck",
          "stylua",
          "sqlfluff",
        },
      })
    end,
    requires = {
      { "williamboman/mason-lspconfig.nvim" },
      { "jay-babu/mason-nvim-dap.nvim" },
      { "jay-babu/mason-null-ls.nvim" },
    },
  })

  use({
    "jose-elias-alvarez/null-ls.nvim",
    event = { "LspAttach" },
    config = function()
      local null_ls = require("null-ls")
      local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.goimports,
          null_ls.builtins.formatting.rustfmt,
          null_ls.builtins.formatting.isort,
          null_ls.builtins.formatting.black,
          null_ls.builtins.formatting.google_java_format,
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.formatting.sqlfluff.with({
            extra_args = { "--dialect", "bigquery" },
          }),
          null_ls.builtins.diagnostics.staticcheck,
          null_ls.builtins.diagnostics.flake8,
          null_ls.builtins.diagnostics.mypy,
          null_ls.builtins.diagnostics.eslint,
          null_ls.builtins.diagnostics.sqlfluff.with({
            extra_args = { "--dialect", "bigquery" },
          }),
        },
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
              end,
            })
          end
        end,
      })
    end,
    requires = { "nvim-lua/plenary.nvim" },
  })

  use({
    "folke/trouble.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TroubleToggle" },
    setup = function()
      vim.keymap.set("n", "<Leader>xx", "<Cmd>TroubleToggle<CR>", {})
      vim.keymap.set("n", "<Leader>xw", "<Cmd>TroubleToggle workspace_diagnostics<CR>", {})
      vim.keymap.set("n", "<Leader>xd", "<Cmd>TroubleToggle document_diagnostics<CR>", {})
      vim.keymap.set("n", "<Leader>xl", "<Cmd>TroubleToggle loclist<CR>", {})
      vim.keymap.set("n", "<Leader>xq", "<Cmd>TroubleToggle quickfix<CR>", {})
      vim.keymap.set("n", "gR", "<Cmd>TroubleToggle lsp_references<CR>", {})
    end,
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
    requires = {
      { "nvim-tree/nvim-web-devicons" },
    },
  })

  use({
    "glepnir/lspsaga.nvim",
    opt = true,
    branch = "main",
    config = function()
      require("lspsaga").setup({
        lightbulb = {
          enable = false,
        },
        ui = {
          kind = {
            ["Folder"] = { " ", "NvimTreeFolderIcon" },
          },
        },
      })
    end,
    requires = {
      { "nvim-tree/nvim-web-devicons" },
      { "nvim-treesitter/nvim-treesitter" },
    },
    after = "nvim-treesitter",
  })

  -- }}}

  -- DAP: {{{

  use({
    "rcarriga/nvim-dap-ui",
    config = function()
      require("dapui").setup()
      require("dap-go").setup()
      require("dap-python").setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")
      require("dap-vscode-js").setup({
        adapters = { "pwa-node", "node-terminal" },
      })

      for _, language in ipairs({ "typescript", "javascript" }) do
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

      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      -- dap.listeners.before.event_terminated["dapui_config"] = function()
      --   dapui.close()
      -- end
      -- dap.listeners.before.event_exited["dapui_config"] = function()
      --   dapui.close()
      -- end

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
    end,
    requires = {
      { "mfussenegger/nvim-dap" },
      { "mfussenegger/nvim-dap-python" },
      { "mfussenegger/nvim-jdtls" },
      { "mxsdev/nvim-dap-vscode-js" },
      { "leoluz/nvim-dap-go" },
      { "theHamsta/nvim-dap-virtual-text" },
      {
        "microsoft/vscode-js-debug",
        opt = true,
        run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
      },
    },
  })

  use({
    "vim-test/vim-test",
    setup = function()
      vim.keymap.set("n", "<leader>df", "<Cmd>TestFile<CR>", {})
      vim.keymap.set("n", "<leader>dn", "<Cmd>TestNearest<CR>", {})
    end,
  })

  -- }}}

  -- Finder: {{{

  use({
    "nvim-telescope/telescope.nvim",
    cmd = { "Telescope" },
    setup = function()
      vim.keymap.set("n", "<C-p>", "<Cmd>Telescope find_files<CR>", {})
      vim.keymap.set("n", "<Leader>ff", "<Cmd>Telescope find_files<CR>", {})
      vim.keymap.set("n", "<Leader>fg", "<Cmd>Telescope live_grep<CR>", {})
      vim.keymap.set("n", "<Leader>fb", "<Cmd>Telescope buffers<CR>", {})
      vim.keymap.set("n", "<Leader>fr", "<Cmd>Telescope oldfiles<CR>", {})
      vim.keymap.set("n", "<Leader>fh", "<Cmd>Telescope help_tags<CR>", {})
      vim.keymap.set("n", "<Leader>fs", "<Cmd>Telescope lsp_document_symbols<CR>", {})
      vim.keymap.set("n", "<Leader>fS", "<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>", {})
    end,
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
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
    requires = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
      { "nvim-telescope/telescope-ui-select.nvim" },
    },
  })

  use({
    "kevinhwang91/nvim-bqf",
    ft = "qf",
  })

  use({
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle" },
    setup = function()
      vim.keymap.set("n", "<Leader>e", "<Cmd>NvimTreeToggle<CR>", {})
    end,
    config = function()
      require("nvim-tree").setup({
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
      })
      vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#24292e" })
    end,
    requires = {
      { "nvim-tree/nvim-web-devicons", opt = true },
    },
  })

  use({
    "phaazon/hop.nvim",
    branch = "v2",
    setup = function()
      vim.keymap.set("n", "ff", "<Cmd>HopWord<CR>", {})
    end,
    config = function()
      require("hop").setup()
    end,
  })

  -- }}}

  -- Terminal: {{{

  use({
    "akinsho/toggleterm.nvim",
    tag = "v2.*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<C-\>]],
        insert_mappings = true,
      })
      vim.keymap.set("n", "<Leader>lg", function()
        require("toggleterm.terminal").Terminal
            :new({
              cmd = "lazygit",
              direction = "float",
              hidden = true,
              count = 0,
            })
            :toggle()
      end)
      vim.cmd([[
      autocmd TermOpen * startinsert
      autocmd TermOpen * setlocal nonumber norelativenumber
      ]])
    end,
  })

  -- }}}

  -- Theme: {{{

  use({
    "projekt0n/github-nvim-theme",
    event = { "VimEnter" },
    tag = "v0.0.7",
    config = function()
      require("github-theme").setup({
        function_style = "italic",
        sidebars = { "qf", "vista_kind", "terminal", "packer" },
        transparent = true,
      })
      vim.cmd([[colorscheme github_dark_default]])
      vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#24292e" })
    end,
  })

  use({
    "folke/tokyonight.nvim",
    event = { "VimEnter" },
    config = function()
      require("tokyonight").setup({
        style = "night",
        styles = {
          functions = {},
        },
        sidebars = { "qf", "vista_kind", "terminal", "packer" },
        on_colors = function() end,
      })
      -- vim.cmd([[colorscheme tokyonight]])
    end,
  })

  use({
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = { theme = "auto" },
        sections = {
          lualine_x = {
            {
              require("noice").api.statusline.mode.get,
              cond = require("noice").api.statusline.mode.has,
              color = { fg = "#ff9e64" },
            },
          },
        },
      })
      vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "None" })
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", { sp = "#24292e", underline = true })
    end,
    after = "github-nvim-theme",
  })

  use({
    "folke/noice.nvim",
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
          command_palette = false,
          long_message_to_split = true,
          inc_rename = true,
          lsp_doc_border = false,
        },
      })
      require("inc_rename").setup()
      require("notify").setup({
        background_colour = "#000000",
      })
    end,
    requires = {
      { "MunifTanjim/nui.nvim" },
      { "rcarriga/nvim-notify" },
      { "smjonas/inc-rename.nvim" },
    },
  })

  use({
    "folke/todo-comments.nvim",
    config = function()
      require("todo-comments").setup()
    end,
    requires = {
      { "nvim-lua/plenary.nvim" },
    },
  })

  use({
    "akinsho/bufferline.nvim",
    tag = "v3.*",
    config = function()
      require("bufferline").setup({
        options = {
          offsets = {
            { filetype = "NvimTree" },
          },
        },
      })
    end,
  })

  use({
    "norcalli/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        "*",
        "!toggleterm",
      })
    end,
  })

  use({
    "lukas-reineke/virt-column.nvim",
    config = function()
      require("virt-column").setup({
        char = "▕",
      })
      vim.api.nvim_set_hl(0, "VirtColumn", { fg = "#24292e", bg = nil })
    end,
    after = "github-nvim-theme",
  })

  use({
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    setup = function()
      vim.keymap.set("n", "]c", "<Cmd>Gitsigns next_hunk<CR>", {})
      vim.keymap.set("n", "[c", "<Cmd>Gitsigns prev_hunk<CR>", {})
    end,
    config = function()
      require("gitsigns").setup()
    end,
  })

  use({
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
    requires = {
      { "nvim-tree/nvim-web-devicons" },
    },
  })

  use({
    "wfxr/minimap.vim",
    run = "cargo install --locked code-minimap",
    config = function()
      vim.cmd("let g:minimap_width = 10")
      vim.cmd("let g:minimap_auto_start = 0")
      vim.cmd("let g:minimap_auto_start_win_enter = 0")
    end,
  })

  --- }}}

  -- Plugins end: {{{
  if packer_bootstrap then
    require("packer").sync()
  end
end)

-- }}}
