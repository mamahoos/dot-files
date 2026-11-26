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

# _install TARGET — write stdin to TARGET, reporting whether it changed.
_install() {
  local target="$1" tmp
  tmp="$(mktemp)"
  cat >"$tmp"

  if [[ -f "$target" ]] && cmp -s "$tmp" "$target"; then
    rm -f "$tmp"
    _log "unchanged ${target#"$REPO_ROOT"/}"
    return 0
  fi

  mv "$tmp" "$target"
  _log "updated   ${target#"$REPO_ROOT"/}"
}

# _generate TOOL TARGET [ARGS...] — run TOOL ARGS and install its stdout.
_generate() {
  local tool="$1" target="$2"
  shift 2

  if ! command -v "$tool" >/dev/null 2>&1; then
    _log "skipped   $tool (not installed)"
    return 0
  fi

  "$@" | _install "$target" || _die "failed to generate $tool completion"
}

# poetry names its function after the current directory and registers bogus
# absolute paths, so both are normalized for a reproducible file.
_generate_poetry() {
  local target="$DEST_DIR/poetry"

  if ! command -v poetry >/dev/null 2>&1; then
    _log "skipped   poetry (not installed)"
    return 0
  fi

  poetry completions bash 2>/dev/null |
    grep -v '^complete .* /' |
    sed -E 's/_poetry_[0-9a-f]{16}_complete/_poetry_complete/g' |
    _install "$target" || _die "failed to generate poetry completion"
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
  mkdir -p "$DEST_DIR"

  _generate opencode "$DEST_DIR/opencode" opencode --completions bash
  _generate_poetry
  _generate glow "$DEST_DIR/glow" glow completion bash

  _log "kept      config/bash-completion/completions/poe (no generator)"
}

main "$@"
