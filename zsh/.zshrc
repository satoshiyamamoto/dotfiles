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
  $GOPATH/src/github.com/wbingli/zsh-claudecode-completion(N)
  $HOMEBREW_PREFIX/share/zsh/site-functions(N)
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
autoload -Uz compinit && zsh-defer compinit -C && zsh-defer compdef _tailscale Tailscale


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
  eval "$(atuin init --disable-up-arrow zsh)"
  eval "$(direnv hook zsh)"
  eval "$(fzf --zsh)"
  eval "$(mise activate zsh)"
  eval "$(wt config shell init zsh)"
  eval "$(zoxide init zsh)"
}
zsh-defer __load_plugins


#
# Functions
#
zshexit() {
  (($? >= 128)) && exit 0
}

gi() {
  curl -sLw "\n" https://www.gitignore.io/api/$@ ;
}

wsct() {
  local branch="${1:?Usage: wsct <branch> [-- prompt]}"
  shift
  local prompt=""
  if [[ "$1" == "--" ]]; then
    shift
    prompt="$*"
  fi
  if git show-ref --verify --quiet "refs/heads/${branch}"; then
    echo "error: branch '${branch}' already exists" >&2
    return 1
  fi
  local cmd="wt switch --create --execute=claude ${branch}"
  [[ -n "$prompt" ]] && cmd+=" -- ${(q)prompt}"
  tmux new -d -s "${branch}" "${cmd}"
}

y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

.sync() {
  local dotfiles_dir brewfile
  local is_i386=false ret=0
  local -a i386_excluded=(
    'brew "container"'
    'cask "google-gemini"'
  )

  # Resolve dotfiles directory path and navigate into it
  dotfiles_dir="$(zoxide query dotfiles)" || return 1
  pushd -q "$dotfiles_dir" || return 1

  # Pull the latest changes from the remote repository
  git pull || { popd -q; return 1; }

  # Refresh dotfile symlinks from the repo (--restow: repo is source of truth,
  # no --adopt so unexpected local files surface as errors instead of overwriting)
  STOW_FLAGS="--restow" sh install.darwin.sh || ret=$?

  # Detect Rosetta (i386) environment and locate the Brewfile
  [[ "$(arch)" == "i386" ]] && is_i386=true
  brewfile="$(fd --hidden --type f '^Brewfile$' | head -n 1)"

  if $is_i386 && [[ -n "$brewfile" ]]; then
    # Temporarily comment out i386-unsupported formulas/casks
    for formula in "${i386_excluded[@]}"; do
      sed -i '' "s/^${formula}$/# ${formula}/" "$brewfile"
    done

    # Install or update all packages defined in the Brewfile
    brew bundle -g || ret=$?

    # Restore the commented-out entries after bundle completes
    for formula in "${i386_excluded[@]}"; do
      sed -i '' "s/^# ${formula}$/${formula}/" "$brewfile"
    done
  else
    # Install or update all packages defined in the Brewfile
    brew bundle -g || ret=$?
  fi

  popd -q
  return $ret
}

## ZLE Widgets
git-repos() {
  local repo
  repo=$(ghq list | fzf \
    --height=40% \
    --reverse \
    --prompt="> " \
    --preview="bat --color=always --language=markdown $(ghq root)/{}/README.md" \
  )
  zle reset-prompt
  [[ -z "$repo" ]] && return
  BUFFER="builtin cd -- $(ghq root)/${repo}"
  zle accept-line
}
zle -N git-repos
bindkey '^G' git-repos

# The three session pickers below work both as ZLE widgets and as plain
# commands. $WIDGET is only set while a widget runs, so it tells the two apart:
# from a widget a TTY-taking command has to go through BUFFER and accept-line,
# while called by name the function already owns the TTY and can run it
# directly. Binding or unbinding a key then needs no change to the body
tmux-sessions() {
  local session
  session=$(tmux list-sessions 2>/dev/null | fzf \
    --height=40% \
    --reverse \
    --prompt="> " \
    --preview='tmux capture-pane -ep -t $(echo {} | cut -d: -f1)' \
    --preview-window=right:50%:follow \
  | cut -d: -f1)
  [[ -n "$WIDGET" ]] && zle reset-prompt
  [[ -z "$session" ]] && return
  if [[ -n "$TMUX" ]]; then
    tmux switch-client -t "$session"
  elif [[ -n "$WIDGET" ]]; then
    BUFFER="tmux attach -t ${(q)session}"
    zle accept-line
  else
    tmux attach -t "$session"
  fi
}
zle -N tmux-sessions

