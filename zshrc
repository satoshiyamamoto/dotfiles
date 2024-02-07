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
export HISTORY_IGNORE="(ls|cd|bg|fg|clear|pwd|exit|*<<<*|*assume-role-with-saml*)"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export KUBE_PS1_ENABLED='off'
export COLIMA_SSH_AUTH_SOCK="$(colima ssh env | grep SSH_AUTH_SOCK | cut -d = -f 2)" 2> /dev/null
export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
export TESTCONTAINERS_HOST_OVERRIDE="$(colima ls -j | jq -r '.address')" 2> /dev/null
export SDKMAN_DIR=$(brew --prefix sdkman-cli)/libexec
export HOMEBREW_GITHUB_API_TOKEN="$(security find-generic-password -gs github-token -w)"

# sources
local _homebrew="$(brew --prefix)"
local _gcloud_sdk="$_homebrew/Caskroom/google-cloud-sdk"
[ -d "$_gcloud_sdk" ] && source "$_gcloud_sdk/latest/google-cloud-sdk/path.zsh.inc"
[ -d "$_gcloud_sdk" ] && source "$_gcloud_sdk/latest/google-cloud-sdk/completion.zsh.inc"
[ -f "$_homebrew/etc/profile.d/z.sh" ] && source "$_homebrew/etc/profile.d/z.sh"
[ -f "$_homebrew/bin/atuin" ] && eval "$(atuin init zsh --disable-up-arrow)"
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
[ -f "$HOME/.fig/shell/zshrc.post.zsh" ] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
[ -f "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
unset _homebrew _gcloud_sdk

# functions
kubectl() {
    if ! type __start_kubectl >/dev/null 2>&1; then
        source <(command kubectl completion zsh)
    fi

    command kubectl "$@"
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
alias nodeips='kubectl get nodes -o wide | rg -v control-plane | tail -n +2 | awk "{print \$6}"'
alias nodeip='nodeips | fzf'
alias nodeip1='nodeips | head -n 1'
alias nodeport='kubectl get services/$(kubectl get services | rg NodePort | awk "{print \$1}" | fzf) | tail -n +2 | cut -d: -f2 | cut -d/ -f1'
alias nodeurl='echo http://$(nodeip1):$(nodeport)'
alias nvimdiff='nvim -d'
alias tree='eza -T'
alias curl='curl --silent'
alias stern='stern --exclude-container "(fluentd|datadog)"'
alias vpn='/opt/cisco/secureclient/bin/vpn'
if [[ "$TERM" == "xterm-kitty" ]]; then
  alias ssh="kitty +kitten ssh"
  alias icat='kitty +kitten icat'
fi

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
