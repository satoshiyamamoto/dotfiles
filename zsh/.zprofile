# zmodload zsh/zprof

# Editors
export EDITOR='nvim'
export PAGER='bat'
export LESSOPEN="| src-hilite-lesspipe.sh %s"
export LESS='--hilite-search --hilite-unread --ignore-case --long-prompt --no-init --raw-control-chars --chop-long-lines --window=4'

# Language
export LANG='en_US.UTF-8'

## Colors
export LS_COLORS="${$(/opt/homebrew/bin/vivid generate tokyonight-night 2>/dev/null || echo ''):-'di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'}"

# Paths
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export GOPATH="$HOME/Projects"
export JAVA_HOME="$(/usr/libexec/java_home -v 21)"

typeset -gU cdpath fpath path
cdpath=(
  $HOME(N)
  $GOPATH/src/*(N)
  $cdpath
)
path=(
  $XDG_DATA_HOME/nvim/mason/bin(N)
  $GOPATH/bin(N)
  $HOME/.cargo/bin(N)
  $HOME/{,s}bin(N)
  /opt/homebrew/opt/mysql-client/bin(N)
  /opt/homebrew/opt/rustup/bin(N)
  /opt/homebrew/{,s}bin(N)
  /usr/local/{,s}bin(N)
  /{,s}bin(N)
  $path
)

## Homebrew
export HOMEBREW_PREFIX='/opt/homebrew'
export HOMEBREW_NO_ENV_HINTS='true'
export HOMEBREW_GITHUB_API_TOKEN="$(security find-generic-password -gs github-token -w)"

## fzf
FZF_PREVIEW_FILE='bat --style=changes,header --color=always --line-range :50 {}'
FZF_PREVIEW_DIR='eza --tree --all --color=always --icons=always {}'
export FZF_CTRL_T_OPTS='--preview="[[ -d {} ]] && '"$FZF_PREVIEW_DIR"' || '"$FZF_PREVIEW_FILE"'"'
export FZF_ALT_C_OPTS='--preview="${FZF_PREVIEW_DIR}"'

## Colima
export COLIMA_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/colima"

## Direnv
export DIRENV_LOG_FORMAT=""

## Google Cloud SDK
export CLOUDSDK_PYTHON="$HOMEBREW_PREFIX/bin/python3.12"
