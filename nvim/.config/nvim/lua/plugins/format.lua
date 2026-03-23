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
        go = { "goimports", "gofmt" },
        java = { "google-java-format" },
        javascript = { "prettierd", "biome", stop_after_first = true },
        javascriptreact = { "prettierd", "biome", stop_after_first = true },
        lua = { "stylua" },
        proto = { "buf" },
        python = { "ruff_format" },
        rust = { "rustfmt" },
        sql = { "sqlfluff" },
        typescript = { "prettierd", "biome", stop_after_first = true },
        typescriptreact = { "prettierd", "biome", stop_after_first = true },
        yaml = { "yamlfmt" },
      },
      formatters = {
        prettierd = {
          condition = function(_, ctx)
            if vim.fs.find({
              ".prettierrc",
              ".prettierrc.js",
              ".prettierrc.cjs",
              ".prettierrc.json",
              ".prettierrc.yaml",
              ".prettierrc.yml",
              "prettier.config.js",
              "prettier.config.cjs",
            }, { upward = true, path = ctx.dirname })[1] ~= nil then
              return true
            end
            local pkg = vim.fs.find("package.json", { upward = true, path = ctx.dirname })[1]
            if pkg then
              local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(pkg), "\n"))
              return ok and data.prettier ~= nil
            end
            return false
          end,
        },
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
