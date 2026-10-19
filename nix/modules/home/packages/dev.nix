# Language toolchains, build tools, linters/formatters and database clients.
{ available, pkgs, ... }:
{
  home.packages = available (
    with pkgs;
    [
      biome
      buf
      caddy
      delve
      devcontainer
      duckdb
      go
      go-tools
      golangci-lint
      google-java-format
      gopls
      gotools
      gradle
      grpc
      grpcurl
      hey
      # nvim-httpyac shells out to it to send .http requests
      httpyac
      jd-diff-patch
      # jdk21, not jdk: on darwin every JDK attribute is Azul Zulu, and plain
      # `jdk` is nixpkgs' default-LTS pointer -- today it resolves to the same
      # derivation as jdk21, but it moves on its own when the default LTS bumps.
      jdk21
      jwt-cli
      lefthook
      litecli
      luarocks
      maven
      mermaid-cli
      mysql84
      nodejs
      pgcli
      pnpm
      prettier
      protobuf
      # python3, not a pinned pythonNNN: the channel default is what every other
      # python app in that channel is built against -- 3.14.7 on unstable, 3.13.15
      # on Kenya's 26.05 pin. Following it keeps each host to a single interpreter
      # and inside the binary cache, where a pin would force source builds on the
      # channel that has moved on.
      python3
      ruff
      rustup
      sqlfluff
      stylua
      ttyd
      uv
      yamlfmt
    ]
  );
}
