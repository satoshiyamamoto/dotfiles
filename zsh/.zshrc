
# Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"
#
# Executes commands at login pre-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

#
# Browser
#

if [[ -z "$BROWSER" && "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

#
# Editors
#

if [[ -z "$EDITOR" ]]; then
  export EDITOR='nvim'
fi
if [[ -z "$VISUAL" ]]; then
  export VISUAL='nvim'
fi
if [[ -z "$PAGER" ]]; then
  export PAGER='less'
fi

#
# Language
#

export LANG='en_US.UTF-8'
# if [[ -z "$LANG" ]]; then
#   export LANG='en_US.UTF-8'
# fi

#
# Paths
#

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:=$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:=$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:=$HOME/.local/share}"
export GOPATH="$HOME/Projects"

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

fpath=(
  /opt/homebrew/share/zsh/site-functions(N)
  $fpath
)

# Set the list of directories that Zsh searches for programs.
path=(
  $XDG_DATA_HOME/nvim/mason/bin(N)
  {$GOROOT,$GOPATH}/bin(N)
  $HOME/.krew/bin(N)
  $HOME/.tiup/bin(N)
  $HOME/.cargo/bin(N)
  $HOME/{,s}bin(N)
  /opt/{homebrew,local}/{,s}bin(N)
  /opt/{homebrew,local}/opt/rustup/bin(N)
  /opt/{homebrew,local}/opt/mysql-client/bin(N)
  /usr/local/{,s}bin(N)
  $path
)

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X to enable it.
if [[ -z "$LESS" ]]; then
  export LESS='-g -i -M -R -S -w -X -z-4'
fi

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

#
# Cargo
#
if [[ -f "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
fi

#
# GitHub Copilot
#
if [[ -d "$XDG_CONFIG_HOME/gh-copilot" ]]; then
  eval "$(gh copilot alias -- zsh)"
fi

#
# Homebrew
#
export HOMEBREW_NO_ENV_HINTS='true'
export HOMEBREW_GITHUB_API_TOKEN="$(security find-generic-password -gs github-token -w)"

#
# fzf
#
FZF_PREVIEW_FILE='bat --style=changes,header --color=always --line-range :50 {}'
FZF_PREVIEW_DIR='eza --tree --all --color=always --icons=always {}'
export FZF_CTRL_T_OPTS='--preview="[[ -d {} ]] && '"${FZF_PREVIEW_DIR}"' || '"${FZF_PREVIEW_FILE}"'"'
export FZF_ALT_C_OPTS='--preview='"${FZF_PREVIEW_DIR}"


#
# Atuin
#
if command -v brew &>/dev/null && [[ -d "$(brew --prefix atuin)" ]]; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

#
# Z
#
if command -v brew &>/dev/null && [[ -d "$(brew --prefix z)" ]]; then
  source "$(brew --prefix)/etc/profile.d/z.sh"
fi

#
# SDKMAN
#
export SDKMAN_DIR="$(brew --prefix sdkman-cli)/libexec"
if [[ -d "$SDKMAN_DIR" && -f "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

#
# Google Cloud CLI
#
GOOGLE_CLOUD_SDK_DIR="$(brew --prefix)/Caskroom/google-cloud-sdk"
if [[ -d "$GOOGLE_CLOUD_SDK_DIR" ]]; then
  source "$GOOGLE_CLOUD_SDK_DIR/latest/google-cloud-sdk/path.zsh.inc"
  source "$GOOGLE_CLOUD_SDK_DIR/latest/google-cloud-sdk/completion.zsh.inc"
fi

#
# Colima
#
export COLIMA_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/colima"

# Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
#
#
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
