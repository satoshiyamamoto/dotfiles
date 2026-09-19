# dotfiles: Homebrew → Nix (nix-darwin + home-manager) 移行計画

作成 2026-09-19 (全項目決定済み、同日ゼロベースで再構成) / 対象: `satoshiyamamoto/dotfiles`

## 1. 方針

| 項目 | 決定 |
|---|---|
| スタック | nix-darwin + home-manager (flake)。home-manager は nix-darwin モジュールとして組み込む |
| CLI パッケージ | Brewfile の `brew` / `go` / `uv` / `npm` 行と CLI 系 cask を nixpkgs の `environment.systemPackages` へ |
| GUI (cask / mas) | nix-darwin `homebrew` モジュールで宣言。Homebrew は GUI 専用バックエンドとして残す |
| dotfiles のリンク | GNU Stow を維持したまま Nix 化し、home-manager `home.file` への移行は別計画 |
| arm 2 台 (CA-20033978 / CA-20031962) | nixpkgs-unstable + nix-darwin master + home-manager master (今の brew と同じローリング)。インストーラーは NixOS/nix-installer |
| Kenya (Intel) | Nix 化する。nixpkgs **26.05 固定** (EOL 2026-12-31 以降は凍結運用)。インストーラーは公式 nixos.org スクリプト (Intel バイナリを配る唯一の正規手段) |
| gcloud | cask をやめ nixpkgs `google-cloud-sdk` へ |
| AI エージェント CLI | claude-code / codex / opencode / pi-coding-agent / skills / grok-build / antigravity-cli はすべて nixpkgs。cask `claude-code@latest` `codex` `grok-build` `antigravity-cli` は廃止。claude-code だけは Kenya でも unstable の版を使う (§3.5)、それ以外は Kenya は 26.05 の版で妥協 (利用頻度が低く遅れは許容) |
| Rust | `rustup` のみ。`rustc` / `cargo` は rustup のツールチェインが出すので nixpkgs `rust` は入れない |
| `homebrew/trust.json` | repo から外して `.gitignore`。`trusted = true` は nix-darwin 側で宣言 |
| Nix にない formula | gcviewer / showkey / socket_vmnet / utimer は移行前に削除。moshi-hook だけ `homebrew.brews` に残す |

判断根拠となる実測値は §10 にまとめた。

## 2. 対象端末 (2026-09-19 SSH 実測)

| ホスト | user | CPU | macOS | brew | 特記 |
|---|---|---|---|---|---|
| CA-20033978 (この端末) | a12019 | M4 / arm64 | 26.6.2 | 7.0.4 `/opt/homebrew`、304 formulae / 28 casks | `~/.config/starship.toml` が実ファイル、`~/.config/mise` が空の実ディレクトリ (stow リンク切れ)。追加 cask: intellij-idea。moshi-hook サービス稼働。bundle check で drift (codex, argo, snappy, awscli, node, openjdk, gradle, openexr, mise, mycli, skills, uv) |
| CA-20031962 | a12019 | M4 Max / arm64 | 26.6.2 | 7.0.4、317 / 29 | stow 正常。追加 formula: graphviz。追加 cask: google-cloud-sdk, handbrake。go pkgs / zmx / moshi-hook 未導入 |
| Kenya | **satoshi** | i7-8700B / **x86_64** | 15.8 | 7.0.4 **`/usr/local`**、root に `/opt/homebrew -> /usr/local` シンボリックリンク、305 / 29 | repo が 2 コミット遅れ。追加 formulae: code-minimap, helm-ls, z。追加 cask: antigravity, codex-app。grok-build 1.0.34 (x86_64 バイナリ) と antigravity-cli 1.0.3 (`agy`、5 月から未更新) が cask で入っている。hermes gateway + moshi-hook 稼働 |

共通: admin、SIP 有効、zsh 5.9、nvim 0.12.5、tmux 3.7c、Xcode CLT あり、Nix 未導入。

## 3. 目標構成

リポジトリ内に `nix/` を追加する (stow 対象にはしない)。

```
nix/
  flake.nix              inputs: nixpkgs (unstable), nixpkgs-2605, nix-darwin, nix-darwin-2605,
                         home-manager, home-manager-2605
  hosts/
    CA-20033978.nix      nixpkgs.hostPlatform = "aarch64-darwin"; system.primaryUser = "a12019"
    CA-20031962.nix      同上 (+ graphviz / handbrake)
    Kenya.nix            nixpkgs.hostPlatform = "x86_64-darwin"; primaryUser = "satoshi"
                         (26.05 系 inputs、+ code-minimap / helm-ls / z / antigravity / codex-app)
  modules/
    packages.nix         environment.systemPackages (§4)、claude-code の callPackage (§3.5)
    homebrew.nix         homebrew.{enable,taps,brews,casks,masApps,onActivation}
    home.nix             home-manager: 当面は home.stateVersion と PATH まわりのみ
```

