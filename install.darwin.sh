#!/bin/sh
# Bootstrap a Mac to the point where nix-darwin can take over. Every step here
# installs something the flake cannot install for itself: Xcode's command line
# tools, Homebrew (nix-darwin runs `brew bundle` but never installs brew), the
# git submodules, and Nix. Each step is skipped when it is already in place, so
# re-running the script is safe.
#
# Dotfiles themselves are no longer this script's business -- home-manager links
# them from nix/modules/home. After the first switch, `.sync` (zsh/.zshrc)
# is the only command needed.
set -eu

repo="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
host="$(scutil --get LocalHostName)"
nix=/nix/var/nix/profiles/default/bin/nix

# Fail before installing anything if this machine has no entry in the flake.
# Nix may not exist yet, so read flake.nix as text rather than evaluating it.
if ! grep -q "\"$host\" = mkDarwin" "$repo/nix/flake.nix"; then
  echo "install.darwin.sh: nix/flake.nix has no darwinConfigurations.\"$host\"" >&2
  exit 1
fi

# Command Line Tools. The GUI installer cannot be waited on, so stop and let
# the user re-run once it finishes.
if ! xcode-select -p >/dev/null 2>&1; then
  echo "==> Installing the Command Line Tools"
  xcode-select --install
  echo "Re-run this script when the installer finishes." >&2
  exit 1
fi

# Homebrew. The prefix is architecture-dependent -- /opt/homebrew on Apple
# Silicon, /usr/local on Intel -- and brew is not on PATH until a shell picks
# up its shellenv, so probe both paths instead of using `command -v`.
if ! [ -x /opt/homebrew/bin/brew ] && ! [ -x /usr/local/bin/brew ]; then
  echo "==> Installing Homebrew"
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# ghostty's shaders are submodules. They are linked straight out of the working
# tree, so an uninitialised submodule leaves ghostty with an empty directory.
echo "==> Updating git submodules"
git -C "$repo" submodule update --init --recursive

# Nix itself.
if ! [ -x "$nix" ]; then
  echo "==> Installing Nix"
  curl -sSfL https://artifacts.nixos.org/nix-installer | sh -s -- install --enable-flakes
fi

if [ -x /run/current-system/sw/bin/darwin-rebuild ]; then
  echo "==> nix-darwin is already installed; use .sync from here on"
else
  # First switch only. darwin-rebuild does not exist yet, so build the system
  # closure and run the copy that lives inside it.
  echo "==> Building the system closure for $host"
  system="$("$nix" build --no-link --print-out-paths "$repo/nix#darwinConfigurations.$host.system")"
  echo "==> Activating"
  sudo "$system/sw/bin/darwin-rebuild" switch --flake "$repo/nix"
fi

# lua-json5 (nvim) builds with cargo, and nixpkgs' rustup ships with no
# default toolchain, so cargo refuses to run until one is chosen.
rustup=/etc/profiles/per-user/$USER/bin/rustup
if [ -x "$rustup" ] && ! "$rustup" default >/dev/null 2>&1; then
  echo "==> Installing the stable Rust toolchain"
  "$rustup" default stable
fi

# cycloud and cdap stay out of the flake so they can update themselves, and
# their repos are internal, so take the latest release through gh's own login.
# Once installed they are left alone: later updates are theirs to make.
gh=/etc/profiles/per-user/$USER/bin/gh
os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m | sed 's/x86_64/amd64/; s/aarch64/arm64/')"
# <repo> <binary> <asset prefix>
fetch_release() {
  [ -x "$HOME/.local/bin/$2" ] && return
  echo "==> Installing $2"
  # Unpack beside, then move, so an interrupted download leaves no binary
  # behind for the -x check above to mistake for a finished install.
  tmp="$(mktemp -d)"
  "$gh" release download --repo "$1" --pattern "$3_${os}_${arch}.tar.gz" -O - |
    tar -xzf - -C "$tmp" "$2"
  mv "$tmp/$2" "$HOME/.local/bin/$2"
  rmdir "$tmp"
}
if [ -x "$gh" ] && "$gh" auth status --active >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  fetch_release cycloud-io/cycloud-cli cycloud cycloud
  fetch_release ca-data-pf/cdap-cli cdap 'cdap-cli_*'
else
  echo "==> Skipping cycloud and cdap: run 'gh auth login', then re-run this script" >&2
fi
