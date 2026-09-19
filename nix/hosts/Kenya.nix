# Mac mini 2018 (Macmini8,1, i7-8700B), user satoshi. The only x86_64 host, so
# it builds against the 26.05 inputs in flake.nix rather than unstable.
{
  nixpkgs.hostPlatform = "x86_64-darwin";
  system.primaryUser = "satoshi";

  # scutil reported "kenya" while ComputerName and HostName were already
  # "Kenya", and darwin-rebuild resolves the flake attribute from LocalHostName.
  # It was corrected by hand once (the resolution happens before activation, so
  # it had to be); declaring it keeps it from drifting back.
  networking.localHostName = "Kenya";

  # Unavailable from nixpkgs 26.05, so they stay on Homebrew here while the two
  # aarch64 hosts get them from Nix. The first three are simply absent from
  # 26.05; mycli evaluates but pulls arrow-cpp through llm, and 26.05 marks
  # arrow-cpp broken on x86_64-darwin alone. All four are in homebrew/core, so
  # no tap is needed.
  homebrew.brews = [
    "cloudflare-speed-cli"
    "herdr"
    "hunk"
    "mycli"
  ];
}
