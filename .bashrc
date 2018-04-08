# .bashrc

# Source global definitions
[ -f /etc/bashrc ] && . /etc/bashrc

# User specific aliases and functions

## functions
function get_ls_options() 
{
  LSOPTS='--color=auto'
  case `uname` in
    Darwin) LSOPTS='-G' ;;
    Linux) ;; # no specifiy  
    CYGWIN) LSOPTS="$LSOPTS -INTUSER.DAT* -Intuser.*" ;;
  esac
  echo $LSOPTS
}

## aliases
alias ls="ls $(get_ls_options)" 
alias l.='ls -d .*'
alias ll='ls -l'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias grep='grep --color=always'
alias egrep='egrep --color=always'
alias less='less -r'
alias sudo='sudo -E'
alias mux='tmuxinator'
alias urlencode='nkf -WwMQ | tr = %'
alias urldecode='tr % = | nkf -WwmQ':w


[ -f ~/.fzf.bash ] && source ~/.fzf.bash
