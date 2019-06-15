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
if [ -f "${HOME}/.fzf.zsh" ]; then
  source "${HOME}/.fzf.zsh"
fi

export HISTORY_IGNORE="(ls|cd|pwd|rm|clear|man|exit)"
export GOPATH="$HOME/Develop"
export PATH="$GOPATH/bin:$PATH"
export HOMEBREW_GITHUB_API_TOKEN=c32c3959a143abdda5a7fa8359261a7dec7132ba

alias vpn='/opt/cisco/anyconnect/bin/vpn'

gi() { curl -sLw "\n" https://www.gitignore.io/api/$@ ; }
