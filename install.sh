#!/bin/bash
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
WORKDIR="$(cd $(dirname $0) && pwd)"
cd "$WORKDIR"

# User HOME directories
ln -si ${WORKDIR}/aliases ${HOME}/.bash_aliases
ln -si ${WORKDIR}/editorconfig ${HOME}/.editorconfig

## Set the XDG config
mkdir -p ${XDG_CONFIG_HOME}/git
ln -si ${WORKDIR}/config/git/config ${XDG_CONFIG_HOME}/git/config

## Set the Vimrc
mkdir -p ${HOME}/.vim
ln -si ${WORKDIR}/vim/vimrc ${HOME}/.vim/vimrc
