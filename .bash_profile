# .bash_profile

# Get the aliases and functions
[ -f ~/.bashrc ] && . ~/.bashrc

# User specific environment and startup programs
[ -d $HOME/bin ] && PATH=$HOME/bin:$PATH
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

## Less settings
export LESS='-R'

## Java Home Environment
[ -x /usr/libexec/java_home ] && JAVA_HOME="$(/usr/libexec/java_home)" # darwin
[ -d /usr/local/java ] && JAVA_HOME='/usr/local/java' # source install
export JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH

## Ruby and Gems managed under Rbenv
export RI='--format ansi'
export PATH="vendor/bin:$PATH"

## Homebrew 
if [ -x /usr/local/bin/brew ]; then
  [ -f $(brew --prefix)/etc/bash_completion ] && . $(brew --prefix)/etc/bash_completion
fi
export HOMEBREW_GITHUB_API_TOKEN='61017bffa2da43c3585f5c78f2ac409004edb1cc'

## Visual Studio Code
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

## Gitignore.io
gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

## Google Cloud SDK
GCLOUD_HOME='/opt/homebrew-cask/Caskroom/google-cloud-sdk/latest/google-cloud-sdk'
. "$GCLOUD_HOME/path.bash.inc"
. "$GCLOUD_HOME/completion.bash.inc"
