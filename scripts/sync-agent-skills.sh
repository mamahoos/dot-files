#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# CONFIG
# ==============================================================================

readonly SCRIPT_NAME="${0##*/}"
readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SKILLS_DEST="$REPO_ROOT/home/.cursor/skills"
readonly UPSTREAM_ROOT="${AGENT_SKILLS_DIR:-$HOME/dev/vendor/agent-skills}"
readonly UPSTREAM_SKILLS="$UPSTREAM_ROOT/skills"
readonly IDEA_REFINE_SCRIPT='bash ~/.cursor/skills/idea-refine/scripts/idea-refine.sh'

PULL=false
DRY_RUN=false
CHECK=false

# ==============================================================================
# LOGGING
# ==============================================================================

_skills_sync_error() {
  printf '[%s] %s\n' "$SCRIPT_NAME" "$*" >&2
}

# ==============================================================================
# USAGE
# ==============================================================================

_skills_sync_usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [--pull] [--dry-run] [--check]

Sync home/.cursor/skills from addyosmani/agent-skills.

Environment:
  AGENT_SKILLS_DIR  Upstream repo path (default: ~/dev/vendor/agent-skills)

Options:
  --pull     Run 'git pull --ff-only' in the upstream repo first
  --dry-run  Show what would change without writing files
  --check    Exit 1 if local skills differ from upstream after overlay
EOF
}

# ==============================================================================
# ARGUMENT PARSING
# ==============================================================================

_skills_sync_parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --pull) PULL=true ;;
    --dry-run) DRY_RUN=true ;;
    --check) CHECK=true ;;
    -h | --help)
      _skills_sync_usage
      exit 0
      ;;
    *)
      _skills_sync_error "unknown option: $1"
      _skills_sync_usage >&2
      exit 1
      ;;
    esac
    shift
  done

  if [[ "$CHECK" == true && "$DRY_RUN" == true ]]; then
    _skills_sync_error "use either --check or --dry-run, not both"
    exit 1
  fi
}

# ==============================================================================
# VALIDATION
# ==============================================================================

_skills_sync_validate() {
  if [[ ! -d "$UPSTREAM_SKILLS" ]]; then
    _skills_sync_error "upstream skills not found: $UPSTREAM_SKILLS"
    exit 1
  fi

  command -v rsync >/dev/null 2>&1 || {
    _skills_sync_error "missing dependency: rsync"
    exit 1
  }

  command -v diff >/dev/null 2>&1 || {
    _skills_sync_error "missing dependency: diff"
    exit 1
  }
}

# ==============================================================================
# UPSTREAM
# ==============================================================================

_skills_sync_pull_upstream() {
  if [[ "$PULL" != true ]]; then
    return 0
  fi

  printf 'pulling %s\n' "$UPSTREAM_ROOT"
  git -C "$UPSTREAM_ROOT" pull --ff-only
}

# ==============================================================================
# LOCAL OVERLAY
# ==============================================================================

_skills_sync_add_disable_invocation() {
  local skill_file="$1"
  local tmp_file

  if grep -q '^disable-model-invocation:' "$skill_file"; then
    return 0
  fi

  tmp_file="${skill_file}.tmp"
  awk '
        /^description:/ && !added {
            print
            print "disable-model-invocation: true"
            added = 1
            next
        }
        { print }
    ' "$skill_file" >"$tmp_file"
  mv "$tmp_file" "$skill_file"
}

_skills_sync_fix_idea_refine_path() {
  local idea_refine_skill="$1"

  [[ -f "$idea_refine_skill" ]] || return 0

  sed -i \
    -e 's|bash .cursor/skills/idea-refine/scripts/idea-refine.sh|'"$IDEA_REFINE_SCRIPT"'|g' \
    -e 's|bash skills/idea-refine/scripts/idea-refine.sh|'"$IDEA_REFINE_SCRIPT"'|g' \
    -e 's|bash /mnt/skills/user/idea-refine/scripts/idea-refine.sh|'"$IDEA_REFINE_SCRIPT"'|g' \
    "$idea_refine_skill"
}

_skills_sync_apply_overlay() {
  local overlay_dest="$1"
  local skill_file

  while IFS= read -r -d '' skill_file; do
    _skills_sync_add_disable_invocation "$skill_file"
  done < <(find "$overlay_dest" -name SKILL.md -print0)

  _skills_sync_fix_idea_refine_path "$overlay_dest/idea-refine/SKILL.md"
}

# ==============================================================================
# BUILD EXPECTED TREE
# ==============================================================================

_skills_sync_build_expected() {
  local expected_dir="$1"

  rsync -a "$UPSTREAM_SKILLS/" "$expected_dir/"
  _skills_sync_apply_overlay "$expected_dir"
}

# ==============================================================================
# MODES
# ==============================================================================

_skills_sync_check_drift() {
  local expected_dir drift_report

  expected_dir="$(mktemp -d)"
  drift_report="$(mktemp)"
  trap 'rm -rf "$expected_dir" "$drift_report"' RETURN

  _skills_sync_build_expected "$expected_dir"

  if diff -rq "$SKILLS_DEST" "$expected_dir" >"$drift_report"; then
    printf 'skills are in sync with upstream\n'
    return 0
  fi

  _skills_sync_error "skills drift detected against upstream ($UPSTREAM_ROOT)"
  _skills_sync_error "run: ./scripts/sync-agent-skills.sh --pull"
  cat "$drift_report" >&2
  return 1
}

_skills_sync_run() {
  local -a rsync_args=(-a --delete --itemize-changes)

  if [[ "$DRY_RUN" == true ]]; then
    rsync_args+=(--dry-run)
  fi

  printf 'syncing %s -> %s\n' "$UPSTREAM_SKILLS" "$SKILLS_DEST"
  rsync "${rsync_args[@]}" "$UPSTREAM_SKILLS/" "$SKILLS_DEST/"

  if [[ "$DRY_RUN" == true ]]; then
    return 0
  fi

  _skills_sync_apply_overlay "$SKILLS_DEST"
  printf 'applied local overlay\n'
  printf 'review with: git diff --stat home/.cursor/skills\n'
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
  _skills_sync_parse_args "$@"
  _skills_sync_validate
  _skills_sync_pull_upstream

  if [[ "$CHECK" == true ]]; then
    _skills_sync_check_drift
    exit $?
  fi

  _skills_sync_run
}

main "$@"
