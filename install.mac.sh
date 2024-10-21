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
  sqls
  starship
  vim
  yamlfmt
  zellij
  # zprezto
  zsh
)

for package in "${packages[@]}"; do
  stow -v $package -t $HOME
done
