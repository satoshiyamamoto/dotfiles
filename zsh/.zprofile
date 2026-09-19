# zmodload zsh/zprof

# Editors
export EDITOR='nvim'
export PAGER='bat'
export LESSOPEN="| src-hilite-lesspipe.sh %s"
export LESS='--hilite-search --hilite-unread --ignore-case --long-prompt --no-init --raw-control-chars --chop-long-lines --window=4'

# Language
export LANG='en_US.UTF-8'

## Colors
export COLORTERM='truecolor'

# Paths
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export GOPATH="$HOME/Projects"

typeset -gU cdpath fpath path
cdpath=(
  $HOME(N)
  $GOPATH/src/*(N)
  $cdpath
)
path=(
  /etc/profiles/per-user/$USER/bin(N)
  /run/current-system/sw/bin(N)
  $GOPATH/bin(N)
  $HOME/.cargo/bin(N)
  $HOME/.local/bin(N)
  $HOME/{,s}bin(N)
  /opt/ca-data-pf/cdap-cli/(N)
  /opt/cycloud-io/cycloud-cli(N)
  /opt/homebrew/{,s}bin(N)
  /usr/local/{,s}bin(N)
  /{,s}bin(N)
  $path
)

## Homebrew
export HOMEBREW_CURLRC="$XDG_CONFIG_HOME/homebrew/curlrc"
export HOMEBREW_NO_ENV_HINTS='true'
export HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS='1'

## fzf
FZF_PREVIEW_FILE='bat --style=changes,header --color=always --line-range :50 {}'
FZF_PREVIEW_DIR='eza --tree --all --color=always --icons=always {}'
# Ctrl-R belongs to atuin where atuin exists -- an empty value is how fzf's
# shell integration is told to leave the binding alone. Kenya has no atuin
# (nix/modules/packages.nix), so there fzf keeps Ctrl-R.
(( $+commands[atuin] )) && export FZF_CTRL_R_COMMAND=''
export FZF_CTRL_T_OPTS='--preview="[[ -d {} ]] && '"$FZF_PREVIEW_DIR"' || '"$FZF_PREVIEW_FILE"'"'
export FZF_ALT_C_OPTS='--preview="${FZF_PREVIEW_DIR}"'

## eza
export EZA_CONFIG_DIR="$XDG_CONFIG_HOME/eza"
unset EZA_COLORS

## Direnv
export DIRENV_LOG_FORMAT=""

## GitHub
export GITHUB_PERSONAL_ACCESS_TOKEN=$(gh auth token 2>/dev/null)

## Claude Code
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

## Starship
export STARSHIP_CONFIG=~/.config/starship.toml

## Java
export JAVA_TOOL_OPTIONS='-Djava.net.preferIPv4Stack=true'
export MAVEN_ARGS='-Dstyle.color=always -Dsurefire.failIfNoSpecifiedTests=false'
export JDTLS_JVM_ARGS="-Xmx4G -Xlog:disable"
