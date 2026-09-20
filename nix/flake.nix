{
  description = "nix-darwin configuration for satoshiyamamoto/dotfiles";

  # Kenya is the only x86_64 Mac here and nixpkgs 26.11 refuses that platform
  # outright -- importing it at all throws "Nixpkgs 26.11 has dropped support
  # for x86_64-darwin", so no per-package override can save it. Hence a second
  # pair of inputs pinned to 26.05, which only warns. That pin expires with
  # 26.05 on 2026-12-31; see docs/nix-migration.md.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # herdr for Kenya. Its own `packages` output skips x86_64-darwin, but the
    # shared-nixpkgs overlay builds the tree against the consumer's pkgs, which
    # is how that host gets it anyway -- see hosts/Kenya.nix. `follows` keeps a
    # third nixpkgs out of the lock: upstream uses its own only for `lib` and
    # for a per-system package set that x86_64-darwin never reaches.
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Phase 5: stow replaced by home-manager (modules/home.nix). Paired with
    # nixpkgs the same way nix-darwin is, so each host gets the home-manager
    # that matches its channel.
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-2605.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin-2605 = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
    home-manager-2605 = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
  };

  # Keys match `scutil --get LocalHostName` -- not `hostname -s`, which can
  # differ in case -- so `darwin-rebuild switch --flake <this directory>` needs
  # no host argument.
  outputs =
    inputs@{
      home-manager,
      home-manager-2605,
      nix-darwin,
      nix-darwin-2605,
      ...
    }:
    let
      mkHost =
        darwin: hm: hostModule:
        darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };
          modules = [
            hostModule
            hm.darwinModules.home-manager
            ./modules/common.nix
            ./modules/home.nix
            ./modules/homebrew.nix
            ./modules/packages.nix
          ];
        };
    in
    {
      darwinConfigurations = {
        "CA-20033978" = mkHost nix-darwin home-manager ./hosts/CA-20033978.nix;
        "CA-20031962" = mkHost nix-darwin home-manager ./hosts/CA-20031962.nix;
        "Kenya" = mkHost nix-darwin-2605 home-manager-2605 ./hosts/Kenya.nix;
      };
    };
}
