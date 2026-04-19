return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
  },

  -- HTTP
  {
    "rest-nvim/rest.nvim",
    ft = "http",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    keys = {
      { "<Leader>rr", "<cmd>Rest run<cr>", desc = "Run HTTP Request" },
      { "<Leader>rl", "<cmd>Rest last<cr>", desc = "Re-run Last HTTP Request" },
      { "<Leader>re", "<cmd>Rest env select<cr>", desc = "Select REST Environment" },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.keymap.set("n", "]c", "<Cmd>Gitsigns next_hunk<CR>", {})
      vim.keymap.set("n", "[c", "<Cmd>Gitsigns prev_hunk<CR>", {})
    end,
    config = function() require("gitsigns").setup() end,
  },

  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    main = "rainbow-delimiters.setup",
    opts = {
      strategy = {
        [""] = "rainbow-delimiters.strategy.global",
        vim = "rainbow-delimiters.strategy.local",
      },
      query = {
        [""] = "rainbow-delimiters",
        lua = "rainbow-blocks",
      },
      priority = {
        [""] = 110,
        lua = 210,
      },
      highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
      },
    },
  },

  {
    "catgoose/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("colorizer").setup({
        filetypes = {
          "*",
          "!help",
          "!lazy",
          "!noice",
          "!trouble",
          "!snacks_dashboard",
          "!snacks_notif",
          "!snacks_notif_history",
          "!snacks_picker_input",
          "!snacks_picker_list",
          "!snacks_picker_preview",
          css = { css = true, tailwind = true },
          html = { css = true, tailwind = true },
          javascriptreact = { tailwind = true },
          typescriptreact = { tailwind = true },
        },
      })
    end,
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
    "iloginow/vim-stylus",
    event = { "BufReadPost", "BufNewFile" },
  },

  -- Miscellaneous
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

}
