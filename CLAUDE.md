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

### Intel Macs — Homebrew no longer publishes x86_64 bottles

kenya.local is an Intel Mac (macOS 15.7.9, `x86_64`, default prefix `/usr/local`). Homebrew has stopped building macOS Intel bottles for many formulae, so `brew bundle` there dies with `Error: <formula>: no bottle available!`. As of 2026-09-01 these eighteen Brewfile entries have **no** x86_64 macOS bottle at all (only `arm64_*` and `*_linux`): `atuin awscli grpc grpcurl hunk lefthook mise mycli neovim node openssl@3 pandoc qemu tree-sitter tree-sitter-cli unibilium uv zellij`. The list only ever grows, so re-check with the API query below rather than trusting it. Formulae that still carry a legacy `sonoma` Intel bottle (ripgrep, fd, git, …) keep installing fine, because Sequoia falls back to the older tag.

The accompanying `This is a Tier 3 configuration` text is **boilerplate**, not a diagnosis: `formula_installer.rb:452` appends it to every no-bottle error because *building from source* is Tier 3. The machine itself still meets the Tier 1 conditions (Apple-supported macOS, default prefix, bottles). `/opt/homebrew` on kenya is a symlink to `/usr/local`, so the hard-coded `HOMEBREW_PREFIX` in `zsh/.zprofile` is harmless — `brew config` resolves the real prefix.

`brew info --json=v2` cannot answer "does an Intel bottle exist?": it lists only the tags usable on the machine running it. Query the API instead:

```sh
curl -fsSL https://formulae.brew.sh/api/formula/uv.json |
  python3 -c 'import json,sys; print(sorted(json.load(sys.stdin)["bottle"]["stable"]["files"]))'
```

How this is handled:

- **`HOMEBREW_BUNDLE_BREW_SKIP` in `zsh/.zprofile`, guarded by `$CPUTYPE`.** The skip list lives in the shell config, never in the Brewfile, because `brew bundle dump` regenerates the Brewfile from the arm64 machine. `bundle/skipper.rb:55` reads it; it is a no-op on arm64.
- **Skipping an entry does not skip it as a dependency.** `HOMEBREW_BUNDLE_BREW_SKIP` drops the matching *entry* only; a formula that is also a dependency of a non-skipped entry is still upgraded along with it, and then fails. `openssl@3` is a dependency of ~50 installed formulae (bat, eza, git-delta, tmux, python@3.13, …) and `tree-sitter`/`unibilium` are dependencies of `neovim`, so they surface as `Upgrading <name> has failed!` (`bundle/installer.rb:316`) even while listed in the skip list. `brew pin` is what actually stops those.
- **`brew pin awscli grpc grpcurl hunk lefthook mise mycli neovim node openssl@3 pandoc qemu tree-sitter tree-sitter-cli unibilium`** on kenya — the skip list minus uv/atuin/zellij, which are not Homebrew formulae there. `bundle/brew.rb:179` computes `outdated_formulae - pinned_formulae`, and pinning also keeps a plain `brew upgrade` from failing. Those versions are now frozen until an Intel bottle reappears or they are built from source.
- **Pinning `openssl@3` is a deliberate trade-off — keep it pinned.** It is a dependency of ~50 installed formulae, so a plain `brew upgrade` now stops on every outdated dependent with ``Error: You must `brew unpin openssl@3` as installing <name> requires the latest version of pinned dependencies``; on 2026-09-01 that was `gpgme`, `pydantic` and seven `aws-c-*` formulae. `brew bundle` is unaffected: none of the nine is a Brewfile entry, and their dependents (`gnupg`, `poppler`, `litecli`, `awscli`) are either up to date or skipped. Unpinning would only trade this for an openssl source build on every release, and the remaining 13 outdated formulae upgrade normally as it stands.
- **uv, atuin and zellij come from upstream release tarballs into `~/.local/bin`**, not Homebrew. Only `brew`/`cask`/`mas`/`tap`/`flatpak`/`winget` entries can be skipped (`bundle/skipper.rb:55`), so the `uv "docutils"` … lines cannot be; instead `bundle/extensions/extension.rb:57` resolves `uv` with `which`, so a uv on `PATH` satisfies them without the formula. Do not use the atuin/uv official install scripts on kenya — they append to the stowed `~/.zshrc`. `zellij-x86_64-apple-darwin.sha256sum` hashes the **extracted binary**, not the tarball; `uv`/`atuin` publish `.tar.gz.sha256` of the archive.
- **node deliberately stays on Homebrew** despite being pinned to an old version. `brew uses --installed node` on kenya returns devcontainer, mermaid-cli, opencode and skills, and `~/.config/mise` is a stow symlink into this repo, so `mise use -g node@lts` would write the tool into the shared `mise/.config/mise/config.toml` and leak to the arm64 machine.
- **`.zprofile` is read by login shells only.** `.sync` (`zsh/.zshrc:109`) runs `git pull` -> restow -> `brew bundle -g` inside the *running* shell, so a skip list that the pull just updated does not take effect for that same run. After a `.sync` that changes the list, open a new login shell before re-running it.

