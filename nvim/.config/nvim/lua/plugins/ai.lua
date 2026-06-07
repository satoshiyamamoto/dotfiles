return {
  {
    "folke/sidekick.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = { "VeryLazy" },
    opts = {
      cli = {
        win = {
          layout = "left",
          keys = {
            buffers = false,
            files = false,
            prompt = false,
            stopinsert = false,
            nav_left = false,
            nav_down = false,
            nav_up = false,
            nav_right = false,
          },
        },
      },
    },
    keys = {
      {
        "<c-.>",
        function()
          require("sidekick.cli").focus()
          -- FIXME: workaround for Claude Code TUI one-line-up shift on focus
          vim.defer_fn(function()
            local buf = vim.api.nvim_get_current_buf()
            local chan = vim.bo[buf].channel
            if chan > 0 then
              vim.api.nvim_chan_send(chan, "\x0c")
            end
          end, 100)
        end,
        mode = { "n", "t", "i", "x" },
        desc = "Sidekick Focus",
      },
      {
        "<leader>at",
        function() require("sidekick.cli").send({ msg = "{this}" }) end,
        mode = { "n", "x" },
        desc = "Sidekick Send This",
      },
      {
        "<leader>af",
        function() require("sidekick.cli").send({ msg = "{file}" }) end,
        desc = "Sidekick Send File",
      },
      {
        "<leader>av",
        function() require("sidekick.cli").send({ msg = "{selection}" }) end,
        mode = { "x" },
        desc = "Sidekick Send Selection",
      },
    },
  },

  {
    -- WebSocket MCP server for /ide integration (UI is delegated to sidekick.nvim)
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = { "VeryLazy" },
    config = true,
    opts = {
      terminal = {
        provider = "none",
      },
      diff_opts = {
        layout = "horizontal", -- "vertical" or "horizontal"
      },
    },
  },
}
