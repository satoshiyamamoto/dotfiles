return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre", "BufNewFile" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<Leader>f",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        css = { "prettier", "biome", stop_after_first = true },
        go = { "goimports", "gofmt" },
        html = { "prettier" },
        java = { "google-java-format" },
        javascript = { "prettier", "biome", stop_after_first = true },
        javascriptreact = { "prettier", "biome", stop_after_first = true },
        json = { "prettier", "biome", stop_after_first = true },
        jsonc = { "prettier", "biome", stop_after_first = true },
        lua = { "stylua" },
        proto = { "buf" },
        python = { "ruff_format" },
        rust = { "rustfmt" },
        sql = { "sqlfluff" },
        typescript = { "prettier", "biome", stop_after_first = true },
        typescriptreact = { "prettier", "biome", stop_after_first = true },
        yaml = { "yamlfmt" },
      },
    },
    -- format_on_save = {
    --   timeout_ms = 500,
    --   lsp_fallback = true,
    -- },
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("lint").linters_by_ft = {
        go = { "staticcheck" },
        sql = { "sqlfluff" },
      }

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        callback = function() require("lint").try_lint() end,
      })
    end,
  },
}
