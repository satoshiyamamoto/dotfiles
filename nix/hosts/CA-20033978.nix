# MacBook Air 13" M4 (2025), user a12019.
{
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.primaryUser = "a12019";

  # Required: the default (system.maxStateVersion) trips an assertion in
  # nix-darwin's modules/system/version.nix.
  system.stateVersion = 7;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Phase 0 keeps this empty on purpose: Homebrew still owns every package and
  # every cask. environment.systemPackages arrives in Phase 2, the homebrew
  # module right after it. See docs/nix-migration.md.
}
