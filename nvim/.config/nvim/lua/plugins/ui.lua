local sidekick_cli_sessions = {}
local ui_status = { msg_showcmd = "", msg_showmode = "" }

local function sidekick_cli_status()
  local count = vim.tbl_count(sidekick_cli_sessions)
  if count == 0 then
    return ""
  end
  return "󱙺 " .. (count > 1 and count or "")
end

local function refresh_lualine_status()
  if package.loaded.lualine then
    require("lualine").refresh({ place = { "statusline" }, force = true })
    vim.api.nvim__redraw({ statusline = true, flush = true })
  end
end

return {
  -- Snacks
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    init = function()
      -- Herdr supports Kitty placeholders but is not recognized by Snacks.
      if vim.env.TERM_PROGRAM == "herdr" then
        vim.env.SNACKS_GHOSTTY = vim.env.SNACKS_GHOSTTY or "true"
      end
    end,
    opts = {
      dashboard = {},
      explorer = {},
      image = {},
      indent = {},
      notifier = {},
      picker = {
        sources = {
          explorer = {
            layout = {
              layout = {
                position = "right",
                width = 30,
              },
            },
          },
        },
      },
      statuscolumn = {},
    },
    keys = {
      -- Top Pickers & Explorer
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete buffer (keep layout)" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
      -- Productivity Tools
      { "<Leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
      { "<c-/>", function() Snacks.terminal() end, desc = "Toggle Terminal", mode = { "n", "t" } },
      { "<c-_>", function() Snacks.terminal() end, desc = "Toggle Terminal", mode = { "n", "t" } },
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
    "folke/trouble.nvim",
    event = { "VeryLazy" },
    keys = {
      { "<Leader>xx", "<Cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (Trouble)" },
      { "<Leader>xX", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Buffer Diagnostics (Trouble)" },
      { "<Leader>cs", "<Cmd>Trouble symbols toggle<CR>", desc = "Symbols (Trouble)" },
      {
        "<Leader>cl",
        "<Cmd>Trouble lsp toggle focus=false win.position=right<CR>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
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
        Error = " ",
        Warn = " ",
        Hint = " ",
        Info = " ",
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
    opts = {
      win = { row = -1 }, -- Keep the global statusline visible with cmdheight=0.
      spec = {
        { "<leader>o", group = "overseer" },
        { "<leader>R", group = "kulala" },
      },
    },
    keys = {
      {
        "<leader>?",
        function() require("which-key").show({ global = false }) end,
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
      })
      vim.cmd("colorscheme tokyonight")
      vim.api.nvim_set_hl(0, "VertSplit", { fg = "#000000" })
      vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#000000" })
      vim.api.nvim_set_hl(0, "@property.json", { fg = "#7aa2f7" })
      vim.api.nvim_set_hl(0, "@property.yaml", { fg = "#f7768e" })
      vim.api.nvim_set_hl(0, "@property.gotmpl", { fg = "#f7768e" })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#737AA2" })
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = { "VeryLazy" },
    init = function()
      vim.api.nvim_create_autocmd("UIEnter", {
        once = true,
        callback = function()
          -- Mirror status text without taking over ui2's message rendering.
          vim.ui_attach(vim.api.nvim_create_namespace("dotfiles.lualine_status"), {
            ext_messages = true,
            set_cmdheight = false,
          }, function(event, content)
            if ui_status[event] == nil then
              return
            end
            ui_status[event] =
              table.concat(vim.tbl_map(function(chunk) return chunk[2] end, content)):gsub("%%", "%%%%")
            if vim.in_fast_event() then
              vim.schedule(refresh_lualine_status)
            else
              refresh_lualine_status()
            end
          end)
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        group = vim.api.nvim_create_augroup("dotfiles_sidekick_cli_lualine_status", { clear = true }),
        pattern = { "SidekickCliAttach", "SidekickCliDetach" },
        callback = function(event)
          local id = event.data and event.data.id
          if id then
            sidekick_cli_sessions[id] = event.match == "SidekickCliAttach" and true or nil
          end
          vim.schedule(refresh_lualine_status)
        end,
      })
    end,
    opts = function()
      return {
        options = {
          theme = "auto",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_x = {
            { function() return ui_status.msg_showcmd end, color = { fg = "#ff9e64" } },
            { function() return ui_status.msg_showmode end, color = { fg = "#ff9e64" } },
            {
              "searchcount",
              color = { fg = "#ff9e64" },
            },
            {
              sidekick_cli_status,
              color = function() return "Special" end,
            },
            {
              function() return vim.bo.filetype == "http" and vim.g.kulala_selected_env or "" end,
              icon = { "", color = { fg = "#428890" } },
            },
            "encoding",
            "fileformat",
            "filetype",
          },
          lualine_z = {
            "location",
            {
              "datetime",
              style = "%-I:%M %p",
            },
          },
        },
        inactive_sections = {
          lualine_x = {
            {
              sidekick_cli_status,
              color = function() return "Special" end,
            },
            "location",
          },
        },
      }
    end,
    dependencies = {
      { "folke/tokyonight.nvim" },
      { "projekt0n/github-nvim-theme" },
    },
  },

  { "Bekaboo/dropbar.nvim", event = { "BufReadPost", "BufNewFile" }, opts = {} },

  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = { "BufReadPost", "BufNewFile" },
    keys = function()
      local keys = {
        { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
        { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "Pick buffer" },
        { "<leader>0", "<cmd>BufferLineGoToBuffer -1<cr>", desc = "Go to last buffer" },
      }
      for i = 1, 9 do
        table.insert(
          keys,
          { "<leader>" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", desc = "Go to buffer " .. i }
        )
      end
      return keys
    end,
    opts = {
      options = {
        numbers = function(opts) return opts.raise(opts.ordinal) end,
        offsets = {
          {
            filetype = "sidekick_terminal",
            text = "󱙺  Agent Panel",
            separator = true,
          },
          {
            filetype = "snacks_layout_box",
            text = "󰙅  File Explorer",
            separator = true,
          },
        },
      },
    },
    config = true,
  },

  {
    "sphamba/smear-cursor.nvim",
    enabled = false,
    event = "VeryLazy",
    opts = {},
  },

  {
    "karb94/neoscroll.nvim",
    event = "VeryLazy",
    opts = {},
  },
}
