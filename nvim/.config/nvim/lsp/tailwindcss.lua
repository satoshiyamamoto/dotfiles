---@type vim.lsp.Config
return {
  -- Allow event loop to process graceful shutdown sequence on VimLeavePre,
  -- then force-stop if not completed within the timeout.
  exit_timeout = 500,
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
