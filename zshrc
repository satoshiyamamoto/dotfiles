# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
export HISTORY_IGNORE="(ls|cd|bg|fg|clear|pwd|exit|*assume-role-with-saml*)"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# sources
local _homebrew="$(brew --prefix)"
local _gcloud_sdk="$_homebrew/Caskroom/google-cloud-sdk"
[ -d "$_gcloud_sdk" ] && source "$_gcloud_sdk/latest/google-cloud-sdk/path.zsh.inc"
[ -d "$_gcloud_sdk" ] && source "$_gcloud_sdk/latest/google-cloud-sdk/completion.zsh.inc"
[ -f "$_homebrew/etc/profile.d/z.sh" ] && source "$_homebrew/etc/profile.d/z.sh"
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
unset _homebrew _gcloud_sdk

# functions
kubectl() {
    if ! type __start_kubectl >/dev/null 2>&1; then
        source <(command kubectl completion zsh)
    fi

    command kubectl "$@"
}

sdk() {
    # "metaprogramming" lol - source init if sdk currently looks like this sdk function
    if [[ "$(which sdk | wc -l)" -le 10 ]]; then
        unset -f sdk
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    fi

    sdk "$@"
}

gi() {
  curl -sLw "\n" https://www.gitignore.io/api/$@ ;
}

otp() {
  oathtool --totp -b $(security find-generic-password -gs $@-otp -w)
}

bw() {
  local _bw="$(brew --prefix)/bin/bw"
  case "${1}" in
    "login" )
      local _email=$(security find-generic-password -gs bitwarden-user -w)
      local _password=$(security find-generic-password -gs bitwarden -w)
      local _code=$(otp bitwarden)
      export BW_SESSION="$($_bw login $_email $_password --method 0 --code $_code --raw)"
    ;;

    * )
      $_bw $@ --pretty | bat -l json
    ;;
  esac
}

# aliases
alias dk='docker'
alias k='kubectl'
alias g='git'
alias gore='gore -autoimport'
alias grp='repo=$(ghq list | fzf) && cd $(ghq root)/$repo; unset repo'
alias gpr='cd $GOPATH'
alias gps='cd $GOPATH/src'
alias ls='exa'
alias l='exa -1a'
alias la='exa -lgha --color-scale --git --icons'
alias lu='exa -lgh --color-scale --git --icons --sort=changed'
alias lu='exa -lgh --color-scale --git --icons --sort=size'
alias ll='exa -lgh --color-scale --git --icons'
alias lt='exa -lgh --color-scale --git --icons --sort=newest'
alias lu='exa -lgh --color-scale --git --icons --sort=accessed'
alias lg='lazygit'
alias lzd='lazydocker'
alias tree='exa -T'
alias vpn='/opt/cisco/anyconnect/bin/vpn'
if [[ "$TERM" == "xterm-kitty" ]]; then
  alias ssh="kitty +kitten ssh"
  alias icat='kitty +kitten icat'
fi

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
