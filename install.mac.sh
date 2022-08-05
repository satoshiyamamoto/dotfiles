#!/bin/bash
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
WORKDIR="$(cd $(dirname $0) && pwd)"
cd "$WORKDIR"

# User HOME directories
ln -si ${WORKDIR}/editorconfig ${HOME}/.editorconfig
ln -si ${WORKDIR}/sqliterc ${HOME}/.sqliterc

## Set the XDG config
mkdir -p ${XDG_CONFIG_HOME}/{git,bat,fd,kitty,intelephense,nvim/ftplugin,sqls,tmux}
ln -si ${WORKDIR}/config/git/config.mac ${XDG_CONFIG_HOME}/git/config
ln -si ${WORKDIR}/config/bat/config ${XDG_CONFIG_HOME}/bat/config
ln -si ${WORKDIR}/config/fd/ignore ${XDG_CONFIG_HOME}/fd/ignore
ln -si ${WORKDIR}/config/kitty/kitty.conf ${XDG_CONFIG_HOME}/kitty/kitty.conf
ln -si ${WORKDIR}/config/nvim/init.lua ${XDG_CONFIG_HOME}/nvim/init.lua
ln -si ${WORKDIR}/config/nvim/ftplugin/java.lua ${XDG_CONFIG_HOME}/nvim/ftplugin/java.lua
ln -si ${WORKDIR}/config/sqls/config.yml ${XDG_CONFIG_HOME}/sqls/config.yml
ln -si ${WORKDIR}/config/tmux/tmux.conf ${XDG_CONFIG_HOME}/tmux/tmux.conf
ln -si ${WORKDIR}/config/zsh/zshrc ${XDG_CONFIG_HOME}/zsh/.zshrc
ln -si ${WORKDIR}/config/zsh/zpreztorc ${XDG_CONFIG_HOME}/zsh/.zpreztorc

## Set the Vimrc
mkdir -p ${HOME}/.vim
ln -si ${WORKDIR}/vim/vimrc ${HOME}/.vim/vimrc

## Set the Terminal fonts
tic -x ${WORKDIR}/terminfo/xterm-256color-italic.terminfo
tic -x ${WORKDIR}/terminfo/tmux-256color.terminfo
