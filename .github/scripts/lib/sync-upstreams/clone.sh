#!/usr/bin/env bash
# Clone / refresh cached upstream checkouts.
# Sourced by sync-upstreams.sh — not executable on its own.

_sync_ensure_clone() {
  local name="$1"
  local repo="$2"
  local branch="$3"
  local root="$CACHE_ROOT/$name"

  if [[ ! -d "$root/.git" ]]; then
    mkdir -p "$CACHE_ROOT"
    printf 'cloning %s (%s) -> %s\n' "$repo" "$branch" "$root"
    git clone --depth 1 --branch "$branch" "$repo" "$root"
    return 0
  fi

  if [[ "$PULL" != true ]]; then
    return 0
  fi

  printf 'pulling %s\n' "$root"
  git -C "$root" fetch --depth 1 origin "$branch"
  git -C "$root" checkout -q "$branch"
  git -C "$root" reset --hard "origin/$branch"
}
