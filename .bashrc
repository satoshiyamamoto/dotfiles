# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific aliases and functions

## functions
function getlsoptions() 
{
  LSOPTS='--color=auto'
  case "`uname`" in
    Darwin*) type gls > /dev/null 2>&1 || LSOPTS='-G'
    ;;
    Linux*)  # no specifiy 
    ;;
    CYGWIN*) LSOPTS="$LSOPTS -INTUSER.DAT* -Intuser.*"
    ;;
  esac
  echo $LSOPTS
}

## aliases
alias ls="ls $(getlsoptions)" 
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
alias getclip='getclip | nkf -w'
alias putclip='nkf -s | putclip'

## enable color support of ls
if [ -x /usr/local/opt/coreutils/libexec/gnubin/dircolors ]; then
  dircolors='/usr/local/opt/coreutils/libexec/gnubin/dircolors'
elif [ -x /usr/bin/dircolors ]; then
  dircolors='/usr/bin/dircolors'
fi
test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)"
