return {
  { "neovim/nvim-lspconfig" },

  { "mason-org/mason.nvim", opts = {} },

  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Global configuration for all LSP servers
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
        on_attach = function(_, bufnr)
          vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"

          local opts = function(desc)
            return { buffer = bufnr, desc = desc }
          end
          -- Go to
          vim.keymap.set("n", "gd", function()
            Snacks.picker.lsp_definitions()
          end, opts("Go to Definition"))
          vim.keymap.set("n", "gD", function()
            Snacks.picker.lsp_declarations()
          end, opts("Go to Declaration"))
          vim.keymap.set("n", "gI", function()
            Snacks.picker.lsp_implementations()
          end, opts("Go to Implementation"))
          vim.keymap.set("n", "gy", function()
            Snacks.picker.lsp_type_definitions()
          end, opts("Go to Type Definition"))
          vim.keymap.set("n", "gr", function()
            Snacks.picker.lsp_references()
          end, opts("Find References"))
          -- Actions
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts("Hover Documentation"))
          vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, opts("Signature Help"))
          vim.keymap.set({ "n", "v" }, "<Leader>ca", vim.lsp.buf.code_action, opts("Code Action"))
          vim.keymap.set("n", "<Leader>cr", vim.lsp.buf.rename, opts("Rename Symbol"))
          -- Calls
          vim.keymap.set("n", "gai", function()
            Snacks.picker.lsp_incoming_calls()
          end, opts("Incoming Calls"))
          vim.keymap.set("n", "gao", function()
            Snacks.picker.lsp_outgoing_calls()
          end, opts("Outgoing Calls"))
        end,
      })

      -- Enable LSP servers
      vim.lsp.enable("cssls")
      vim.lsp.enable("emmet_language_server")
      vim.lsp.enable("eslint")
      vim.lsp.enable("gopls")
      vim.lsp.enable("html")
      vim.lsp.enable("lua_ls")
      vim.lsp.enable("pyright")
      vim.lsp.enable("ruff")
      vim.lsp.enable("rust_analyzer")
      vim.lsp.enable("tailwindcss")
      vim.lsp.enable("terraformls")
      vim.lsp.enable("ts_ls")

      require("mason-lspconfig").setup({
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
      })
    end,
    dependencies = {
      { "saghen/blink.cmp" },
    },
  },
}
