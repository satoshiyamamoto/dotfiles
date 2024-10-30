#!/bin/bash
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

mkdir -p \
  "$HOME/.vim" \
  "$XDG_CONFIG_HOME/git"

## Deploy dotfiles
cd $(realpath "$(dirname "$0")")
ln -si bash/.bash_aliases "$HOME/.bash_aliases"
ln -si editorconfig/.editorconfig "$HOME/.editorconfig"
ln -si vim/.vimrc "$HOME/.vim/vimrc"
ln -si git/.config/git/config.linux "$XDG_CONFIG_HOME/git/config"
