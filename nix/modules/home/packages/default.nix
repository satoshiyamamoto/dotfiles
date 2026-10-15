# Packages shared by every host. This list came from the Brewfile, minus
# the ~70 entries that were only there as runtime dependencies -- Nix carries
# those itself, so nothing here names a library another package pulls in.
#
# Split by purpose so that a host can import only the groups it wants.
{ lib, pkgs, ... }:
{
  imports = [
    ./ai.nix
    ./cloud.nix
    ./core.nix
    ./dev.nix
    ./fun.nix
  ];

  # Everything below is unavailable on Kenya, the only x86_64 host.
  #
  # container is Apple's own runtime and Apple Silicon only. The rest cannot
  # be had from 26.05, which Kenya pins: herdr and hunk are absent from it,
  # and mycli pulls arrow-cpp through llm, which 26.05 marks broken on
  # x86_64-darwin alone. Of those, only herdr is wanted on Kenya, and it
  # comes from numtide/llm-agents.nix there (hosts/Kenya.nix); hunk and mycli
  # are not installed on that host at all. aarch64 keeps taking herdr from
  # nixpkgs here, which is cached, rather than compiling it.
  #
  # atuin is here for a different reason: 26.05 has it, but at 18.15.2,
  # older than whatever last migrated Kenya's SQLite history. An older client
  # refuses a migrated database outright ("migration <id> was previously
  # applied but is missing in the resolved migrations") and every
  # `atuin history start` -- which runs synchronously in preexec -- then took
  # 4-8 seconds instead of 10ms, stalling every single command. Homebrew
  # cannot stand in either: it no longer bottles for macOS 15 / x86_64. So
  # Kenya simply runs no atuin, and zsh/.zshrc skips `atuin init` where the
  # binary is absent -- Ctrl-R falls back to fzf there (zsh/.zprofile).
  #
  # antigravity-cli and grok-build both declare
  # platforms = lib.attrNames sourceData and upstream publishes no darwin-x64
  # hash, so neither can follow the claude-code trick in ./ai.nix.
  home.packages = lib.optionals pkgs.stdenv.hostPlatform.isAarch64 (
    with pkgs;
    [
      antigravity-cli
      atuin
      container
      grok-build
      herdr
      hunk
      mycli
    ]
  );
}
