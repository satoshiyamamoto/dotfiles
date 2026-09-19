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

判断根拠となる実測値は §11 にまとめた。

### この計画を一度立て直した理由 (2026-09-19)

Phase 1 の初回 switch で想定外が 3 件出た。activation が `/etc/pam.d/sudo_local` で中断し、`/etc/zshrc` が nix-darwin 生成物に置き換わって `zsh-defer compinit -C` が無効化され、`nix` が PATH に 2 つ並んだ。いずれも原因は同じで、**自分が書くつもりのオプション (`homebrew.*`, `security.pam.*`) だけを事前調査し、既定で有効になるオプションを調査しなかった**ことにある。`security.pam.services.sudo_local.enable` / `programs.zsh.enable` / `nix.enable` はどれも既定 `true` で、設定ファイルに一行も書かなくても効く。

さらに悪いことに、「既定が `true` のオプション」を全列挙しても 3 件目は捕まらない。`environment.profiles` は真偽値ではなく**既定値が空でないリスト**で、その中身 (`/nix/var/nix/profiles/default`) が nix 二重化の直接原因だった (§3.8)。オプションの型を見るだけでは足りず、**効果面 (`environment.etc` / `activationScripts` / `launchd` / `environment.systemPath`) を評価して読む**必要がある。

再発防止として §5「切り替え前監査」を全フェーズ共通の必須手順として追加した。上の 3 件はすべて §5 を回していれば switch 前に見えていたものである。

## 2. 対象端末 (2026-09-19 SSH 実測)

| ホスト | user | CPU | macOS | brew | 特記 |
|---|---|---|---|---|---|
| CA-20033978 (この端末) | a12019 | M4 / arm64 | 26.6.2 | 7.0.4 `/opt/homebrew`、304 formulae / 28 casks | `~/.config/starship.toml` が実ファイル、`~/.config/mise` が空の実ディレクトリ (stow リンク切れ)。追加 cask: intellij-idea。moshi-hook サービス稼働。bundle check で drift (codex, argo, snappy, awscli, node, openjdk, gradle, openexr, mise, mycli, skills, uv) |
| CA-20031962 | a12019 | M4 Max / arm64 | 26.6.2 | 7.0.4、317 / 29 | stow 正常。追加 formula: graphviz。追加 tap: neurosnap/tap (zmx の供給元)。追加 cask: google-cloud-sdk (共通 Brewfile の `gcloud-cli` とは別名の同一 SDK)。`handbrake` も入っているが共通 Brewfile の `handbrake-app` の旧名で別物ではない。go pkgs / moshi-hook 未導入 (**訂正 2026-09-19**: 当初「zmx 未導入」と記録したが誤りで、`neurosnap/tap` から導入済みだった。Phase 3 で判明) |
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
    CA-20031962.nix      同上 (graphviz は不要と判断し引き継がない)
    Kenya.nix            nixpkgs.hostPlatform = "x86_64-darwin"; primaryUser = "satoshi"
                         (26.05 系 inputs、+ code-minimap / helm-ls / z / antigravity / codex-app)
  modules/
    common.nix           全ホスト共通: stateVersion / experimental-features / programs.zsh /
                         security.pam (ホスト固有は hosts/ に残す)
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

- `homebrew.taps = ["rjyo/moshi"]`、`homebrew.brews = [{ name = "rjyo/moshi/moshi-hook"; restart_service = "changed"; }]`。Homebrew に残す唯一の formula。`trusted` は書かない — nix-darwin の `modules/homebrew.nix:547` で `default = true` で、完全修飾名にだけ効く。
- `homebrew.casks`: 3 台共通 18 個 (§4.4)。ホスト差分は `hosts/*.nix`。現時点でホスト固有の cask は無い。
- `homebrew.masApps = { "AdGuard Mini" = 1440147259; … }` (14 個)。
- `homebrew.onActivation = { autoUpdate = false; upgrade = false; cleanup = "none"; }` で開始し、Nix 側が安定したら `cleanup = "uninstall"` に上げて残存 formulae を一括削除。`zap` は使わない (cask 設定まで消える)。
- `homebrew.global.autoUpdate = false`。`homebrew.caskArgs` に `--no-quarantine` は入れない (CLAUDE.md の cask quarantine 節どおり)。

#### このモジュールが実際にやること (2026-09-19 実測)

`homebrew.enable = true` の実体は activation スクリプト 1 本だけで、`environment.etc` にも `launchd.daemons` にも `launchd.user.agents` にも何も足さない (§5.3 の `extendModules` で確認済み)。つまり Phase 2 に「既定で有効になる隠れオプション」の類は無い。危険なのは生成されるコマンドそのもの:

```sh
PATH="/opt/homebrew/bin:/nix/store/…-mas-7.0.0/bin:$PATH" sudo --preserve-env=PATH \
  --user=a12019 --set-home env HOMEBREW_NO_AUTO_UPDATE=1 \
  brew bundle --file='/nix/store/…-Brewfile' --no-upgrade
```

- **`--file` が nix store の生成物になるので、リポジトリの `homebrew/.config/homebrew/Brewfile` は参照されなくなる。** `.sync` の `brew bundle -g` (グローバル Brewfile = stow リンク先) を残すと二重管理になるため、§7 のとおり同じ Phase で差し替える。
- `cleanup` を `"uninstall"` にすると `--cleanup --force-cleanup` が、`"zap"` にするとさらに `--zap` が付き、**宣言に無い formula / cask を switch のたびに削除する**。Phase 2-3 までは `"none"` のまま進め、`brew list --formula` を目視してから上げる。
- `mas` はモジュールが自前で PATH に足すので `environment.systemPackages` に入れる必要はない。

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

**これは Phase 2 ではなく Phase 1 で必要になる** (2026-09-19、CA-20033978 の初回 switch で判明)。理由は 2 つ:

1. `security.pam.services.sudo_local.enable` の既定が **true** (`modules/security/pam.nix:15-16`)。手書きの `/etc/pam.d/sudo_local` が既にあると activation が
   `error: Unexpected files in /etc, aborting activation` で中断するので、`sudo mv /etc/pam.d/sudo_local{,.before-nix-darwin}` が必須になる。
