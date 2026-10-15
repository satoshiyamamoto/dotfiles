# The system-level half of what used to be modules/packages.nix: settings that
# have no home-manager equivalent on macOS. The package list itself moved to
# ../home/packages so that Linux hosts can share it.
{ lib, pkgs, ... }:
{
  # nix-darwin's default pathsToLink is narrower than NixOS's: it has /share/zsh
  # but not /share in general, and no /libexec. zsh-syntax-highlighting installs
  # outside /share/zsh, and the docker CLI plugins live under libexec. The
  # per-user profile that home.packages lands in is built with this same list.
  environment.pathsToLink = [
    "/libexec/docker/cli-plugins"
    "/share/zsh-syntax-highlighting"
  ];

  # nix-darwin has no programs.java, and home-manager's only sets
  # home.sessionVariables, which lands in an hm-session-vars.sh that nothing
  # here sources -- zsh is a plain dotfile link, not programs.zsh. This is the
  # option that works: /etc/zshenv sources set-environment for every zsh.
  # `.home` is what the JDK's own nix-support/setup-hook exports, which on
  # darwin is the store root, not the Contents/Home inside it.
  environment.variables.JAVA_HOME = "${pkgs.jdk21.home}";

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

  # mas drives homebrew.masApps, which exists on macOS alone.
  environment.systemPackages = [ pkgs.mas ];

  nixpkgs.config.allowUnfreePredicate =
    pkg: builtins.elem (lib.getName pkg) (import ../../lib/unfree.nix);
}
