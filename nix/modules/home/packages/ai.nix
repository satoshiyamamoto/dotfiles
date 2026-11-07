# AI coding agents. The AI CLIs are not self-updating -- see CLAUDE.md.
{
  available,
  inputs,
  pkgs,
  ...
}:
let
  # claude-code from nixpkgs-unstable on every host. Kenya's nixpkgs is 26.05,
  # whose claude-code is frozen at 2.1.223, so build unstable's package.nix with
  # 26.05's stdenv instead. Referencing it as a path keeps x86_64-darwin from
  # importing unstable, which does not evaluate there. Upstream still ships
  # darwin-x64 binaries; only the meta.platforms declaration in unstable dropped
  # x86_64-darwin.
  claude-code =
    (pkgs.callPackage "${inputs.nixpkgs}/pkgs/by-name/cl/claude-code/package.nix" { }).overrideAttrs
      (old: {
        meta = old.meta // {
          platforms = old.meta.platforms ++ [ "x86_64-darwin" ];
        };
      });
  # shortcut: nixpkgs has no x86_64-darwin rusty_v8, update this pin with Codex.
  codex =
    if pkgs.stdenv.hostPlatform.system == "x86_64-darwin" then
      pkgs.stdenvNoCC.mkDerivation {
        pname = "codex";
        version = "0.165.0";
        src = pkgs.fetchurl {
          url = "https://github.com/openai/codex/releases/download/rust-v0.165.0/codex-package-x86_64-apple-darwin.tar.gz";
          hash = "sha256-eS7KsFlgBr2fKGQwsnkKpIf9QPyi81HKMTrYWZFyAiY=";
        };
        sourceRoot = ".";
        dontFixup = true;
        installPhase = ''
          mkdir -p "$out"
          cp -R . "$out"
        '';
        meta = pkgs.codex.meta // {
          platforms = [ "x86_64-darwin" ];
          sourceProvenance = with pkgs.lib.sourceTypes; [ binaryNativeCode ];
        };
      }
    else
      pkgs.codex;
  # shortcut: opencode 2.2.5 has a mismatched dependency hash in nixpkgs; remove after an upstream fix.
  opencode =
    if pkgs.opencode.version == "2.2.5" then
      pkgs.opencode.overrideAttrs (old: {
        node_modules = old.node_modules.overrideAttrs {
          outputHash =
            if pkgs.stdenv.hostPlatform.isLinux then
              "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA="
            else
              "sha256-dIveiaiPFGSItwLyeMuPDxTE9gpvvnlTCB/+nG24qCc=";
        };
      })
    else
      pkgs.opencode;
in
{
  home.packages = available (
    [
      claude-code
      codex
      opencode
    ]
    ++ (with pkgs; [
      pi-coding-agent
      skills
    ])
  );
}
