return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = { enabled = false },
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
  },

  -- HTTP
  {
    -- Runs the `httpyac` CLI from nixpkgs; its commands exist only in http buffers
    "abidibo/nvim-httpyac",
    ft = "http",
    keys = {
      { "<Leader>rr", "<Cmd>NvimHttpYac<CR>", ft = "http", desc = "Run request under cursor" },
      { "<Leader>ra", "<Cmd>NvimHttpYacAll<CR>", ft = "http", desc = "Run all requests" },
      { "<Leader>rp", "<Cmd>NvimHttpYacPicker<CR>", ft = "http", desc = "Pick a named request" },
      { "<Leader>re", "<Cmd>NvimHttpYacEnv<CR>", ft = "http", desc = "Select environment" },
      { "<Leader>rc", "<Cmd>NvimHttpYacEnvClear<CR>", ft = "http", desc = "Clear environment" },
      { "<Leader>rq", "<Cmd>NvimHttpYacSequence<CR>", ft = "http", desc = "Toggle sequence recording" },
      { "<Leader>rs", "<Cmd>NvimHttpYacSequencePicker<CR>", ft = "http", desc = "Sequence picker" },
      { "<Leader>ry", "<Cmd>NvimHttpYacCopyCmd<CR>", ft = "http", desc = "Copy httpyac command to clipboard" },
    },
    opts = {},
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.keymap.set("n", "]c", "<Cmd>Gitsigns next_hunk<CR>", {})
      vim.keymap.set("n", "[c", "<Cmd>Gitsigns prev_hunk<CR>", {})
    end,
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 0,
        virt_text_pos = "eol",
      },
      current_line_blame_formatter = " <author>, <author_time:%R> - <summary>",
    },
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
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      filetypes = {
        css = { css = true, tailwind = true },
        html = { css = true, tailwind = true },
        javascript = {},
        javascriptreact = { tailwind = true },
        scss = { css = true, tailwind = true },
        typescript = {},
        typescriptreact = { tailwind = true },
      },
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
