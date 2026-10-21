{
  description = "nix-darwin and home-manager configurations for satoshiyamamoto/dotfiles";

  # Kenya is the only x86_64 Mac here and nixpkgs 26.11 refuses that platform
  # outright -- importing it at all throws "Nixpkgs 26.11 has dropped support
  # for x86_64-darwin", so no per-package override can save it. Hence a second
  # pair of inputs pinned to 26.05, which only warns. That pin expires with
  # 26.05 on 2026-12-31, by which time Kenya needs a channel bump or a
  # retirement -- see CLAUDE.md.
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

    # Phase 5: stow replaced by home-manager (modules/home). Paired with
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
      nixpkgs,
      ...
    }:
    let
      mkDarwin =
        darwin: hm: hostModule:
        darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };
          modules = [
            hostModule
            hm.darwinModules.home-manager
            ./modules/darwin/environment.nix
            ./modules/darwin/home-manager.nix
            ./modules/darwin/homebrew.nix
            ./modules/darwin/system.nix
          ];
        };

      # Linux hosts run home-manager on its own over a distribution's Nix, so
      # only the platform-neutral core plus the Linux glue applies. useGlobalPkgs
      # is a nix-darwin notion; here the unfree list goes straight into pkgs.
      mkHome =
        system: hostModule:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate =
              pkg: builtins.elem (nixpkgs.lib.getName pkg) (import ./lib/unfree.nix);
            # shortcut: diff-cover 10.5.1, which sqlfluff depends on, fails an
            # HTML-output test on x86_64-linux only; drop this once it is cached.
            overlays = [
              (final: prev: {
                pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
                  (pyfinal: pyprev: {
                    diff-cover = pyprev.diff-cover.overridePythonAttrs { doCheck = false; };
                  })
                ];
              })
            ];
          };
          extraSpecialArgs = { inherit inputs; };
          modules = [
            hostModule
            ./modules/home
            ./modules/home/linux.nix
          ];
        };
    in
    {
      # Keys are "$USER@$(hostname -s)", one of the names `home-manager switch
      # --flake <this directory>` tries on its own.
      homeConfigurations = {
        "satoshi_yamamoto@devcontainer01" = mkHome "x86_64-linux" ./hosts/linux/devcontainer01.nix;
      };

      darwinConfigurations = {
        "CA-20040831" = mkDarwin nix-darwin home-manager ./hosts/darwin/CA-20040831.nix;
        "CA-20040386" = mkDarwin nix-darwin home-manager ./hosts/darwin/CA-20040386.nix;
        "Kenya" = mkDarwin nix-darwin-2605 home-manager-2605 ./hosts/darwin/Kenya.nix;
      };
    };
}
