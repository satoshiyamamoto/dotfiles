# Shell, editor, git and the everyday CLI tools -- what every host needs.
{
  available,
  lib,
  pkgs,
  ...
}:
{
  home.packages =
    available (
      with pkgs;
      [
        asciinema
        bash
        bat
        bat-extras.batdiff
        bat-extras.batgrep
        bat-extras.batman
        bat-extras.batpipe
        bat-extras.batwatch
        bat-extras.prettybat
        btop
        colordiff
        coreutils
        delta
        direnv
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
        gping
        htop
        imagemagick
        jq
        lazygit
        mise
        mosh
        neovim
        nkf
        nmap
        pandoc
        poppler
        pwgen
        ripgrep
        socat
        sourceHighlight
        starship
        stow
        tldr
        tmux
        translate-shell
        tree
        tree-sitter
        unbound
        viddy
        watch
        wget
        worktrunk
        yazi
        yq
        zellij
        zoxide
        zsh-autosuggestions
        zsh-powerlevel10k
        zsh-syntax-highlighting
        zsh-you-should-use
      ]
    )
    # macOS ships BSD ifconfig/ping/hostname etc.; inetutils' GNU versions would
    # shadow them on PATH with incompatible flags (e.g. `ping -t`).
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.inetutils ]
    # macOS dropped telnet (whois/traceroute/sftp it still ships), so link just
    # that one out of inetutils.
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      (pkgs.runCommand "inetutils-telnet" { } ''
        mkdir -p $out/bin
        ln -s ${pkgs.inetutils}/bin/telnet $out/bin/
      '')
    ];
}
