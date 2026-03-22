return {
  -- Snacks
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      {
        "<Leader>gg",
        function()
          Snacks.lazygit()
        end,
        desc = "Lazygit",
      },
      {
        "<c-/>",
        function()
          Snacks.terminal()
        end,
        desc = "Toggle Terminal",
        mode = { "n", "t" },
      },
      {
        "<c-_>",
        function()
          Snacks.terminal()
        end,
        desc = "which_key_ignore",
        mode = { "n", "t" },
      },
    },
    opts = {
      notifier = { enabled = true },
      terminal = { enabled = true },
      lazygit = { enabled = true },
      indent = { enabled = true },
      dashboard = { enabled = true },
    },
  },

  -- Finder
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
    keys = {
      {
        "S",
        function()
          require("hop").hint_words()
        end,
        desc = "Hop to Word",
      },
    },
    config = function()
      require("hop").setup()
    end,
  },

  -- Notifications / UI enhancements
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
        expr = true,
        desc = "Lsp Hover Doc Scroll Backward",
        mode = { "i", "n", "s" },
      },
    },
    opts = {
      lsp = {
        signature = { enabled = false },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["vim.ui.select"] = false,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = false,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "written" },
              { find = " lines --%" },
              { find = " bytes --%" },
              { find = "^$" }, -- Empty messages
            },
          },
          opts = { skip = true },
        },
        -- FIXME: Cannot get stdout while running !commands
        -- https://github.com/folke/noice.nvim/issues/1097
        {
          filter = { event = "msg_show" },
          view = "notify",
          opts = {
            level = "info",
            skip = false,
            replace = false,
          },
        },
      },
      views = {
        cmdline_popup = {
          position = {
            row = 5,
            col = "50%",
          },
          size = {
            width = 60,
            height = "auto",
          },
        },
        popupmenu = {
          relative = "editor",
          position = {
            row = 8,
            col = "50%",
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = "rounded",
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
          },
        },
      },
    },
    dependencies = {
      { "MunifTanjim/nui.nvim" },
    },
  },

  {
    "folke/trouble.nvim",
    event = { "VeryLazy" },
    keys = {
      { "<Leader>xx", "<Cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
      {
        "<Leader>xX",
        "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>",
        desc = "Buffer Diagnostics (Trouble)",
      },
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
        Error = "",
        Warn = "",
        Hint = "",
        Info = "",
      }
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = signs.Error,
            [vim.diagnostic.severity.WARN] = signs.Warn,
            [vim.diagnostic.severity.HINT] = signs.Hint,
            [vim.diagnostic.severity.INFO] = signs.Info,
          },
        },
      })
    end,
    dependencies = {
      { "nvim-tree/nvim-web-devicons" },
    },
  },

  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000,
    config = function()
      require("tiny-inline-diagnostic").setup()
      vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
    end,
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

  -- Themes
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
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
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
      { "folke/noice.nvim" },
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
}