Verify with `brew bundle check --verbose` on kenya: the eighteen entries must print `Skipping <name>` rather than an error.

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

## Moshi (moshi-hook)

`moshi-hook serve` runs as a Homebrew launchd agent (`brew "rjyo/moshi/moshi-hook", trusted: true`) and bridges AI coding agents to the Moshi mobile app. The `moshi` package stows only `~/.config/moshi/config.toml`; everything else moshi-hook owns lives in `~/Library/Application Support/Moshi/` (socket, `hook.log`, pairing state) and must stay out of the repo.

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

`kulala-core` — the backend that executes HTTP/gRPC/WebSocket/GraphQL requests and formats responses — is managed by the plugin itself, not by Homebrew: it is auto-downloaded from GitHub Releases into nvim's data dir on first use, so `brew bundle` alone will not restore it on a new machine. Override with `kulala_core.path` only when using a hand-installed binary. Check it with `:checkhealth kulala` (the plugin is lazy-loaded, so run `:Lazy load kulala.nvim` first in a non-`http` buffer). Neovim 0.12+ is required.

Keymaps come from kulala's own `global_keymaps = true` under the `<Leader>R` prefix (which-key group in `ui.lua`). The `keys` entries in the spec are lazy-load stubs for the subset kulala maps globally; the rest are filetype-local to `http`/`rest`. The lualine environment indicator reads `vim.g.kulala_selected_env` directly so that lualine never loads kulala.

#### Highlighting: `treesitter = { enable = false }`, use nvim-treesitter's `http`

kulala ships its own `kulala_http` grammar and, left enabled, clones `tree-sitter-kulala-http` into `~/.local/share/nvim/kulala.nvim/`, builds it, and installs `site/parser/kulala_http.dylib` plus `site/queries/kulala_http/`. **That is disabled here** (`treesitter = { enable = false }` in `lua/plugins/coding.lua`); `http` is in the `require("nvim-treesitter").install({...})` list in `lua/plugins/treesitter.lua` instead, and the FileType autocmd there starts it like any other language.

Two reasons:

1. **`kulala_http` errors on value-less variables.** `variable_declaration` makes the value mandatory (`grammar.js:297-306`, still true on upstream `main`), so a placeholder line like `@token =` is a parse error. On `orion-classic/api/orion-api/requests.http` that is **91 ERROR nodes vs 0** for the standard parser, and each one spans three lines — swallowing the `POST` keyword of the request that follows, which then loses its highlight.
2. Everything else is close enough: `###` separators, `< ./body.json`, `>> ./response.json`, `{% script %}`, `{{var}}` and the json/xml/graphql injections all parse the same under both. Only kulala-specific `run #name` / `import ./other.http` (misread as a request URL) and multi-line query params (flat `target_url` instead of `query_param`) degrade, and neither produces an error.

**The trade-off is kulala's LSP layer.** `config/init.lua:34` gates `require("kulala.cmd.lsp").start()` on `Parser.is_up_to_date()`, i.e. on `parser/kulala_http.*` and `queries/kulala_http/*.scm` being findable on `runtimepath`. With the parser gone, inlay hints, completion, hover, code actions, document symbols and folding are all off (`cmd/lsp.lua:143` needs the parser directly for folding), so the spec says `lsp = { enable = false, keymaps = false }` outright rather than leaving a block that cannot take effect (`keymaps = false` is already kulala's default — it maps `K` and `<leader>l*` only when asked). Request execution (`<Leader>Rs`) and the response UI are unaffected — `parser/document.lua` is plain Lua and `ui/init.lua` passes an explicit language to `vim.treesitter.start`.

Two consequences worth remembering:

- `brew "tree-sitter-cli"` must still stay in the Brewfile, but for nvim-treesitter's own sake: it shells out to `tree-sitter build` for every parser it compiles (`install.lua:305-317`).
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

Common scopes: `nvim`, `zsh`, `tmux`, `git`, `starship`, `ghostty`, `homebrew`

## Before Making Any Edit

State the following and wait for confirmation:

1. The minimal set of changes required (what and why)
2. The specific files to be touched
3. How to verify the change works (for Neovim, confirm on the real machine in headless mode — see [Verifying Changes](#verifying-changes); otherwise `:Lazy sync`, LSP restart, shell reload)
