# Mac mini 2018 (Macmini8,1, i7-8700B), user satoshi. The only x86_64 host, so
# it builds against the 26.05 inputs in flake.nix rather than unstable.
{ inputs, pkgs, ... }:
{
  nixpkgs.hostPlatform = "x86_64-darwin";
  system.primaryUser = "satoshi";

  # herdr is absent from 26.05 and Homebrew will not stand in -- it has
  # declared macOS 15 / x86_64 a Tier 3 configuration and no longer bottles
  # for it, so nothing new can come from there. numtide/llm-agents.nix builds
  # it from source instead: its own `packages` output lists only the three
  # systems it caches for, but `overlays.shared-nixpkgs` builds the same tree
  # against whatever pkgs the consumer has, and herdr's meta.platforms already
  # covers this one. No cache hit follows, so it compiles on the machine
  # (Rust plus a vendored libghostty-vt through zig, about four minutes here).
  #
  # hunk cannot come the same way: it pins meta.platforms without
  # x86_64-darwin because bun-bin, the `bun build --compile` runtime, has no
  # darwin-x64 triple there. cloudflare-speed-cli, hunk and mycli are simply
  # not wanted on this host, so with those three gone Homebrew keeps only the
  # moshi-hook that modules/homebrew.nix declares for every machine.
  nixpkgs.overlays = [ inputs.llm-agents.overlays.shared-nixpkgs ];
  environment.systemPackages = [ pkgs.llm-agents.herdr ];
}
