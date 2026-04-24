return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- vim.lsp.enable() is called automatically by mason-lspconfig
      -- via `automatic_enable = true` (default) for each installed server.
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
