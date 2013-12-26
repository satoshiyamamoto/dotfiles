# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs
PATH=$HOME/bin:$PATH

# Ruby environment
RUBY_HOME='/usr/local/opt/ruby'
RI="--format ansi"
PAGER="less -R"
PATH=$RUBY_HOME/bin:$PATH
export RUBY_HOME RI PAGER PATH

# Java environment
if [ -f /usr/libexec/java_home ]; then
	JAVA_HOME=`/usr/libexec/java_home`
elif [ -d /usr/local/java ]; then
	JAVA_HOME='/usr/local/java'
fi
PATH=$JAVA_HOME/bin:$RUBY_HOME/bin:$PATH
export JAVA_HOME PATH
