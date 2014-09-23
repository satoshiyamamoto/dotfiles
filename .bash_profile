# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# User specific environment and startup programs
if [ -d /usr/local/bin ]; then
  PATH=/usr/local/bin:$PATH
fi

## Java
if [ -x /usr/libexec/java_home ]; then
  JAVA_HOME="$(/usr/libexec/java_home)"
elif [ -s /usr/bin/java ]; then
  JAVA_HOME='/usr/java/default'
elif [ -d /usr/local/java ]; then
  JAVA_HOME='/usr/local/java'
fi
export JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH

## Ruby and Gems managed under Rbenv
if [ -d "$HOME/.rbenv" ]; then
  PATH=$HOME/.rbenv/shims:$PATH
fi
export PATH
