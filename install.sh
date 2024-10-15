#!/bin/bash
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
DOTFILES="$(cd $(dirname $0) && pwd)"
cd "$DOTFILES"

# User HOME directories
ln -si $DOTFILES/bash/.bash_aliases $HOME/.bash_aliases
ln -si $DOTFILES/editorconfig/.editorconfig $HOME/.editorconfig

## Set the XDG config
mkdir -p $XDG_CONFIG_HOME/git
ln -si $DOTFILES/git/.config/git/config.linux $XDG_CONFIG_HOME/git/config

## Set the Vimrc
mkdir -p $HOME/.vim
ln -si $DOTFILES/vim/.vimrc $HOME/.vim/vimrc
