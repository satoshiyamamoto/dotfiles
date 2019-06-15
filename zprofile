# zprofile

# User specific environment and startup programs
[ -d $HOME/bin ] && PATH=$HOME/bin:$PATH
[ -d /usr/local/bin ] && PATH=/usr/local/bin:$PATH
[ -d /usr/local/sbin ] && PATH=/usr/local/sbin:$PATH

# Default language and editor.
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export SHELL='zsh'
export EDITOR='vi'
export PAGER='less -R'
if type vim > /dev/null; then export EDITOR='vim'; fi

## Less settings
export LESS='-R'

## Java Home Environment
[ -x /usr/libexec/java_home ] && JAVA_HOME="$(/usr/libexec/java_home)" # darwin
export JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH

## Ruby
export RI='--format ansi'
export PATH="vendor/bin:$PATH"
eval "$(rbenv init -)"

## Python
[ -d $HOME/Library/Python/2.7/bin ] && export PATH="$HOME/Library/Python/2.7/bin:$PATH"
if [ -d "$HOME/Library/Python/2.7/lib/python/site-packages/powerline" ]; then
  export POWERLINE_ROOT="$HOME/Library/Python/2.7/lib/python/site-packages/powerline"
fi

## Homebrew 
if [ -x /usr/local/bin/brew ]; then
  export HOMEBREW_GITHUB_API_TOKEN='61017bffa2da43c3585f5c78f2ac409004edb1cc'
fi

## Visual Studio Code
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

## Gitignore.io
gi() { curl -L -s https://www.gitignore.io/api/$@ ;}

