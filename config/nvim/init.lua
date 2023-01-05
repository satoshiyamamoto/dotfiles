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
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.clipboard:append({ "unnamedplus" })
vim.opt.updatetime = 100
--vim.opt_global.shortmess:remove("F"):append("c")

-- }}}

-- Mappings: {{{

local opts = { noremap = true, silent = true }

-- Insert
vim.keymap.set("i", "jj", "<Esc>", opts)

-- Buffers
vim.keymap.set("n", "[b", "<Cmd>:bprevious<CR>", opts)
vim.keymap.set("n", "]b", "<Cmd>:bnext<CR>", opts)
vim.keymap.set("n", "[B", "<Cmd>:bfirst<CR>", opts)
vim.keymap.set("n", "]B", "<Cmd>:blast<CR>", opts)

-- Windows
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Diagnostics
vim.keymap.set("n", "<Leader>e", vim.diagnostic.open_float, opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
vim.keymap.set("n", "<Leader>q", vim.diagnostic.setloclist, opts)

-- Terminal
vim.keymap.set("n", "<C-`>", "<Cmd>:ToggleTerm<CR>", opts)
vim.keymap.set("t", "<C-`>", "<Cmd>:ToggleTerm<CR>", opts)
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)
vim.keymap.set("t", "<C-[>", "<C-\\><C-n>", opts)

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
  use({ "dstein64/vim-startuptime" })

  -- }}}

  -- Syntax: {{{

  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
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
          "yaml",
        },
        highlight = {
          enable = true,
          disable = { "html" },
          additional_vim_regex_highlighting = { "yaml" },
        },
        rainbow = {
          enable = true,
          disable = { "html" },
          extended_mode = false,
          max_file_lines = nil,
        },
      })
      require("treesitter-context").setup({
        enable = true,
      })
      vim.api.nvim_set_hl(0, "TreesitterContext", { link = "Normal" })
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", { sp = "#2f363d", underline = true })
    end,
    requires = {
      { "nvim-treesitter/nvim-treesitter-context" },
      { "p00f/nvim-ts-rainbow" },
    },
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
          "rainbowcol3",
          "rainbowcol5",
          "rainbowcol7",
          "rainbowcol2",
          "rainbowcol4",
          "rainbowcol6",
          "rainbowcol1",
        },
      })
      vim.api.nvim_set_hl(0, "IndentBlanklineContextStart", { sp = "#b16286", underline = true })
    end,
    after = "nvim-ts-rainbow",
  })

  use({ "editorconfig/editorconfig-vim" })

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
          -- completion = cmp.config.window.bordered(),
          -- documentation = cmp.config.window.bordered(),
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
          { name = "vsnip" }, -- For vsnip users.
        }, {
          { name = "buffer" },
          { name = "path" },
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
        sources = {
          { name = "buffer" },
        },
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
      vim.cmd([[imap <expr> <C-j>   vsnip#expandable()  ? "<Plug>(vsnip-expand)"         : "<C-j>"]])
      vim.cmd([[smap <expr> <C-j>   vsnip#expandable()  ? "<Plug>(vsnip-expand)"         : "<C-j>"]])
      vim.cmd([[imap <expr> <C-l>   vsnip#available(1)  ? "<Plug>(vsnip-expand-or-jump)" : "<C-l>"]])
      vim.cmd([[smap <expr> <C-l>   vsnip#available(1)  ? "<Plug>(vsnip-expand-or-jump)" : "<C-l>"]])
      vim.cmd([[imap <expr> <Tab>   vsnip#jumpable(1)   ? "<Plug>(vsnip-jump-next)"      : "<Tab>"]])
      vim.cmd([[smap <expr> <Tab>   vsnip#jumpable(1)   ? "<Plug>(vsnip-jump-next)"      : "<Tab>"]])
      vim.cmd([[imap <expr> <S-Tab> vsnip#jumpable(-1)  ? "<Plug>(vsnip-jump-prev)"      : "<S-Tab>"]])
      vim.cmd([[smap <expr> <S-Tab> vsnip#jumpable(-1)  ? "<Plug>(vsnip-jump-prev)"      : "<S-Tab>"]])
    end,
    requires = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-cmdline" },
      { "hrsh7th/cmp-vsnip" },
      { "hrsh7th/vim-vsnip" },
      { "hrsh7th/vim-vsnip-integ" },
    },
  })

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
    config = function()
      local lspconfig = require("lspconfig")
      local on_attach = function(_, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

        -- Mappings.
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
        vim.keymap.set("n", "gs", vim.lsp.buf.document_symbol, bufopts)
        vim.keymap.set("n", "gS", vim.lsp.buf.workspace_symbol, bufopts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set("n", "<Space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
        vim.keymap.set("n", "<Space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
        vim.keymap.set("n", "<Space>wl", function()
          print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)
        vim.keymap.set("n", "<Space>D", vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set("n", "<Space>rn", function()
          return ":IncRename " .. vim.fn.expand("<cword>")
        end, { expr = true })
        vim.keymap.set("n", "<Space>ca", vim.lsp.buf.code_action, bufopts)
        vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
        vim.keymap.set("n", "<Space>f", function()
          vim.lsp.buf.format({ async = true })
        end, bufopts)
      end
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Language servers
      lspconfig["gopls"].setup({ on_attach = on_attach, capabilities = capabilities })
      lspconfig["pyright"].setup({ on_attach = on_attach, capabilities = capabilities })
      lspconfig["tsserver"].setup({ on_attach = on_attach, capabilities = capabilities })
      lspconfig["terraformls"].setup({ on_attach = on_attach, capabilities = capabilities })
      lspconfig["rust_analyzer"].setup({ on_attach = on_attach, capabilities = capabilities })
      lspconfig["sqls"].setup({
        on_attach = function(client, bufnr)
          require("sqls").on_attach(client, bufnr)
        end,
        capabilities = capabilities,
      })
      lspconfig["sumneko_lua"].setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim", "require" },
            },
          },
        },
      })
    end,
    requires = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "nanotee/sqls.nvim" },
    },
  })

  use({
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "gopls",
          "jdtls",
          "pyright",
          "rust_analyzer",
          "sqls",
          "sumneko_lua",
          "tsserver",
          "terraformls",
        },
      })
    end,
    requires = {
      { "williamboman/mason.nvim" },
    },
  })

  use({
    "jayp0521/mason-null-ls.nvim",
    config = function()
      require("mason-null-ls").setup({
        ensure_installed = {
          "black",
          "debugpy",
          "dlv",
          "eslint_d",
          "flake8",
          "goimports",
          "isort",
          "mypy",
          "prettier",
          "staticcheck",
          "stylua",
        },
      })
    end,
    requires = {
      { "williamboman/mason.nvim" },
      { "jose-elias-alvarez/null-ls.nvim" },
      { "jayp0521/mason-null-ls.nvim" },
    },
  })

  use({
    "jose-elias-alvarez/null-ls.nvim",
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
          null_ls.builtins.diagnostics.staticcheck,
          null_ls.builtins.diagnostics.flake8,
          null_ls.builtins.diagnostics.mypy,
          null_ls.builtins.diagnostics.eslint_d,
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

  -- }}}

  -- DAP: {{{

  use({
    "rcarriga/nvim-dap-ui",
    config = function()
      require("dapui").setup()
      require("dap-go").setup()
      require("dap-python").setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")

      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        -- dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        -- dapui.close()
      end

      vim.keymap.set("n", "<F5>", dap.continue, {})
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
      vim.keymap.set("n", "<Leader>d", dapui.toggle, {})
    end,
    requires = {
      { "mfussenegger/nvim-dap" },
      { "mfussenegger/nvim-dap-python" },
      { "mfussenegger/nvim-jdtls" },
      { "microsoft/java-debug" },
      { "microsoft/vscode-java-test" },
      { "theHamsta/nvim-dap-virtual-text" },
      { "leoluz/nvim-dap-go" },
    },
  })

  use({ "vim-test/vim-test" })

  -- }}}

  -- Finder: {{{

  use({
    "nvim-telescope/telescope.nvim",
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
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })
      telescope.load_extension("frecency")
      telescope.load_extension("ui-select")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<C-p>", builtin.find_files, opts)
      vim.keymap.set("n", "<Leader>ff", builtin.find_files, opts)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, opts)
      vim.keymap.set("n", "<leader>fb", builtin.buffers, opts)
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, opts)
      vim.keymap.set("n", "<leader>fr", telescope.extensions.frecency.frecency, opts)
    end,
    requires = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope-ui-select.nvim" },
      { "nvim-telescope/telescope-frecency.nvim" },
      { "tami5/sqlite.lua" },
    },
  })

  use({
    "nvim-tree/nvim-tree.lua",
    setup = function()
      vim.keymap.set("n", "<C-n>", "<Cmd>NvimTreeToggle<CR>", {})
      vim.keymap.set("n", "<Leader>r", "<Cmd>NvimTreeRefresh<CR>", {})
      vim.keymap.set("n", "<Leader>n", "<Cmd>NvimTreeFindFile<CR>", {})
      vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#2f363d" })
    end,
    config = function()
      require("nvim-tree").setup({
        view = { hide_root_folder = true },
        renderer = { group_empty = true },
        filters = { dotfiles = true },
      })
    end,
    requires = {
      { "nvim-tree/nvim-web-devicons" },
    },
  })

  use({
    "phaazon/hop.nvim",
    branch = "v2",
    config = function()
      require("hop").setup()

      local hop = require("hop")
      local directions = require("hop.hint").HintDirection
      vim.keymap.set("", "<Leader><Leader>w", function()
        hop.hint_words()
      end, {})
      vim.keymap.set("", "<Leader><Leader>f", function()
        hop.hint_char1({ direction = directions.AFTER_CURSOR })
      end, {})
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
      vim.keymap.set("n", "<Leader>g", function()
        require("toggleterm.terminal").Terminal
            :new({
              cmd = "lazygit",
              direction = "float",
              hidden = true,
              count = 0,
            })
            :toggle()
      end)

      vim.cmd([[autocmd TermOpen * startinsert]])
      vim.cmd([[autocmd TermOpen * setlocal nonumber norelativenumber]])
    end,
  })

  -- }}}

  -- Theme: {{{

  use({
    "projekt0n/github-nvim-theme",
    config = function()
      require("github-theme").setup({
        theme_style = "dark_default",
        function_style = "italic",
        sidebars = { "qf", "vista_kind", "terminal", "packer" },
        transparent = true,
      })
      vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#2f363d" })
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
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = false, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = true, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
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
    "folke/trouble.nvim",
    config = function()
      require("trouble").setup()

      local signs = {
        Error = " ",
        Warn = " ",
        Hint = " ",
        Info = " ",
      }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      vim.keymap.set("n", "<leader>xx", "<Cmd>TroubleToggle<CR>", {})
      vim.keymap.set("n", "<leader>xw", "<Cmd>TroubleToggle workspace_diagnostics<CR>", {})
      vim.keymap.set("n", "<leader>xd", "<Cmd>TroubleToggle document_diagnostics<CR>", {})
      vim.keymap.set("n", "<leader>xl", "<Cmd>TroubleToggle loclist<CR>", {})
      vim.keymap.set("n", "<leader>xq", "<Cmd>TroubleToggle quickfix<CR>", {})
      vim.keymap.set("n", "gR", "<Cmd>TroubleToggle lsp_references<CR>", {})
    end,
    requires = {
      { "kyazdani42/nvim-web-devicons" },
      { "folke/lsp-colors.nvim" },
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
    config = function()
      require("colorizer").setup()
    end,
  })

  use({
    "lukas-reineke/virt-column.nvim",
    config = function()
      require("virt-column").setup({
        char = "▕",
      })

      vim.api.nvim_set_hl(0, "VirtColumn", { fg = "#2f363d", bg = nil })
    end,
    after = "editorconfig-vim",
  })

  use({ "airblade/vim-gitgutter" })

  --- }}}

  -- Plugins end: {{{
  if packer_bootstrap then
    require("packer").sync()
  end
end)

-- }}}
