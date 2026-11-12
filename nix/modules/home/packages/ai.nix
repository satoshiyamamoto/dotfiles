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
      # shortcut: nixpkgs codex omits system libraries required by Cargo; remove when fixed upstream.
      pkgs.codex.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ [
          pkgs.aws-lc
          pkgs.oniguruma
          pkgs.sqlite
          pkgs.zlib
          pkgs.zstd
        ];
      });
in
{
  home.packages = available (
    [
      claude-code
      codex
    ]
    ++ (with pkgs; [
      opencode
      pi-coding-agent
      skills
    ])
  );
}
