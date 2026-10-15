# Hooks the platform-neutral home-manager modules (../home) into nix-darwin for
# the host's primary user. Linux hosts reach the same modules through
# standalone home-manager instead, so nothing under ../home may read nix-darwin
# options such as system.primaryUser.
{ config, inputs, ... }:
let
  user = config.system.primaryUser;
in
{
  # home-manager reads the account's home directory from here. nix-darwin only
  # creates accounts listed in users.knownUsers, so declaring it does not put
  # this repo in charge of macOS user management.
  users.users.${user}.home = "/Users/${user}";

  home-manager = {
    # Build against the system's own pkgs and put per-user paths in
    # /etc/profiles/per-user, which zsh/.zprofile already has on PATH. That
    # profile is built with environment.pathsToLink, so ./environment.nix still
    # decides which of /share and /libexec reach it.
    useGlobalPkgs = true;
    useUserPackages = true;
    # Never clobber a file that is already there -- rename it instead. This is
    # what makes the first switch on a stow machine recoverable.
    backupFileExtension = "hm-bak";
    # ../home/packages/ai.nix builds claude-code from the unstable input.
    extraSpecialArgs = { inherit inputs; };

    users.${user}.imports = [ ../home ];
  };
}
