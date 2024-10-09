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
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
export HISTORY_IGNORE="(ls|cd|bg|fg|clear|pwd|exit|*<<<*|*assume-role-with-saml*)"
export FZF_PREVIEW_FILE_COMMAND='bat --style=changes,header --color=always --line-range :50 {}'
export FZF_PREVIEW_DIR_COMMAND='eza --tree --color=always --icons=always {}'
export FZF_CTRL_T_OPTS="--preview=\"[[ -d {} ]] && ${FZF_PREVIEW_DIR_COMMAND} || ${FZF_PREVIEW_FILE_COMMAND}\""
export FZF_ALT_C_OPTS="--preview=\"${FZF_PREVIEW_DIR_COMMAND}\""
export COLIMA_HOME="${XDG_CONFIG_HOME}/colima"
export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec

# sources
local _homebrew="$(brew --prefix)"
local _gcloud_sdk="$_homebrew/Caskroom/google-cloud-sdk"
[ -d "$_gcloud_sdk" ] && source "$_gcloud_sdk/latest/google-cloud-sdk/path.zsh.inc"
[ -d "$_gcloud_sdk" ] && source "$_gcloud_sdk/latest/google-cloud-sdk/completion.zsh.inc"
[ -d "$_homebrew/opt/fzf" ] && source <(fzf --zsh)
[ -d "$_homebrew/opt/atuin" ] && eval "$(atuin init zsh --disable-up-arrow)"
[ -d "$_homebrew/opt/z" ] && source "$_homebrew/etc/profile.d/z.sh"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
[ -d "$XDG_CONFIG_HOME/gh-copilot" ] && eval "$(gh copilot alias -- zsh)"
[ -f "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
unset _homebrew _gcloud_sdk

# functions
kubectl() {
    if ! type __start_kubectl >/dev/null 2>&1; then
        source <(command kubectl completion zsh)
    fi

    command kubectl "$@"
}

sdk() {
  unset -f sdk
  [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
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
alias kcat='kcat -X broker.address.family=v4'
alias f='fzf --preview "bat --color=always --style=changes,header --line-range :50 {}"'
alias g='git'
alias gore='gore -autoimport'
alias grp='repo=$(ghq list | fzf) && cd $(ghq root)/$repo; unset repo'
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
