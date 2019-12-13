#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export HISTORY_IGNORE="(ls|cd|pwd|rm|clear|man|exit)"
export GOPATH="$HOME/Develop"
export KREW_PATH="$HOME/.krew"
export PATH="$GOPATH/bin:$KREW_PATH/bin:$PATH"
export HOMEBREW_GITHUB_API_TOKEN=c32c3959a143abdda5a7fa8359261a7dec7132ba
export KUBE_PS1_PATH='/usr/local/opt/kube-ps1'
export KUBE_PS1_SYMBOL_USE_IMG=false
export SDKMAN_DIR="$HOME/.sdkman"

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
if [ -f "${HOME}/.fzf.zsh" ]; then
  source "${HOME}/.fzf.zsh"
fi

if [ -f "${KUBE_PS1_PATH}/share/kube-ps1.sh" ]; then
  source "${KUBE_PS1_PATH}/share/kube-ps1.sh"
  PS1='$(kube_ps1)'$PS1
  kubeoff
fi

if [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

alias k='kubectl'
alias ssh='TERM=xterm-256color ssh'
alias gcr='ghq look $(ghq list | fzf)'
alias vpn='/opt/cisco/anyconnect/bin/vpn'

gi() { curl -sLw "\n" https://www.gitignore.io/api/$@ ; }
