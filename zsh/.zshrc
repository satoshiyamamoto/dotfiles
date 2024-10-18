# Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  setopt prompt_subst interactive_comments
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
HISTORY_IGNORE="(ls|cd|bg|fg|clear|pwd|exit|*<<<*|*assume-role-with-saml*)"
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# Source for Interactive shells
if command -v fzf &>/dev/null; then
  source <(fzf --zsh)
fi

# Functions
kubectl() {
    if ! type __start_kubectl >/dev/null 2>&1; then
        source <(command kubectl completion zsh)
    fi

    command kubectl "$@"
}

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

# Aliases
alias dk='docker'
alias k='kubectl'
alias kc='security find-generic-password'
alias g='git'
alias gore='gore -autoimport'
alias gpr='cd $GOPATH'
alias gps='cd $GOPATH/src'
alias ls='eza'
alias l='eza -1a'
alias la='eza -lgha --color-scale --git --icons'
alias lu='eza -lgh --color-scale --git --icons --sort=changed'
alias lu='eza -lgh --color-scale --git --icons --sort=size'
alias ll='eza -lgh --color-scale --git --icons'
alias lt='eza -lgh --color-scale --git --icons --sort=newest'
alias lu='eza -lgh --color-scale --git --icons --sort=accessed'
alias lg='lazygit'
alias lzd='lazydocker'
alias nvimdiff='nvim -d'
alias tree='eza --tree --icons=always'
alias curl='curl --silent'
alias stern='stern --exclude-container "(fluentd|datadog)"'
alias vpn='/opt/cisco/secureclient/bin/vpn'
if [[ "$TERM" == "xterm-kitty" ]]; then
  alias ssh="kitty +kitten ssh"
  alias icat='kitty +kitten icat'
fi


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
