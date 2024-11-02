#!/bin/bash
dotfiles="$(realpath "$(dirname "$0")")"

## Create XDG configuration directories
mkdir -p "${XDG_CONFIG_HOME:=$HOME/.config}"

## Deploy dotfiles
ln -si "$dotfiles/bash/.bash_aliases" "$HOME/.bash_aliases"
ln -si "$dotfiles/editorconfig/.editorconfig" "$HOME/.editorconfig"
ln -si "$dotfiles/git/.config/git" "$XDG_CONFIG_HOME/git"
ln -si "$dotfiles/vim/.vim" "$HOME/.vim"

sed --in-place --expression 's/.darwin/.linux/' "$XDG_CONFIG_HOME/git/config"
