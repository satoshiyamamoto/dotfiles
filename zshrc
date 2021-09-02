export EDITOR=nvim
export PAGER='less'
export LESS='-R'
export LESSOPEN='| /usr/local/bin/src-hilite-lesspipe.sh %s'
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export HISTORY_IGNORE="(ls|cd|bg|fg|clear|pwd|exit)"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export HOMEBREW_PREFIX="${HOMEBREW_PREFIX:-/opt/homebrew}"
export GOPATH="$HOME/Develop"
export JAVA_HOME=$(/usr/libexec/java_home -v11)
export KUBE_TMUX_SYMBOL_ENABLE="false"
export KUBE_TMUX_NS_ENABLE="false"

fpath=(
  $HOMEBREW_PREFIX/share/zsh/site-functions
  $fpath
)

path=(
  $HOMEBREW_PREFIX/{bin,sbin}
  $GOPATH/bin
  $path
)

typeset -U path PATH

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
if type brew &>/dev/null; then
  autoload -Uz compinit
  compinit -i
fi

if [ -f "${HOME}/.fzf.zsh" ]; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  source "${HOME}/.fzf.zsh"
fi


alias ls='exa'
alias l='ls -1a'
alias ll='ls -lgh --git --icons'
alias la='ll -a'
alias tree='exa -T'
alias k='kubectl'
alias vim='nvim'
alias view='vim -R'
alias gore='gore -autoimport'
alias vpn='/opt/cisco/anyconnect/bin/vpn'
alias gsr='repo=$(ghq list | fzf) && cd $(ghq root)/$repo; unset repo'
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

