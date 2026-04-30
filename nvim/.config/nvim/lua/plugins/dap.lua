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
      {
        "<Leader>du",
        function() require("dapui").toggle() end,
        desc = "Toggle Debugger UI (Debug)",
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      require("dapui").setup()
      require("nvim-dap-virtual-text").setup()
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
          port = 9229,
          cwd = "${workspaceFolder}",
          skipFiles = { "<node_internals>/**" },
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach Remote (Next.js)",
          port = 9230,
          cwd = "${workspaceFolder}",
          skipFiles = { "<node_internals>/**" },
        },
        {
          type = "pwa-chrome",
          request = "launch",
          name = "Launch Chrome",
          url = "http://localhost:3000",
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

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

      vim.fn.sign_define("DapBreakpoint", { text = " ", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapBreakpointCondition", { text = " ", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapBreakpointRejected", { text = " ", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapLogPoint", { text = " ", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapStopped", { text = " ", texthl = "WarningMsg" })
    end,
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "mfussenegger/nvim-jdtls",
      "leoluz/nvim-dap-go",
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
    },
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    opts = {
      automatic_installation = true,
      ensure_installed = {
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
      { "<Leader>tl", function() require("neotest").run.run_last() end, desc = "Test Last" },
      { "<Leader>ts", function() require("neotest").summary.toggle() end, desc = "Test Summary" },
      { "<Leader>to", function() require("neotest").output.open() end, desc = "Test Output" },
      { "<Leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Test Output Panel" },
      { "<Leader>tS", function() require("neotest").run.stop() end, desc = "Test Stop" },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-golang"),
          require("neotest-python"),
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
}