### 3.1 flake / ホスト

- `darwinConfigurations` のキーはホスト名 (`scutil --get LocalHostName`) と一致させ、`sudo darwin-rebuild switch --flake ~/Projects/src/github.com/satoshiyamamoto/dotfiles/nix` を引数なしで通す。
- 26.05 系の release ブランチ: `NixOS/nixpkgs/nixpkgs-26.05-darwin`、`nix-darwin/nix-darwin/nix-darwin-26.05`、`nix-community/home-manager/release-26.05` (存在確認済み)。
- `nix.settings.experimental-features = ["nix-command" "flakes"]` は flake 側で宣言し、`/etc/nix/nix.conf` は触らない (nix-darwin が既知ハッシュ一致時のみ上書きする)。
- Kenya の Homebrew prefix は `/usr/local`。nix-darwin の `homebrew.prefix` は hostPlatform から既定値を導くので明示不要。
- `system.stateVersion` を各ホストで明示する。既定値 (`system.maxStateVersion`) のままだと `modules/system/version.nix:139` の assertion で評価が落ちる。

### 3.2 `homebrew` モジュール

- `homebrew.taps = ["rjyo/moshi"]`、`homebrew.brews = [{ name = "rjyo/moshi/moshi-hook"; trusted = true; restart_service = "changed"; }]`。Homebrew に残す唯一の formula。
- `homebrew.casks`: 3 台共通 22 個 (§4.4)。ホスト差分は `hosts/*.nix`。
- `homebrew.masApps = { "AdGuard Mini" = 1440147259; … }` (14 個)。
- `homebrew.onActivation = { autoUpdate = false; upgrade = false; cleanup = "none"; }` で開始し、Nix 側が安定したら `cleanup = "uninstall"` に上げて残存 formulae を一括削除。`zap` は使わない (cask 設定まで消える)。
- `homebrew.global.autoUpdate = false`。`homebrew.caskArgs` に `--no-quarantine` は入れない (CLAUDE.md の cask quarantine 節どおり)。

### 3.3 unfree

`nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "claude-code" "grok-build" "antigravity-cli" ];` を 3 台に。

### 3.4 フォント

cask 3 つ (`font-symbols-only-nerd-font` / `font-ipaexfont` / `font-noto-sans-symbols-2`) → `fonts.packages = [ nerd-fonts.symbols-only ipaexfont noto-fonts ]`。

### 3.5 claude-code: unstable の package.nix を 3 台共通で `callPackage`

Kenya の 26.05 は 2.1.223 で凍結しているため、3 台とも unstable の `package.nix` をそのホストの stdenv でビルドする。`modules/packages.nix` の抜粋:

```nix
{ inputs, lib, pkgs, ... }:
let
  # claude-code from nixpkgs-unstable on every host. Kenya's nixpkgs is 26.05,
  # whose claude-code is frozen at 2.1.223, so build unstable's package.nix with
  # 26.05's stdenv instead. Upstream still ships darwin-x64 binaries; only the
  # meta.platforms declaration in unstable dropped x86_64-darwin.
  claude-code =
    (pkgs.callPackage "${inputs.nixpkgs}/pkgs/by-name/cl/claude-code/package.nix" { }).overrideAttrs
      (old: {
        meta = old.meta // {
          platforms = old.meta.platforms ++ [ "x86_64-darwin" ];
        };
      });
in
{
  environment.systemPackages = [ claude-code ] ++ (with pkgs; [ … ]);
}
```

