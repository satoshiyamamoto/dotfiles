# .bash_profile

# Get the aliases and functions
[ -f ~/.bashrc ] && . ~/.bashrc

# User specific environment and startup programs
[ -d /usr/local/bin ] && PATH=/usr/local/bin:$PATH
[ -d /usr/local/sbin ] && PATH=/usr/local/sbin:$PATH

# Default language and editor.
export LANG='en_US.UTF-8'
export EDITOR='vi'
export PAGER='less -R'
if type vim > /dev/null; then export EDITOR='vim'; fi

# Bash command history
export HISTCONTROL=ignoredups
export HISTIGNORE=clear:ls:pwd:fg*:bg*:rm*:history*
export HISTSIZE=10000

## Java Home Environment
[ -x /usr/libexec/java_home ] && JAVA_HOME="$(/usr/libexec/java_home)" # darwin
[ -d /usr/local/java ] && JAVA_HOME='/usr/local/java' # source install
export JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH

## Ruby and Gems managed under Rbenv
export RI='--format ansi'

## Homebrew 
if [ -x /usr/local/bin/brew ]; then
  [ -f $(brew --prefix)/bin/brew-cask ] && export HOMEBREW_CASK_OPTS="--appdir=/Applications"
  [ -f $(brew --prefix)/etc/bash_completion ] && . $(brew --prefix)/etc/bash_completion
fi
