# Stow Packages
stow --verbose --adopt --target=$HOME \
  alacritty \
  bat \
  editorconfig \
  fd \
  flake8 \
  git \
  glow \
  kitty \
  lazygit \
  nvim \
  powerlevel10k \
  sqlfluff \
  sqlite \
  starship \
  vim \
  yamlfmt \
  yazi \
  zellij \
  zsh


# Vimari
if [[ -d '/Applications/Vimari.app' ]]; then
  vimariSettings=$(find vimari -name 'userSettings.json')
  cp "$vimariSettings" "${vimariSettings/vimari/$HOME}"
fi
