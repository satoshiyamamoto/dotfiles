return {
  -- Snacks
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = { enabled = true },
      explorer = { enabled = true },
      image = {
        doc = { enabled = true },
        math = { enabled = true },
      },
      indent = { enabled = true },
      notifier = { enabled = true },
      picker = { enabled = true },
    },
    keys = {
      -- Top Pickers & Explorer
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
      -- Productivity Tools
      { "<Leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<c-/>", function() Snacks.terminal() end, desc = "Toggle Terminal", mode = { "n", "t" } },
    },
  },

  {
    "nvim-mini/mini.icons",
    lazy = true,
    opts = {},
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },

  -- Notifications / UI enhancements
  {
    "folke/noice.nvim",
    event = { "VeryLazy" },
    keys = {
      { "<Leader>nl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<Leader>nh", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<Leader>nd", function() require("noice").cmd("dismiss") end, desc = "Noice Dismiss" },
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
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = false,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
      routes = {
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
            },
          },
          view = "mini",
        },
        -- FIXME: Cannot get stdout while running !commands
        -- https://github.com/folke/noice.nvim/issues/1097
        {
          filter = {
            event = "msg_show",
            kind = {
              "shell_out",
              "shell_err",
            },
          },
          view = "mini",
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
      { "<Leader>xX", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer Diagnostics (Trouble)" },
      { "<Leader>cs", "<Cmd>Trouble symbols toggle<CR>", desc = "Symbols (Trouble)" },
      { "<Leader>cl", "<Cmd>Trouble lsp toggle focus=false win.position=right<CR>", desc = "LSP Definitions / references / ... (Trouble)" },
      { "<Leader>xL", "<Cmd>Trouble loclist toggle<CR>", desc = "Location List (Trouble)" },
      { "<Leader>xQ", "<Cmd>Trouble qflist toggle<CR>", desc = "Quickfix List (Trouble)" },
    },
    opts = {
      modes = {
        lsp = { win = { position = "right" } },
      },
    },
    config = function(_, opts)
      require("trouble").setup(opts)

      local signs = {
        Error = "",
        Warn = "",
        Hint = "",
        Info = "",
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
    dependencies = {
      { "junegunn/fzf" },
    },
  },

  {
    "stevearc/quicker.nvim",
    ft = "qf",
    keys = {
      { "<Leader>q", function() require("quicker").toggle() end, desc = "Toggle Quickfix" },
      { "<Leader>Q", function() require("quicker").toggle({ loclist = true }) end, desc = "Toggle Loclist" },
    },
    opts = {},
  },

  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = {
      { "-", "<Cmd>Oil<CR>", desc = "Open parent directory (Oil)" },
    },
    opts = {},
  },

  {
    "folke/which-key.nvim",
    event = { "VeryLazy" },
    opts = {},
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer Local Keymaps (which-key)" },
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
      vim.api.nvim_set_hl(0, "@property.gotmpl", { fg = "#f7768e" })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = { "VeryLazy" },
    opts = {
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
          {
            function()
              local env = vim.bo.filetype == "http" and vim.b._rest_nvim_env_file or ""
              return vim.fn.fnamemodify(env, ":t")
            end,
            icon = { "", color = { fg = "#428890" } },
          },
          "encoding",
          "fileformat",
          "filetype",
        },
      },
    },
    dependencies = {
      { "folke/noice.nvim" },
      { "folke/tokyonight.nvim" },
      { "projekt0n/github-nvim-theme" },
      { "rest-nvim/rest.nvim" },
    },
  },

  { "Bekaboo/dropbar.nvim", event = { "BufReadPost", "BufNewFile" }, opts = {} },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    config = true,
  },
}
