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
    "nvim-mini/mini.surround",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      mappings = {
        add = "sa",
        delete = "sd",
        find = "sf",
        find_left = "sF",
        highlight = "sh",
        replace = "sr",
        update_n_lines = "sn",
      },
    },
  },

  {
    "nvim-mini/mini.ai",
    event = { "BufReadPost", "BufNewFile" },
    opts = { n_lines = 500 },
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
