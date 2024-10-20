## Sheldon
if [[ -f "$HOMEBREW_PREFIX/bin/sheldon" ]]; then
  eval "$(sheldon source)"
fi

# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#
# Zsh Options
#
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_reduce_blanks
setopt share_history
HISTSIZE=10000
SAVEHIST=5000
HISTFILE=~/.zsh_history
HISTORY_IGNORE="(l[sal]|cd|clear|exit|lg|pwd|z|*<<<*|*<<*EOF*|*assume-role-with-saml*)"

autoload -Uz compinit && compinit -C
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'm:{[:upper:]}={[:lower:]}'
zstyle ':completion:*' menu select
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' squeeze-slashes yes
zstyle ':completion:*:default' list-colors ${(s.:.)"$(echo $LS_COLORS | sed 's/no=[^:]*://g')"}
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:*:*:users' ignored-patterns '_*' 'root' 'daemon' 'nobody'
zstyle ':completion:*' completer _complete _approximate
zstyle ':completion:*:approximate:*' max-errors 1 numeric
bindkey -e

#
# Source files
#

## fzf
if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
fi

## Atuin
if [[ -f "$HOMEBREW_PREFIX/bin/atuin" ]]; then
  eval "$(atuin init zsh)"
fi

## Z
if [[ -f "$HOMEBREW_PREFIX/etc/profile.d/z.sh" ]]; then
  zsh-defer source "$HOMEBREW_PREFIX/etc/profile.d/z.sh"
fi

## SDKMAN
if [[ -d "$SDKMAN_DIR" && -f "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
  zsh-defer source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

## GitHub Copilot
if [[ -d "$XDG_CONFIG_HOME/gh-copilot" ]]; then
  eval "$(gh copilot alias -- zsh)"
fi

# Functions
kubectl() {
 if ! type __start_kubectl >/dev/null 2>&1; then
   source <(command kubectl completion zsh)
 fi

 command kubectl "$@"
}

gcloud() {
  local SDK_DIR="$(brew --prefix)/Caskroom/google-cloud-sdk"
  if [[ -d "$SDK_DIR" ]]; then
    source "$SDK_DIR/latest/google-cloud-sdk/path.zsh.inc"
    source "$SDK_DIR/latest/google-cloud-sdk/completion.zsh.inc"
  fi

  command gcloud "$@"
}
compdef gcloud=gcloud

gi() {
  curl -sLw "\n" https://www.gitignore.io/api/$@ ;
}

totp() {
  oathtool --totp -b $(security find-generic-password -gs $@-otp -w)
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
alias cp='cp -i'
alias curl='curl --silent'
alias dk='docker'
alias g='git'
alias k='kubectl'
alias la='eza -lgha --color-scale --git --icons'
alias lg='lazygit'
alias ll='eza -lgh --color-scale --git --icons'
alias ls='eza'
alias lt='eza -lgh --color-scale --git --icons --sort=newest'
alias ltr='eza -lgh --color-scale --git --icons --sort=newest --reverse'
alias lzd='lazydocker'
alias mv='mv -i'
alias nvimdiff='nvim -d'
alias rm='rm -i'
alias tree='eza --tree --icons'
alias vpn='/opt/cisco/secureclient/bin/vpn'
if [[ "$TERM" == "xterm-kitty" ]]; then
  alias ssh="kitty +kitten ssh"
  alias icat='kitty +kitten icat'
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if (which zprof > /dev/null) ;then
  zprof | bat --language=log --color=always --pager=never
fi
