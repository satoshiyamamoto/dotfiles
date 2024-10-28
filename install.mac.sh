packages=(
  alacritty
  bat
  editorconfig
  fd
  flake8
  git
  glow
  kitty
  lazygit
  nvim
  powerlevel10k
  sqlfluff
  sqlite
  starship
  vim
  yamlfmt
  zellij
  zsh
)

for package in "${packages[@]}"; do
  stow -v $package -t $HOME
done

# Not a stow package
package=$(find vimari | sed 's#^vimari/##' | grep userSettings.json)
if [[ -f "$HOME/$package" ]]; then
  cp "vimari/$package" "$HOME/$package"
fi
