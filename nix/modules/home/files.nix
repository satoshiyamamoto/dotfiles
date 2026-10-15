# Every dotfile link, replacing what GNU Stow used to do. The layout under each
# package still mirrors $HOME, so the source paths below read the same as the
# old stow tree -- only the linking changed. CLAUDE.md "Dotfile Links" explains
# when an entry belongs in the store half and when it has to be `live`.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  repo = "Projects/src/github.com/satoshiyamamoto/dotfiles";

  # Link at the working tree rather than the Nix store. A package needs
  # this when its tool writes where the link points, which a store path
  # -- read-only -- cannot allow:
  #   - it rewrites the file itself: `docker context use`,
  #     `moshi-hook set`, Codex and Claude Code saving settings
  #   - it writes siblings into the same directory: lazy-lock.json,
  #     Karabiner's automatic_backups, brew's trust.json, hunk's
  #     state.json, and the plugin trees under ~/.vim and ~/.config/tmux
  # ghostty is here for a third reason: its shaders are git submodules,
  # which the flake does not copy into the store at all.
  live = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${repo}/${path}";

  # Single files the tool rewrites, linked live.
  #
  # ~/.claude is linked per file, not as a directory: upstream splits
  # that directory into user config and machine-local state
  # (projects/, history.jsonl, shell-snapshots/, .credentials.json),
  # and only settings.json is tracked here. A directory link would
  # drag tens of thousands of state files into the working tree, which
  # is what stow did.
  liveFiles = {
    ".claude/settings.json" = "claude/.claude/settings.json";
    ".codex/config.toml" = "codex/.codex/config.toml";
    ".codex/hooks.json" = "codex/.codex/hooks.json";
    ".codex/rules/default.rules" = "codex/.codex/rules/default.rules";
    ".config/moshi/config.toml" = "moshi/.config/moshi/config.toml";
    ".hermes/SOUL.md" = "hermes/.hermes/SOUL.md";
    ".hermes/config.yaml" = "hermes/.hermes/config.yaml";
  };
