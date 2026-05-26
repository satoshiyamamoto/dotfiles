return {
  {
    "folke/sidekick.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = { "VeryLazy" },
    opts = {
      cli = {
        win = {
          wo = {
            -- Align top padding with dropbar.nvim winbar
            winbar = " ",
            winhighlight = "WinBar:Normal,WinBarNC:NormalNC",
          },
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
        function() require("sidekick.cli").focus() end,
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
    terminal = {
      provider = "none",
    },
    opts = {
      config = true,
    },
  },
}
