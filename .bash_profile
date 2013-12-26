# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs
JAVA_HOME=`/usr/libexec/java_home`
RUBY_HOME='/usr/local/opt/ruby'
RI="--format ansi"
PAGER="less -R"
PATH=$HOME/bin:$RUBY_HOME/bin:$PATH

export PATH PAGER JAVA_HOME RUBY_HOME RI
