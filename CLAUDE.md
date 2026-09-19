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

## Nix (nix-darwin)

Packages come from the flake in `nix/`, applied by `darwin-rebuild`. The `.sync` shell function (`zsh/.zshrc`) runs stow and then the rebuild:

```sh
sudo /run/current-system/sw/bin/darwin-rebuild switch --flake <repo>/nix
```

The absolute path is required — `sudo` resets PATH, so a bare `darwin-rebuild` is not found.

| Path | Holds |
|------|-------|
| `nix/flake.nix` | `darwinConfigurations`, one attribute per host, keyed by `scutil --get LocalHostName` |
| `nix/hosts/<hostname>.nix` | Host-only settings: platform, primary user, and whatever that machine alone needs |
| `nix/modules/common.nix` | Shared by every host: `stateVersion`, experimental features, zsh, PAM |
| `nix/modules/packages.nix` | `environment.systemPackages`, `fonts.packages`, `pathsToLink` |
| `nix/modules/homebrew.nix` | What stays on Homebrew: one tapped formula, the GUI casks, the Mac App Store apps |

**Homebrew survives only as a cask/mas backend.** There is no Brewfile in this repo any more — nix-darwin generates one in the Nix store and runs `brew bundle` against it, so edits belong in `nix/modules/homebrew.nix`. `onActivation.cleanup = "uninstall"` makes that file the single source of truth: any formula or cask installed by hand is removed on the next switch. `masApps` is the exception, because Homebrew Bundle has no mas cleanup — deleting an entry there does not uninstall the app.

**All three Macs run nix-darwin.** CA-20033978, CA-20031962 and Kenya have each switched, so `darwin-rebuild` and a Nix store exist everywhere and `.sync` rebuilds on every host. The `[[ -x $darwin_rebuild ]]` guard in `.sync` stays as a safety net for a machine being set up from scratch, not because any host still needs it. What is left of the migration is Phase 5 -- stow to home-manager `home.file`, planned separately. Plan and record: `docs/nix-migration.md`.

**Kenya pins nixpkgs 26.05** rather than following unstable, via its own `nixpkgs-2605` / `nix-darwin-2605` inputs. It is the only x86_64 Mac here and 26.11 does not merely drop `x86_64-darwin` from a few `meta.platforms` — importing nixpkgs at all for that system throws `Nixpkgs 26.11 has dropped support for x86_64-darwin`, so no per-package override can rescue it. That pin has an expiry: 26.05 goes EOL on 2026-12-31, so Kenya needs a channel bump — or a retirement — before then.

Six packages are therefore aarch64-only in `packages.nix`. `container` is Apple Silicon only outright; `antigravity-cli` and `grok-build` publish no darwin-x64 hash upstream; `cloudflare-speed-cli`, `herdr` and `hunk` are absent from 26.05; and `mycli` evaluates but pulls `arrow-cpp` through `llm`, which 26.05 marks broken on x86_64-darwin alone. Of those, only `herdr` is wanted on Kenya, which takes it from `numtide/llm-agents.nix` instead — see below.

`atuin` is gated for a different reason: 26.05 ships 18.15.2, older than whatever last migrated Kenya's SQLite history, and an older client refuses a migrated database outright (`migration <id> was previously applied but is missing in the resolved migrations`). Because `_atuin_preexec` runs `atuin history start` **synchronously**, that failure cost 4-8 seconds on *every* command after the first switch. **Kenya therefore runs no atuin at all** — `zsh/.zshrc` guards `atuin init` with `(( $+commands[atuin] ))`, and `zsh/.zprofile` sets the `FZF_CTRL_R_COMMAND=''` that silences fzf's Ctrl-R only where atuin exists, so Kenya gets fzf's history search instead.