- overlay ではなく `let` 束縛にする。使う箇所が `environment.systemPackages` の 1 か所だけで、`pkgs.claude-code` を差し替えて他モジュールから参照させる必要がない。arm 2 台では unstable の `pkgs.claude-code` と同じ derivation になる。
- `inputs.nixpkgs` (unstable) は**ファイルパスとして参照するだけ**なので、x86_64-darwin で unstable を `import` したときの eval エラー (PR #492189) は起きない。
- 成立条件 (2026-09-19 確認済み): upstream の `downloads.claude.ai/claude-code-releases/<ver>/manifest.json` と unstable の `manifest.zst.json` の両方に `darwin-x64` がある。unstable の `package.nix` が要求する `zstd` / `makeBinaryWrapper` / `versionCheckHook` / `writableTmpDirAsHomeHook` / `stdenv.hostPlatform.node.platform` は 26.05 にもある。
- Darwin では `__noChroot = true` を使うため Nix の `sandbox = true` ではビルドできない。両インストーラーは macOS で sandbox を有効にしないが、Phase 1 で `nix config show sandbox` を確認する。
- nixpkgs 版は `DISABLE_AUTOUPDATER=1` でラップされ自己更新しない。更新は `darwin-rebuild switch` (= `.sync`) のタイミングに揃う。
- **フォールバック** (今日時点では非該当): unstable の `package.nix` が 26.05 にない依存を要求し始めた場合、または upstream が `darwin-x64` の配布をやめた場合は、upstream の `manifest.json` (非圧縮 `claude` + checksum の旧形式) を `nix/pkgs/claude-code-manifest.json` に vendoring し、26.05 の `pkgs.claude-code.override { manifest = lib.importJSON ./…; }` に切り替える。26.05 の `package.nix` は zst 形式の manifest とは互換がない。
- この手は grok-build / antigravity-cli には**使えない**。どちらも `platforms = lib.attrNames sourceData` で、`sourceData` に x86_64-darwin のハッシュがない (upstream は Intel 版を配っている)。meta の書き換えでは足りず package.nix 全体の vendoring になるので、利用頻度の低さからやらない。

### 3.6 Touch ID sudo (`/etc/pam.d/sudo_local`)

これまで手作業だった `sudo cp /etc/pam.d/sudo_local{.template,}` + `pam_reattach.so` / `pam_tid.so` の追記を宣言に置き換える。

```nix
security.pam.services.sudo_local = {
  touchIdAuth = true;   # pam_tid.so
  reattach = true;      # tmux/screen 内でも効かせる
};
```

nix-darwin の `modules/security/pam.nix` が `/etc/pam.d/sudo_local` を生成し、`pkgs.pam-reattach` も自身で引く。そのため `environment.systemPackages` に入れる必要はない (§4.1)。

## 4. Brewfile → Nix マッピング

nixpkgs-unstable の `packages.json` (2026-09 取得) で照合。Brewfile の `brew` 207 行を、leaf として移すもの / 依存として落とすもの / 名前が変わるもの / Nix にないもの に分類した。

### 4.1 名前が変わるもの

| Brewfile | nixpkgs attr |
|---|---|
| node | `nodejs` |
| kubernetes-cli | `kubectl` |
| git-delta | `delta` |
| openjdk / openjdk@21 | `jdk` / `jdk21` |
| openssl@3 | `openssl` (依存のみ、通常は不要) |
| mysql-client | `mysql84` (CLI が要るなら) |
| tree-sitter-cli | `tree-sitter` |
| powerlevel10k | `zsh-powerlevel10k` |
| jd | `jd-diff-patch` |
| docker-credential-helper | `docker-credential-helpers` |
| source-highlight | `sourceHighlight` |
| rust | **移さない** (§1 Rust) |
| helm | `kubernetes-helm` |
| argo | `argo-workflows` |
| pam-reattach | **移さない** — `security.pam.services.sudo_local` が `pkgs.pam-reattach` を引く (§3.6) |
| ca-certificates | `cacert` (依存のみ) |
| bdw-gc | `boehmgc` (依存のみ) |
| jpeg-xl | `libjxl` (依存のみ) |
| libxmlsec1 | `xmlsec` (依存のみ) |
| telnet | `inetutils` |
| googleworkspace-cli | `gws` |
| cask gcloud-cli (CA-20031962 は cask google-cloud-sdk) | `google-cloud-sdk`。`bin/{gcloud,bq,gsutil,docker-credential-gcloud}` と `share/zsh/site-functions/_gcloud` を出す。`disable_updater` 済みなので `gcloud components` は使えず、追加コンポーネントは `google-cloud-sdk.withExtraComponents`。現在入っている追加コンポーネント (gsutil / gcloud-crc32c) はどちらも同梱 |

### 4.2 Nix にないもの

| Brewfile | 方針 |
|---|---|
| `rjyo/moshi/moshi-hook` | `homebrew.brews` に残す (§3.2) |
| gcviewer / showkey / socket_vmnet / utimer | Phase 0-0 で `brew uninstall` + Brewfile から除去。Nix 側には何も書かない |
| `neurosnap/tap/zmx` | nixpkgs に `zmx` あり → Nix 側。tap は不要になる (同一物か `nix run nixpkgs#zmx -- --version` で確認) |

### 4.3 依存としてしか使っていない行 → Nix リストから落とす (Nix はランタイム依存を自動で持つ)

abseil avro-c bdw-gc boost brotli c-ares ca-certificates cairo certifi cryptography fontconfig freetype gettext giflib glib gmp gnutls harfbuzz imath krb5 libevent libffi libfido2 libgit2 libidn2 libnghttp2 libpng libpq librdkafka libssh libtasn1 libtiff libtool libunistring libuv libyaml libzip little-cms2 luajit luv lz4 lzo m4 mpdecimal ncurses nettle oniguruma openexr openjpeg openssl@3 p11-kit pcre pcre2 pixman pkgconf pycparser re2 snappy unibilium utf8proc webp xz zstd libiconv libtermkey msgpack gdbm guile autoconf libdvdcss librist freetds

約 70 行が消え、`environment.systemPackages` は 120 前後になる。

### 4.4 leaf として Nix へ移すもの (nixpkgs attr)

argocd asciinema atuin awscli bash bat bat-extras bk btop buf caddy cbonsai cloudflare-speed-cli cmatrix colima colordiff container coreutils devcontainer direnv docker docker-buildx docker-compose docker-credential-helpers duckdb exiftool eza fastfetch fd ffmpeg fzf gawk gh ghq delta glow gnupg go google-cloud-sdk google-java-format gws gping gradle protobuf grpc grpcurl kubernetes-helm herdr hey htop hunk imagemagick jd-diff-patch jq jwt-cli k9s kcat kubectl kubectl-tree lazydocker lazygit lefthook litecli lolcat luarocks mas maven mermaid-cli minikube mise mosh mycli mysql84 tree-sitter neovim nkf nmap nyancat ripgrep opencode codex jdk jdk21 pandoc pgcli pnpm ponysay poppler zsh-powerlevel10k pwgen qemu rustup skills sl socat sops sourceHighlight starship stern stow stylua inetutils tfenv tldr tmux translate-shell tree ttyd unbound uv viddy vivid watch wget worktrunk yamlfmt yazi yq zellij zoxide zsh-autosuggestions zsh-syntax-highlighting zsh-you-should-use zmx nodejs

- `go "…"` 5 行 → `delve gopls gotools golangci-lint go-tools` (staticcheck は go-tools)。`GOPATH=$HOME/Projects` は維持。
- `uv "…"` 4 行 → `ruff sqlfluff python313Packages.ipython python313Packages.docutils`。
- `npm "…"` 3 行 → `biome prettier pi-coding-agent`。
- `rustup component add rust-analyzer` は従来通り (CLAUDE.md メモ)。
- `grok-build` `antigravity-cli` は `lib.optionals stdenv.hostPlatform.isAarch64 [ grok-build antigravity-cli ]` で arm 2 台に限定する。unstable の `package.nix` が aarch64-darwin のハッシュしか持たず、26.05 は antigravity-cli を欠く。Kenya の grok-build だけ 26.05 の `grok-build` (0.2.93) を `hosts/Kenya.nix` に置く。
- CLI 系 cask 4 つ (`claude-code@latest` `codex` `grok-build` `antigravity-cli`) はここに含めた。`codex` は cask だが CLI で、GUI は別 cask `codex-app` (Kenya のみ)。
- 残る cask は 3 台共通で 22 個 (元 30 個 − フォント 3 − gcloud-cli − CLI 4)。

## 5. 段階的ロールアウト

### Phase 0-0: Nix にない formula を先に捨てる (3 台、Nix 導入前)

```sh
brew services list | grep socket_vmnet          # サービス登録があれば先に止める
sudo brew services stop socket_vmnet 2>/dev/null || true
brew uninstall gcviewer showkey socket_vmnet utimer
brew autoremove                                  # 4 つだけが使っていた依存を掃除 (openjdk 等は他が使うので残る)
```

- Brewfile から該当 4 行 (コメント行込み) を削除してコミット `chore(homebrew): drop formulae with no nixpkgs equivalent`。
- 残り 2 台は `git pull` 後に同じ `brew uninstall` を実行 (`brew bundle cleanup` は他の drift も一緒に消すので使わない)。
- `socket_vmnet` は `/opt/homebrew/var/run/socket_vmnet` のソケットと launchd plist を持つ。`brew services` 登録があれば uninstall 前に stop しないと plist が残る。

### Phase 0: リポジトリ準備 (Nix 未導入でも書ける)

1. `nix/` を §3 のとおり追加。まず `hosts/CA-20033978.nix` のみ。`environment.systemPackages` は空、`homebrew.enable = false`。
2. この端末の stow リンク切れを直す: `~/.config/starship.toml` (実ファイル) と `~/.config/mise` (空ディレクトリ) を repo と diff → 差分なければ削除して `STOW_FLAGS=--restow sh install.darwin.sh`。
3. コミット `feat(nix): scaffold nix-darwin flake for CA-20033978`。

### Phase 1: この端末 (CA-20033978) に Nix + nix-darwin 最小構成

```sh
curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes
# 新しいシェルで
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/Projects/src/github.com/satoshiyamamoto/dotfiles/nix
```

検証: `darwin-rebuild --list-generations`、`nix doctor`、`nix config show sandbox` が `false` または `relaxed` (§3.5)、新シェルで `echo $PATH` に `/run/current-system/sw/bin` と `/etc/profiles/per-user/a12019/bin` が入ること。brew はまだ全部残っているので日常作業に影響なし。

### Phase 2: この端末でパッケージ移行

1. `modules/packages.nix` に §4.4 と §3.5 を投入、`darwin-rebuild switch`。brew と Nix が両方 PATH にある状態で `.zprofile` の path 順を Nix 優先にし (§6)、1〜2 日使う。`claude` の実体が `/opt/homebrew/bin/claude` から `/run/current-system/sw/bin/claude` に変わるので、`grep -r '/opt/homebrew/bin/claude'` で claudecode.nvim / sidekick.nvim / moshi-hook 等が絶対パスを持っていないか確認する。
2. `.zshrc` / `.zprofile` の Homebrew 依存を §6 のとおり書き換え、`exec zsh` で検証。
3. `homebrew.enable = true` + §3.2 (cleanup = "none") を投入、`darwin-rebuild switch` が内部で `brew bundle` を走らせるのを確認。`homebrew` stow パッケージから Brewfile / `trust.json` / `trust.json.lock` を外す (`curlrc` は残す)。
4. 問題なければ `cleanup = "uninstall"` にして switch。`brew list --formula` が moshi-hook だけになることを確認。
5. `.sync` を `sudo darwin-rebuild switch --flake "$dotfiles_dir/nix"` に差し替え (§6)。
6. CLAUDE.md 更新 (§7)。

### Phase 3: CA-20031962 (a12019, arm)

`git pull` → `hosts/CA-20031962.nix` (graphviz / handbrake を追加。cask `google-cloud-sdk` は共通の Nix パッケージに吸収されるので書かない) → Phase 1 と同じインストーラー → `darwin-rebuild switch`。Phase 2 の内容は既に main に入っているので 1 回で終わる想定。

### Phase 4: Kenya (satoshi, x86_64, 26.05 固定)

```sh
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh   # multi-user を選ぶ
sudo nix --extra-experimental-features "nix-command flakes" \
  run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake ~/Projects/src/github.com/satoshiyamamoto/dotfiles/nix
```

- 事前に `git pull` して遅れを解消。
- `hosts/Kenya.nix` は 26.05 系 inputs で組む。§4.4 のうち 26.05 にない / x86_64-darwin で壊れているパッケージが出たら、その場で `homebrew.brews` にフォールバック (推測で外さず、`nix build` のエラーで判断)。
- switch 前に `darwin-rebuild build --flake …#Kenya && ./result/sw/bin/claude --version` で claude-code を通す (§3.5 は `let` 束縛なので `pkgs.claude-code` は 26.05 の 2.1.223 を指し、単体 `nix build` の対象にならない)。失敗したら §3.5 のフォールバックへ。
- AI エージェント CLI は 26.05 の版になる: codex 0.146.0、opencode 1.15.10、pi-coding-agent 0.75.4、skills 1.5.7、grok-build 0.2.93 (いずれも x86_64-darwin の Hydra キャッシュあり、ローカルビルドなし)。grok-build は 1.0.34 → 0.2.93 の大幅な戻りなので switch 後に `grok --version` と一度の対話で動作確認し、壊れていれば cask に戻さず**外す**。antigravity-cli (`agy`) は Kenya では外す (GUI の `antigravity` cask は残す)。
- `/opt/homebrew -> /usr/local` リンクは `.zprofile` 修正後に不要になるので、動作確認後に削除。
- hermes gateway は brew 非依存 (§10.3)、moshi-hook は `homebrew.brews` で継続。

### Phase 5: Stow → home-manager `home.file` (別計画)

`install.darwin.sh` の stow 一覧を `home.file` に写す。`.sync` の stow 行が消え、`darwin-rebuild switch` 1 本になる。

### 新端末 (Apple Silicon) の初期セットアップ

`~/Documents/knowledge/macos-setup.md` の「パッケージ管理」節は移行後こうなる。システム設定・ネットワーク設定・秘密鍵のコピー・Font Book (Operator Mono) は従来どおり。

```sh
xcode-select --install                                 # git のため

# Homebrew は先に入れる (GUI cask / mas 専用バックエンドとして残る)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

mkdir -p ~/Projects/{bin,pkg,src}
mkdir -p ~/Projects/src/github.com/satoshiyamamoto
git clone git@github.com:satoshiyamamoto/dotfiles.git

scutil --get LocalHostName                             # → nix/hosts/<hostname>.nix を追加し
                                                       #   flake.nix にキーを足して git add (commit 推奨)

curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes
# 新しいシェルで
sudo nix run nix-darwin/master#darwin-rebuild -- \
  switch --flake ~/Projects/src/github.com/satoshiyamamoto/dotfiles/nix

sh install.darwin.sh                                   # Phase 5 までは stow が残る
atuin login && atuin sync --force
gh auth login && gh extension install dlvhdr/gh-dash
```

- **Homebrew を先に入れる**こと。nix-darwin の `homebrew` モジュールは brew を導入しない。`modules/homebrew.nix:1032-1036` は `${prefix}/bin/brew` がなければ `error: Homebrew is not installed, skipping...` を出すだけで switch 自体は成功するため、cask と mas が黙って入らない。
- flake は git 管理外のファイルを無視する。`hosts/<hostname>.nix` を `git add` しないと `darwin-rebuild` がその構成を見つけられない。
- `mas` は同モジュールが自前で PATH に足す (`modules/homebrew.nix:181`) ので、masApps のために入れる必要はない (§4.4 には別用途で入れている)。
- 2 回目以降の更新は `.sync` (= `darwin-rebuild switch`) だけ。`brew bundle` を手で叩く手順は消える。
- Touch ID sudo の手編集も消える (§3.6)。

## 6. dotfiles 側の変更 (Phase 2 で実施)

### `zsh/.zprofile`

| 行 | 現在 | 変更 |
|---|---|---|
| 14 | `/opt/homebrew/bin/vivid generate …` | `vivid generate …` (PATH 解決) |
| 29-42 `path=(…)` | `/opt/homebrew/opt/mysql-client/bin`、`/opt/homebrew/opt/rustup/bin`、`/opt/homebrew/{,s}bin` | 先頭に `/etc/profiles/per-user/$USER/bin(N)` と `/run/current-system/sw/bin(N)` を追加。`mysql-client` / `rustup` の opt 行は削除 (Nix は bin に直接出す)。`/opt/homebrew/{,s}bin(N)` は残す (brew 本体と `moshi-hook`、cask が bin に出す CLI 用)。Kenya は `/usr/local/{,s}bin(N)` が既にある |
| 44-49 `## Homebrew` | `HOMEBREW_PREFIX='/opt/homebrew'` 決め打ち | `HOMEBREW_PREFIX` 行を削除 (brew 自身が shellenv で決める。Kenya は `/usr/local`)。`HOMEBREW_BUNDLE_MAS_SKIP` は削除 (nix-darwin が Brewfile を生成する)。`HOMEBREW_CURLRC`、`HOMEBREW_NO_ENV_HINTS`、`HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS` は残す |
| 70 `## Claude Code` | `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE=1` | **削除**。nixpkgs 版は `DISABLE_AUTOUPDATER=1` でラップされるので意味を持たない。`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` は残す |

### `zsh/.zshrc`

| 行 | 現在 | 変更 |
|---|---|---|
| 33 | `$HOMEBREW_PREFIX/share/zsh/site-functions(N)` | `/run/current-system/sw/share/zsh/site-functions(N)` (nix-darwin が補完を集約) |
| 56-58 | `$HOMEBREW_PREFIX/share/zsh-*` | `/run/current-system/sw/share/zsh-autosuggestions/zsh-autosuggestions.zsh`、`…/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh`、`…/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh` (nixpkgs の配置。`nix build nixpkgs#zsh-you-should-use && ls result/share` で確定させる) |
| 59-61 | gcloud `path.zsh.inc` / `completion.zsh.inc` と `z.sh` | **削除**。nixpkgs `google-cloud-sdk` は `bin/gcloud` を PATH に、補完を `share/zsh/site-functions/_gcloud` (`#compdef` 付き) に出すので、行 33 の fpath 変更だけで補完が効く。`z.sh` は 3 台とも存在しないデッド行 (z は zoxide が代替) |
| 104-107 `.sync` | `STOW_FLAGS=--restow sh install.darwin.sh` + `brew bundle -g` | stow 行は維持、`brew bundle -g` を `sudo darwin-rebuild switch --flake "$dotfiles_dir/nix"` に置換 |

### その他

- `docker/.docker/config.json`: `cliPluginsExtraDirs` の `/opt/homebrew/lib/docker/cli-plugins` → Nix の `docker-buildx` / `docker-compose` は `$out/libexec/docker/cli-plugins` に出るので、home-manager 側で `~/.docker/cli-plugins` にリンクするか `/run/current-system/sw/libexec/docker/cli-plugins` を指す (実パスは build 後に確認)。
- `homebrew/` stow パッケージ: `Brewfile`、`trust.json`、`trust.json.lock` を `git rm` し `curlrc` のみ残す。`.gitignore` に `homebrew/.config/homebrew/trust.json*` を追加 (brew が `~/.config/homebrew/` に書き続けるため、stow 経由で repo に現れないように)。`Brewfile.lock.json` の行は不要になる。Brewfile ごと消えるので `brew "rust"` や CLI 系 cask の行単位削除は発生しない。
- `install.darwin.sh`: stow 一覧はそのまま。末尾に `darwin-rebuild` は足さない (初回は `nix run` 経由、以後は `.sync`)。
- `install.sh` (Linux): 変更なし。

## 7. CLAUDE.md の更新点

- 「Homebrew / Brewfile」節を「Nix (nix-darwin)」節に置き換え: `nix/` 構成、`sudo darwin-rebuild switch --flake …/nix`、Kenya は 26.05 固定で EOL 2026-12-31、x86_64-darwin は unstable にない。
- 「node comes from Homebrew, not mise」→「node comes from nixpkgs (`nodejs`), not mise」。理由 (mise の config.toml が stow 管理) は同じ。
- hermes の ffmpeg 記述を「installer は `command -v rg` / `command -v ffmpeg` / `command -v git` で探し、見つかれば brew を呼ばない。`ripgrep` / `ffmpeg` / `git` は `modules/packages.nix` に置き、インストーラーは Nix パスが PATH に入ったログインシェルから実行する」に。
- moshi-hook: brew launchd service は継続、宣言場所が `modules/homebrew.nix` の `brews` に変わる。
- cask quarantine 節: そのまま有効。`homebrew.caskArgs` に `--no-quarantine` を入れない旨を 1 行追加。
- kulala / tree-sitter-cli 節: `brew "tree-sitter-cli"` → `tree-sitter` (nixpkgs)。
- claude-code / codex 等の AI エージェント CLI は nixpkgs 版で自己更新しない旨を追加。

## 8. 検証

- 各 Phase 後: `darwin-rebuild --list-generations`、`which -a <tool>` で Nix 側が先に来ること、`brew list --formula` の残り、`darwin-rebuild switch` の `brew bundle` 出力。
- zsh: `exec zsh` 後の起動時間 (`zprof`)、`type __load_plugins` 後の `bindkey` で autosuggestions が生きていること。
- nvim: `nvim --headless "+Lazy! sync" +qa`、`:checkhealth` で tree-sitter CLI / node / ripgrep / fd が Nix パスで検出されること。
- moshi-hook: `moshi-hook servers`、`launchctl list | grep moshi`。
- hermes: `hermes doctor`、gateway の launchd が生きていること (Kenya)。
- docker: `docker buildx version`、`docker compose version`。
- claude-code: `claude --version` が unstable の版 (3 台同じ) であること。

## 9. ロールバック

- nix-darwin の世代戻し: `darwin-rebuild --list-generations` → `sudo darwin-rebuild switch --rollback` (または `--switch-generation N`)。
- nix-darwin 撤去: `sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin#darwin-uninstaller` (Kenya は `nix-darwin/nix-darwin-26.05#darwin-uninstaller`)。
- Nix 本体撤去: arm 2 台は `/nix/nix-installer uninstall`。Kenya は公式手順 (`/etc/zshrc` 等の `.backup-before-nix` 復元、launchd 2 本、`_nixbld` ユーザー/グループ、`synthetic.conf`、fstab、`diskutil apfs deleteVolume /nix`)。**nix-darwin を消す前に Nix を消さない** (ネットワーク設定が壊れる既知の quirk)。
- Homebrew は `cleanup = "uninstall"` を入れるまで formulae が残るので、Phase 2-4 より前ならロールバックコストはゼロ。それ以降は `git show <rev>:homebrew/.config/homebrew/Brewfile > /tmp/Brewfile && brew bundle --file=/tmp/Brewfile` で復元可能。

## 10. 判断根拠 (2026-09-19 実測)

### 10.1 x86_64-darwin の現状

- nixpkgs master/unstable は `x86_64-darwin` を削除済み (bd832325 "lib/systems/doubles: drop x86_64-darwin"、PR #492189 で評価時エラー化、2026-06)。`nixpkgs-26.05-darwin` にはまだ残る (`lib/systems/doubles.nix:14`)。
- インストーラー: Determinate は 2025-10 に Intel ビルド停止 (#1693)、NixOS/nix-installer は 2.35.1 (2026-07-15) から `nix-installer-x86_64-darwin` を配布せず、Lix installer は Intel 非サポートを警告。公式 `nixos.org/nix/install` は `nix-2.35.2-x86_64-darwin.tar.xz` を配布中。

### 10.2 AI エージェント CLI の版と遅れ

claude-code (upstream 最新 2.1.277、09-18):

| 経路 | 版 | 遅れ |
|---|---|---|
| cask `claude-code@latest` + 自己更新 (移行前) | 2.1.277 | 0 日 |
| nixpkgs master | 2.1.276 | 1 日 / 1 版 |
| nixpkgs-unstable チャンネル (arm 2 台が引く先) | 2.1.272 | 4 日 / 5 版 |
| nixpkgs 26.05 | 2.1.223 | 6 週 / 54 版、以後凍結 |

upstream はほぼ毎日リリース (08-12〜09-18 で 40 版)。nixpkgs master の bump は 1〜3 日おき、master → unstable チャンネルで +2〜3 日。定常的な遅れは **3〜5 日 / 3〜5 版**。nixpkgs `claude-code` は master で `meta.platforms` から `x86_64-darwin` を外している (2026-07-14) が、manifest とビルド手順は Intel 対応のまま。

その他:

| ツール | Brewfile | upstream 最新 | nixpkgs master | unstable チャンネル | 26.05 (Kenya) | nixpkgs のビルド方式 |
|---|---|---|---|---|---|---|
| codex | cask 0.154.0 | 0.155.1 (09-18) | 0.154.0 | 0.154.0 | 0.146.0 | `rustPlatform.buildRustPackage` (ソース)。bump は週 1 回程度 |
| opencode | brew 1.18.30 | 1.18.31 (09-14) | 1.18.31 | 1.18.30 | 1.15.10 | `stdenv.mkDerivation` + bun (ソース)、unstable は aarch64-darwin のみ |
| pi-coding-agent | npm | 0.85.1 (09-05) | 0.85.1 | 0.85.1 | 0.75.4 | `buildNpmPackage` |
| skills | brew 1.5.26 | 1.7.0 (09-17) | 1.6.0 | 1.6.0 | 1.5.7 | `stdenv.mkDerivation` (fetchFromGitHub) |
| grok-build | cask 1.0.34 | 1.0.34 | 1.0.34 | 1.0.13 | 0.2.93 | バイナリ fetchurl (unfree)。unstable は x86_64-darwin なし、26.05 はあり |
| antigravity-cli | cask 1.2.6 (`auto_updates`) | 1.2.6 | 1.2.3 | 1.2.3 | なし | バイナリ fetchurl (unfree)。x86_64-darwin なし |

- codex を Kenya で unstable からソースビルドすると、x86_64-darwin の unstable にキャッシュがないため i7 で毎回 Rust コンパイルになる。26.05 の 0.146.0 を採る。
- upstream は grok-build (`grok-<ver>-macos-x86_64`) と antigravity-cli (`darwin-x64`) の Intel 版を配っているが、nixpkgs の `sourceData` にハッシュがない (§3.5 末尾)。

### 10.3 hermes の brew 依存

公式 `install.sh` (3945 行) を取得して確認。`install_system_packages()` は `command -v rg` / `command -v ffmpeg` で探し、両方見つかれば brew を呼ばない。見つからない場合だけ macOS で `brew install ripgrep ffmpeg`。git も `attempt_install_git()` が `command -v git` を先に見る。`hermes doctor` (`hermes_cli/doctor.py`) も `shutil.which` で検出し、`brew install <pkg>` は案内文の文言にすぎない。→ Nix の `ripgrep` / `ffmpeg` / `git` が PATH にあれば Homebrew 側は不要。

### 10.4 gcloud

nixpkgs `google-cloud-sdk`: unstable 583.0.0 (aarch64-darwin)、26.05 565.0.0 (x86_64-darwin あり)。cask は 569.0.0。追加コンポーネント gsutil / gcloud-crc32c はどちらも同梱。
