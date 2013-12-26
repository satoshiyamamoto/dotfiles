# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs
RUBY_HOME='/usr/local/opt/ruby'
RI="--format ansi"
PAGER="less -R"
PATH=$HOME/bin:$RUBY_HOME/bin:$PATH

# Java environment
if [ -f /usr/libexec/java_home ]; then
  JAVA_HOME=`/usr/libexec/java_home`
else if [ -f /usr/local/java ]; then
  JAVA_HOME='/usr/local/java'
fi

export PATH PAGER JAVA_HOME RUBY_HOME RI
