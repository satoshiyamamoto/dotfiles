#!/bin/bash
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
WORKDIR="$(cd $(dirname $0) && pwd)"
cd "$WORKDIR"

# User HOME directories
ln -si ${WORKDIR}/editorconfig ${HOME}/.editorconfig
ln -si ${WORKDIR}/sqliterc ${HOME}/.sqliterc

## Set the XDG config
source ${HOME}/.zshenv
mkdir -p ${XDG_CONFIG_HOME}/{git,bat,fd,kitty,nvim/ftplugin,tmux}
ln -si ${WORKDIR}/config/git/config.mac ${XDG_CONFIG_HOME}/git/config
ln -si ${WORKDIR}/config/bat/config ${XDG_CONFIG_HOME}/bat/config
ln -si ${WORKDIR}/config/fd/ignore ${XDG_CONFIG_HOME}/fd/ignore
ln -si ${WORKDIR}/config/kitty/kitty.conf ${XDG_CONFIG_HOME}/kitty/kitty.conf
ln -si ${WORKDIR}/config/nvim/init.lua ${XDG_CONFIG_HOME}/nvim/init.lua
ln -si ${WORKDIR}/config/nvim/ftplugin/java.lua ${XDG_CONFIG_HOME}/nvim/ftplugin/java.lua
ln -si ${WORKDIR}/config/tmux/tmux.conf ${XDG_CONFIG_HOME}/tmux/tmux.conf

## Set the Zsh config
cat << 'EOL' >> ${XDG_CONFIG_HOME}/zsh/.zshrc
export DOTFILES="${HOME}/Develop/src/github.com/satoshiyamamoto/dotfiles"
[ -f "${DOTFILES}/env" ] && source "${DOTFILES}/env"
[ -f "${DOTFILES}/functions" ] && source "${DOTFILES}/functions"
[ -f "${DOTFILES}/aliases.mac" ] && source "${DOTFILES}/aliases.mac"
[ -f "${HOME}/.fzf.zsh" ] && source "${HOME}/.fzf.zsh"
[ -f "${HOME}/.cargo/env" ] && source "${HOME}/.cargo/env"
[ -f "${HOME}/.sdkman/bin/sdkman-init.sh" ] && source "${HOME}/.sdkman/bin/sdkman-init.sh"

which anyenv > /dev/null && eval "$(anyenv init -)"
EOL

## Set the Vimrc
mkdir -p ${HOME}/.vim
ln -si ${WORKDIR}/vim/vimrc ${HOME}/.vim/vimrc

## Set the Terminal fonts
tic -x ${WORKDIR}/terminfo/xterm-256color-italic.terminfo
