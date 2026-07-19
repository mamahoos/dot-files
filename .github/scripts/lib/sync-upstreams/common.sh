#!/usr/bin/env bash
# Shared paths, flags, and logging for sync-upstreams.
# Sourced by sync-upstreams.sh — not executable on its own.

# ==============================================================================
# PATHS
# ==============================================================================

: "${SYNC_UPSTREAMS_ROOT:?SYNC_UPSTREAMS_ROOT must be set by the entry script}"

readonly REPO_ROOT="$(cd "$SYNC_UPSTREAMS_ROOT/../.." && pwd)"
readonly UPSTREAMS_DIR="$REPO_ROOT/.github/upstreams"
readonly INDEX_FILE="$UPSTREAMS_DIR/upstreams.yml"
readonly CACHE_ROOT="$REPO_ROOT/.cache/upstreams"
readonly IDEA_REFINE_SCRIPT='bash ~/.cursor/skills/idea-refine/scripts/idea-refine.sh'

# ==============================================================================
# FLAGS (mutated by CLI)
# ==============================================================================

PULL=false
DRY_RUN=false
CHECK=false
LIST_SOURCES=false
SOURCE_FILTER=''

# skill_name -> claiming source name (first wins)
declare -A CLAIMED_BY=()

# ==============================================================================
# LOGGING
# ==============================================================================

_sync_error() {
  printf '[%s] %s\n' "${SCRIPT_NAME:-sync-upstreams.sh}" "$*" >&2
}

_sync_warn() {
  printf '[%s] warning: %s\n' "${SCRIPT_NAME:-sync-upstreams.sh}" "$*" >&2
}

# ==============================================================================
# DEPENDENCIES
# ==============================================================================

_sync_validate() {
  command -v git >/dev/null 2>&1 || {
    _sync_error "missing dependency: git"
    exit 1
  }
  command -v rsync >/dev/null 2>&1 || {
    _sync_error "missing dependency: rsync"
    exit 1
  }
  command -v diff >/dev/null 2>&1 || {
    _sync_error "missing dependency: diff"
    exit 1
  }

  [[ -f "$INDEX_FILE" ]] || {
    _sync_error "missing index: $INDEX_FILE"
    exit 1
  }
}