2. リネームしただけで `touchIdAuth` / `reattach` を入れずに switch すると、生成されるのは **0 バイトの空ファイル** (両オプションの既定は false、`pam.nix:64-67` が `lib.optional` で行を組み立てる)。Touch ID sudo がその場で壊れる。

つまりリネームと §3.6 の投入は**同じ switch で**行う。生成結果は手書き版と同じ 2 行で、`pam_reattach.so` のパスだけが `/opt/homebrew/lib/pam` から nix store に変わる。仮に store パスの読み込みに失敗しても `pam_reattach` は `optional` / `pam_tid` は `sufficient` なので、sudo はパスワード認証にフォールバックする (ロックアウトしない)。

**検証済み (2026-09-19, CA-20033978)**: 生成された `/etc/pam.d/sudo_local` は `/etc/static/pam.d/sudo_local` へのシンボリックリンクで、中身は予想どおり `pam_reattach.so` (nix store の `pam_reattach-1.3`) → `pam_tid.so` の 2 行。`/etc/pam.d/sudo` の 1 行目が `auth include sudo_local` なので順序も保たれている。`sudo -k; sudo true` が **tmux の外でも中でも** Touch ID を出すことを確認した。Phase 3 / 4 でも同じ結果を期待してよい。

tmux 内の確認は `tmux new-session -d -s … 'sudo true'` では**できない**。クライアントが繋がっていないと sudo に prompt を出す TTY が無く、コマンドが即終了してセッションごと消える。対話的にアタッチして手で打つこと。

### 3.7 `/etc/zshrc` と compinit の二重実行

`programs.zsh.enable` の既定は **true** (`modules/programs/zsh/default.nix:19-21`) で、nix-darwin が `/etc/zshrc` を生成する。これは `~/.zshrc` より先に読まれ、既定では次を実行する:

```zsh
autoload -U promptinit && promptinit && prompt suse && setopt prompt_sp
autoload -U compinit && compinit      # -C なし・同期実行
autoload -U bashcompinit && bashcompinit
```

`zsh/.zshrc:49` は `zsh-defer compinit -C` で意図的に遅延・キャッシュ利用しているので、その前に素の `compinit` が走ると遅延化が丸ごと無効になる。`prompt suse` は starship に上書きされるだけ無駄。よって切る:

```nix
programs.zsh = {
  enableCompletion = false;      # compinit は ~/.zshrc が zsh-defer で持つ
  enableBashCompletion = false;
  promptInit = "";               # prompt は starship
};
```

`programs.zsh.enable = false` は**不可**。生成される `/etc/zshenv` が `set-environment` を source して `/run/current-system/sw/bin` と `/nix/var/nix/profiles/default/bin` を PATH に入れているので、これを止めると §4 で入れる Nix パッケージが PATH に乗らない。`~/.zprofile` の `path=(...)` はその後に前置されるため Homebrew 優先の順序は保たれる。

history 設定 (`HISTSIZE=2000` 等) と `bindkey -e` も生成されるが、`~/.zshrc` が後から上書きするので放置でよい。

### 3.8 `nix.enable` は既定のまま / `nix config check` の FAIL は黙認する

インストーラーが入れる Nix は 2.35.2、`nixpkgs-unstable` の既定は 2.34.8。`nix.enable` の既定が true なので switch で後者に下がり、launchd daemon も nix-darwin 管理になる。インストールされているのは upstream Nix (Determinate Nix ではない) ので nix-darwin 管理は正規サポート内であり、nixpkgs がテストしている組み合わせなのでそのまま受け入れる。

`nix.enable = false` にすればインストーラー管理の 2.35.2 を維持できるが、`/etc/nix/nix.conf` が宣言的管理から外れて §3.1 の `nix.settings.*` が全部無効になるので採らない。新しめに寄せたい場合だけ `nix.package = pkgs.nixVersions.latest` を検討する。

#### nix が PATH に 2 つ並ぶ (黙認する)

上の結果、switch 後に `nix config check` (旧 `nix doctor`) が FAIL する:

```
[FAIL] Multiple versions of nix found in PATH:
  /nix/store/…-nix-2.35.2/bin   ← /nix/var/nix/profiles/default/bin (インストーラー)
  /nix/store/…-nix-2.34.8/bin   ← /run/current-system/sw/bin       (nix-darwin)
```

原因は 2 つのモジュールの既定値の組み合わせで、**設定ファイルには一行も書いていない**:

- `modules/nix/default.nix:730-736` — `nix.enable = true` が nixpkgs の nix を `environment.systemPackages` に入れる。
- `modules/environment/default.nix:145-148` — `environment.profiles` の既定が `[ "$HOME/.nix-profile" "/run/current-system/sw" "/nix/var/nix/profiles/default" ]`。3 つ目にインストーラーの nix が残っている。

nix-darwin は「既存のマルチユーザー Nix」を前提とするモジュールであり、NixOS/nix-installer・公式 nixos.org・Determinate・Lix のどれで入れてもこのプロファイルは作られる。**先に nix-darwin を入れておけば避けられた、という順序の問題ではない**。既定設定で nix-darwin を使う全員に起きる。

**この FAIL は黙認する。** 根拠:

