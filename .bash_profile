# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# User specific environment and startup programs

## Ruby
if [ -d /usr/local/opt/ruby ]; then
  PATH=/usr/local/opt/ruby/bin:$PATH
fi
RI="--format ansi"
PAGER="less -R"

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

export RI PAGER JAVA_HOME PATH
