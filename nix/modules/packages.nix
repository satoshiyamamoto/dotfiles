# Packages shared by all three hosts. docs/nix-migration.md section 4 records how
# the Brewfile maps onto this list, including the ~70 lines dropped because Nix
# carries runtime dependencies itself.
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  # claude-code from nixpkgs-unstable on every host. Kenya's nixpkgs is 26.05,
  # whose claude-code is frozen at 2.1.223, so build unstable's package.nix with
  # 26.05's stdenv instead. Referencing it as a path keeps x86_64-darwin from
  # importing unstable, which does not evaluate there. Upstream still ships
  # darwin-x64 binaries; only the meta.platforms declaration in unstable dropped
  # x86_64-darwin.
  claude-code =
    (pkgs.callPackage "${inputs.nixpkgs}/pkgs/by-name/cl/claude-code/package.nix" { }).overrideAttrs
      (old: {
        meta = old.meta // {
          platforms = old.meta.platforms ++ [ "x86_64-darwin" ];
        };
      });
in
{
  # nix-darwin's default pathsToLink is narrower than NixOS's: it has /share/zsh
  # but not /share in general, and no /libexec. zsh-syntax-highlighting installs
  # outside /share/zsh, and the docker CLI plugins live under libexec.
  environment.pathsToLink = [
    "/libexec/docker/cli-plugins"
    "/share/zsh-syntax-highlighting"
  ];

  # Replaces the font-symbols-only-nerd-font / font-ipaexfont /
  # font-noto-sans-symbols-2 casks. noto-fonts is the only nixpkgs attribute
  # that ships NotoSansSymbols2, which tokyo-night-tmux needs for its segmented
  # window numbers. The fonts module only rsyncs /Library/Fonts/Nix Fonts, so
  # cask-installed fonts elsewhere in /Library/Fonts are left alone.
  fonts.packages = with pkgs; [
    ipaexfont
    nerd-fonts.symbols-only
    noto-fonts
  ];

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "antigravity-cli"
      "claude-code"
      "grok-build"
    ];

  environment.systemPackages = [
    claude-code
  ]
  ++ (with pkgs; [
    argo-workflows
    argocd
    asciinema
    awscli
    bash
    bat
    bat-extras.batdiff
    bat-extras.batgrep
    bat-extras.batman
    bat-extras.batpipe
    bat-extras.batwatch
    bat-extras.prettybat
    biome
    bk
    btop
    buf
    caddy
    cbonsai
    cmatrix
    codex
    colima
    colordiff
    coreutils
    delta
    delve
    devcontainer
    direnv
    docker
    docker-buildx
    docker-compose
    docker-credential-helpers
    duckdb
    exiftool
    eza
    fastfetch
    fd
    ffmpeg
    fzf
    gawk
    gh
    ghq
    glow
    gnupg
    go
    go-tools
    golangci-lint
    google-cloud-sdk
    google-java-format
    gopls
    gotools
    gping
    gradle
    grpc
    grpcurl
    gws
    hey
    htop
    imagemagick
    inetutils
    jd-diff-patch
    jdk
    jdk21
    jq
    jwt-cli
    k9s
    kubectl
    kubectl-tree
    kubernetes-helm
    lazydocker
    lazygit
    lefthook
    litecli
    lolcat
    luarocks
    mas
    maven
    mermaid-cli
    minikube
    mise
    mosh
    mysql84
    neovim
    nkf
    nmap
    nodejs
    nyancat
    opencode
    pandoc
    pgcli
    pi-coding-agent
    pnpm
    ponysay
    poppler
    prettier
    protobuf
    pwgen
    python313Packages.docutils
    python313Packages.ipython
    qemu
    ripgrep
    ruff
    rustup
    skills
    sl
    socat
    sops
    sourceHighlight
    sqlfluff
    starship
    stern
    stow
    stylua
    tfenv
    tldr
    tmux
    translate-shell
    tree
    tree-sitter
    ttyd
    unbound
    uv
    viddy
    watch
    wget
    worktrunk
    yamlfmt
    yazi
    yq
    zellij
    zoxide
    zsh-autosuggestions
    zsh-powerlevel10k
    zsh-syntax-highlighting
    zsh-you-should-use
  ])
  # Everything below is unavailable on Kenya, the only x86_64 host.
  #
  # container is Apple's own runtime and Apple Silicon only. The rest cannot
  # be had from 26.05, which Kenya pins: herdr and hunk are absent from it,
  # and mycli pulls arrow-cpp through llm, which 26.05 marks broken on
  # x86_64-darwin alone. Of those, only herdr is wanted on Kenya, and it
  # comes from numtide/llm-agents.nix there (hosts/Kenya.nix); hunk and mycli
  # are not installed on that host at all. aarch64 keeps taking herdr from
  # nixpkgs here, which is cached, rather than compiling it.
  #
  # atuin is here for a different reason: 26.05 has it, but at 18.15.2,
  # older than whatever last migrated Kenya's SQLite history. An older client
  # refuses a migrated database outright ("migration <id> was previously
  # applied but is missing in the resolved migrations") and every
  # `atuin history start` -- which runs synchronously in preexec -- then took
  # 4-8 seconds instead of 10ms, stalling every single command. Homebrew
  # cannot stand in either: it no longer bottles for macOS 15 / x86_64. So
  # Kenya simply runs no atuin, and zsh/.zshrc skips `atuin init` where the
  # binary is absent -- Ctrl-R falls back to fzf there (zsh/.zprofile).
  #
  # antigravity-cli and grok-build both declare
  # platforms = lib.attrNames sourceData and upstream publishes no darwin-x64
  # hash, so neither can follow the claude-code trick above.
  ++ lib.optionals pkgs.stdenv.hostPlatform.isAarch64 (
    with pkgs;
    [
      antigravity-cli
      atuin
      container
      grok-build
      herdr
      hunk
      mycli
    ]
  );
}
