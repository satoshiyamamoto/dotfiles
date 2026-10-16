# What a standalone home-manager on a non-NixOS Linux needs on top of the shared
# core. Imported by mkHome in flake.nix, never by nix-darwin.
{ config, pkgs, ... }:
{
  # XDG_DATA_DIRS, terminfo and locale glue for Nix packages running on a
  # distribution's own userland.
  targets.genericLinux.enable = true;

  # The `home-manager` command itself. On macOS darwin-rebuild does its job.
  programs.home-manager.enable = true;

  # macOS gets this from nix-darwin's /etc/zshenv (../darwin/environment.nix).
  # Here it lands in hm-session-vars.sh, which zsh/.zshenv sources.
  home.sessionVariables.JAVA_HOME = "${pkgs.jdk21.home}";

  # k9s resolves its cache dir through user.Current() unless this is set, and
  # Nix's glibc cannot see an LDAP account (sssd), so k9s exits at startup.
  home.sessionVariables.KUBECACHEDIR = "${config.home.homeDirectory}/.kube/cache";

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
    zsh
  ];

  # The login shell stays the distribution's bash: an LDAP account usually
  # cannot chsh, and /etc/shells would need the store path anyway. Hand
  # interactive logins over to zsh instead. Non-interactive ones -- `ssh host
  # cmd`, scp, VS Code's remote server -- never get here. SHELL is set so that
  # tmux and friends start zsh for new panes too. ~/.profile is what bash would
  # have read without this file, so it still runs first.
  home.file.".bash_profile".text = ''
    [ -f "$HOME/.profile" ] && . "$HOME/.profile"
    case $- in
      *i*)
        if [ -x "$HOME/.nix-profile/bin/zsh" ]; then
          SHELL="$HOME/.nix-profile/bin/zsh" exec "$HOME/.nix-profile/bin/zsh" -l
        fi
        ;;
    esac
  '';
}
