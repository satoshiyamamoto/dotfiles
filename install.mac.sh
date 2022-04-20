#!/bin/bash
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
WORKDIR="$(cd $(dirname $0) && pwd)"
cd "$WORKDIR"

# User HOME directories
ln -si ${WORKDIR}/zshenv ${HOME}/.zshenv
ln -si ${WORKDIR}/tmux.conf ${HOME}/.tmux.conf
ln -si ${WORKDIR}/editorconfig ${HOME}/.editorconfig
ln -si ${WORKDIR}/tigrc ${HOME}/.tigrc

## Set the XDG config
source ${HOME}/.zshenv
mkdir -p ${XDG_CONFIG_HOME}/{git,fd,kitty,nvim,zsh}
ln -si ${WORKDIR}/config/zsh/zshrc ${ZDOTDIR}/.zshrc
ln -si ${WORKDIR}/config/zsh/zpreztorc ${ZDOTDIR}/.zpreztorc
ln -si ${WORKDIR}/config/git/config.mac ${XDG_CONFIG_HOME}/git/config
ln -si ${WORKDIR}/config/fd/ignore ${XDG_CONFIG_HOME}/fd/ignore
ln -si ${WORKDIR}/config/kitty/kitty.conf ${XDG_CONFIG_HOME}/kitty/kitty.conf
ln -si ${WORKDIR}/config/nvim/init.lua ${XDG_CONFIG_HOME}/nvim/init.lua

## Set the Vimrc
mkdir -p ${HOME}/.vim
ln -si ${WORKDIR}/vim/vimrc ${HOME}/.vim/vimrc

## Set the Terminal fonts
tic -x ${WORKDIR}/terminfo/xterm-256color-italic.terminfo
