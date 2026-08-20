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
    "mistweaverco/kulala.nvim",
    ft = { "http", "rest" },
    -- Load before session save/restore hooks run
    event = { "SessionLoadPost", "VimLeavePre" },
    keys = {
      -- Lazy-load stubs for the keymaps kulala registers globally;
      -- the rest are only mapped inside http/rest buffers.
      { "<Leader>Rs", desc = "Send Request" },
      { "<Leader>Ra", desc = "Send All Requests" },
      { "<Leader>Rr", desc = "Replay Last Request" },
      { "<Leader>Ro", desc = "Open Kulala" },
      { "<Leader>Rb", desc = "Open Scratchpad" },
    },
    opts = {
      global_keymaps = true,
      global_keymaps_prefix = "<Leader>R",
      lsp = {
        filetypes = { "http", "rest" },
      },
      ui = {
        -- Show the body in the result panel instead of a path to the temp file
        max_response_size = 10 * 1024 * 1024,
      },
    },
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
