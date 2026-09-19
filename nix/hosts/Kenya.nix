# Mac mini 2018 (Macmini8,1, i7-8700B), user satoshi. The only x86_64 host, so
# it builds against the 26.05 inputs in flake.nix rather than unstable.
{
  nixpkgs.hostPlatform = "x86_64-darwin";
  system.primaryUser = "satoshi";

  # Unavailable from nixpkgs 26.05, so they stay on Homebrew here while the two
  # aarch64 hosts get them from Nix. The first three are simply absent from
  # 26.05; mycli evaluates but pulls arrow-cpp through llm, and 26.05 marks
  # arrow-cpp broken on x86_64-darwin alone. All four are in homebrew/core, so
  # no tap is needed.
  #
  # Nothing new can be added here: Homebrew has declared this configuration
  # Tier 3 and no longer bottles for macOS 15 / x86_64, so any further formula
  # would be a source build. The four above predate that and stay installed.
  homebrew.brews = [
    "cloudflare-speed-cli"
    "herdr"
    "hunk"
    "mycli"
  ];
}
