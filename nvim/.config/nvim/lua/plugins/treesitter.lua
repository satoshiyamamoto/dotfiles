return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").install({
        "bash",
        "csv",
        "go",
        "gomod",
        "gotmpl",
        "hcl",
        "html",
        "http",
        "java",
        "javascript",
        "json",
        "kdl",
        "lua",
        "markdown",
        "markdown_inline",
        "pug",
        "proto",
        "python",
        "query",
        "regex",
        "rust",
        "sql",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "yaml",
      })

      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          -- Ignore special buffers (e.g. nofile)
          if vim.bo.buftype ~= "" then
            return
          end

          local ok = pcall(vim.treesitter.start)
          if ok then
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
            vim.wo.foldmethod = "expr"
            vim.wo.foldlevel = 99
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      enable = true,
    },
    config = function(_, opts)
      require("treesitter-context").setup(opts)
      vim.api.nvim_set_hl(0, "TreesitterContext", { bg = "None" })
      vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "#000000" })
    end,
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
      { "folke/tokyonight.nvim" },
      { "projekt0n/github-nvim-theme" },
    },
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      -- Native commenting in Neovim 0.10
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })

      local get_option = vim.filetype.get_option
      vim.filetype.get_option = function(filetype, option) ---@diagnostic disable-line duplicate-set-field
        return option == "commentstring" --
            and require("ts_context_commentstring.internal").calculate_commentstring() --
          or get_option(filetype, option)
      end
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local swap = require("nvim-treesitter-textobjects.swap")
      local move = require("nvim-treesitter-textobjects.move")
      local repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

      -- Select
      vim.keymap.set(
        { "x", "o" },
        "am",
        function() select.select_textobject("@function.outer", "textobjects") end,
        { desc = "Around function" }
      )
      vim.keymap.set(
        { "x", "o" },
        "im",
        function() select.select_textobject("@function.inner", "textobjects") end,
        { desc = "Inside function" }
      )
      vim.keymap.set(
        { "x", "o" },
        "ac",
        function() select.select_textobject("@class.outer", "textobjects") end,
        { desc = "Around class" }
      )
      vim.keymap.set(
        { "x", "o" },
        "ic",
        function() select.select_textobject("@class.inner", "textobjects") end,
        { desc = "Inside class" }
      )
      vim.keymap.set(
        { "x", "o" },
        "as",
        function() select.select_textobject("@local.scope", "locals") end,
        { desc = "Around scope" }
      )

      -- Swap
      vim.keymap.set(
        "n",
        "<leader>a",
        function() swap.swap_next("@parameter.inner") end,
        { desc = "Swap with next parameter" }
      )
      vim.keymap.set(
        "n",
        "<leader>A",
        function() swap.swap_previous("@parameter.outer") end,
        { desc = "Swap with previous parameter" }
      )

      -- Move
      vim.keymap.set(
        { "n", "x", "o" },
        "]m",
        function() move.goto_next_start("@function.outer", "textobjects") end,
        { desc = "Next function start" }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        "]]",
        function() move.goto_next_start("@class.outer", "textobjects") end,
        { desc = "Next class start" }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        "]M",
        function() move.goto_next_end("@function.outer", "textobjects") end,
        { desc = "Next function end" }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        "][",
        function() move.goto_next_end("@class.outer", "textobjects") end,
        { desc = "Next class end" }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        "[m",
        function() move.goto_previous_start("@function.outer", "textobjects") end,
        { desc = "Previous function start" }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        "[[",
        function() move.goto_previous_start("@class.outer", "textobjects") end,
        { desc = "Previous class start" }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        "[M",
        function() move.goto_previous_end("@function.outer", "textobjects") end,
        { desc = "Previous function end" }
      )
      vim.keymap.set(
        { "n", "x", "o" },
        "[]",
        function() move.goto_previous_end("@class.outer", "textobjects") end,
        { desc = "Previous class end" }
      )

      -- Repeat with ; and , (also integrates f/F/t/T)
      vim.keymap.set({ "n", "x", "o" }, ";", repeat_move.repeat_last_move_next, { desc = "Repeat last move" })
      vim.keymap.set(
        { "n", "x", "o" },
        ",",
        repeat_move.repeat_last_move_previous,
        { desc = "Repeat last move (reverse)" }
      )
      vim.keymap.set({ "n", "x", "o" }, "f", repeat_move.builtin_f_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "F", repeat_move.builtin_F_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "t", repeat_move.builtin_t_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "T", repeat_move.builtin_T_expr, { expr = true })
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      completions = { lsp = { enabled = true } },
      anti_conceal = { enabled = false },
      heading = { enabled = false },
      bullet = { enabled = true, icons = { "•" } },
      checkbox = { enabled = false },
      code = { sign = false, disable = { "mermaid" } },
    },
    config = function(_, opts)
      require("render-markdown").setup(opts)
      -- Glow (glamour dark.json) colors
      -- https://github.com/charmbracelet/glamour/blob/master/styles/dark.json

      -- Heading
      vim.api.nvim_set_hl(0, "@markup.heading.markdown", { link = "Normal" }) -- table header (fallback)
      vim.api.nvim_set_hl(0, "@markup.heading.1.markdown", { fg = "#FFFF87", bg = "#5F5FFF", bold = true }) -- h1: 228, 63
      vim.api.nvim_set_hl(0, "@markup.heading.2.markdown", { fg = "#00AFFF", bold = true }) -- heading: 39
      vim.api.nvim_set_hl(0, "@markup.heading.3.markdown", { fg = "#00AFFF", bold = true })
      vim.api.nvim_set_hl(0, "@markup.heading.4.markdown", { fg = "#00AFFF", bold = true })
      vim.api.nvim_set_hl(0, "@markup.heading.5.markdown", { fg = "#00AFFF", bold = true })
      vim.api.nvim_set_hl(0, "@markup.heading.6.markdown", { fg = "#00AF5F" }) -- h6: 35, no bold
      -- List
      vim.api.nvim_set_hl(0, "@markup.list.markdown", { link = "Normal" }) -- list marker
      vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { link = "Normal" })
      -- Code
      vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "RenderMarkdownCodeBorder", { bg = "NONE" })
      vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { fg = "#FF5F5F", bg = "#303030" }) -- code: 203, 236
      vim.api.nvim_set_hl(0, "@markup.raw.markdown_inline", { link = "RenderMarkdownCodeInline" })
      -- Table
      vim.api.nvim_set_hl(0, "@punctuation.special.markdown", { link = "Normal" }) -- table border
      vim.api.nvim_set_hl(0, "RenderMarkdownTableHead", { link = "Normal" })
      vim.api.nvim_set_hl(0, "RenderMarkdownTableRow", { fg = "#D0D0D0" }) -- table: {} (doc color: 252)
      -- Link
      vim.api.nvim_set_hl(0, "markdownLink", { fg = "#00AF5F", bold = true }) -- link_text: 35
      vim.api.nvim_set_hl(0, "markdownUrl", { fg = "#008787", underline = true })
      vim.api.nvim_set_hl(0, "RenderMarkdownLink", { fg = "#008787", underline = true }) -- link: 30
      -- Other
      vim.api.nvim_set_hl(0, "RenderMarkdownDash", { fg = "#585858" }) -- hr: 240
    end,
  },
}