zmx-sessions() {
  local display
  display=$(zmx list 2>/dev/null | while IFS=$'\t' read -r name pid clients created dir; do
    name=${name#*name=}
    pid=${pid#*pid=}
    clients=${clients#*clients=}
    dir=${dir#*start_dir=}
    [[ "$pid" != *[!0-9]* ]] || continue
    printf "%-20s  pid:%-8s  clients:%-2s  %s\n" "$name" "$pid" "$clients" "$dir"
  done)
  [[ -z "$display" ]] && return

  local selected session_name
  selected=$(echo "$display" | fzf \
    --height=40% \
    --reverse \
    --prompt="> " \
    --preview='zmx history {1} --vt' \
    --preview-window=right:50%:follow \
  )
  [[ -n "$WIDGET" ]] && zle reset-prompt
  [[ -z "$selected" ]] && return

  session_name=$(echo "$selected" | awk '{print $1}')
  if [[ -n "$WIDGET" ]]; then
    BUFFER="zmx attach ${(q)session_name}"
    zle accept-line
  else
    zmx attach "$session_name"
  fi
}
zle -N zmx-sessions

herdr-sessions() {
  # Nested herdr is disabled by default, so no session can be attached from
  # inside another one. Detach exists only as the prefix+q keybinding and
  # cannot be triggered programmatically
  if [[ "${HERDR_ENV:-}" == "1" ]]; then
    echo "error: nested herdr is disabled; detach with prefix+q before switching sessions" >&2
    return 1
  fi

  local display
  display=$(herdr session list --json 2>/dev/null \
    | jq -r '.sessions[] | [.name, (if .default then "*" else "-" end), (if .running then "running" else "stopped" end), .session_dir, .socket_path] | @tsv' \
    | while IFS=$'\t' read -r name mark state dir sock; do
        printf "%-20s  %-1s  %-8s  %-40s  %s\n" "$name" "$mark" "$state" "${dir/#$HOME/~}" "$sock"
      done)
  [[ -z "$display" ]] && return

  local selected
  # The socket path is needed as {5} in the preview but only clutters the list,
  # so --with-nth hides it. The preview joins fields on | rather than a tab
  # because --preview is single-quoted, which rules out $'\t'; column -t also
  # lines up East Asian wide characters
  selected=$(echo "$display" | fzf \
    --height=80% \
    --reverse \
    --prompt="> " \
    --with-nth=1,2,3,4 \
    --preview='HERDR_SOCKET_PATH={5} herdr api snapshot | jq -r ".result.snapshot.workspaces[] | [(.number|tostring)+\".\", .label, .agent_status, \"panes:\"+(.pane_count|tostring)] | join(\"|\")" | column -t -s"|"' \
    --preview-window=right:50% \
  )
  [[ -n "$WIDGET" ]] && zle reset-prompt
  [[ -z "$selected" ]] && return

  # Attach doubles as start, so stopped sessions work too
  local name=${selected%% *}
  if [[ -n "$WIDGET" ]]; then
    BUFFER="herdr session attach ${(q)name}"
    zle accept-line
  else
    herdr session attach "$name"
  fi
}
zle -N herdr-sessions



#
# Aliases
#
alias cisco='/opt/cisco/secureclient/bin/vpn'
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
alias gcg='YSU_IGNORED_ALIASES=("g" "gf") && git fetch --prune && git switch main && git reset --hard origin/main && git branch -vv | awk "/: gone]/{print (\$1 == \"*\" || \$1 == \"+\") ? \$2 : \$1}" | xargs --no-run-if-empty git branch --delete --force && unset YSU_IGNORED_ALIASES'
alias gc='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gf='git fetch'
alias ghce='gh copilot explain'
alias ghcs='gh copilot suggest'
alias gl='git log --graph --pretty=format:"%x09%C(blue)%h %C(magenta)%an%C(auto)%d%C(reset) %s %C(green)(%cr)"'
alias gm='git merge'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias grh='git reset'
alias grb='git rebase'
alias grs='git restore'
alias gst='git status'
alias gsta='git stash'
alias gsw='git switch'
alias gwt='git worktree'
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
alias kubeon='starship config kubernetes.disabled false'
alias kubeoff='starship config kubernetes.disabled true'
alias la='eza --color=always --icons --long --header --group --git --color-scale=all --all'
alias lg='lazygit'
alias ll='YSU_IGNORED_ALIASES=("ls") && eza --color=auto --icons=auto --long --header --group --git --git-repos --color-scale=all && unset YSU_IGNORED_ALIASES'
alias ls='eza --color=auto --icons=auto'
alias lt='YSU_IGNORED_ALIASES=("ls") && eza --color=auto --icons=auto --long --header --group --git --git-repos --color-scale=all --sort=newest && unset YSU_IGNORED_ALIASES'
alias lzd='lazydocker'
alias mv='mv -i'
alias rm='rm -i'
alias speedtest='cloudflare-speed-cli'
alias tailscale='/Applications/Tailscale.app/Contents/MacOS/Tailscale'
alias trans='trans --brief :ja'
alias tree='eza --color=always --icons --tree'
alias vpnon='starship config custom.vpn.disabled false'
alias vpnoff='starship config custom.vpn.disabled true'
alias wsc='wt switch --create --execute=claude'

#
# Prompt
#
eval "$(starship init zsh)"

__load_starship_config() {
  local width=$COLUMNS

  if [[ $width -ge 100 ]]; then
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
