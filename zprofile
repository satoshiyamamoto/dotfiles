# Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"
#
# Executes commands at login pre-zshrc.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

#
# Browser
#

if [[ -z "$BROWSER" && "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

#
# Editors
#

if [[ -z "$EDITOR" ]]; then
  export EDITOR='nvim'
fi
if [[ -z "$VISUAL" ]]; then
  export VISUAL='nvim'
fi
if [[ -z "$PAGER" ]]; then
  export PAGER='less'
fi

#
# Language
#

export LANG='en_US.UTF-8'
# if [[ -z "$LANG" ]]; then
#   export LANG='en_US.UTF-8'
# fi

#
# Paths
#

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:=$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:=$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:=$HOME/.local/share}"
export GOPATH="$HOME/Projects"

# Ensure path arrays do not contain duplicates.
typeset -gU cdpath fpath mailpath path

# Set the list of directories that cd searches.
# cdpath=(
#   $cdpath
# )

fpath=(
  /opt/homebrew/share/zsh/site-functions(N)
  $fpath
)

# Set the list of directories that Zsh searches for programs.
path=(
  $XDG_DATA_HOME/nvim/mason/bin(N)
  {$GOROOT,$GOPATH}/bin(N)
  $HOME/.krew/bin(N)
  $HOME/.tiup/bin(N)
  $HOME/.cargo/bin(N)
  $HOME/{,s}bin(N)
  /opt/{homebrew,local}/{,s}bin(N)
  /opt/{homebrew,local}/opt/rustup/bin(N)
  /opt/{homebrew,local}/opt/mysql-client/bin(N)
  /usr/local/{,s}bin(N)
  $path
)

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X to enable it.
if [[ -z "$LESS" ]]; then
  export LESS='-g -i -M -R -S -w -X -z-4'
fi

# Set the Less input preprocessor.
# Try both `lesspipe` and `lesspipe.sh` as either might exist on a system.
if [[ -z "$LESSOPEN" ]] && (( $#commands[(i)lesspipe(|.sh)] )); then
  export LESSOPEN="| /usr/bin/env $commands[(i)lesspipe(|.sh)] %s 2>&-"
fi

export HOMEBREW_GITHUB_API_TOKEN="$(security find-generic-password -gs github-token -w)"
export HOMEBREW_NO_ENV_HINTS='true'

# Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
