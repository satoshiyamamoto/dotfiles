#!/bin/bash
set -euo pipefail

INPUT=$(cat)
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name')
BASE_REPO=$(echo "$INPUT" | jq -r '.base_repo_path // .cwd')

worktree_create() {
  local WORKTREE_NAME BRANCH
  WORKTREE_NAME=$(echo "$INPUT" | jq -r '.worktree_name // .name')
  BRANCH=$(echo "$INPUT" | jq -r '.branch // empty')

  if ! [[ "$WORKTREE_NAME" =~ ^[A-Za-z0-9_][A-Za-z0-9_/-]{0,127}$ ]] || [[ "$WORKTREE_NAME" =~ \.\. ]]; then
    echo "invalid worktree name: $WORKTREE_NAME" >&2
    exit 1
  fi

  if [ -n "$BRANCH" ] && (! [[ "$BRANCH" =~ ^[A-Za-z0-9_][A-Za-z0-9_/.-]{0,127}$ ]] || [[ "$BRANCH" =~ \.\. ]]); then
    echo "invalid branch: $BRANCH" >&2
    exit 1
  fi

  local WORKTREE_DIR="$BASE_REPO/.worktrees/$WORKTREE_NAME"

  if [ -d "$WORKTREE_DIR" ]; then
    echo "$WORKTREE_DIR"
    return
  fi

  mkdir -p "$(dirname "$WORKTREE_DIR")"
  cd "$BASE_REPO" || exit 1

  if [ -n "$BRANCH" ]; then
    if git show-ref --verify --quiet "refs/heads/$BRANCH"; then
      git worktree add -- "$WORKTREE_DIR" "$BRANCH" >&2
    else
      git worktree add -b "$BRANCH" -- "$WORKTREE_DIR" HEAD >&2
    fi
  else
    local BRANCH_NAME="${WORKTREE_NAME//\//-}"
    if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
      git worktree add -- "$WORKTREE_DIR" "$BRANCH_NAME" >&2
    else
      git worktree add -b "$BRANCH_NAME" -- "$WORKTREE_DIR" HEAD >&2
    fi
  fi

  echo "$WORKTREE_DIR"
}

worktree_remove() {
  local WORKTREE_PATH WORKTREE_NAME
  WORKTREE_PATH=$(echo "$INPUT" | jq -r '.worktree_path')
  WORKTREE_NAME=$(echo "$INPUT" | jq -r '.worktree_name // .name')

  [ -d "$WORKTREE_PATH" ] || return 0

  local RESOLVED
  RESOLVED=$(realpath "$WORKTREE_PATH" 2>/dev/null) || return 0
  local EXPECTED_PREFIX
  EXPECTED_PREFIX=$(realpath "$BASE_REPO/.worktrees" 2>/dev/null) || return 0

  case "$RESOLVED" in
    "$EXPECTED_PREFIX"/*) ;;
    *) echo "invalid worktree path (outside .worktrees/): $WORKTREE_PATH" >&2; exit 1 ;;
  esac

  cd "$BASE_REPO" || return 0
  git worktree remove "$RESOLVED" --force 2>/dev/null || rm -rf "$RESOLVED"
  git branch -D -- "${WORKTREE_NAME//\//-}" 2>/dev/null || true
}

case "$HOOK_EVENT" in
  WorktreeCreate) worktree_create ;;
  WorktreeRemove) worktree_remove ;;
esac
