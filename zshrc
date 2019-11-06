#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export HISTORY_IGNORE="(ls|cd|pwd|rm|clear|man|exit)"
export PYTHON3_PATH="$HOME/Library/Python/3.7"
export PYTHON2_PATH="$HOME/Library/Python/2.7"
export GOPATH="$HOME/Develop"
export PATH="$GOPATH/bin:$PYTHON3_PATH/bin:$PYTHON2_PATH/bin:$PATH"
export HOMEBREW_GITHUB_API_TOKEN=c32c3959a143abdda5a7fa8359261a7dec7132ba
export SDKMAN_DIR="$HOME/.sdkman"

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
if [ -f "${HOME}/.fzf.zsh" ]; then
  source "${HOME}/.fzf.zsh"
fi

if [ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]; then
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

alias k='kubectl'
alias gcr='ghq look $(ghq list | fzf)'
alias vpn='/opt/cisco/anyconnect/bin/vpn'

gi() { curl -sLw "\n" https://www.gitignore.io/api/$@ ; }