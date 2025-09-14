#
# Lazy loading
#
if [[ ! -d "${ZSH_DEFER_HOME:=$HOME/.zsh_defer}" ]]; then
  git clone https://github.com/romkatv/zsh-defer $ZSH_DEFER_HOME
fi


#
# Zsh Configurations
#

## Key Bindings
bindkey -e

## Options
setopt auto_cd
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt share_history
HISTFILE=~/.zsh_history
HISTORY_IGNORE="(l[sal]|cd|clear|exit|lg|pwd|z|*<<*|*assume-role-with-saml*)"
HISTSIZE=10000
SAVEHIST=5000

## Completions
fpath=(
  ${HOMEBREW_PREFIX:=/opt/homebrew}/share/zsh/site-functions(N)
  $fpath
)
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'm:{[:upper:]}={[:lower:]}' 'r:|=*' 'l:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' squeeze-slashes yes
zstyle ':completion:*:default' list-colors ${(s.:.)"$(echo $LS_COLORS | sed 's/no=[^:]*://g')"}
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:*:*:users' ignored-patterns '_*' root daemon nobody
zstyle ':completion:*:(ssh|scp):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:(ssh|scp):*:hosts' ignored-patterns loopback ip6-loopback broadcasthost
zstyle ':completion:*' completer _complete _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric
autoload -Uz $ZSH_DEFER_HOME/zsh-defer
autoload -Uz compinit && zsh-defer compinit -C


#
# Plugins
#
__load_plugins() {
  source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  source "$HOMEBREW_PREFIX/share/zsh-you-should-use/you-should-use.plugin.zsh"
  source "$HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
  source "$HOMEBREW_PREFIX/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
  source "$HOMEBREW_PREFIX/etc/profile.d/z.sh"
  eval "$(fzf --zsh)"
  eval "$(atuin init --disable-up-arrow zsh)"
  eval "$(direnv hook zsh)"
}
zsh-defer __load_plugins


#
# Functions
#
gi() {
  curl -sLw "\n" https://www.gitignore.io/api/$@ ;
}

y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

fzf-git-widget() {
  local repositry=$(ghq list | fzf --reverse --height 40% --preview "bat --color always $(ghq root)/{}/README.md")
  if [ -n "${repositry}" ]; then
    BUFFER="builtin cd -- $(ghq root)/${repositry}"
    zle accept-line
  fi
  zle reset-prompt
}
zle     -N    fzf-git-widget
bindkey '\eg' fzf-git-widget


#
# Aliases
#
alias cisco='/opt/cisco/secureclient/bin/vpn'
alias cna='[ -z $CONDA_SHLVL ] && eval "$(conda shell.zsh hook)"; conda activate'
alias cnde='conda deactivate'
alias cp='cp -i'
alias curl='curl --silent'
alias d='docker'
alias dc='docker compose'
alias dcd='docker compose down'
alias dctx='docker context'
alias dcu='docker compose up'
alias dex='docker exec --interactive --tty'
alias di='docker images'
alias dl='docker logs'
alias dlf='docker logs --follow'
alias dps='docker ps'
alias dpsa='docker ps --all'
alias drm='docker rm'
alias drmi='docker rmi'
alias drun='docker run --interactive --tty --rm'
alias dstart='docker start'
alias dstop='docker stop'
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gf='git fetch'
alias ghce='gh copilot explain'
alias ghcs='gh copilot suggest'
alias gl='git log --graph --pretty=format:"%x09%Cblue%h %C(yellow)%an%x09%C(auto)%d%Creset %s %Cgreen(%cr)"'
alias gm='git merge'
alias gp='git push'
alias gpl='git pull'
alias gr='git reset'
alias grb='git rebase'
alias gst='git status'
alias gsta='git stash'
alias gsw='git switch'
alias icat='kitty +kitten icat --align=left'
alias k='kubectl'
alias kaf='kubectl apply --filename'
alias kctx='kubectl config use-context'
alias kd='kubectl describe'
alias kdd='kubectl describe deployment'
alias kdel='kubectl delete'
alias kdp='kubectl describe pod'
alias kds='kubectl describe service'
alias kex='kubectl exec --stdin --tty'
alias kg='kubectl get'
alias kgd='kubectl get deployments'
alias kgi='kubectl get ingresses'
alias kgn='kubectl get nodes'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kl='kubectl logs'
alias klf='kubectl logs --follow'
alias kns='kubectl config set-context --current --namespace'
alias la='eza --color=always --icons --long --header --group --git --color-scale --all'
alias lg='lazygit'
alias ll='eza --color=always --icons --long --header --group --git --color-scale'
alias ls='eza --color=auto'
alias lt='eza --color=always --icons --long --header --group --git --color-scale --sort=newest'
alias lzd='lazydocker'
alias mv='mv -i'
alias rm='rm -i'
alias tailscale='/Applications/Tailscale.app/Contents/MacOS/Tailscale'
alias trans='trans --brief :ja'
alias tree='eza --color=always --icons --tree'

#
# Prompt
#
eval "$(starship init zsh)"

__load_starship_config() {
  local width=$COLUMNS

  if [[ $width -ge 80 ]]; then
    export STARSHIP_CONFIG=~/.config/starship.toml
  else
    export STARSHIP_CONFIG=~/.config/starship-minimal.toml
  fi
}
add-zsh-hook precmd __load_starship_config
TRAPWINCH() { __load_starship_config }


#
# Profiler
#
if type zprof >/dev/null 2>&1; then
  zprof | bat --language=log --color=always --pager=never
fi
