return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      vim.lsp.enable({
        -- Enable it using `automatic_enable` in `mason-lspconfig`
      })
    end,
    dependencies = {
      { "saghen/blink.cmp" },
    },
  },

  {
    "mason-org/mason-lspconfig.nvim",
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "cssls",
        "emmet_language_server",
        "eslint",
        "gopls",
        "html",
        "jdtls",
        "lua_ls",
        "pyright",
        "ruff",
        "rust_analyzer",
        "tailwindcss",
        "terraformls",
        "ts_ls",
      },
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      { "neovim/nvim-lspconfig" },
    },
  },
}
