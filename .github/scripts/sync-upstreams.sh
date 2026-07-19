#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Entry: sync-upstreams
# Thin CLI over lib/sync-upstreams/*.sh
# ==============================================================================

readonly SCRIPT_NAME="${0##*/}"
readonly SYNC_UPSTREAMS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SYNC_UPSTREAMS_LIB="$SYNC_UPSTREAMS_ROOT/lib/sync-upstreams"

# shellcheck source=lib/sync-upstreams/common.sh
source "$SYNC_UPSTREAMS_LIB/common.sh"
# shellcheck source=lib/sync-upstreams/yaml.sh
source "$SYNC_UPSTREAMS_LIB/yaml.sh"
# shellcheck source=lib/sync-upstreams/clone.sh
source "$SYNC_UPSTREAMS_LIB/clone.sh"
# shellcheck source=lib/sync-upstreams/overlays.sh
source "$SYNC_UPSTREAMS_LIB/overlays.sh"
# shellcheck source=lib/sync-upstreams/process.sh
source "$SYNC_UPSTREAMS_LIB/process.sh"

# ==============================================================================
# USAGE / ARGS
# ==============================================================================

_sync_usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [--pull] [--dry-run] [--check] [--source NAME] [--list-sources]

Sync home/.cursor/skills from sources listed in .github/upstreams/upstreams.yml.

Only managed skill dirs (claimed by an enabled upstream) are written or
compared. Unmanaged dirs under the skills root are left alone.

Options:
  --pull           Update cached clones before syncing
  --dry-run        Show rsync itemize without writing
  --check          Exit 1 if any managed skill differs from expected
  --source NAME    Only process the named source
  --list-sources   Print enabled source names as JSON array and exit
EOF
}

_sync_parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --pull) PULL=true ;;
    --dry-run) DRY_RUN=true ;;
    --check) CHECK=true ;;
    --list-sources) LIST_SOURCES=true ;;
    --source)
      shift
      [[ $# -gt 0 ]] || {
        _sync_error "--source requires a name"
        exit 1
      }
      SOURCE_FILTER="$1"
      ;;
    -h | --help)
      _sync_usage
      exit 0
      ;;
    *)
      _sync_error "unknown option: $1"
      _sync_usage >&2
      exit 1
      ;;
    esac
    shift
  done

  if [[ "$CHECK" == true && "$DRY_RUN" == true ]]; then
    _sync_error "use either --check or --dry-run, not both"
    exit 1
  fi
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
  local file enabled config_path
  local check_failed=false
  local processed=false

  _sync_parse_args "$@"
  _sync_validate

  if [[ "$LIST_SOURCES" == true ]]; then
    _sync_list_sources_json
    exit 0
  fi

  while IFS=$'\t' read -r file enabled; do
    [[ "$enabled" == "true" ]] || continue
    config_path="$UPSTREAMS_DIR/$file"
    [[ -f "$config_path" ]] || {
      _sync_error "missing source config: $config_path"
      exit 1
    }

    if [[ -n "$SOURCE_FILTER" ]]; then
      local src_name
      src_name="$(_sync_yaml_get "$config_path" name)"
      [[ "$src_name" == "$SOURCE_FILTER" ]] || continue
    fi

    processed=true
    if ! _sync_process_source "$config_path"; then
      check_failed=true
    fi
  done < <(_sync_index_entries)

  if [[ -n "$SOURCE_FILTER" && "$processed" != true ]]; then
    _sync_error "unknown or disabled source: $SOURCE_FILTER"
    exit 1
  fi

  if [[ "$CHECK" == true ]]; then
    if [[ "$check_failed" == true ]]; then
      _sync_error "run: ./.github/scripts/sync-upstreams.sh --pull"
      exit 1
    fi
    printf 'skills are in sync with upstreams\n'
    exit 0
  fi

  if [[ "$DRY_RUN" != true ]]; then
    printf 'review with: git diff --stat home/.cursor/skills\n'
  fi
}

main "$@"
