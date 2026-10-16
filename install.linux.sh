#!/bin/sh
# Bootstrap a Linux host to the point where home-manager can take over: Nix
# itself, then the first switch. Nothing here depends on the distribution --
# home-manager's targets.genericLinux absorbs the differences -- so Ubuntu,
# Debian and Arch all run the same steps. Each step is skipped when it is
# already in place, so re-running the script is safe.
#
# Packages and dotfiles come from nix/modules/home. After the first switch,
# `.sync` (zsh/.zshrc) is the only command needed.
set -eu

repo="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
# `hostname` is not installed everywhere (Arch keeps it in inetutils).
host="$(uname -n)"
target="$USER@${host%%.*}"
nix=/nix/var/nix/profiles/default/bin/nix

# Fail before installing anything if this host has no entry in the flake.
# Nix may not exist yet, so read flake.nix as text rather than evaluating it.
if ! grep -q "\"$target\" = mkHome" "$repo/nix/flake.nix"; then
  echo "install.linux.sh: nix/flake.nix has no homeConfigurations.\"$target\"" >&2
  exit 1
fi

# Nix itself, multi-user. The installer asks for sudo and needs systemd.
if ! [ -x "$nix" ]; then
  echo "==> Installing Nix"
  curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes
fi
# The installer's profile.d hook only reaches new shells, and home-manager's
# activation calls nix-build by name, so put Nix on this shell's PATH too.
PATH=/nix/var/nix/profiles/default/bin:$PATH

# The previous version of this script linked these straight into the working
# tree. Left in place, ~/.config/git would make home-manager write its links
# into the repo, so remove any that still point here -- and nothing else.
for f in .bash_aliases .editorconfig .config/git .vim; do
  if [ -L "$HOME/$f" ]; then
    case "$(readlink "$HOME/$f")" in
      "$repo"/*) rm "$HOME/$f" ;;
    esac
  fi
done

if [ -x "$HOME/.nix-profile/bin/home-manager" ]; then
  echo "==> home-manager is already installed; use .sync from here on"
else
  # First switch only. The home-manager command does not exist yet, so run the
  # activation script of the flake's own pinned home-manager instead. Files in
  # the way are renamed to *.hm-bak rather than overwritten.
  echo "==> Activating home-manager for $target"
  HOME_MANAGER_BACKUP_EXT=hm-bak "$nix" --extra-experimental-features 'nix-command flakes' \
    run "$repo/nix#homeConfigurations.\"$target\".activationPackage"
fi

# lua-json5 (nvim) builds with cargo, and nixpkgs' rustup ships with no
# default toolchain, so cargo refuses to run until one is chosen.
rustup="$HOME/.nix-profile/bin/rustup"
if [ -x "$rustup" ] && ! "$rustup" default >/dev/null 2>&1; then
  echo "==> Installing the stable Rust toolchain"
  "$rustup" default stable
fi
