# Unfree packages allowed by name. Shared rather than set in a module because
# home-manager's useGlobalPkgs forbids nixpkgs.config there: nix-darwin feeds
# this to its own nixpkgs.config, and a standalone home-manager to the pkgs it
# imports.
[
  "antigravity-cli"
  "claude-code"
  "grok-build"
]
