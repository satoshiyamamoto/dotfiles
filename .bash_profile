# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs
PATH=/usr/local/bin:$HOME/bin:$PATH

### Ruby environment
RI="--format ansi"
PAGER="less -R"
HEROKU_HOME='/usr/local/heroku'
PATH=$RUBY_HOME/bin:$HEROKU_HOME/bin:$PATH
export RI PAGER PATH

### Java environment
if [ -f /usr/libexec/java_home ]; then
	JAVA_HOME=`/usr/libexec/java_home`
elif [ -d /usr/local/java ]; then
	JAVA_HOME='/usr/local/java'
fi
PATH=$JAVA_HOME/bin:$PATH
export JAVA_HOME PATH
