{
  description = "nix-darwin configuration for satoshiyamamoto/dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Keys match `scutil --get LocalHostName`, so `darwin-rebuild switch --flake
  # <this directory>` needs no host argument. Kenya (x86_64) joins in Phase 4
  # with its own 26.05 inputs -- see docs/nix-migration.md.
  outputs =
    inputs@{ nix-darwin, ... }:
    let
      mkHost =
        hostModule:
        nix-darwin.lib.darwinSystem {
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
        "CA-20033978" = mkHost ./hosts/CA-20033978.nix;
        "CA-20031962" = mkHost ./hosts/CA-20031962.nix;
      };
    };
}
