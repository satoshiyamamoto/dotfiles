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

## Homebrew / Brewfile

`homebrew/.config/homebrew/Brewfile` is periodically regenerated with `brew bundle dump`, which strips every comment. Record package-specific caveats here instead of in the Brewfile.

- **hermes-agent is deliberately absent from the Brewfile.** Upstream lists both `brew install hermes-agent` and PyPI installs (`uv tool install`, `pip install`) as unsupported distribution methods that receive no further updates, and `hermes update` prints a deprecation notice on every run. Use the official installer instead — see [Hermes Agent](#hermes-agent).

### Cask Quarantine — do not set `HOMEBREW_CASK_OPTS='--no-quarantine'`

`--no-quarantine` was removed in Homebrew 6.x (deprecated in `ffe954753b`, 2025-10-23; removed in `ba25213c81`, 2026-07-30). `cask_opts_quarantine?` is gone from `env_config.rb` and `Cask::Installer` no longer takes a `quarantine:` argument. The flag is now **silently ignored** — `brew install --cask` exits 0 with no warning — so it looks like it still works. `brew config` echoes `HOMEBREW_CASK_OPTS` verbatim and is not evidence that the flag is honored. Supported values are only `--*dir`, `--language`, `--require-sha` and `--no-binaries` (`env_config.rb:228`).

The replacement is automatic and needs no configuration. `0a137ee80b` ("Preserve cask quarantine approval", 2026-07-11) makes `brew upgrade --cask` inherit the old version's Gatekeeper approval when both hold:

1. the old app's `com.apple.quarantine` has the user-approved bit `0x0040` set (i.e. it was approved once by hand), and
2. the new app satisfies the old app's designated requirement, verified through Security.framework rather than `codesign`.

`quarantine_release_decision` in `cask/upgrade.rb:302` decides this and warns with the reason otherwise (`signer_changed` / `signer_unverified` / `unapproved`). So each app prompts **once**, on first launch after it is first quarantined, and never again across upgrades.

Apps installed while `--no-quarantine` still worked carry no quarantine attribute at all, so they read as `unapproved` and will prompt once on their next upgrade. That one-time cost is expected — do not try to suppress it by reintroducing the flag. Inspect any app's state with:

```sh
brew ruby -e 'require "cask/quarantine"; p2 = Pathname(ARGV[0]);
  puts "status=#{Cask::Quarantine.status(p2)} approved=#{Cask::Quarantine.user_approved?(p2)}"' /Applications/Zed.app
```

## Hermes Agent

Installed with the official script — a Tier 1 supported method — **not** Homebrew or uv:

```sh
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --skip-setup
```

Drop `--skip-setup` only on a machine with no `~/.hermes/config.yaml` yet; the wizard would otherwise rewrite existing settings.

- Code lives in `~/.hermes/hermes-agent` (git checkout of `main` plus a Python 3.11 venv driven by Hermes' own uv at `~/.hermes/bin/uv`). The `hermes` command is a shim at `~/.local/bin/hermes`.
- **Never pass `--branch <tag>`.** `git clone --depth 1 --branch <tag>` pins the refspec to that single tag and leaves no remote-tracking branch, so `hermes update` dies with `Branch 'main' not found on origin`. Recover with `git remote set-branches origin main && git fetch --depth 1 origin main`.
- `hermes update` does a git pull on `main`. From a detached HEAD it switches to `main` automatically (autostashing local changes), so tag pinning and `hermes update` are mutually exclusive.
- `~/.hermes` is shared by every install method, so switching methods keeps all config and state. The installer skips files that already exist, and `atomic_yaml_write` preserves symlinks (upstream #16743) — stow-linked `config.yaml` / `SOUL.md` are never clobbered.
- **The `hermes` package deliberately stows only `config.yaml` and `SOUL.md`.** `~/.hermes/skills` belongs to Hermes (bundled skills seeded by the installer, hub installs, `.hub/` provenance, usage telemetry) and must stay out of stow's reach — see [Personal Skills](#personal-skills) for why.
- The launchd plist points at `~/.hermes/hermes-agent/venv/bin/python`, which carries no version, so `hermes update` won't break the gateway. Re-run `hermes gateway install` only when switching install methods.
- The installer shells out to `brew install` for missing system tools (ripgrep, ffmpeg, git). That is why `ffmpeg` is declared in the Brewfile — keep it there so the Brewfile stays in sync with what Hermes needs.

### Computer Use (cua-driver)

`/Applications/CuaDriver.app` (`com.trycua.driver`, signed by Cua AI, Inc.) is installed **by Hermes, not by Homebrew** — no cask exists. When `platform_toolsets` in `config.yaml` includes `computer_use`, the post-setup hook (`install_cua_driver()` in `hermes_cli/tools_config.py`) runs the upstream installer:

```sh
curl -fsSL https://raw.githubusercontent.com/trycua/cua/main/libs/cua-driver/scripts/install.sh | bash
```

- The installer unpacks to `/Applications/CuaDriver.app` and symlinks `~/.local/bin/cua-driver` to the executable. Hermes skips the install when `/Applications` is not writable.
- Refresh with `hermes computer-use install --upgrade` (also called by `hermes update`). The installer always pulls the latest release, so re-running *is* the upgrade path — there is no version pin. Inspect with `hermes computer-use status` / `doctor`.
- macOS TCC grants (Accessibility, Screen Recording) attach to `com.trycua.driver` itself — approve **Cua Driver** in System Settings, not the terminal or Hermes.
- Unlike `ffmpeg`, it never appears in the Brewfile, and `brew bundle` alone will not restore it on a new machine.

Full notes: `~/Documents/knowledge/hermes.md` §8.

### Personal Skills

Hand-written skills are **not** in this repo. They live in [satoshiyamamoto/skills](https://github.com/satoshiyamamoto/skills), which serves two agents from two trees:

```
skills/<skill-name>/SKILL.md             Claude Code (plugin.json "skills": "./skills")
hermes/<category>/<skill-name>/SKILL.md  Hermes Agent (skills.external_dirs)
```

Hermes reads the `hermes/` tree via `skills.external_dirs` in `config.yaml`, pointed at the local clone. A local path needs no auth even though the repo is private, and edits are live. The directory level under `hermes/` becomes the skill's category.

Three reasons not to put personal skills under `~/.hermes/skills` instead:

1. **Stow folding breaks `hermes skills install`.** If any part of `~/.hermes/skills` comes from stow, stow collapses the whole directory into one symlink pointing at this repo, and installs fail with `Installation blocked: '<repo path>' is not in the subpath of '/Users/<user>/.hermes/skills'`. Upstream bug: `install_from_quarantine()` in `tools/skills_hub.py` compares a `resolve()`d `install_dir` against an unresolved `_skills_dir()`. It raises *after* `shutil.move()`, so the skill lands on disk but never reaches `lock.json` — recover by re-running the install.
2. **`--no-folding` dodges that but trips the trust check.** `skill_view()` resolves both sides before comparing against `_trusted_dirs`, so a symlinked `SKILL.md` under a real `~/.hermes/skills` logs `skill file is outside the trusted skills directory` on every load. Paths from `external_dirs` are in `_trusted_dirs`, so they stay quiet.
3. `~/.hermes/skills` also accumulates ~48 MB of bundled skills plus `.hub/` state, which has no business in a dotfiles working tree.

`hermes skills tap add satoshiyamamoto/skills` is the wrong tool for these: taps install a **copy** through the GitHub API, which needs auth for a private repo and drops the live link.

## Neovim Configuration

Entry point: `nvim/.config/nvim/init.lua`  
Plugin manager: lazy.nvim (bootstrapped in `lua/config/lazy.lua`)

### Plugin Spec Layout

All plugins live under `lua/plugins/`, one file per category. Before adding a plugin, read the target file to match its style.

| File | Contents |
|------|----------|
| `ai.lua` | AI tools: sidekick.nvim (Claude/Codex/Gemini), claudecode.nvim |
| `coding.lua` | Editing helpers: flash, surround, gitsigns, colorizer, todo-comments, IME, kulala.nvim (HTTP) |
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

### Filetype-specific Settings

Settings that apply only to a specific filetype (options, keymaps, highlights) go in `ftplugin/<filetype>.lua`, not in `init.lua` or autocmds.

- Set buffer-locally: `vim.opt_local` for options, `{ buffer = true }` for keymaps. Never use global `vim.opt` here, as it leaks into other filetypes.
- Example: markdown-specific settings → `ftplugin/markdown.lua`

### Adding a Plugin

1. Identify the correct category file from the table above.
2. Read that file in full before editing.
3. Follow the existing spec style: `event`/`ft`/`cmd`/`keys` for lazy loading; `opts = {}` when no custom logic is needed; `config = function(_, opts)` only when extra setup beyond `opts` is required.
4. LSP servers go in `lsp.lua` under `mason-lspconfig` `ensure_installed`; their config files go in `lsp/<name>.lua`.

### External Runtime Paths

Add external nvim site paths via `performance.rtp.paths` in `lua/config/lazy.lua`, not `vim.opt.rtp:append()` (lazy.nvim overwrites the latter).

### HTTP Client (kulala.nvim)

`mistweaverco/kulala.nvim` in `lua/plugins/coding.lua` replaced `rest-nvim/rest.nvim`, which was the only plugin here that needed lazy.nvim's luarocks/hererocks machinery.

Two artifacts are managed by the plugin itself, not by Homebrew — `brew bundle` alone will not restore them on a new machine:

- **`kulala-core`** — the backend that executes HTTP/gRPC/WebSocket/GraphQL requests and formats responses. Auto-downloaded from GitHub Releases into nvim's data dir on first use. Override with `kulala_core.path` only when using a hand-installed binary.
- **`kulala_http` Tree-sitter parser** — kulala clones `tree-sitter-kulala-http` at a pinned commit into `~/.local/share/nvim/kulala.nvim/`, builds it with the Tree-sitter CLI, and installs `site/parser/kulala_http.dylib` plus `site/queries/kulala_http/`. This is why `brew "tree-sitter-cli"` must stay in the Brewfile; `git` and `curl` are also required. Because kulala registers `kulala_http` for the `http` and `rest` filetypes, `http` is deliberately absent from the `require("nvim-treesitter").install({...})` list in `lua/plugins/treesitter.lua`.

Check both with `:checkhealth kulala` (the plugin is lazy-loaded, so run `:Lazy load kulala.nvim` first in a non-`http` buffer). Neovim 0.12+ is required.

**The grammar fetch is async and not crash-safe.** `fetch_grammar()` in `lua/kulala/config/parser.lua` runs `git init` → `git remote add origin` → `git fetch` as chained callbacks, but its resume check only tests whether `.git` exists. If Neovim exits between `init` and `remote add` — easy to hit with `nvim --headless ... +qa` — every later run skips `remote add` and dies with `fatal: 'origin' does not appear to be a git repository`, silently leaving `http` files without highlighting. Recover by deleting the clone and reopening an `.http` file in a session that stays alive for ~2 minutes:

```sh
rm -rf ~/.local/share/nvim/kulala.nvim/tree-sitter-kulala-http
```

Keymaps come from kulala's own `global_keymaps = true` under the `<Leader>R` prefix (which-key group in `ui.lua`). The `keys` entries in the spec are lazy-load stubs for the subset kulala maps globally; the rest are filetype-local to `http`/`rest`. The lualine environment indicator reads `vim.g.kulala_selected_env` directly so that lualine never loads kulala.

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
