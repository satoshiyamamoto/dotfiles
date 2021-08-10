export EDITOR=nvim
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export HISTORY_IGNORE="(ls|cd|bg|fg|clear|pwd|exit)"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export GOPATH="$HOME/Develop"
export JAVA_HOME=$(/usr/libexec/java_home -v11)
export PATH="$GOPATH/bin:$KREW_PATH/bin:/usr/local/sbin:$PATH"
export PAGER='less'
export LESS='-R'
export LESSOPEN='| /usr/local/bin/src-hilite-lesspipe.sh %s'
export FZF_DEFAULT_COMMAND='rg --files --hidden'
export KUBE_TMUX_SYMBOL_ENABLE="false"
export KUBE_TMUX_NS_ENABLE="false"
typeset -U path PATH

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit -i
fi

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
if [ -f "${HOME}/.fzf.zsh" ]; then
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
alias gsr='_gsr=$(ghq list | fzf) && cd $(ghq root)/$_gsr'
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

