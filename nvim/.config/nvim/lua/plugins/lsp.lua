return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        exit_timeout = 1000,
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
        "tailwindcss",
        "terraformls",
        "ts_ls",
      },
      automatic_enable = {
        -- rust_analyzer is managed by rustaceanvim, not nvim-lspconfig.
        exclude = { "jdtls", "rust_analyzer" },
      },
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      { "neovim/nvim-lspconfig" },
    },
  },

  {
    "mrcjkb/rustaceanvim",
    version = "^9",
    lazy = false, -- rustaceanvim lazy-loads itself; do not lazy-load via lazy.nvim
    config = function()
      -- Configure via vim.g.rustaceanvim (do NOT call setup()).
      -- Function form defers require("blink.cmp") until rust-analyzer starts.
      vim.g.rustaceanvim = function()
        return {
          server = {
            capabilities = require("blink.cmp").get_lsp_capabilities(),
          },
        }
      end
    end,
  },
}
