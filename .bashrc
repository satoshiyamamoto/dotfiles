# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias du='du -d=1'
alias vi='vim'
alias grep='grep --color=always'
alias egrep='egrep --color=always'
alias l.='ls -d .*'
alias ll='ls -l'
case "`uname`" in
Linux*)  alias ls='ls --color=auto' ;;
Darwin*) alias ls='ls -G' ;;
esac

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
