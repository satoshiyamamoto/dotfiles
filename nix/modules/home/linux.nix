# What a standalone home-manager on a non-NixOS Linux needs on top of the shared
# core. Imported by mkHome in flake.nix, never by nix-darwin.
{
  config,
  lib,
  pkgs,
  ...
}:
{
  # XDG_DATA_DIRS, terminfo and locale glue for Nix packages running on a
  # distribution's own userland.
  targets.genericLinux.enable = true;

  # The `home-manager` command itself. On macOS darwin-rebuild does its job.
  programs.home-manager.enable = true;

  # Let Chromium find Japanese fonts when rendering Mermaid diagrams.
  fonts.fontconfig.enable = true;

  # macOS gets this from nix-darwin's /etc/zshenv (../darwin/environment.nix).
  # Here it lands in hm-session-vars.sh, which zsh/.zshenv sources.
  home.sessionVariables.JAVA_HOME = "${pkgs.jdk21.home}";

  # k9s resolves its cache dir through user.Current() unless this is set, and
  # Nix's glibc cannot see an LDAP account (sssd), so k9s exits at startup.
  home.sessionVariables.KUBECACHEDIR = "${config.home.homeDirectory}/.kube/cache";

  # Ubuntu only: /etc/bash.bashrc runs `groups` for its sudo hint after the Nix
  # hook put Nix's coreutils first, which cannot name LDAP groups either and
  # warns at every login. This file is the hint's own off switch.
  home.file.".sudo_as_admin_successful".text = "";

  # Ubuntu's AppArmor userns restriction blocks Chromium's sandbox. The Linux
  # installer applies this host policy with sudo; home-manager owns its source.
  home.file.".config/apparmor.d/nix-chromium".text = ''
    abi <abi/4.0>,
    include <tunables/global>

    profile nix-chromium /nix/store/*-chromium-unwrapped-*/libexec/chromium/chromium flags=(unconfined) {
      userns,
    }
  '';

  # What macOS supplies outside Nix and a distribution may not ship at all
  # (Ubuntu ships neither): zsh, which nix-darwin's programs.zsh installs on
  # macOS, and a C compiler, which the Command Line Tools provide there.
  # nvim-treesitter compiles every parser with `cc`, and cargo links with it.
  # git too: the shared config sets merge.conflictStyle = zdiff3, which needs
  # 2.35, and a distribution's git can be older (Ubuntu 22.04 ships 2.34).
  # git-credential-manager is a cask on macOS (../darwin/homebrew.nix).
  home.packages = with pkgs; [
    gcc
    git
    git-credential-manager
    ipaexfont
    zsh
    # Only the proxy loads NSS modules; clients keep their normal library paths.
    (writeShellScriptBin "nsncd" ''
      export LD_LIBRARY_PATH=${lib.makeLibraryPath [ sssd ]}
      exec ${nsncd}/bin/nsncd "$@"
    '')
  ];
}
