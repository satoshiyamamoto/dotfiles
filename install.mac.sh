#!/bin/bash
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
WORKDIR="$(cd $(dirname $0) && pwd)"
cd "$WORKDIR"

# User HOME directories
ln -si $WORKDIR/zprofile $HOME/.zprofile
ln -si $WORKDIR/zshrc $HOME/.zshrc
ln -si $WORKDIR/zpreztorc $HOME/.zpreztorc
ln -si $WORKDIR/zpreztorc $HOME/.zpreztorc
ln -si $WORKDIR/p10k.zsh $HOME/.p10k.zsh
ln -si $WORKDIR/editorconfig $HOME/.editorconfig
ln -si $WORKDIR/flake8 $HOME/.flake8
ln -si $WORKDIR/sqliterc $HOME/.sqliterc

## Set the XDG config
mkdir -p $XDG_CONFIG_HOME/{git,bat,fd,lazygit,kitty/themes,nvim/ftplugin,yamlfmt,tmux}
ln -si $WORKDIR/config/git/config.mac $XDG_CONFIG_HOME/git/config
ln -si $WORKDIR/config/bat/config $XDG_CONFIG_HOME/bat/config
ln -si $WORKDIR/config/fd/ignore $XDG_CONFIG_HOME/fd/ignore
ln -si $WORKDIR/config/kitty/kitty.conf $XDG_CONFIG_HOME/kitty/kitty.conf
ln -si $WORKDIR/config/lazygit/config.yml $XDG_CONFIG_HOME/lazygit/config.yml
ln -si $WORKDIR/config/nvim/init.lua $XDG_CONFIG_HOME/nvim/init.lua
ln -si $WORKDIR/config/nvim/ftplugin/java.lua $XDG_CONFIG_HOME/nvim/ftplugin/java.lua
ln -si $WORKDIR/config/sqlfluff $XDG_CONFIG_HOME/sqlfluff
ln -si $WORKDIR/config/yamlfmt/yamlfmt $XDG_CONFIG_HOME/yamlfmt/.yamlfmt
ln -si $WORKDIR/config/tmux/tmux.conf $XDG_CONFIG_HOME/tmux/tmux.conf

## Set the Vimrc
mkdir -p $HOME/.vim
ln -si $WORKDIR/vim/vimrc $HOME/.vim/vimrc

## Set the Terminal fonts
tic -x $WORKDIR/terminfo/tmux-256color.terminfo
tic -x $WORKDIR/terminfo/xterm-256color.terminfo
#tic -x $WORKDIR/terminfo/xterm-kitty.terminfo