in
{
  home.file = {
    # Read-only copies in the Nix store.
    ".bash_aliases".source = ../../../bash/.bash_aliases;
    ".config/bat/config".source = ../../../bat/.config/bat/config;
    ".config/bat/themes/tokyonight_day.tmTheme".source =
      ../../../bat/.config/bat/themes/tokyonight_day.tmTheme;
    ".config/bat/themes/tokyonight_moon.tmTheme".source =
      ../../../bat/.config/bat/themes/tokyonight_moon.tmTheme;
    ".config/bat/themes/tokyonight_night.tmTheme".source =
      ../../../bat/.config/bat/themes/tokyonight_night.tmTheme;
    ".config/bat/themes/tokyonight_storm.tmTheme".source =
      ../../../bat/.config/bat/themes/tokyonight_storm.tmTheme;
    ".config/eza/theme.yml".source = ../../../eza/.config/eza/theme.yml;
    ".config/fd/ignore".source = ../../../fd/.config/fd/ignore;
    ".config/gh-dash/config.yml".source = ../../../gh-dash/.config/gh-dash/config.yml;
    ".config/gh/config.yml".source = ../../../gh/.config/gh/config.yml;
    ".config/git/ignore".source = ../../../git/.config/git/ignore;
    ".config/glow/glow.yml".source = ../../../glow/.config/glow/glow.yml;
    ".config/herdr/config.toml".source = ../../../herdr/.config/herdr/config.toml;
    ".config/k9s/aliases.yaml".source = ../../../k9s/.config/k9s/aliases.yaml;
    ".config/k9s/config.yaml".source = ../../../k9s/.config/k9s/config.yaml;
    ".config/k9s/skins/transparent.yaml".source = ../../../k9s/.config/k9s/skins/transparent.yaml;
    ".config/kitty/current-theme.conf".source = ../../../kitty/.config/kitty/current-theme.conf;
    ".config/kitty/kitty-icon.sh".source = ../../../kitty/.config/kitty/kitty-icon.sh;
    ".config/kitty/kitty.conf".source = ../../../kitty/.config/kitty/kitty.conf;
    ".config/kitty/themes/tokyo-night-kitty.conf".source =
      ../../../kitty/.config/kitty/themes/tokyo-night-kitty.conf;
    ".config/lazygit/config.yml".source = ../../../lazygit/.config/lazygit/config.yml;
    ".config/mise/config.toml".source = ../../../mise/.config/mise/config.toml;
    ".config/p10k.zsh".source = ../../../powerlevel10k/.config/p10k.zsh;
    ".config/sqlfluff".source = ../../../sqlfluff/.config/sqlfluff;
    ".config/sqlite3/sqliterc".source = ../../../sqlite/.config/sqlite3/sqliterc;
    # starship belongs here even though `starship config` writes: it does
    # not write through a symlink at all, it replaces the link with a
    # regular file, so pointing at the working tree would gain nothing.
    # force: that regular file only ever holds a `kubeon`/`vpnoff` toggle,
    # and a second one would collide with the single-generation .hm-bak
    # and abort activation, so it is overwritten rather than backed up.
    ".config/starship-minimal.toml".source = ../../../starship/.config/starship-minimal.toml;
    ".config/starship.toml".source = ../../../starship/.config/starship.toml;
    ".config/starship.toml".force = true;
    ".config/worktrunk/config.toml".source = ../../../worktrunk/.config/worktrunk/config.toml;
    ".config/yamlfmt/yamlfmt".source = ../../../yamlfmt/.config/yamlfmt/yamlfmt;
    ".config/yazi/flavors/tokyo-night.yazi/LICENSE".source =
      ../../../yazi/.config/yazi/flavors/tokyo-night.yazi/LICENSE;
    ".config/yazi/flavors/tokyo-night.yazi/LICENSE-tmtheme".source =
      ../../../yazi/.config/yazi/flavors/tokyo-night.yazi/LICENSE-tmtheme;
    ".config/yazi/flavors/tokyo-night.yazi/README.md".source =
      ../../../yazi/.config/yazi/flavors/tokyo-night.yazi/README.md;
    ".config/yazi/flavors/tokyo-night.yazi/flavor.toml".source =
      ../../../yazi/.config/yazi/flavors/tokyo-night.yazi/flavor.toml;
    ".config/yazi/flavors/tokyo-night.yazi/preview.png".source =
      ../../../yazi/.config/yazi/flavors/tokyo-night.yazi/preview.png;
    ".config/yazi/flavors/tokyo-night.yazi/tmtheme.xml".source =
      ../../../yazi/.config/yazi/flavors/tokyo-night.yazi/tmtheme.xml;
    ".config/yazi/theme.toml".source = ../../../yazi/.config/yazi/theme.toml;
    ".config/zed/keymap.json".source = ../../../zed/.config/zed/keymap.json;
    ".config/zed/settings.json".source = ../../../zed/.config/zed/settings.json;
    ".config/zellij/config.kdl".source = ../../../zellij/.config/zellij/config.kdl;
    ".editorconfig".source = ../../../editorconfig/.editorconfig;
    ".puppeteerrc.cjs".source = ../../../puppeteer/.puppeteerrc.cjs;
    ".testcontainers.properties".source = ../../../testcontainers/.testcontainers.properties;
    ".zprofile".source = ../../../zsh/.zprofile;
    ".zshenv".source = ../../../zsh/.zshenv;
    ".zshrc".source = ../../../zsh/.zshrc;

    # Whole directories the tool owns, linked live.
    ".config/ghostty".source = live "ghostty/.config/ghostty";
    ".config/hunk".source = live "hunk/.config/hunk";
    ".config/nvim".source = live "nvim/.config/nvim";
    ".config/tmux".source = live "tmux/.config/tmux";
    ".vim".source = live "vim/.vim";
  }
  // lib.mapAttrs (_: p: { source = live p; }) liveFiles
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
    # Everything in it is per-Mac: currentContext names colima's context and
    # credsStore is osxkeychain. Linux keeps a local config of its own, so
    # its docker uses the default context, the host's /var/run/docker.sock.
    ".docker/config.json".source = live "docker/.docker/config.json";
    ".config/git/config".source = ../../../git/.config/git/config;
    ".config/git/config.darwin".source = ../../../git/.config/git/config.darwin;
    ".config/kitty/macos-launch-services-cmdline".source =
      ../../../kitty/.config/kitty/macos-launch-services-cmdline;
    ".config/homebrew".source = live "homebrew/.config/homebrew";
    ".config/karabiner".source = live "karabiner/.config/karabiner";
  }
  // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    # git/config includes config.darwin by name. install.linux.sh used to sed
    # that in place, which a read-only store copy cannot take, so Linux gets
    # the same file with the include pointed at config.linux instead.
    ".config/git/config".text = builtins.replaceStrings [ "config.darwin" ] [ "config.linux" ] (
      builtins.readFile ../../../git/.config/git/config
    );
    ".config/git/config.linux".source = ../../../git/.config/git/config.linux;
  };

  # moshi-hook's auto-update reruns `install`, which replaces these links
  # with regular files, and a second replacement collides with the
  # single-generation .hm-bak and aborts activation. Move the file back
  # into the repo instead so the link is recreated; the moshi additions
  # then show up in `git diff`. A repo copy newer than the file wins.
  # Only a path the previous generation linked is adopted: on a first
  # switch the file is whatever the tool created on its own (Claude Code
  # writes a bare {"theme": "auto"}), and adopting it would overwrite the
  # tracked config. Such a file falls through to the usual .hm-bak.
  home.activation.adoptReplacedLiveFiles = lib.hm.dag.entryBefore [ "checkLinkTargets" ] (
    lib.concatStrings (
      lib.mapAttrsToList (t: p: ''
        f="$HOME/${t}" r="$HOME/${repo}/${p}"
        if [ -f "$f" ] && [ ! -L "$f" ] && [ ! "$r" -nt "$f" ] \
          && [ -n "''${oldGenPath:-}" ] && [ -e "$oldGenPath/home-files/${t}" ]; then
          run mv "$f" "$r"
        fi
      '') liveFiles
    )
  );

  # bat reads only the compiled ~/.cache/bat, never themes/*.tmTheme
  # directly, so the linked tokyonight themes are unknown until built.
  home.activation.batCache = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run ${pkgs.bat}/bin/bat cache --build >/dev/null
  '';
}
