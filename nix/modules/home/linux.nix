# What a standalone home-manager on a non-NixOS Linux needs on top of the shared
# core. Imported by mkHome in flake.nix, never by nix-darwin.
{ pkgs, ... }:
{
  # XDG_DATA_DIRS, terminfo and locale glue for Nix packages running on a
  # distribution's own userland.
  targets.genericLinux.enable = true;

  # The `home-manager` command itself. On macOS darwin-rebuild does its job.
  programs.home-manager.enable = true;

  # macOS gets this from nix-darwin's /etc/zshenv (../darwin/environment.nix).
  # Here it lands in hm-session-vars.sh, which zsh/.zshenv sources.
  home.sessionVariables.JAVA_HOME = "${pkgs.jdk21.home}";
}
