---@type vim.lsp.Config
return {
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = false,
      },
    },
  },
  settings = {
    tailwindCSS = {
      experimental = {
        -- Placeholder to prevent find_tailwind_global_css() from running.
        -- The actual value is resolved in before_init below.
        configFile = "",
      },
    },
  },
}
