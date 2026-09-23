# Read by every zsh, and the only place that survives both holes the other
# files have: ~/.zprofile reaches login shells only, and /etc/zshenv skips
# nix-darwin's set-environment for any shell inheriting
# __NIX_DARWIN_SET_ENVIRONMENT_DONE=1 -- which a herdr server started before
# the last switch keeps alive for days.
# XDG_CONFIG_HOME is the one with teeth: colima 0.10.3 and brew's trust store
# fall back to ~/.colima / ~/.homebrew when it is unset, not to the XDG
# default, and ~/.colima then wins over XDG for good.
export LANG='en_US.UTF-8'
export EDITOR='nvim'
export GOPATH="$HOME/Projects"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
