#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#
export EDITOR=nvim
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export HISTORY_IGNORE="(ls|cd|pwd|rm|clear|man|exit)"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export KREW_PATH="$HOME/.krew"
export PYTHON_HOME="/Users/a12019/Library/Python/3.9"
export GOPATH="$HOME/Develop"
export GOROOT="$(brew --prefix)/opt/go/libexec"
export PATH="$GOROOT/bin:$GOPATH/bin:$KREW_PATH/bin:$PYTHON_HOME/bin:$PATH"
export HOMEBREW_GITHUB_API_TOKEN=c32c3959a143abdda5a7fa8359261a7dec7132ba

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
if [ -f "${HOME}/.fzf.zsh" ]; then
  source "${HOME}/.fzf.zsh"
fi

export KUBE_PS1_PATH='/usr/local/opt/kube-ps1'
export KUBE_PS1_SYMBOL_USE_IMG=false
if [ -f "${KUBE_PS1_PATH}/share/kube-ps1.sh" ]; then
  source "${KUBE_PS1_PATH}/share/kube-ps1.sh"
  PS1='$(kube_ps1)'$PS1
  kubeoff
fi

export SDKMAN_DIR="$HOME/.sdkman"
if [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

alias k='kubectl'
alias vim='nvim'
alias vpn='/opt/cisco/anyconnect/bin/vpn'
alias gsr='ghq get --look $(ghq list | fzf)'
alias gsb='git checkout $(git branch -a | fzf)'
alias ssh='TERM=xterm-256color ssh'

gi() { curl -sLw "\n" https://www.gitignore.io/api/$@ ; }

