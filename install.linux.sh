#!/bin/sh
# Bootstrap a Linux host to the point where home-manager can take over: Nix
# itself, then the first switch and the host's NSS proxy when LDAP is used.
# Packages come from Nix on every distribution; systemd manages the proxy.
# Re-running the script is safe.
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

# Nix raises its soft stack limit to 60 MiB, but cannot exceed the hard limit.
stack_hard="$(ulimit -Hs)"
if [ "$stack_hard" != unlimited ] && [ "$stack_hard" -lt 61440 ]; then
  echo "==> Raising the stack hard limit to 60 MiB for $USER"
  printf '%s hard stack 61440\n' "$USER" |
    sudo tee "/etc/security/limits.d/99-nix-stack-$USER.conf" >/dev/null
  # PAM applies the file at login; update this installer process immediately.
  sudo prlimit --pid "$$" --stack=:62914560
  echo "==> Log out and back in to apply the stack limit to your terminal too"
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

# Ubuntu 24.04+ restricts the user namespaces Chromium needs for its sandbox.
# Keep the host restriction and allow only Nix Chromium's executable paths.
if [ -r /proc/sys/kernel/apparmor_restrict_unprivileged_userns ] &&
  [ "$(cat /proc/sys/kernel/apparmor_restrict_unprivileged_userns)" = 1 ]; then
  echo "==> Configuring Chromium's AppArmor sandbox permission"
  sudo install -o root -g root -m 0644 "$HOME/.config/apparmor.d/nix-chromium" /etc/apparmor.d/nix-chromium
  sudo /sbin/apparmor_parser -r /etc/apparmor.d/nix-chromium
fi

# Nix clients cannot load the host's LDAP NSS module, so use a shared proxy.
if grep -Eq '^(passwd|group):.*[[:space:]]sss([[:space:]]|$)' /etc/nsswitch.conf; then
  if ! [ -x "$HOME/.nix-profile/bin/nsncd" ]; then
    "$HOME/.nix-profile/bin/home-manager" switch -b hm-bak --flake "$repo/nix"
  fi
  echo "==> Configuring the NSS proxy"
  sudo tee /etc/systemd/system/nsncd.service >/dev/null <<EOF
[Unit]
Description=NSS proxy for Nix clients
After=sssd.service

[Service]
ExecStart="$HOME/.nix-profile/bin/nsncd"
DynamicUser=yes
RuntimeDirectory=nscd
Type=notify
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
  sudo systemctl daemon-reload
  sudo systemctl enable --now nsncd.service
fi

# lua-json5 (nvim) builds with cargo, and nixpkgs' rustup ships with no
# default toolchain, so cargo refuses to run until one is chosen.
rustup="$HOME/.nix-profile/bin/rustup"
if [ -x "$rustup" ] && ! "$rustup" default >/dev/null 2>&1; then
  echo "==> Installing the stable Rust toolchain"
  "$rustup" default stable
fi

# cycloud and cdap stay out of the flake so they can update themselves, and
# their repos are internal, so take the latest release through gh's own login.
# Once installed they are left alone: later updates are theirs to make.
gh="$HOME/.nix-profile/bin/gh"
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
