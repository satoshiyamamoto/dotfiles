# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# platform dependents
case "`uname`" in
Darwin*)
	LSOPTS='-G'	
	;;
Linux*|CYGWIN*) 
        LSOPTS='--color=auto -INTUSER.DAT* -Intuser.*'	
	;;
esac
# User specific aliases and functions
alias ls="ls $LSOPTS" 
alias l.='ls -d .*'
alias ll='ls -l'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias du='du -d=1'
alias grep='grep --color=always'
alias egrep='egrep --color=always'
alias sqlite3='sqlite3 -header -column'
alias vi='vim'
