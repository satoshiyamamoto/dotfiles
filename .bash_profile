# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi

# User specific environment and startup programs
if [ -d /usr/local/bin ]; then
  PATH=/usr/local/bin:$PATH
fi

## These are only Homebrew
if type brew > /dev/null 2>&1; then
  ## GNU coreutils
  if brew list | grep "coreutils" > /dev/null; then
    PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
  fi
  ##  Ruby and Gems
  if brew list | grep "ruby" > /dev/null; then
    PATH="$(brew --prefix ruby)/bin:$PATH"
  fi
fi

## Java
if [ -x /usr/libexec/java_home ]; then
  JAVA_HOME="$(/usr/libexec/java_home)"
elif [ -d /usr/local/java ]; then
  JAVA_HOME='/usr/local/java'
  PATH=$JAVA_HOME/bin:$PATH
fi

EDITOR=vim

export PATH EDITOR JAVA_HOME

## Enable color support of ls
test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)"
