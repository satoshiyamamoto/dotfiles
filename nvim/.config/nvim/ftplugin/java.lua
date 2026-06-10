local root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew" })
if not root_dir then
  return
end

local function jar_path(package)
  return vim.fn.stdpath("data") .. "/mason/packages/" .. package .. "/extension/server/"
end

local function glob(pattern)
  return vim.fn.glob(pattern, true, true)
end

local bundles = glob(jar_path("java-debug-adapter") .. "com.microsoft.java.debug.plugin-*.jar")

local excluded_test_bundles = {
  ["com.microsoft.java.test.runner-jar-with-dependencies.jar"] = true,
  ["jacocoagent.jar"] = true,
}

for _, java_test_jar in ipairs(glob(jar_path("java-test") .. "*.jar")) do
  local fname = vim.fn.fnamemodify(java_test_jar, ":t")
  if not excluded_test_bundles[fname] then
    table.insert(bundles, java_test_jar)
  end
end

local function get_workspace_dir(root)
  local normalized_root = vim.fs.normalize(root)
  local project_name = vim.fs.basename(normalized_root)
  local root_hash = vim.fn.sha256(normalized_root):sub(1, 8)
  return vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. project_name .. "-" .. root_hash
end

local function is_lombok_agent_arg(arg)
  return arg:match("^-javaagent:") and arg:match("lombok%.jar")
end

local function get_jvm_args()
  local args = {}

  for arg in string.gmatch(os.getenv("JDTLS_JVM_ARGS") or "", "%S+") do
    if not is_lombok_agent_arg(arg) then
      table.insert(args, "--jvm-arg=" .. arg)
    end
  end

  local lombok_jar = vim.fn.stdpath("data") .. "/mason/packages/jdtls/lombok.jar"
  if vim.fn.filereadable(lombok_jar) == 1 then
    table.insert(args, "--jvm-arg=-javaagent:" .. lombok_jar)
  end

  return args
end

local cmd = {
  "jdtls",
  "-data",
  get_workspace_dir(root_dir),
}
vim.list_extend(cmd, get_jvm_args())

local capabilities
local has_blink, blink = pcall(require, "blink.cmp")
if has_blink then
  capabilities = blink.get_lsp_capabilities()
end

local config = {
  name = "jdtls",
  cmd = cmd,
  root_dir = root_dir,
  capabilities = capabilities,
  settings = {
    java = {
      signatureHelp = { enabled = true },
      test = { config_overrides = { vmArgs = "--add-opens=java.base/java.lang=ALL-UNNAMED" } },
    },
  },
  init_options = {
    bundles = bundles,
  },
  on_attach = function(_, bufnr)
    local jdtls = require("jdtls")
    vim.keymap.set("n", "<leader>tt", jdtls.test_class, { buffer = bufnr, desc = "Test Class (Debug)" })
    vim.keymap.set("n", "<leader>tr", jdtls.test_nearest_method, { buffer = bufnr, desc = "Test Method (Debug)" })
  end,
}

require("jdtls").start_or_attach(config, {
  dap = {
    hotcodereplace = "auto",
    config_overrides = {
      vmArgs = "--add-opens=java.base/java.lang=ALL-UNNAMED",
    },
  },
})