**Homebrew cannot take over a package on Kenya any more.** Homebrew has declared macOS 15 / x86_64 a [Tier 3](https://docs.brew.sh/Support-Tiers#tier-3) configuration and stopped bottling for it, so a new formula there means a source build — that, plus a pinned `openssl@3`, is why the atuin fallback was abandoned. Kenya's `homebrew.brews` is empty as a result: `cloudflare-speed-cli`, `hunk` and `mycli` were dropped as unwanted, `herdr` moved to Nix, and only the `moshi-hook` that `nix/modules/homebrew.nix` declares for every machine is left.

**Kenya's `herdr` comes from `numtide/llm-agents.nix`**, wired in as a flake input and applied on that host alone through `overlays.shared-nixpkgs`, which builds the upstream package tree against the consumer's own `pkgs` (hence `pkgs.llm-agents.herdr` on 26.05). The flake's `packages` output skips `x86_64-darwin` — that is just the systems it caches for — while herdr's own `meta.platforms` covers it and the package is built from source, so nothing upstream blocks it. The cost is that it compiles on the machine: Rust plus a vendored libghostty-vt through zig, about four minutes on the 2018 Mac mini, repeated whenever the input or a dependency moves. `hunk` cannot follow the same route — it pins `meta.platforms` without `x86_64-darwin` because `bun-bin`, the `bun build --compile` runtime, has no `darwin-x64` triple there.

**The AI agent CLIs do not self-update.** `claude`, `codex`, `opencode`, `pi-coding-agent`, `grok-build` and `skills` all come from the Nix store, which is read-only, so an in-place updater could not work even if it tried; nixpkgs wraps `claude` with `DISABLE_AUTOUPDATER=1` and `opencode` with `DISABLE_AUTOUPDATE=true` outright. Their versions move only when the flake inputs are updated (`nix flake update` in `nix/`, then a switch), so a stale CLI is a lockfile question, not a broken updater.

- **hermes-agent is deliberately absent from `packages.nix`.** Upstream lists both `brew install hermes-agent` and PyPI installs (`uv tool install`, `pip install`) as unsupported distribution methods that receive no further updates, and `hermes update` prints a deprecation notice on every run. Use the official installer instead — see [Hermes Agent](#hermes-agent).
- **node comes from nixpkgs, not mise.** `~/.config/mise` is a stow symlink into this repo, so `mise use -g node@lts` would write the tool into the version-controlled `mise/.config/mise/config.toml` instead of a machine-local file. Keep `nodejs` in `nix/modules/packages.nix` and let the flake own the version.

### Cask Quarantine — do not set `HOMEBREW_CASK_OPTS='--no-quarantine'`

`--no-quarantine` was removed in Homebrew 6.x (deprecated in `ffe954753b`, 2025-10-23; removed in `ba25213c81`, 2026-07-30). `cask_opts_quarantine?` is gone from `env_config.rb` and `Cask::Installer` no longer takes a `quarantine:` argument. The flag is now **silently ignored** — `brew install --cask` exits 0 with no warning — so it looks like it still works. `brew config` echoes `HOMEBREW_CASK_OPTS` verbatim and is not evidence that the flag is honored. Supported values are only `--*dir`, `--language`, `--require-sha` and `--no-binaries` (`env_config.rb:228`). The same applies to nix-darwin's `homebrew.caskArgs`, which just renders those values into the generated Brewfile — do not put `no_quarantine = true` there either.

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
- The installer shells out to `brew install` for missing system tools (ripgrep, ffmpeg, git). `ripgrep` and `ffmpeg` are declared in `nix/modules/packages.nix` — keep them there so the flake stays in sync with what Hermes needs. `git` is not declared anywhere: macOS ships Apple Git at `/usr/bin/git`, which is what this machine uses.

### Computer Use (cua-driver)

`/Applications/CuaDriver.app` (`com.trycua.driver`, signed by Cua AI, Inc.) is installed **by Hermes, not by Homebrew** — no cask exists. When `platform_toolsets` in `config.yaml` includes `computer_use`, the post-setup hook (`install_cua_driver()` in `hermes_cli/tools_config.py`) runs the upstream installer:

```sh
curl -fsSL https://raw.githubusercontent.com/trycua/cua/main/libs/cua-driver/scripts/install.sh | bash
```

- The installer unpacks to `/Applications/CuaDriver.app` and symlinks `~/.local/bin/cua-driver` to the executable. Hermes skips the install when `/Applications` is not writable.
- Refresh with `hermes computer-use install --upgrade` (also called by `hermes update`). The installer always pulls the latest release, so re-running *is* the upgrade path — there is no version pin. Inspect with `hermes computer-use status` / `doctor`.
- macOS TCC grants (Accessibility, Screen Recording) attach to `com.trycua.driver` itself — approve **Cua Driver** in System Settings, not the terminal or Hermes.
- Unlike `ffmpeg`, it is not declared in `nix/modules/packages.nix`, and a `darwin-rebuild switch` alone will not restore it on a new machine.

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

## Moshi (moshi-hook)

`moshi-hook serve` runs as a Homebrew launchd agent — declared in `nix/modules/homebrew.nix` under `brews` with `restart_service = "changed"` — and bridges AI coding agents to the Moshi mobile app. The `moshi` package stows only `~/.config/moshi/config.toml`; everything else moshi-hook owns lives in `~/Library/Application Support/Moshi/` (socket, `hook.log`, pairing state) and must stay out of the repo.

The tap is third-party, and since Homebrew 6.0.0 `HOMEBREW_REQUIRE_TAP_TRUST` refuses to load its formula until it is trusted. Activation is already covered: nix-darwin's `trusted` option defaults to **true for `brews` and `casks`** (and false only for `taps`), so the generated Brewfile carries `brew "rjyo/moshi/moshi-hook", ..., trusted: true`, and `brew bundle` writes that into the trust store itself before loading any entry (`Library/Homebrew/bundle/installer.rb`). No tap-wide grant is needed.

What is *not* covered is anything undeclared. `cleanup = "uninstall"` cannot load an undeclared formula from an undeclared tap in order to remove it, and aborts activation — this is what happened on CA-20031962. Untap such leftovers by hand before the first switch.

Interactive `brew` is a separate store: `brew trust` writes `$XDG_CONFIG_HOME/homebrew/trust.json` while a run without `XDG_CONFIG_HOME` reads `~/.homebrew/trust.json` (`Library/Homebrew/trust.rb`), so `brew trust --formula rjyo/moshi/moshi-hook` is still worth running once per machine for your own shell.

`moshi-hook set` writes **through** the stow symlink rather than replacing it, so the CLI and the repo stay in sync — no `--no-folding` needed, unlike the Hermes skills case above. It also sorts the port list on write. Editing `config.toml` by hand is equivalent; `set` just saves you finding the file.

### `scan_ports` is a deliberate allowlist — do not set it back to `all`

With the default `scan_ports = all`, moshi-hook HTTP-probes **every** loopback listener to decide which ones are dev servers (`gateway.listListeningPorts` -> `filterConfiguredScanPorts` -> `probeHTTPServer` -> `classifyServeSim`, detecting tokens like `Vite` / `Next.js` / `X-Powered-By`). Each probe is a bare `GET /` from Go's http.Client, sent twice per port — once with `Host: 127.0.0.1:<port>`, once with `Host: localhost:<port>`, identifiable by `User-Agent: Go-http-client/1.1`.

claudecode.nvim serves WebSocket only, on a random port in 10000-65535, so those probes make it answer 400 `Bad WebSocket upgrade request: Missing or invalid Upgrade header` (body is exactly 64 bytes, so `Content-Length: 64` is the fingerprint) and log a WARN. That path then trips an upstream bug: `server/client.lua` schedules `client.tcp_handle:close()` without the `is_closing()` guard that `server/tcp.lua` `_remove_client` has, so when the peer hangs up first Neovim reports `handle 0x... is already closing` with `[C]: in function 'close'`. Both messages are noise — the Claude Code CLI's own `/ide` handshake is valid and unaffected.

Because the claudecode.nvim port is random, an allowlist is the only fix that survives a restart. **Ranges are not supported** — `moshi-hook set scan-ports 3000-3005` fails with `invalid scan port "3000-3005" (use 1-65535)` (that `1-65535` is the valid range for a *single* port, not range syntax). Only `all`, `none`, or comma-separated individual ports are accepted.

The listed ports come from what this machine actually runs: 3000 (`next dev` / `remix dev` / `wrangler pages dev`, and orion-classic's web app), 8080 (orion-classic's admin app), 5173 (`vite`), 3001 / 5174 (the Next.js and Vite fallbacks when the default is taken), and 4180 (oauth2-proxy in orion-classic's `docker-compose.yml`, which is the URL you actually open in a browser).

Two ports from that compose file are deliberately **not** listed: redis on 6379 speaks no HTTP, and imgproxy on 18080 serves signed-URL image transforms rather than a browsable page, so listing it would only buy an extra probe. Ports outside the list are invisible to the Moshi app — Chrome's `:9222` DevTools endpoint no longer shows up in `moshi-hook servers`, which is the intended trade-off.

Scan-port changes apply on the next discovery refresh (no restart); boolean settings such as `always-on-discovery` need the daemon restarted. Verify with `moshi-hook set` (lists every setting) and `moshi-hook servers` (JSON of what was discovered).

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

`kulala-core` — the backend that executes HTTP/gRPC/WebSocket/GraphQL requests and formats responses — is managed by the plugin itself, not by Nix: it is auto-downloaded from GitHub Releases into nvim's data dir on first use, so a `darwin-rebuild switch` alone will not restore it on a new machine. Override with `kulala_core.path` only when using a hand-installed binary. Check it with `:checkhealth kulala` (the plugin is lazy-loaded, so run `:Lazy load kulala.nvim` first in a non-`http` buffer). Neovim 0.12+ is required.

Keymaps come from kulala's own `global_keymaps = true` under the `<Leader>R` prefix (which-key group in `ui.lua`). The `keys` entries in the spec are lazy-load stubs for the subset kulala maps globally; the rest are filetype-local to `http`/`rest`. The lualine environment indicator reads `vim.g.kulala_selected_env` directly so that lualine never loads kulala.

#### Highlighting: `treesitter = { enable = false }`, use nvim-treesitter's `http`

kulala ships its own `kulala_http` grammar and, left enabled, clones `tree-sitter-kulala-http` into `~/.local/share/nvim/kulala.nvim/`, builds it, and installs `site/parser/kulala_http.dylib` plus `site/queries/kulala_http/`. **That is disabled here** (`treesitter = { enable = false }` in `lua/plugins/coding.lua`); `http` is in the `require("nvim-treesitter").install({...})` list in `lua/plugins/treesitter.lua` instead, and the FileType autocmd there starts it like any other language.

Two reasons:

1. **`kulala_http` errors on value-less variables.** `variable_declaration` makes the value mandatory (`grammar.js:297-306`, still true on upstream `main`), so a placeholder line like `@token =` is a parse error. On `orion-classic/api/orion-api/requests.http` that is **91 ERROR nodes vs 0** for the standard parser, and each one spans three lines — swallowing the `POST` keyword of the request that follows, which then loses its highlight.
2. Everything else is close enough: `###` separators, `< ./body.json`, `>> ./response.json`, `{% script %}`, `{{var}}` and the json/xml/graphql injections all parse the same under both. Only kulala-specific `run #name` / `import ./other.http` (misread as a request URL) and multi-line query params (flat `target_url` instead of `query_param`) degrade, and neither produces an error.

**The trade-off is kulala's LSP layer.** `config/init.lua:34` gates `require("kulala.cmd.lsp").start()` on `Parser.is_up_to_date()`, i.e. on `parser/kulala_http.*` and `queries/kulala_http/*.scm` being findable on `runtimepath`. With the parser gone, inlay hints, completion, hover, code actions, document symbols and folding are all off (`cmd/lsp.lua:143` needs the parser directly for folding), so the spec says `lsp = { enable = false, keymaps = false }` outright rather than leaving a block that cannot take effect (`keymaps = false` is already kulala's default — it maps `K` and `<leader>l*` only when asked). Request execution (`<Leader>Rs`) and the response UI are unaffected — `parser/document.lua` is plain Lua and `ui/init.lua` passes an explicit language to `vim.treesitter.start`.

Two consequences worth remembering:

- nixpkgs' `tree-sitter` (the CLI, in `nix/modules/packages.nix`) must stay declared, but for nvim-treesitter's own sake: it shells out to `tree-sitter build` for every parser it compiles (`install.lua:305-317`).
- A bare `:TSUpdate` used to fail with `Parser not available for language "kulala_http"`. `config.get_installed()` builds its list by scanning `site/parser` and `site/queries`, so kulala's artifacts looked like nvim-treesitter's own; `norm_languages` returns that list verbatim for `'all'` (`config.lua:105-109`), and the unknown language then errors in `get_parser_install_info`. Re-enabling kulala's treesitter handling brings that back. The alternative fix — moving nvim-treesitter's own `install_dir` out of `site/` — was rejected as the bigger change.

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

Common scopes: `nvim`, `zsh`, `tmux`, `git`, `starship`, `ghostty`, `nix`

## Before Making Any Edit

State the following and wait for confirmation:

1. The minimal set of changes required (what and why)
2. The specific files to be touched
3. How to verify the change works (for Neovim, confirm on the real machine in headless mode — see [Verifying Changes](#verifying-changes); otherwise `:Lazy sync`, LSP restart, shell reload)
