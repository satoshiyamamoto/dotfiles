return {
  {
    "folke/sidekick.nvim",
    dependencies = { "folke/snacks.nvim" },
    event = { "VeryLazy" },
    opts = {
      cli = {
        mux = { enabled = true, backend = "tmux" },
      },
    },
    keys = {
      {
        "<tab>",
        function()
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>"
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<c-.>",
        function() require("sidekick.cli").focus() end,
        mode = { "n", "t", "i", "x" },
        desc = "Sidekick Focus",
      },
      {
        "<leader>aa",
        function() require("sidekick.cli").toggle() end,
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>ac",
        function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end,
        desc = "Sidekick Toggle Claude",
      },
      {
        "<leader>ax",
        function() require("sidekick.cli").toggle({ name = "codex", focus = true }) end,
        desc = "Sidekick Toggle Codex",
      },
      {
        "<leader>ag",
        function() require("sidekick.cli").toggle({ name = "gemini", focus = true }) end,
        desc = "Sidekick Toggle Gemini",
      },
      {
        "<leader>as",
        function() require("sidekick.cli").select() end,
        desc = "Sidekick Select CLI",
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
      {
        "<leader>ap",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
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
    },
  },
}
