#!/bin/sh
# Stow Packages
# STOW_FLAGS defaults to --adopt --verbose (first install: absorb pre-existing
# files and show every link). Override for sync, e.g. STOW_FLAGS="--restow" to
# refresh links treating the repo as source of truth (conflicts surface as
# errors instead of being adopted) while staying quiet on success.
STOW_FLAGS="${STOW_FLAGS:---adopt --verbose}"
stow $STOW_FLAGS --target="$HOME" \
  alacritty \
  bat \
  claude \
  codex \
  docker \
  editorconfig \
  eza \
  fd \
  flake8 \
  gh \
  gh-dash \
  ghostty \
  git \
  glow \
  herdr \
  homebrew \
  hunk \
  k9s \
  karabiner \
  kitty \
  lazygit \
  mise \
  puppeteer \
  nvim \
  powerlevel10k \
  sqlfluff \
  sqlite \
  starship \
  tmux \
  vim \
  worktrunk \
  yamlfmt \
  yazi \
  zed \
  zellij \
  zsh

