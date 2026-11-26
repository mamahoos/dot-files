#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# CONFIG
# ==============================================================================

readonly SCRIPT_NAME="${0##*/}"
readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly DEST_DIR="$REPO_ROOT/config/bash-completion/completions"

# ==============================================================================
# LOGGING
# ==============================================================================

_log() {
  printf '[%s] %s\n' "$SCRIPT_NAME" "$*"
}

_die() {
  printf '[%s] %s\n' "$SCRIPT_NAME" "$*" >&2
  exit 1
}

# ==============================================================================
# HELPERS
# ==============================================================================

# _install_file TARGET SOURCE — move SOURCE onto TARGET, reporting the change.
_install_file() {
  local target="$1" source="$2"

  if [[ -f "$target" ]] && cmp -s "$source" "$target"; then
    rm -f "$source"
    _log "unchanged ${target#"$REPO_ROOT"/}"
    return 0
  fi

  mv "$source" "$target"
  _log "updated   ${target#"$REPO_ROOT"/}"
}

# _generate TOOL TARGET [ARGS...] — render TOOL ARGS into TARGET.
# The generator writes next to the target and only replaces it on success, so a
# failing tool cannot leave a truncated completion behind.
_generate() {
  local tool="$1" target="$2" tmp
  shift 2

  if ! command -v "$tool" >/dev/null 2>&1; then
    _log "skipped   $tool (not installed)"
    return 0
  fi

  tmp="$target.tmp.$$"
  if ! "$@" >"$tmp"; then
    rm -f "$tmp"
    _die "failed to generate $tool completion"
  fi

  _install_file "$target" "$tmp"
}

# poetry names its function after the current directory and registers bogus
# absolute paths, so both are normalized for a reproducible file.
_generate_poetry() {
  local target="$DEST_DIR/poetry" tmp

  if ! command -v poetry >/dev/null 2>&1; then
    _log "skipped   poetry (not installed)"
    return 0
  fi

  tmp="$target.tmp.$$"
  if ! poetry completions bash 2>/dev/null |
    grep -v '^complete .* /' |
    sed -E 's/_poetry_[0-9a-f]{16}_complete/_poetry_complete/g' >"$tmp"; then
    rm -f "$tmp"
    _die "failed to generate poetry completion"
  fi

  _install_file "$target" "$tmp"
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
  mkdir -p "$DEST_DIR"
  trap 'rm -f "$DEST_DIR"/*.tmp.$$' EXIT

  _generate opencode "$DEST_DIR/opencode" opencode --completions bash
  _generate_poetry
  _generate glow "$DEST_DIR/glow" glow completion bash

  _log "kept      config/bash-completion/completions/poe (no generator)"
}

main "$@"
