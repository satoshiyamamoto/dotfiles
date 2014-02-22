# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific aliases and functions

## functions
function getlsopts() {
  LSOPTS='--color=auto'
  case "`uname`" in
    Darwin*)
      if ! type gls > /dev/null 2>&1 ; then
        LSOPTS='-G'
      fi
    ;;
    Linux*)
      # no specifiy 
    ;;
    CYGWIN*) 
      LSOPTS="$LSOPTS -INTUSER.DAT* -Intuser.*"
    ;;
  esac
  echo $LSOPTS
}

## aliases
alias ls="ls $(getlsopts)" 
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


