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
if [ -f /usr/libexec/java_home ]; then
  JAVA_HOME="$(/usr/libexec/java_home)"
elif [ -d /usr/local/java ]; then
  JAVA_HOME='/usr/local/java'
  PATH=$JAVA_HOME/bin:$PATH
fi

### GNU coreutils for Darwin
if type gls > /dev/null 2>&1; then
  PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
fi
setdircolors

export JAVA_HOME PATH
