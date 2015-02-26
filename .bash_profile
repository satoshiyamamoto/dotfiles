# .bash_profile

# Get the aliases and functions
[ -f ~/.bashrc ] && . ~/.bashrc

# User specific environment and startup programs
[ -d /usr/local/bin ] && PATH=/usr/local/bin:$PATH
[ -d /usr/local/sbin ] && PATH=/usr/local/sbin:$PATH

# Default language and editor.
export LANG='en_US.UTF-8'
export EDITOR='vi'
if type vim > /dev/null; then export EDITOR='vim'; fi

# Bash command history
export HISTCONTROL=ignoredups
export HISTIGNORE=clear:ls:pwd:fg*:bg*:rm*:history*
export HISTSIZE=10000

## Java Home Environment
[ -x /usr/libexec/java_home ] && JAVA_HOME="$(/usr/libexec/java_home)" # darwin
[ -d /usr/local/java ] && JAVA_HOME='/usr/local/java' # source install
export JAVA_HOME
export PATH=$JAVA_HOME/bin:$PATH

## Ruby and Gems managed under Rbenv
if type rbenv > /dev/null; then eval "$(rbenv init -)"; fi
