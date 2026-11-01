return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        exit_timeout = 1000,
      })

      local open_floating_preview = vim.lsp.util.open_floating_preview
      vim.lsp.util.open_floating_preview = function(contents, syntax, opts)
        local buf, win = open_floating_preview(contents, syntax, opts)
        if opts and (opts.focus_id == "textDocument/hover" or opts.focus_id == "rust-analyzer-hover-actions") then
          -- Markdown's window namespace otherwise overrides the hover background.
          vim.api.nvim_win_set_hl_ns(win, -1)
          vim.wo[win].winhighlight = "Normal:LspHover,NormalNC:LspHover,FloatBorder:LspHoverBorder"
          vim.wo[win].winblend = 10
        end
        return buf, win
      end

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
