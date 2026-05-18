-- Suppress find_tailwind_global_css() by providing an explicit configFile.
-- Candidates: Next.js App Router, React Router v7, plain Vite.
local function find_tailwind_config_css()
  local root = vim.uv.cwd()
  for _, rel in ipairs({
    "app/globals.css", -- Next.js
    "app/app.css", -- React Router
    "src/index.css",
  }) do
    local path = root .. "/" .. rel
    if vim.uv.fs_stat(path) then
      return path
    end
  end
end

---@type vim.lsp.Config
return {
  filetypes = {
    "html",
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
      classFunctions = { "cn", "cva", "clsx", "tw", "twMerge", "tv" },
    },
  },
  before_init = function(_, config)
    config.settings = vim.tbl_deep_extend(
      "force",
      config.settings,
      { tailwindCSS = { experimental = { configFile = find_tailwind_config_css() } } }
    )
  end,
}
