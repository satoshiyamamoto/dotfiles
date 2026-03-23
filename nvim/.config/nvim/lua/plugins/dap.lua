return {
  {
    "mfussenegger/nvim-dap",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      require("mason-registry")
      require("dapui").setup()
      require("nvim-dap-virtual-text").setup()
      require("dap-go").setup()
      require("dap-python").setup(vim.fn.expand("$MASON/packages/debugpy/venv/bin/python"))
      dap.adapters["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "js-debug-adapter",
          args = { "${port}" },
        },
      }
      for _, language in ipairs({ "typescript", "javascript", "javascriptreact", "typescriptreact" }) do
        require("dap").configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
            resolveSourceMapLocations = { "${workspaceFolder}/**", "!**/node_modules/**" },
          },
        }
      end

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      vim.keymap.set("n", "<F5>", dap.continue, { desc = "Continue (Debug)" })
      vim.keymap.set("n", "<F17>", dap.terminate, { desc = "Terminate (Debug)" })
      vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step Over (Debug)" })
      vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step Into (Debug)" })
      vim.keymap.set("n", "<F23>", dap.step_out, { desc = "Step Out (Debug)" })
      vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint (Debug)" })
      vim.keymap.set("n", "<Leader>dB", function()
        dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end, { desc = "Breakpoint Condition (Debug)" })
      vim.keymap.set("n", "<Leader>lp", function()
        dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
      end, { desc = "Breakpoint Log point message (Debug)" })
      vim.keymap.set("n", "<Leader>du", dapui.toggle, { desc = "Toggle Debugger UI (Debug)" })
      vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapLogPoint", { text = "", texthl = "ErrorMsg" })
      vim.fn.sign_define("DapStopped", { text = "", texthl = "WarningMsg" })
    end,
    dependencies = {
      { "mfussenegger/nvim-dap-python" },
      { "mfussenegger/nvim-jdtls" },
      { "leoluz/nvim-dap-go" },
      { "nvim-neotest/nvim-nio" },
      { "rcarriga/nvim-dap-ui" },
      { "theHamsta/nvim-dap-virtual-text" },
    },
  },

  {
    "jay-babu/mason-nvim-dap.nvim",
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
  },

  {
    "nvim-neotest/neotest",
    keys = {
      {
        "<Leader>df",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Test File",
      },
      {
        "<Leader>dn",
        function()
          require("neotest").run.run()
        end,
        desc = "Test Nearest",
      },
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-golang"),
        },
      })
    end,
    dependencies = {
      { "nvim-neotest/nvim-nio" },
      { "nvim-lua/plenary.nvim" },
      { "nvim-treesitter/nvim-treesitter" },
      { "fredrikaverpil/neotest-golang" },
      { "rcasia/neotest-java" },
    },
  },

  {
    "linux-cultist/venv-selector.nvim",
    keys = {
      { ",v", "<Cmd>VenvSelect<CR>", desc = "Open VenvSelector to pick a venv" },
    },
    ft = "python",
    opts = {
      search = {},
      options = {},
    },
    dependencies = {
      "mfussenegger/nvim-dap-python",
    },
  },
}
