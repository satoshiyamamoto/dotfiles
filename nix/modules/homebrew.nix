# What stays on Homebrew: one formula from a personal tap, the GUI casks with no
# nixpkgs equivalent, and the Mac App Store apps. docs/nix-migration.md section
# 3.2 records why, and section 4.4 records how the Brewfile maps onto this.
#
# darwin-rebuild runs `brew bundle --file=<nix store Brewfile>`, so the Brewfile
# in this repo is no longer read -- it is removed from the homebrew stow package
# in the same commit.
{
  homebrew = {
    enable = true;

    # Anything not declared above is uninstalled: the Brewfile in this repo is
    # gone, so Homebrew's own state is no longer a second source of truth.
    # "zap" is never used -- it deletes cask app settings and Application
    # Support data along with the app.
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "uninstall";
    };

    global.autoUpdate = false;

    # No caskArgs. --no-quarantine has been a silent no-op since Homebrew 6.x
    # and upgrades inherit Gatekeeper approval on their own -- see CLAUDE.md.

    taps = [ "rjyo/moshi" ];

    # The only formula left. `trusted` defaults to true for fully-qualified
    # names, which is what HOMEBREW_REQUIRE_TAP_TRUST wants for a personal tap.
    brews = [
      {
        name = "rjyo/moshi/moshi-hook";
        restart_service = "changed";
      }
    ];

    # Fonts moved to fonts.packages, gcloud-cli and the four CLI casks
    # (claude-code@latest, codex, grok-build, antigravity-cli) to nixpkgs.
    casks = [
      "chatgpt"
      "claude"
      "figma"
      "ghostty"
      "git-credential-manager"
      "google-chrome"
      "google-drive"
      "karabiner-elements"
      "kitty"
      "licecap"
      "notion"
      "qlmarkdown"
      "slack"
      "syntax-highlight"
      "tradingview"
      "visual-studio-code"
      "zed"
      "zoom"
    ];

    # Removing an entry here does not uninstall the app: Homebrew Bundle has no
    # mas cleanup, so `cleanup = "uninstall"` skips them.
    masApps = {
      "AdGuard Mini" = 1440147259;
      GarageBand = 682658836;
      "Hidden Bar" = 1452453066;
      iMovie = 408981434;
      "JSON Peep" = 1458969831;
      Keynote = 409183694;
      Kindle = 302584613;
      Noir = 1592917505;
      Numbers = 409203825;
      Pages = 409201541;
      Speedtest = 1153157709;
      Tailscale = 1475387142;
      Vimlike = 1584519802;
      Xcode = 497799835;
    };
  };
}
