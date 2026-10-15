# AI coding agents. The AI CLIs are not self-updating -- see CLAUDE.md.
{ inputs, pkgs, ... }:
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
in
{
  home.packages = [
    claude-code
  ]
  ++ (with pkgs; [
    codex
    opencode
    pi-coding-agent
    skills
  ]);
}
