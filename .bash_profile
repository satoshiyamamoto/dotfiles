# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# User specific environment and startup programs
if [ -d /usr/local/bin ]; then
  PATH=/usr/local/bin:$PATH
fi

# Bash command history
export HISTCONTROL=ignoredups
export HISTIGNORE=clear:ls:pwd:cd*:fg*:bg*:rm*:cp*:history*
export HISTSIZE=10000

## Default editor using vim
if type vim > /dev/null 2>&1; then
  EDITOR=vim
else
  EDITOR=vi
fi
export EDITOR

## Java
if [ -x /usr/libexec/java_home ]; then
  JAVA_HOME="$(/usr/libexec/java_home)"
elif [ -d /usr/local/java ]; then
  JAVA_HOME='/usr/local/java'
elif [ -s /usr/bin/java ]; then
  JAVA_HOME='/usr/java/default'
fi
export JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH

## Ruby and Gems managed under Rbenv
if [ -d "$HOME/.rbenv" ]; then
  PATH=$HOME/.rbenv/shims:$PATH
fi
export PATH
