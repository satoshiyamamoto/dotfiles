# Every dotfile link, replacing what GNU Stow used to do. The layout under each
# package still mirrors $HOME, so the source paths below read the same as the
# old stow tree -- only the linking changed. CLAUDE.md "Dotfile Links" explains
# when an entry belongs in the store half and when it has to be `live`.
{ config, ... }:
let
  repo = "Projects/src/github.com/satoshiyamamoto/dotfiles";
  # Bound out here because the per-user module below shadows `config` with
  # home-manager's own.
  user = config.system.primaryUser;
in
{
  # home-manager reads the account's home directory from here. nix-darwin only
  # creates accounts listed in users.knownUsers, so declaring it does not put
  # this repo in charge of macOS user management.
  users.users.${user}.home = "/Users/${user}";

  home-manager = {
    # Build against the system's own pkgs and put per-user paths in
    # /etc/profiles/per-user, which zsh/.zprofile already has on PATH.
    useGlobalPkgs = true;
    useUserPackages = true;
    # Never clobber a file that is already there -- rename it instead. This is
    # what makes the first switch on a stow machine recoverable.
    backupFileExtension = "hm-bak";

    users.${user} =
      { config, ... }:
      let
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
      in
      {
        # Matches the oldest home-manager in flake.nix (Kenya's 26.05); the
        # option only gates behaviour changes, so one value serves every host.
        home.stateVersion = "26.05";

        home.file = {
          # Read-only copies in the Nix store.
          ".bash_aliases".source = ../../bash/.bash_aliases;
          ".config/bat/config".source = ../../bat/.config/bat/config;
          ".config/bat/themes/tokyonight_day.tmTheme".source =
            ../../bat/.config/bat/themes/tokyonight_day.tmTheme;
          ".config/bat/themes/tokyonight_moon.tmTheme".source =
            ../../bat/.config/bat/themes/tokyonight_moon.tmTheme;
          ".config/bat/themes/tokyonight_night.tmTheme".source =
            ../../bat/.config/bat/themes/tokyonight_night.tmTheme;
          ".config/bat/themes/tokyonight_storm.tmTheme".source =
            ../../bat/.config/bat/themes/tokyonight_storm.tmTheme;
          ".config/eza/theme.yml".source = ../../eza/.config/eza/theme.yml;
          ".config/fd/ignore".source = ../../fd/.config/fd/ignore;
          ".config/gh-dash/config.yml".source = ../../gh-dash/.config/gh-dash/config.yml;
          ".config/gh/config.yml".source = ../../gh/.config/gh/config.yml;
          ".config/git/config".source = ../../git/.config/git/config;
          ".config/git/config.darwin".source = ../../git/.config/git/config.darwin;
          ".config/git/config.linux".source = ../../git/.config/git/config.linux;
          ".config/git/ignore".source = ../../git/.config/git/ignore;
          ".config/glow/glow.yml".source = ../../glow/.config/glow/glow.yml;
          ".config/herdr/config.toml".source = ../../herdr/.config/herdr/config.toml;
          ".config/k9s/aliases.yaml".source = ../../k9s/.config/k9s/aliases.yaml;
          ".config/k9s/config.yaml".source = ../../k9s/.config/k9s/config.yaml;
          ".config/k9s/skins/transparent.yaml".source = ../../k9s/.config/k9s/skins/transparent.yaml;
          ".config/kitty/current-theme.conf".source = ../../kitty/.config/kitty/current-theme.conf;
          ".config/kitty/kitty-icon.sh".source = ../../kitty/.config/kitty/kitty-icon.sh;
          ".config/kitty/kitty.conf".source = ../../kitty/.config/kitty/kitty.conf;
          ".config/kitty/macos-launch-services-cmdline".source =
            ../../kitty/.config/kitty/macos-launch-services-cmdline;
          ".config/kitty/themes/tokyo-night-kitty.conf".source =
            ../../kitty/.config/kitty/themes/tokyo-night-kitty.conf;
          ".config/lazygit/config.yml".source = ../../lazygit/.config/lazygit/config.yml;
          ".config/mise/config.toml".source = ../../mise/.config/mise/config.toml;
          ".config/p10k.zsh".source = ../../powerlevel10k/.config/p10k.zsh;
          ".config/sqlfluff".source = ../../sqlfluff/.config/sqlfluff;
          ".config/sqlite3/sqliterc".source = ../../sqlite/.config/sqlite3/sqliterc;
          # starship belongs here even though `starship config` writes: it does
          # not write through a symlink at all, it replaces the link with a
          # regular file, so pointing at the working tree would gain nothing.
          ".config/starship-minimal.toml".source = ../../starship/.config/starship-minimal.toml;
          ".config/starship.toml".source = ../../starship/.config/starship.toml;
          ".config/worktrunk/config.toml".source = ../../worktrunk/.config/worktrunk/config.toml;
          ".config/yamlfmt/yamlfmt".source = ../../yamlfmt/.config/yamlfmt/yamlfmt;
          ".config/yazi/flavors/tokyo-night.yazi/LICENSE".source =
            ../../yazi/.config/yazi/flavors/tokyo-night.yazi/LICENSE;
          ".config/yazi/flavors/tokyo-night.yazi/LICENSE-tmtheme".source =
            ../../yazi/.config/yazi/flavors/tokyo-night.yazi/LICENSE-tmtheme;
          ".config/yazi/flavors/tokyo-night.yazi/README.md".source =
            ../../yazi/.config/yazi/flavors/tokyo-night.yazi/README.md;
          ".config/yazi/flavors/tokyo-night.yazi/flavor.toml".source =
            ../../yazi/.config/yazi/flavors/tokyo-night.yazi/flavor.toml;
          ".config/yazi/flavors/tokyo-night.yazi/preview.png".source =
            ../../yazi/.config/yazi/flavors/tokyo-night.yazi/preview.png;
          ".config/yazi/flavors/tokyo-night.yazi/tmtheme.xml".source =
            ../../yazi/.config/yazi/flavors/tokyo-night.yazi/tmtheme.xml;
          ".config/yazi/theme.toml".source = ../../yazi/.config/yazi/theme.toml;
          ".config/zed/keymap.json".source = ../../zed/.config/zed/keymap.json;
          ".config/zed/settings.json".source = ../../zed/.config/zed/settings.json;
          ".config/zellij/config.kdl".source = ../../zellij/.config/zellij/config.kdl;
          ".editorconfig".source = ../../editorconfig/.editorconfig;
          ".puppeteerrc.cjs".source = ../../puppeteer/.puppeteerrc.cjs;
          ".testcontainers.properties".source = ../../testcontainers/.testcontainers.properties;
          ".zprofile".source = ../../zsh/.zprofile;
          ".zshenv".source = ../../zsh/.zshenv;
          ".zshrc".source = ../../zsh/.zshrc;

          # Whole directories the tool owns, linked live.
          ".config/ghostty".source = live "ghostty/.config/ghostty";
          ".config/homebrew".source = live "homebrew/.config/homebrew";
          ".config/hunk".source = live "hunk/.config/hunk";
          ".config/karabiner".source = live "karabiner/.config/karabiner";
          ".config/nvim".source = live "nvim/.config/nvim";
          ".config/tmux".source = live "tmux/.config/tmux";
          ".vim".source = live "vim/.vim";

          # Single files the tool rewrites, linked live.
          #
          # ~/.claude is linked per file, not as a directory: upstream splits
          # that directory into user config and machine-local state
          # (projects/, history.jsonl, shell-snapshots/, .credentials.json),
          # and only settings.json is tracked here. A directory link would
          # drag tens of thousands of state files into the working tree, which
          # is what stow did.
          ".claude/settings.json".source = live "claude/.claude/settings.json";
          ".codex/config.toml".source = live "codex/.codex/config.toml";
          ".codex/hooks.json".source = live "codex/.codex/hooks.json";
          ".codex/rules/default.rules".source = live "codex/.codex/rules/default.rules";
          ".config/moshi/config.toml".source = live "moshi/.config/moshi/config.toml";
          ".docker/config.json".source = live "docker/.docker/config.json";
          ".hermes/SOUL.md".source = live "hermes/.hermes/SOUL.md";
          ".hermes/config.yaml".source = live "hermes/.hermes/config.yaml";
        };
      };
  };
}
