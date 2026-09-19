# Settings every host shares. Anything that differs per machine -- platform,
# primary user -- stays in hosts/<hostname>.nix.
{
  # Required: the default (system.maxStateVersion) trips an assertion in
  # nix-darwin's modules/system/version.nix. 7 is that current value, which is
  # what the assertion itself recommends for a new install.
  system.stateVersion = 7;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # nix-darwin generates /etc/zshrc, which is sourced before ~/.zshrc. Its
  # defaults would run a plain `compinit` there, defeating the `zsh-defer
  # compinit -C` in ~/.zshrc, and set a prompt that starship replaces anyway.
  # programs.zsh.enable itself stays on: /etc/zshenv is what puts
  # /run/current-system/sw/bin on PATH.
  programs.zsh = {
    enableCompletion = false;
    enableBashCompletion = false;
    promptInit = "";
  };

  # Replaces the hand-written /etc/pam.d/sudo_local from macos-setup.md.
  # pam-reattach comes from nixpkgs instead of /opt/homebrew/lib/pam, so it
  # need not be in environment.systemPackages.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };
}
