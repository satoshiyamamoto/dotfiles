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
elif [ -d /usr/local/java ]; then
  JAVA_HOME='/usr/local/java'
  PATH=$JAVA_HOME/bin:$PATH
fi

## GNU coreutils for in Darwin
if type gls > /dev/null 2>&1; then
  PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
fi

##  Ruby and Gems for in Darwin
if [ -d /usr/local/opt/ruby ]; then
  PATH=/usr/local/opt/ruby/bin:$PATH
fi

export JAVA_HOME PATH

## enable color support of ls
test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)"