- `environment.profiles` の並び順のおかげで `/run/current-system/sw/bin` が `/nix/var/nix/profiles/default/bin` より**前**に来る。実測でも `which nix` は 2.34.8 を返し、2.35.2 は完全にシャドウされていて呼ばれない。
- nix-darwin 作者 (LnL7) の見解として、nix-darwin 配下では宣言的に指定した Nix が常に優先されるのでこの警告は実際には問題ではなく、**古いインストールへロールバックできる余地を残すために意図的に消していない**と明言されている ([NixOS Discourse #19890](https://discourse.nixos.org/t/fail-multiple-versions-of-nix-found-in-path/19890))。
- `/nix/var/nix/profiles/default` はインストーラー版 nix の GC root でもある。消すと `/nix/nix-installer uninstall` の退路が細くなる (§10)。

消したくなった場合の手段は 2 つあるが、いずれも今は採らない:

1. `sudo -i nix-env -e nix` — 端末ごとの手作業で宣言に残らず、上の GC root も失う。
2. `environment.profiles = lib.mkForce [ "$HOME/.nix-profile" "/run/current-system/sw" ];` — 宣言的で 3 台に伝播する。**Discourse には `mkForce []` (空リスト) と書かれているが、それをそのまま写すと `/run/current-system/sw` まで落ちて全パッケージが PATH から消える。** 採用するなら残す 2 つを必ず明示すること。

日本語記事 (Zenn / Qiita) にこの件の解決策を扱ったものは 2026-09 時点で見当たらない。nix-darwin 導入記事はセットアップ手順で終わっており、`nix config check` を打つところまで書かれていない。

なお同じ出力に `[INFO] You are not trusted by store uri: daemon` も出る。現状は無害だが、Phase 2 以降で `nix.settings.substituters` を足すなら `nix.settings.trusted-users` に自分を入れる必要がある。

### 3.9 SSH: `enable` に関係なく置かれる 2 ファイル

`services.openssh.enable` の既定は `null` = 「macOS に任せる」で、`systemsetup -setremotelogin` は呼ばれない。しかし `services.openssh` と `programs.ssh` は **enable と無関係に** 設定ファイルを 2 つ置く。Phase 1 で実際に入った。

| ファイル | 生成元 | 中身 |
|---|---|---|
| `/etc/ssh/sshd_config.d/099-host-keys.conf` | `modules/services/openssh.nix:125` | `HostKey /etc/ssh/ssh_host_{rsa,ecdsa,ed25519}_key` |
| `/etc/ssh/sshd_config.d/101-authorized-keys.conf` | `modules/programs/ssh.nix:180-186` | `AuthorizedKeysCommand /bin/cat /etc/ssh/nix_authorized_keys.d/%u` + `AuthorizedKeysCommandUser _sshd` |

- macOS 既定の `100-macos.conf` とはファイル名が衝突しないので共存する。`sshd_config:19` の `Include /etc/ssh/sshd_config.d/*` は `UsePAM` 等より前にあり、既存設定は生きている。
- `099` は既存 4 本のうち dsa を落とすが、OpenSSH は DSA を廃止済みなので実害なし。**ただし該当の鍵が無い端末では `system.activationScripts.openssh` (`keygenScript`) が `ssh-keygen` で新規生成する。** 3 台とも 2025-07-14 の既存鍵を持つので今回は no-op だが、新端末では「nix-darwin が host key を作る」= 相手側の `known_hosts` が食い違う、という点を憶えておく。
- `101` の参照先 `/etc/ssh/nix_authorized_keys.d/` は `users.users.<name>.openssh.authorizedKeys` が空だと**生成されない**。sshd は `AuthorizedKeysFile` (`~/.ssh/authorized_keys`) を先に見て一致すればそこで終わるので公開鍵認証は壊れないが、一致しなかった場合に `/bin/cat` が失敗してログに出る。この端末は Remote Login 有効 (`com.openssh.sshd => enabled`)。
- 鍵を宣言的に置きたくなったら `users.users.a12019.openssh.authorizedKeys.keys` を使う。現状は使っていない。

### 3.10 `environment.pathsToLink`: nix-darwin の既定は NixOS より狭い

`modules/environment.nix` の既定は `[ "/share/zsh" "/info" "/share/info" "/share/man" "/share/terminfo" "/bin" "/share/locale" ]` だけで、NixOS のように `/share` を丸ごと張らない。`environment.systemPackages` に入れても、ここに無いサブパスは `/run/current-system/sw` に現れない。症状は「バイナリはあるのに相方の `share` / `libexec` が無い」で、パッケージ側の問題に見えるので紛らわしい。

Phase 2 step 1 で実際に 2 つ足りなかった (build 後に `ls` して判明、§7 の 2 行が依存する)。

```nix
environment.pathsToLink = [
  "/libexec/docker/cli-plugins"   # docker-buildx / docker-compose
  "/share/zsh-syntax-highlighting"
];
```

`/share/zsh` は既定にあるので、`zsh-autosuggestions` / `zsh-you-should-use` / `zsh-powerlevel10k` / 各種補完 (`share/zsh/site-functions`) は追加不要。

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
| bat-extras | `bat-extras.{batdiff,batgrep,batman,batpipe,batwatch,prettybat}` — nixpkgs では scope で、`bat-extras` 自体も `bat-extras.core` もインストール可能な derivation ではない (`core` は `cp -a . $out` でソースを置くだけ) |
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
| kcat | 同上。nixpkgs の `kcat` は aarch64-darwin でビルドできない — 依存の `libserdes` が `avro-c++` のヘッダを通せない (`Exception.hh` が `<fmt/core.h>` を include するが fmt 12 で `fmt::format` はそこから外れた)。`kcat/package.nix` に avro を切るオプションはない |
| `neurosnap/tap/zmx` | **使っていないので全端末から削除** (**訂正 2026-09-19**: 当初は nixpkgs の `zmx` へ移す方針だったが、そもそも不要と判明した)。`packages.nix` からも `zsh/.zshrc` の `zmx-sessions` ウィジェットと starship の `[env_var.ZMX_SESSION]` からも外した。tap も残らない。**switch 前に手で外すこと** — 後述 |

`zmx` が入ったままの端末では、`cleanup = "uninstall"` に任せてはいけない。Homebrew 6.0.0 以降は `HOMEBREW_REQUIRE_TAP_TRUST` が既定で有効で、cleanup は**未 trust の tap の formula を読み込めずに中断する**:

```
Error: Refusing to load formula neurosnap/tap/zmx from untrusted tap neurosnap/tap.
```

対話的な `brew trust` は `~/.config/homebrew/trust.json` に書くが、activation 下の brew は `sudo` が `XDG_CONFIG_HOME` を落とすため `~/.homebrew/trust.json` を読む (§3.2 / moshi-hook と同じ事情)。つまり trust を足しても activation 側に届くとは限らない。tap ごと手で消すのが確実で、消してしまえば cleanup が触る対象自体が無くなる:

```sh
brew trust neurosnap/tap     # uninstall が formula を読むために必要
brew uninstall zmx
brew untap neurosnap/tap
```

CA-20031962 で実際にここで止まった (Phase 3)。Kenya も `brew tap` に `neurosnap/tap` があれば同じ手順が要る。

### 4.3 依存としてしか使っていない行 → Nix リストから落とす (Nix はランタイム依存を自動で持つ)

abseil avro-c bdw-gc boost brotli c-ares ca-certificates cairo certifi cryptography fontconfig freetype gettext giflib glib gmp gnutls harfbuzz imath krb5 libevent libffi libfido2 libgit2 libidn2 libnghttp2 libpng libpq librdkafka libssh libtasn1 libtiff libtool libunistring libuv libyaml libzip little-cms2 luajit luv lz4 lzo m4 mpdecimal ncurses nettle oniguruma openexr openjpeg openssl@3 p11-kit pcre pcre2 pixman pkgconf pycparser re2 snappy unibilium utf8proc webp xz zstd libiconv libtermkey msgpack gdbm guile autoconf libdvdcss librist freetds lima

約 70 行が消え、`environment.systemPackages` は 120 前後になる。

### 4.4 leaf として Nix へ移すもの (nixpkgs attr)

argo-workflows argocd asciinema atuin awscli bash bat bat-extras.batdiff bat-extras.batgrep bat-extras.batman bat-extras.batpipe bat-extras.batwatch bat-extras.prettybat bk btop buf caddy cbonsai cloudflare-speed-cli cmatrix colima colordiff container coreutils devcontainer direnv docker docker-buildx docker-compose docker-credential-helpers duckdb exiftool eza fastfetch fd ffmpeg fzf gawk gh ghq delta glow gnupg go google-cloud-sdk google-java-format gws gping gradle protobuf grpc grpcurl kubernetes-helm herdr hey htop hunk imagemagick jd-diff-patch jq jwt-cli k9s kubectl kubectl-tree lazydocker lazygit lefthook litecli lolcat luarocks mas maven mermaid-cli minikube mise mosh mycli mysql84 tree-sitter neovim nkf nmap nyancat ripgrep opencode codex jdk jdk21 pandoc pgcli pnpm ponysay poppler zsh-powerlevel10k pwgen qemu rustup skills sl socat sops sourceHighlight starship stern stow stylua inetutils tfenv tldr tmux translate-shell tree ttyd unbound uv viddy watch wget worktrunk yamlfmt yazi yq zellij zoxide zsh-autosuggestions zsh-syntax-highlighting zsh-you-should-use nodejs

- `go "…"` 5 行 → `delve gopls gotools golangci-lint go-tools` (staticcheck は go-tools)。`GOPATH=$HOME/Projects` は維持。
- `uv "…"` 4 行 → `ruff sqlfluff python313Packages.ipython python313Packages.docutils`。
- `npm "…"` 3 行 → `biome prettier pi-coding-agent`。
- `rustup component add rust-analyzer` は従来通り (CLAUDE.md メモ)。
- `vivid` は移さない。`.zprofile` の `LS_COLORS` 生成が唯一の利用元で、その配線ごと落とした (`060fd5e`)。`eza` は自前の配色を持つ。
- `grok-build` `antigravity-cli` は `lib.optionals stdenv.hostPlatform.isAarch64 [ grok-build antigravity-cli ]` で arm 2 台に限定する。unstable の `package.nix` が aarch64-darwin のハッシュしか持たず、26.05 は antigravity-cli を欠く。Kenya の grok-build だけ 26.05 の `grok-build` (0.2.93) を `hosts/Kenya.nix` に置く。
- CLI 系 cask 4 つ (`claude-code@latest` `codex` `grok-build` `antigravity-cli`) はここに含めた。`codex` は cask だが CLI で、GUI は別 cask `codex-app` (Kenya のみ)。
- 残る cask は 3 台共通で 18 個 (Brewfile の `cask` 27 行 − フォント 3 − `gcloud-cli` 1 − CLI 4 − `handbrake-app` 1)。`handbrake-app` は Nix に移せない (nixpkgs の `handbrake` は `broken = true`、`meta.platforms` に `x86_64-darwin` が無い) が、使っていないので Homebrew にも残さない。`intellij-idea` も同様に非宣言 (Brewfile には元から無く、この端末だけの手動導入だった)。

## 5. 切り替え前監査 (全フェーズ共通の必須手順)

`darwin-rebuild switch` の前に必ず実施する。目的は **設定ファイルに書いていないのに効く既定値** を switch 前に全部見ること。この構成で nix-darwin が公開するオプションは 1225 個、うち既定値を持つものが 1112 個、既定が `true` のものが 56 個 (2026-09-19 実測)。さらに「既定値が空でないリストで、その中身が副作用を持つ」ものが別にある (§5.5)。ドキュメントを読んで拾うのではなく、**実際の設定を評価して機械的に列挙する**。

以下 `$FLAKE` は `~/Projects/src/github.com/satoshiyamamoto/dotfiles/nix`、`$H` は `scutil --get LocalHostName`。flake は untracked ファイルを無視するので、`nix/` 配下は `git add` 済みであること。

### 5.1 ビルドだけ先に通す

```sh
FLAKE=~/Projects/src/github.com/satoshiyamamoto/dotfiles/nix
H=$(scutil --get LocalHostName)
darwin-rebuild build --flake "$FLAKE#$H"     # ./result ができる (nix/result は .gitignore 済み)
```

`result/etc` が `/etc` に入る中身、`result/Library/LaunchDaemons` が入る daemon、`result/sw` が PATH に乗る中身そのもの。5.2 以降はこれを読む。初回で `result` が無いうちは `nix eval` (5.3) だけでも同じことが分かる。

### 5.2 `/etc` の衝突を検出する

activation は `result/etc` 内の全シンボリックリンクについて、同名の `/etc` 実ファイルが `/etc/static/…` へのリンクでなければ既知 sha256 と照合し、**一致しなければ `error: Unexpected files in /etc, aborting activation` で止まり、一致すれば警告なく `.before-nix-darwin` にリネームして置き換える** (`result/activate:810-856`, `:2318`)。止まる側と黙って入れ替わる側の両方を見たいので、ハッシュ照合はせず「触られるファイル」を全部出す:

```sh
sys=$(readlink -f ./result)          # 既存システムを見るときは sys=/run/current-system
find -H "$sys/etc" -type l -print0 | while IFS= read -r -d '' f; do
  sub=${f#"$sys"/etc/}
  [ -e "/etc/$sub" ] || continue                       # 新規作成 = 衝突なし
  [ "$(readlink "/etc/$sub")" = "/etc/static/$sub" ] && continue   # 既に nix-darwin 管理
  echo "TOUCHED: /etc/$sub"
done
```

sudo は要らない。switch 済みのシステムに対して走らせると 0 件になる (実測済み)。出たファイルは一つずつ、

1. 中身を `cat` して、**その設定を nix 側で再現する必要がないか**を判断する。
2. 必要なら対応するオプションを `hosts/*.nix` に書いてから、
3. `sudo mv /etc/<file>{,.before-nix-darwin}` してリネームする。

1 を飛ばすと事故る。`/etc/pam.d/sudo_local` はリネームだけして switch すると nix-darwin 版が 0 バイトの空ファイルになり、Touch ID sudo がその場で壊れる (§3.6)。Phase 1 でこれを踏んだ。

### 5.3 効果面を列挙する

オプション名ではなく「何が置かれるか」を見る。ここが §5.4 で拾えないものを補う本体。

```sh
for a in environment.etc system.activationScripts launchd.daemons launchd.user.agents; do
  echo "== $a"
  nix eval --json "$FLAKE#darwinConfigurations.$H.config.$a" --apply builtins.attrNames
done
nix eval --raw "$FLAKE#darwinConfigurations.$H.config.environment.systemPath"; echo
```

`nix eval` は JSON の前に `warning: Nix search path entry … does not exist` を出すことがある。そのまま `jq` に食わせると落ちるので、必要なら `2>/dev/null` を付ける。

**次フェーズの差分を先に見る**には、コミットせずに `extendModules` で足して同じことをする:

```nix
# /tmp/forecast.nix — nix eval --json -f /tmp/forecast.nix
let
  flake = builtins.getFlake "/Users/a12019/Projects/src/github.com/satoshiyamamoto/dotfiles/nix";
  base = flake.darwinConfigurations."CA-20033978";
  next = base.extendModules {
    modules = [ { homebrew.enable = true; environment.systemPackages = [ base.pkgs.ripgrep ]; } ];
  };
  added = a: b: builtins.filter (x: !(builtins.elem x (builtins.attrNames a))) (builtins.attrNames b);
in {
  etc        = added base.config.environment.etc          next.config.environment.etc;
  daemons    = added base.config.launchd.daemons          next.config.launchd.daemons;
  agents     = added base.config.launchd.user.agents      next.config.launchd.user.agents;
  activation = added base.config.system.activationScripts next.config.system.activationScripts;
}
```

Phase 2 についてこれを回した結果 (2026-09-19 実測) は `{"activation":[],"agents":[],"daemons":[],"etc":[]}` で、**属性名の差分はどれも 0 件**。`system.activationScripts.homebrew` と `.mas` は `homebrew.enable = false` でも属性としては存在し (中身が空文字列)、有効化すると中身だけが埋まる (0 → 430 バイト)。つまりこの差分の取り方は「新しく現れるもの」しか見ないので、**中身の変化は別に見る必要がある**:

```sh
nix eval --impure --raw --expr "let
  b = (builtins.getFlake \"$FLAKE\").darwinConfigurations.\"$H\";
  n = b.extendModules { modules = [ { homebrew.enable = true; } ]; };
in n.config.system.activationScripts.homebrew.text"
```

結論として Phase 2 に隠れた既定値の地雷は無く、危険なのはその activation スクリプトの中身そのものだった (§3.2)。

### 5.4 既定で有効な真偽値オプションを列挙する

```nix
# /tmp/opts.nix — nix eval --json -f /tmp/opts.nix
let
  flake = builtins.getFlake "/Users/a12019/Projects/src/github.com/satoshiyamamoto/dotfiles/nix";
  sys = flake.darwinConfigurations."CA-20033978";
  docs = sys.pkgs.lib.optionAttrSetToDocList sys.options;
  render = d: if builtins.isAttrs d && d ? text then d.text else builtins.toJSON d;
in
  builtins.map (o: o.name)
    (builtins.filter (o: !(o.internal or false) && o ? default && render o.default == "true") docs)
```

Phase 1 時点で 56 件。この中に `nix.enable` / `programs.zsh.enable` / `programs.bash.enable` / `security.pam.services.sudo_local.enable` が並んでいる。**この 4 つが Phase 1 の事故のうち 2 件の原因だった。** フィルタを外せば既定値つきオプション全部 (1112 件) が出る。

読むときの注意 2 点:

- `environment.etc.<name>.enable` のように `<name>` を含む行は submodule の**宣言**であって、その submodule が実際に使われているとは限らない。効いているかは §5.3 の `environment.etc` の attrNames 側で確かめる。
- ここに出るのは**宣言された既定値**であって解決後の値ではない。`programs.zsh.enableCompletion` は `hosts/CA-20033978.nix` で `false` にしているのにこのリストに出る。実際の値は `nix eval "$FLAKE#darwinConfigurations.$H.config.programs.zsh.enableCompletion"` で見る。

### 5.5 既定値そのものが副作用を持つ非真偽値オプション

5.4 のフィルタは真偽値しか見ないので、`environment.profiles` のような「既定値が空でないリスト」は引っかからない。実際 §3.8 の nix 二重化はこれで見落とした。5.3 の効果面列挙がこれを補うが、特に注意して読むものを挙げておく:

| オプション | 既定 | 効果 |
|---|---|---|
| `environment.profiles` | `[ "$HOME/.nix-profile" "/run/current-system/sw" "/nix/var/nix/profiles/default" ]` | PATH / `NIX_PROFILES` / `XDG_{CONFIG,DATA}_DIRS` の生成元。nix が 2 つ並ぶ原因 (§3.8) |
| `environment.systemPath` | 上から生成 + `/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin` | `/etc/zshenv` が export する PATH そのもの |
| `services.openssh.hostKeys` | rsa / ecdsa / ed25519 の 3 本 | `HostKey` を明示し、**鍵が無ければ activation が生成する** (§3.9) |
| `environment.etc.<n>.knownSha256Hashes` | モジュールごと | 5.2 の「黙って `.before-nix-darwin` に退避される」側の判定材料 |

### 5.6 switch 後の確認

```sh
darwin-rebuild --list-generations
nix config check                 # §3.8 の FAIL 1 件は既知・黙認。他が出たら調べる
find -H /run/current-system/etc -type l | wc -l   # /etc に入った本数
```

シェル環境を実測するときは、**Claude Code の Bash ツールや既存の端末から `zsh -lic` を叩いても正しく測れない**。親シェルが既に `__NIX_DARWIN_SET_ENVIRONMENT_DONE=1` を持っているため `/etc/zshenv` の `set-environment` がスキップされる。まっさらなログインシェルで測ること:

```sh
env -i HOME="$HOME" USER="$USER" TERM="$TERM" SHELL=/bin/zsh /bin/zsh -lic 'echo $PATH'
```

## 6. 段階的ロールアウト

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

`hosts/<host>.nix` には §3.6 (Touch ID sudo) と §3.7 (`programs.zsh`) を**この時点で**入れておく。どちらも初回 switch で効いてくる。

```sh
curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes
# 新しいシェルで
nix run nix-darwin/master#darwin-rebuild -- build --flake ~/Projects/src/github.com/satoshiyamamoto/dotfiles/nix
```

**ここで §5 を実施する。** 5.2 で出たファイルを 1 件ずつ処理してから switch すること。この端末では `/etc/pam.d/sudo_local` (手書き版) と `/etc/zshrc` / `/etc/bashrc` (nix-installer が書いたもの) が該当した。前者は §3.6 のオプションを先に書いてからリネームする — 空の `sudo_local` に置き換わると Touch ID sudo がその場で壊れる。

```sh
sudo mv /etc/pam.d/sudo_local{,.before-nix-darwin}
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/Projects/src/github.com/satoshiyamamoto/dotfiles/nix
```

nix の PATH は §3.7 のとおり生成される `/etc/zshenv` が引き継ぐので、`/etc/zshrc` を退避しても壊れない。

検証: `darwin-rebuild --list-generations`、`nix config check` (§3.8 の `Multiple versions of nix` 1 件だけは既知・黙認、他が出たら調べる)、`nix config show sandbox` が `false` または `relaxed` (§3.5)、新シェルで `echo $PATH` に `/run/current-system/sw/bin` と `/etc/profiles/per-user/a12019/bin` が入ること、`sudo -k; sudo true` が tmux の中でも Touch ID を出すこと (§3.6)、`/etc/zshrc` に `compinit` が無いこと (§3.7)。brew はまだ全部残っているので日常作業に影響なし。

### Phase 2: この端末でパッケージ移行

0. **§5 を実施。** Phase 2 の予測は §5.3 に実測済み (新規 `/etc` 0 件・新規 daemon 0 件・増えるのは `activationScripts.homebrew` のみ) なので、ここで想定外が出たら上流が変わったということ。止まって調べる。
1. `modules/packages.nix` に §4.4 と §3.5 を投入、`darwin-rebuild switch`。brew と Nix が両方 PATH にある状態で `.zprofile` の path 順を Nix 優先にし (§7)、1〜2 日使う。`claude` の実体が `/opt/homebrew/bin/claude` から `/run/current-system/sw/bin/claude` に変わるので、`grep -r '/opt/homebrew/bin/claude'` で claudecode.nvim / sidekick.nvim / moshi-hook 等が絶対パスを持っていないか確認する。
2. `.zshrc` / `.zprofile` の Homebrew 依存を §7 のとおり書き換え、`exec zsh` で検証。
3. `homebrew.enable = true` + §3.2 (cleanup = "none") を投入、`darwin-rebuild switch` が内部で `brew bundle` を走らせるのを確認。`homebrew` stow パッケージから Brewfile / `trust.json` / `trust.json.lock` を外す (`curlrc` は残す)。
4. 問題なければ `cleanup = "uninstall"` にして switch。`brew list --formula` が moshi-hook だけになることを確認。switch 後に `brew trust --formula rjyo/moshi/moshi-hook` を 1 回実行する (これが無いと `brew services list` がエラーも出さず空になる)。**宣言に無い cask も同時に消える**ので、Brewfile の外で手動導入していた cask を事前に棚卸しする。
5. `.sync` を `sudo /run/current-system/sw/bin/darwin-rebuild switch --flake "$dotfiles_dir/nix"` に差し替え (§7)。`sudo` は `env_reset` で PATH を捨てるため絶対パスが要る。
6. CLAUDE.md 更新 (§8)。

### Phase 3: CA-20031962 (a12019, arm)

`git pull` → `hosts/CA-20031962.nix` (cask `google-cloud-sdk` は共通の Nix パッケージに吸収されるので書かない。`handbrake` は 3 台とも非宣言なので switch で消える) → Phase 1 と同じインストーラー → **§5 を実施** → `darwin-rebuild switch`。Phase 2 の内容は既に main に入っているので 1 回で終わる想定だが、`/etc` の状態は端末ごとに違うので §5.2 は省略しない (§5.6 で 2 台の `environment.systemPath` を突き合わせておくと差分が早く分かる)。

**実施結果 (2026-09-19, 完了)**

- graphviz は引き継がなかった。結果として `hosts/CA-20031962.nix` はプラットフォームと `primaryUser` の 2 行だけになり、CA-20033978 と同一の system derivation が出る (共通部分は `modules/common.nix` に抽出、`1b50e2e`)。
- `/etc/pam.d/sudo_local` はこの端末でも手書きのままだったので、Phase 1 と同じく `sudo mv /etc/pam.d/sudo_local{,.before-nix-darwin}` が事前に必要だった。`/etc/zshrc` と `/etc/bashrc` はインストーラーが書き換えたもので既知ハッシュに一致し、activation が自動退避した。
- cask cleanup は宣言どおり 18/18 に収束 (`google-cloud-sdk` と `handbrake` は削除)。formula は 309 件が削除された。
- **想定外は 1 件のみ**: `zmx` が `neurosnap/tap` から入っており (§2 の記録が誤っていた)、untrusted tap のため cleanup が中断した。§4.2 の手順で手動除去してから switch をやり直して完了。

### Phase 4: Kenya (satoshi, x86_64, 26.05 固定)

```sh
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon   # multi-user
sudo nix --extra-experimental-features "nix-command flakes" \
  run nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake ~/Projects/src/github.com/satoshiyamamoto/dotfiles/nix
```

- 事前に `git pull` して遅れを解消。
- **§5 を実施。** この端末だけ brew prefix が `/usr/local`、user が `satoshi`、アーキテクチャが x86_64 なので、他 2 台の結果を流用しない。
- 3 台とも `macos-setup.md` の手順で `/etc/pam.d/sudo_local` を手書きしているので、Phase 1 と同じく switch 前に `sudo mv /etc/pam.d/sudo_local{,.before-nix-darwin}` が要る (§3.6, §5.2)。
- `hosts/Kenya.nix` は 26.05 系 inputs で組む。§4.4 のうち 26.05 にない / x86_64-darwin で壊れているパッケージが出たら、その場で `homebrew.brews` にフォールバック (推測で外さず、`nix build` のエラーで判断)。
- switch 前に `darwin-rebuild build --flake …#Kenya && ./result/sw/bin/claude --version` で claude-code を通す (§3.5 は `let` 束縛なので `pkgs.claude-code` は 26.05 の 2.1.223 を指し、単体 `nix build` の対象にならない)。失敗したら §3.5 のフォールバックへ。
- AI エージェント CLI は 26.05 の版になる: codex 0.146.0、opencode 1.15.10、pi-coding-agent 0.75.4、skills 1.5.7、grok-build 0.2.93 (いずれも x86_64-darwin の Hydra キャッシュあり、ローカルビルドなし)。grok-build は 1.0.34 → 0.2.93 の大幅な戻りなので switch 後に `grok --version` と一度の対話で動作確認し、壊れていれば cask に戻さず**外す**。antigravity-cli (`agy`) は Kenya では外す (GUI の `antigravity` cask は残す)。
- `/opt/homebrew -> /usr/local` リンクは `.zprofile` 修正後に不要になるので、動作確認後に削除。
- hermes gateway は brew 非依存 (§11.3)、moshi-hook は `homebrew.brews` で継続。

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

## 7. dotfiles 側の変更 (Phase 2 で実施)

### `zsh/.zprofile`

| 行 | 現在 | 変更 |
|---|---|---|
| 14 | `/opt/homebrew/bin/vivid generate …` | **削除**。`LS_COLORS` は 44 行下の `unset LS_COLORS` で毎回捨てられており最初から無効だった。`vivid` も `modules/packages.nix` から外す (`060fd5e`) |
| 29-42 `path=(…)` | `/opt/homebrew/opt/mysql-client/bin`、`/opt/homebrew/opt/rustup/bin`、`/opt/homebrew/{,s}bin` | 先頭に `/etc/profiles/per-user/$USER/bin(N)` と `/run/current-system/sw/bin(N)` を追加。`mysql-client` / `rustup` の opt 行は削除 (Nix は bin に直接出す)。`/opt/homebrew/{,s}bin(N)` は残す (brew 本体と `moshi-hook`、cask が bin に出す CLI 用)。Kenya は `/usr/local/{,s}bin(N)` が既にある |
| 44-49 `## Homebrew` | `HOMEBREW_PREFIX='/opt/homebrew'` 決め打ち | `HOMEBREW_PREFIX` 行を削除 (brew 自身が shellenv で決める。Kenya は `/usr/local`)。`HOMEBREW_BUNDLE_MAS_SKIP` は削除 (値が `''` で、`bundle/skipper.rb:67` が `split` した結果は空リスト。元から何もスキップしていなかった)。`HOMEBREW_CURLRC`、`HOMEBREW_NO_ENV_HINTS`、`HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS` は残す |
| 70 `## Claude Code` | `CLAUDE_CODE_PACKAGE_MANAGER_AUTO_UPDATE=1` | **削除**。nixpkgs 版は `DISABLE_AUTOUPDATER=1` でラップされるので意味を持たない。`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` は残す |

### `zsh/.zshrc`

| 行 | 現在 | 変更 |
|---|---|---|
| 33 | `$HOMEBREW_PREFIX/share/zsh/site-functions(N)` | `/run/current-system/sw/share/zsh/site-functions(N)` (nix-darwin が補完を集約) |
| 56-58 | `$HOMEBREW_PREFIX/share/zsh-*` | `/run/current-system/sw/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh`、`…/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh`、`…/share/zsh/plugins/you-should-use/you-should-use.plugin.zsh` (Phase 2 step 1 の switch 後に実測。autosuggestions だけ `share/zsh/plugins/` 配下、syntax-highlighting だけ `share/` 直下で、3 つとも配置が違う。後者は §3.10 の `pathsToLink` 追加が前提) |
| 59-61 | gcloud `path.zsh.inc` / `completion.zsh.inc` と `z.sh` | **削除**。nixpkgs `google-cloud-sdk` は `bin/gcloud` を PATH に、補完を `share/zsh/site-functions/_gcloud` (`#compdef` 付き) に出すので、行 33 の fpath 変更だけで補完が効く。3 行とも既にデッドだった。gcloud の 2 行が指す `Caskroom/google-cloud-sdk/` はこの端末の cask (`gcloud-cli`) と別名で存在せず、`z.sh` も 3 台とも無い (z は zoxide が代替) |
| 104-107 `.sync` | `STOW_FLAGS=--restow sh install.darwin.sh` + `brew bundle -g` | stow 行は維持、`brew bundle -g` を `sudo /run/current-system/sw/bin/darwin-rebuild switch --flake "$dotfiles_dir/nix"` に置換 (`sudo` が PATH を捨てるので絶対パス) |

### その他

- `docker/.docker/config.json`: **変更不要**。§3.10 の `pathsToLink` が `/run/current-system/sw/libexec/docker/cli-plugins` に `docker-buildx` / `docker-compose` の 2 本を出すので、switch 後に `docker compose version` (5.5.1) と `docker buildx version` (v0.35.0) がそのまま通る。
- `homebrew/` stow パッケージ: `Brewfile`、`trust.json`、`trust.json.lock` を `git rm` し `curlrc` のみ残す。`.gitignore` に `homebrew/.config/homebrew/trust.json*` を追加 (brew が `~/.config/homebrew/` に書き続けるため、stow 経由で repo に現れないように)。`Brewfile.lock.json` の行は不要になる。Brewfile ごと消えるので `brew "rust"` や CLI 系 cask の行単位削除は発生しない。
- `install.darwin.sh`: stow 一覧はそのまま。末尾に `darwin-rebuild` は足さない (初回は `nix run` 経由、以後は `.sync`)。
- `install.sh` (Linux): 変更なし。

## 8. CLAUDE.md の更新点

- 「Homebrew / Brewfile」節を「Nix (nix-darwin)」節に置き換え: `nix/` 構成、`sudo darwin-rebuild switch --flake …/nix`、Kenya は 26.05 固定で EOL 2026-12-31、x86_64-darwin は unstable にない。
- 「node comes from Homebrew, not mise」→「node comes from nixpkgs (`nodejs`), not mise」。理由 (mise の config.toml が stow 管理) は同じ。
- hermes の ffmpeg 記述を「installer は `command -v rg` / `command -v ffmpeg` / `command -v git` で探し、見つかれば brew を呼ばない。`ripgrep` / `ffmpeg` は `modules/packages.nix` に置く。`git` は 3 台とも Apple Git (`/usr/bin/git`) で Homebrew にも nixpkgs にも無いので宣言しない (新端末は `xcode-select --install` のまま)。インストーラーは Nix パスが PATH に入ったログインシェルから実行する」に。
- moshi-hook: brew launchd service は継続、宣言場所が `modules/homebrew.nix` の `brews` に変わる。
- cask quarantine 節: そのまま有効。`homebrew.caskArgs` に `--no-quarantine` を入れない旨を 1 行追加。
- kulala / tree-sitter-cli 節: `brew "tree-sitter-cli"` → `tree-sitter` (nixpkgs)。
- claude-code / codex 等の AI エージェント CLI は nixpkgs 版で自己更新しない旨を追加。

## 9. 検証

- 各 Phase 後: `darwin-rebuild --list-generations`、`which -a <tool>` で Nix 側が先に来ること、`brew list --formula` の残り、`darwin-rebuild switch` の `brew bundle` 出力。
- zsh: `exec zsh` 後の起動時間 (`zprof`)、`type __load_plugins` 後の `bindkey` で autosuggestions が生きていること。
- nvim: `nvim --headless "+Lazy! sync" +qa`、`:checkhealth` で tree-sitter CLI / node / ripgrep / fd が Nix パスで検出されること。
- moshi-hook: `moshi-hook servers`、`launchctl list | grep moshi`。
- hermes: `hermes doctor`、gateway の launchd が生きていること (Kenya)。
- docker: `docker buildx version`、`docker compose version`。
- claude-code: `claude --version` が unstable の版 (3 台同じ) であること。

## 10. ロールバック

- nix-darwin の世代戻し: `darwin-rebuild --list-generations` → `sudo darwin-rebuild switch --rollback` (または `--switch-generation N`)。
- nix-darwin 撤去: `sudo nix --extra-experimental-features "nix-command flakes" run nix-darwin#darwin-uninstaller` (Kenya は `nix-darwin/nix-darwin-26.05#darwin-uninstaller`)。
- Nix 本体撤去: arm 2 台は `/nix/nix-installer uninstall`。Kenya は公式手順 (`/etc/zshrc` 等の `.backup-before-nix` 復元、launchd 2 本、`_nixbld` ユーザー/グループ、`synthetic.conf`、fstab、`diskutil apfs deleteVolume /nix`)。**nix-darwin を消す前に Nix を消さない** (ネットワーク設定が壊れる既知の quirk)。
- Homebrew は `cleanup = "uninstall"` を入れるまで formulae が残るので、Phase 2-4 より前ならロールバックコストはゼロ。それ以降は `git show <rev>:homebrew/.config/homebrew/Brewfile > /tmp/Brewfile && brew bundle --file=/tmp/Brewfile` で復元可能。

## 11. 判断根拠 (2026-09-19 実測)

### 11.1 x86_64-darwin の現状

- nixpkgs master/unstable は `x86_64-darwin` を削除済み (bd832325 "lib/systems/doubles: drop x86_64-darwin"、PR #492189 で評価時エラー化、2026-06)。`nixpkgs-26.05-darwin` にはまだ残る (`lib/systems/doubles.nix:14`)。
- インストーラー: Determinate は 2025-10 に Intel ビルド停止 (#1693)、NixOS/nix-installer は 2.35.1 (2026-07-15) から `nix-installer-x86_64-darwin` を配布せず、Lix installer は Intel 非サポートを警告。公式 `nixos.org/nix/install` は `nix-2.35.2-x86_64-darwin.tar.xz` を配布中。

### 11.2 AI エージェント CLI の版と遅れ

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

### 11.3 hermes の brew 依存

公式 `install.sh` (3945 行) を取得して確認。`install_system_packages()` は `command -v rg` / `command -v ffmpeg` で探し、両方見つかれば brew を呼ばない。見つからない場合だけ macOS で `brew install ripgrep ffmpeg`。git も `attempt_install_git()` が `command -v git` を先に見る。`hermes doctor` (`hermes_cli/doctor.py`) も `shutil.which` で検出し、`brew install <pkg>` は案内文の文言にすぎない。→ Nix の `ripgrep` / `ffmpeg` / `git` が PATH にあれば Homebrew 側は不要。

### 11.4 gcloud

nixpkgs `google-cloud-sdk`: unstable 583.0.0 (aarch64-darwin)、26.05 565.0.0 (x86_64-darwin あり)。cask は 569.0.0。追加コンポーネント gsutil / gcloud-crc32c はどちらも同梱。
