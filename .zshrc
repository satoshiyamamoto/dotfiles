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
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -d /usr/local/share/zsh/site-functions ] && fpath=(/usr/local/share/zsh/site-functions $fpath)

export HOMEBREW_GITHUB_API_TOKEN=c32c3959a143abdda5a7fa8359261a7dec7132ba

alias vpn='/opt/cisco/anyconnect/bin/vpn'









