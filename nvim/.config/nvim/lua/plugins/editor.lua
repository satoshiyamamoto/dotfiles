return {
  -- Editor utilities
  { "tpope/vim-fugitive", event = { "BufReadPost" } },

  {
    "olrtg/nvim-emmet",
    keys = {
      {
        "<leader>xe",
        function() require("nvim-emmet"):wrap_with_abbreviation() end,
        mode = { "n", "v" },
        desc = "Wrap with Emmet Abbreviation",
      },
    },
  },

  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
  },

  -- Markdown
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      completions = { lsp = { enabled = true } },
      heading = { enabled = false },
      bullet = { enabled = false },
      checkbox = { enabled = false },
      code = { sign = false, disable = { "mermaid" } },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      vim.api.nvim_set_hl(0, "RenderMarkdownCode", { link = "CursorLine" })
      vim.api.nvim_set_hl(0, "RenderMarkdownCodeBorder", { link = "CursorLine" })
      vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { link = "Visual" })
      vim.api.nvim_set_hl(0, "RenderMarkdownDash", { link = "Normal" })
      vim.api.nvim_set_hl(0, "RenderMarkdownTableHead", { link = "Normal" })
      vim.api.nvim_set_hl(0, "RenderMarkdownTableRow", { link = "Normal" })
      vim.api.nvim_set_hl(0, "markdownUrl", { link = "Comment" })
      vim.api.nvim_set_hl(0, "markdownLink", { link = "Comment" })
    end,
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
