export EDITOR=nvim
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export HISTORY_IGNORE="(ls|cd|bg|fg|clear|pwd|exit)"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export GOPATH="$HOME/Develop"
export PYTHON_HOME="$HOME/Library/Python/3.9"
export JAVA_HOME=$(/usr/libexec/java_home -v11)
export KREW_PATH="$HOME/.krew"
export PATH="$GOPATH/bin:$PYTHON_HOME/bin:$KREW_PATH/bin:/usr/local/sbin:$PATH"
export LESS='-R'
export LESSOPEN='| /usr/local/bin/src-hilite-lesspipe.sh %s'
typeset -U path PATH

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
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

alias k='kubectl'
alias vim='nvim'
alias vpn='/opt/cisco/anyconnect/bin/vpn'
alias gsr='_gsr=$(ghq list | fzf) && cd $GOPATH/src/$_gsr'
alias ssh='TERM=xterm-256color ssh'

kubectl() {
    if ! type __start_kubectl >/dev/null 2>&1; then
        source <(command kubectl completion zsh)
    fi

    command kubectl "$@"
}

jdk() {
  version=$1
  export JAVA_HOME=$(/usr/libexec/java_home -v"$version");
  java -version
 }

gi() {
  curl -sLw "\n" https://www.gitignore.io/api/$@ ;
}

