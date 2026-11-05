{ inputs, ... }:
{
  imports = [ inputs.rex.homeManagerModules.default ];

  programs.rex = {
    enable = true;
    config = ../../../rex/.config/rex/init.lua;
    # ~/.ssh/config is managed outside home-manager.
    sshGuard = false;
  };
}
