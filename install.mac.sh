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
