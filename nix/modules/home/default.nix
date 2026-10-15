# The home-manager core every host shares, macOS or Linux: packages and dotfile
# links. Only home-manager options belong under this directory -- the account
# (home.username / home.homeDirectory) is supplied by whoever imports it.
{
  imports = [
    ./files.nix
    ./packages
  ];

  # Matches the oldest home-manager in flake.nix (Kenya's 26.05); the option
  # only gates behaviour changes, so one value serves every host.
  home.stateVersion = "26.05";
}
