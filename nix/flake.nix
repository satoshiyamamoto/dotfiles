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

    nixpkgs-2605.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin-2605 = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-2605";
    };
  };

  # Keys match `scutil --get LocalHostName` -- not `hostname -s`, which can
  # differ in case -- so `darwin-rebuild switch --flake <this directory>` needs
  # no host argument.
  outputs =
    inputs@{ nix-darwin, nix-darwin-2605, ... }:
    let
      mkHost =
        darwin: hostModule:
        darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };
          modules = [
            hostModule
            ./modules/common.nix
            ./modules/homebrew.nix
            ./modules/packages.nix
          ];
        };
    in
    {
      darwinConfigurations = {
        "CA-20033978" = mkHost nix-darwin ./hosts/CA-20033978.nix;
        "CA-20031962" = mkHost nix-darwin ./hosts/CA-20031962.nix;
        "Kenya" = mkHost nix-darwin-2605 ./hosts/Kenya.nix;
      };
    };
}
