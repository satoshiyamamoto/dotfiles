# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a Stow package that mirrors `$HOME`. Deployment symlinks package contents into the home directory.

**Install (macOS):**
```sh
./install.darwin.sh   # runs: stow --verbose --adopt --target=$HOME <packages...>
```

**Install (Linux):**
```sh
./install.sh          # manually symlinks a smaller set of configs
```

### Directory Structure Convention

Config files are placed under `<package>/.config/<tool>/` to follow the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/) (`$XDG_CONFIG_HOME`). Prefer this layout when adding new packages. Place files directly under `<package>/` only when the tool does not support XDG (e.g., `~/.editorconfig`, `~/.bash_aliases`).

## Neovim Configuration

Entry point: `nvim/.config/nvim/init.lua`  
Plugin manager: lazy.nvim (bootstrapped in `lua/config/lazy.lua`)

### Plugin Spec Layout

All plugins live under `lua/plugins/`, one file per category. Before adding a plugin, read the target file to match its style.

| File | Contents |
|------|----------|
| `ai.lua` | AI tools: sidekick.nvim (Claude/Codex/Gemini), claudecode.nvim |
| `coding.lua` | Editing helpers: flash, surround, gitsigns, colorizer, todo-comments, IME |
| `completion.lua` | blink.cmp, LuaSnip, nvim-autopairs |
| `dap.lua` | nvim-dap adapters/configs, dap-ui, neotest, venv-selector |
| `formatting.lua` | conform.nvim (formatters), nvim-lint (linters) |
| `git.lua` | Git-specific plugins (currently empty, reserved) |
| `lsp.lua` | nvim-lspconfig, mason-lspconfig, mason.nvim |
| `treesitter.lua` | nvim-treesitter, context, textobjects, render-markdown |
| `ui.lua` | snacks.nvim, noice, lualine, bufferline, themes, trouble, oil, which-key |

### LSP Server Configs

- Per-server settings: `lsp/<server>.lua` (loaded automatically by nvim-lspconfig)
- Override/extend: `after/lsp/<server>.lua`

### Adding a Plugin

1. Identify the correct category file from the table above.
2. Read that file in full before editing.
3. Follow the existing spec style: `event`/`ft`/`cmd`/`keys` for lazy loading; `opts = {}` when no custom logic is needed; `config = function(_, opts)` only when extra setup beyond `opts` is required.
4. LSP servers go in `lsp.lua` under `mason-lspconfig` `ensure_installed`; their config files go in `lsp/<name>.lua`.

### External Runtime Paths

Add external nvim site paths via `performance.rtp.paths` in `lua/config/lazy.lua`, not `vim.opt.rtp:append()` (lazy.nvim overwrites the latter).

### Investigating Plugins

When investigating a Neovim plugin's behavior, API, or options, always consult the official source — the plugin's README/docs, `:help`, or the installed source under `~/.local/share/nvim/lazy/<plugin>` and the bundled runtime `~/.local/share/nvim/runtime` (or `$VIMRUNTIME`). Do not rely on assumptions or memory; verify against the actual code/docs for the installed version.

### Verifying Changes

Verify Neovim config changes on the real machine using headless mode, not by reasoning alone. Examples:

```sh
# Sync plugins and exit
nvim --headless "+Lazy! sync" +qa

# Inspect runtime state (e.g. resolved LSP client option)
nvim --headless path/to/File.java "+sleep 3" \
  "+lua print(vim.inspect((vim.lsp.get_clients()[1] or {}).exit_timeout))" +qa
```

### Lua Formatting

Formatter: **stylua** — config at `nvim/.config/nvim/.stylua.toml`

```toml
column_width = 120
indent_type = "Spaces"
indent_width = 2
collapse_simple_statement = "FunctionOnly"
```

Run before committing Lua changes: `stylua <file>`

## Commit Style

Conventional Commits with a scope derived from the changed package:

```
feat(nvim): add <plugin> for <purpose>
fix(tmux): correct status bar character rendering
refactor(zsh): reorder functions by type
```

Common scopes: `nvim`, `zsh`, `tmux`, `git`, `starship`, `ghostty`, `homebrew`

## Before Making Any Edit

State the following and wait for confirmation:

1. The minimal set of changes required (what and why)
2. The specific files to be touched
3. How to verify the change works (for Neovim, confirm on the real machine in headless mode — see [Verifying Changes](#verifying-changes); otherwise `:Lazy sync`, LSP restart, shell reload)
