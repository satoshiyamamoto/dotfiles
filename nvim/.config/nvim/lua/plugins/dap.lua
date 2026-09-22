return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      {
        "<F5>",
        function() require("dap").continue() end,
        desc = "Continue (Debug)",
      },
      {
        "<F9>",
        function() require("dap").toggle_breakpoint() end,
        desc = "Toggle Breakpoint (Debug)",
      },
      {
        "<F17>",
        function() require("dap").terminate() end,
        desc = "Terminate (Debug)",
      },
      {
        "<F10>",
        function() require("dap").step_over() end,
        desc = "Step Over (Debug)",
      },
      {
        "<F11>",
        function() require("dap").step_into() end,
        desc = "Step Into (Debug)",
      },
      {
        "<F23>",
        function() require("dap").step_out() end,
        desc = "Step Out (Debug)",
      },
      {
        "<Leader>dc",
        function() require("dap").continue() end,
        desc = "Continue (Debug)",
      },
      {
        "<Leader>dt",
        function() require("dap").terminate() end,
        desc = "Terminate (Debug)",
      },
      {
        "<Leader>di",
        function() require("dap").step_into() end,
        desc = "Step Into (Debug)",
      },
      {
        "<Leader>do",
        function() require("dap").step_out() end,
        desc = "Step Out (Debug)",
      },
      {
        "<Leader>dO",
        function() require("dap").step_over() end,
        desc = "Step Over (Debug)",
      },
      {
        "<Leader>dr",
        function() require("dap.repl").toggle() end,
        desc = "Toggle REPL (Debug)",
      },
      {
        "<Leader>db",
        function() require("dap").toggle_breakpoint() end,
        desc = "Toggle Breakpoint (Debug)",
      },
      {
        "<Leader>dB",
        function() require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: ")) end,
        desc = "Breakpoint Condition (Debug)",
      },
      {
        "<Leader>lp",
        function() require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end,
        desc = "Breakpoint Log point message (Debug)",
      },
    },
    config = function()
      local dap = require("dap")
      require("dap.ext.vscode").json_decode = require("json5").parse
      require("dap-go").setup()
      require("dap-python").setup("uv")

      -- Adapters
      local js_adapter = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "js-debug-adapter",
          args = { "${port}" },
        },
      }
      local function js_alias(target_type)
        return function(cb, config)
          config.type = target_type
          cb(js_adapter)
        end
      end
      dap.adapters["node"] = js_alias("pwa-node")
      dap.adapters["chrome"] = js_alias("pwa-chrome")
      dap.adapters["pwa-node"] = js_adapter
      dap.adapters["pwa-chrome"] = js_adapter

      -- Configurations
      local js_configs = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch",
          program = "${file}",
          cwd = "${workspaceFolder}",
          skipFiles = { "<node_internals>/**" },
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach Process",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
          skipFiles = { "<node_internals>/**" },
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach Remote",
          port = function() return tonumber(vim.fn.input("Port: ", "9229")) end,
          cwd = "${workspaceFolder}",
          skipFiles = { "<node_internals>/**" },
        },
        {
          type = "pwa-chrome",
          request = "launch",
          name = "Launch Chrome",
          url = function() return vim.fn.input("URL: ", "http://localhost:3000") end,
        },
      }
      for _, lang in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        dap.configurations[lang] = js_configs
      end
      local java_configs = {
        {
          type = "java",
          request = "attach",
          name = "Attach",
          hostName = "127.0.0.1",
          port = 5005,
        },
      }
      dap.configurations.java = vim.list_extend(dap.configurations.java or {}, java_configs)

      -- UIs
      vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapBreakpointCondition", { text = " ", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapBreakpointRejected", { text = " ", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapLogPoint", { text = " ", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapStopped", { text = " ", texthl = "WarningMsg" })
    end,
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "leoluz/nvim-dap-go",
      "nvim-neotest/nvim-nio",
      { "Joakker/lua-json5", build = "./install.sh" },
    },
  },

  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
  },

  {
    "igorlfs/nvim-dap-view",
    event = "VeryLazy",
    keys = {
      { "<Leader>dv", function() require("dap-view").toggle() end, desc = "Toggle Debugger View (Debug)" },
      {
        "<Leader>dh",
        function() require("dap-view").hover() end,
        mode = { "n", "v" },
        desc = "Hover Variable (Debug)",
      },
      {
        "<Leader>dV",
        function() require("dap-view").virtual_text_toggle() end,
        desc = "Toggle Virtual Text (Debug)",
      },
    },
    opts = {
      virtual_text = {
        enabled = true,
      },
      winbar = {
        sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
        default_section = "console",
        controls = {
          enabled = true,
        },
      },
      windows = {
        terminal = {
          hide = true,
        },
      },
      auto_toggle = true,
    },
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    opts = {
      automatic_installation = true,
      ensure_installed = {
        "codelldb",
        "debugpy",
        "delve",
        "javadbg",
        "javatest",
        "js",
      },
    },
    dependencies = {
      "mason-org/mason.nvim",
      "mfussenegger/nvim-dap",
    },
  },

  {
    "nvim-neotest/neotest",
    keys = {
      { "<Leader>tt", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test File" },
      { "<Leader>tr", function() require("neotest").run.run() end, desc = "Test Nearest" },
      { "<Leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Test Nearest (Debug)" },
      {
        "<Leader>tD",
        function() require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" }) end,
        desc = "Test File (Debug)",
      },
      { "<Leader>tl", function() require("neotest").run.run_last() end, desc = "Test Last" },
      { "<Leader>ts", function() require("neotest").summary.toggle() end, desc = "Test Summary" },
      { "<Leader>to", function() require("neotest").output.open() end, desc = "Test Output" },
      { "<Leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Test Output Panel" },
      { "<Leader>tS", function() require("neotest").run.stop() end, desc = "Test Stop" },
    },
    config = function()
      -- Go: outside a Go tree, neotest-golang's root falls back to a repo-wide
      -- recursive go.mod scan that returns nil without caching anything. Guard it
      -- with a cheap upward lookup; a repo whose only go.mod sits below cwd is no
      -- longer detected.
      local golang = require("neotest-golang")
      local golang_root = golang.root
      local has_go_mod = require("neotest.lib").files.match_root_pattern("go.work", "go.mod")
      golang.root = function(dir) return has_go_mod(dir) and golang_root(dir) or nil end

      -- Java: neotest-java rebuilds its module list on every run by walking the
      -- whole project root, and its dir_scan has no exclusion mechanism of its own.
      -- Swapping an internal API; drop it once the adapter takes an exclusion
      -- option of its own.
      local function iter_java_entries(dir)
        local entries = vim.fs.dir(dir:to_string())
        return function()
          for name, typ in entries do
            if name ~= "node_modules" and name ~= ".git" then
              return { path = dir:append(name), typ = typ }
            end
          end
        end
      end
      local java_scan = require("neotest-java.util.dir_scan")
      package.loaded["neotest-java.util.dir_scan"] = function(dir, opts)
        return java_scan(dir, opts, { iter_dir = iter_java_entries })
      end

      -- neotest-java's root finder falls back to the .git root alone, so it claims
      -- every git repository and registers an adapter that discovers nothing but
      -- still walks the whole tree. Require a build file, as its own higher
      -- priorities already do.
      local java = require("neotest-java")({
        -- Deep reflection in the tests needs java.lang opened to the unnamed module.
        jvm_args = { "--add-opens=java.base/java.lang=ALL-UNNAMED" },
      })
      local java_root = java.root
      local has_build_file = require("neotest.lib").files.match_root_pattern(
        "pom.xml",
        "settings.gradle",
        "settings.gradle.kts",
        "build.gradle",
        "build.gradle.kts",
        "mvnw",
        "gradlew"
      )
      java.root = function(dir) return has_build_file(dir) and java_root(dir) or nil end

      require("neotest").setup({
        adapters = {
          golang,
          java,
          require("neotest-mocha"),
          require("neotest-python"),
          require("rustaceanvim.neotest"),
          require("neotest-vitest"),
        },
        discovery = {
          -- neotest-java roots at the monorepo and has no node_modules exclusion
          -- of its own. neotest ANDs this with each adapter's own filter_dir.
          filter_dir = function(name) return name ~= "node_modules" end,
        },
      })
    end,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-neotest/neotest-python",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "fredrikaverpil/neotest-golang",
      "rcasia/neotest-java",
      "marilari88/neotest-vitest",
      "adrigzr/neotest-mocha",
    },
  },

  {
    "linux-cultist/venv-selector.nvim",
    keys = {
      { ",v", "<Cmd>VenvSelect<CR>", desc = "Open VenvSelector to pick a venv" },
    },
    ft = "python",
    opts = {},
    dependencies = {
      "mfussenegger/nvim-dap-python",
    },
  },

  {
    "stevearc/overseer.nvim",
    cmd = {
      "OverseerOpen",
      "OverseerClose",
      "OverseerToggle",
      "OverseerRun",
      "OverseerShell",
      "OverseerTaskAction",
    },
    keys = {
      { "<Leader>or", "<Cmd>OverseerRun<CR>", desc = "Run Task" },
      { "<Leader>ot", "<Cmd>OverseerToggle<CR>", desc = "Toggle Task List" },
      { "<Leader>oo", "<Cmd>OverseerOpen<CR>", desc = "Open Task List" },
      { "<Leader>oc", "<Cmd>OverseerClose<CR>", desc = "Close Task List" },
      { "<Leader>oa", "<Cmd>OverseerTaskAction<CR>", desc = "Task Action (stop/restart/dispose)" },
      { "<Leader>os", "<Cmd>OverseerShell<CR>", desc = "Run Shell Command" },
    },
    opts = {
      dap = true,
      task_list = {
        direction = "bottom",
        bindings = {
          ["<C-h>"] = false,
          ["<C-j>"] = false,
          ["<C-k>"] = false,
          ["<C-l>"] = false,
        },
      },
    },
  },
}
