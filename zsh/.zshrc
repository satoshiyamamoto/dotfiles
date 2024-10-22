#
# Lazy loading
#
if [[ -r "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "$XDG_CACHE_HOME/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ ! -d "$ZSH_DEFER_HOME" ]]; then
  git clone https://github.com/romkatv/zsh-defer $ZSH_DEFER_HOME
fi
source "$ZSH_DEFER_HOME/zsh-defer.plugin.zsh"


#
# Zsh Configurations
#

## Key Bindings
bindkey -e

## Options
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
zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'm:{[:upper:]}={[:lower:]}'
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
autoload -Uz compinit && zsh-defer compinit -C


#
# Source files
#

## Prompt
source "$HOMEBREW_PREFIX/share/powerlevel10k/powerlevel10k.zsh-theme"

## Zsh, Google Cloud etc...
zsh-defer source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
zsh-defer source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
zsh-defer source "$HOMEBREW_PREFIX/etc/profile.d/z.sh"
zsh-defer source "$GOOGLE_CLOUD_CLI_HOME/path.zsh.inc"
zsh-defer source "$GOOGLE_CLOUD_CLI_HOME/completion.zsh.inc"
zsh-defer source "$SDKMAN_DIR/bin/sdkman-init.sh"

## fzf
if type fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

## Atuin
if [[ -f "$HOMEBREW_PREFIX/bin/atuin" ]]; then
  eval "$(atuin init zsh)"
fi


#
# Functions
#
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
alias ghcs='gh copilot suggest'
alias ghce='gh copilot explain'
alias la='eza --color=always --icons --long --header --group --git --color-scale --all'
alias lg='lazygit'
alias ls='eza --color=always'
alias ll='eza --color=always --icons --long --header --group --git --color-scale'
alias lt='eza --color=always --icons --long --header --group --git --color-scale --sort=newest'
alias lzd='lazydocker'
alias mv='mv -i'
alias nvimdiff='nvim -d'
alias rm='rm -i'
alias tree='eza --color=always --icons --tree'
alias vpn='/opt/cisco/secureclient/bin/vpn'
if [[ "$TERM" == "xterm-kitty" ]]; then
  alias ssh="kitty +kitten ssh"
  alias icat='kitty +kitten icat'
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if type zprof >/dev/null 2>&1; then
  zprof | bat --language=log --color=always --pager=never
fi
