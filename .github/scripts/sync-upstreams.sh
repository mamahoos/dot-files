#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# CONFIG
# ==============================================================================

readonly SCRIPT_NAME="${0##*/}"
readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly UPSTREAMS_DIR="$REPO_ROOT/.github/upstreams"
readonly INDEX_FILE="$UPSTREAMS_DIR/upstreams.yml"
readonly CACHE_ROOT="$REPO_ROOT/.cache/upstreams"
readonly IDEA_REFINE_SCRIPT='bash ~/.cursor/skills/idea-refine/scripts/idea-refine.sh'

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
  printf '[%s] %s\n' "$SCRIPT_NAME" "$*" >&2
}

_sync_warn() {
  printf '[%s] warning: %s\n' "$SCRIPT_NAME" "$*" >&2
}

# ==============================================================================
# USAGE
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

# ==============================================================================
# ARGUMENT PARSING
# ==============================================================================

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
# VALIDATION
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

# ==============================================================================
# YAML (constrained subset)
# ==============================================================================

# Read a top-level scalar key from a flat YAML file (key: value).
_sync_yaml_get() {
  local file="$1"
  local key="$2"
  local line value

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^${key}:[[:space:]]*(.*)$ ]]; then
      value="${BASH_REMATCH[1]}"
      value="${value#\"}"
      value="${value%\"}"
      value="${value#\'}"
      value="${value%\'}"
      printf '%s\n' "$value"
      return 0
    fi
  done <"$file"
  return 1
}

# Print overlay names listed under an "overlays:" key (lines "  - name").
_sync_yaml_overlays() {
  local file="$1"
  local in_overlays=false
  local line item

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^overlays:[[:space:]]*$ ]]; then
      in_overlays=true
      continue
    fi
    if [[ "$in_overlays" == true ]]; then
      if [[ "$line" =~ ^[[:space:]]+-[[:space:]]+(.+)$ ]]; then
        item="${BASH_REMATCH[1]}"
        item="${item#\"}"
        item="${item%\"}"
        printf '%s\n' "$item"
        continue
      fi
      # next top-level key ends the list
      if [[ "$line" =~ ^[a-zA-Z_] ]]; then
        break
      fi
    fi
  done <"$file"
}

# Emit "file<TAB>enabled" rows from upstreams.yml in order.
_sync_index_entries() {
  local line file enabled
  local pending_file=''

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^[[:space:]]+-[[:space:]]+file:[[:space:]]*(.+)$ ]]; then
      if [[ -n "$pending_file" ]]; then
        printf '%s\ttrue\n' "$pending_file"
      fi
      pending_file="${BASH_REMATCH[1]}"
      pending_file="${pending_file#\"}"
      pending_file="${pending_file%\"}"
      continue
    fi
    if [[ -n "$pending_file" && "$line" =~ ^[[:space:]]+enabled:[[:space:]]*(.+)$ ]]; then
      enabled="${BASH_REMATCH[1]}"
      enabled="${enabled#\"}"
      enabled="${enabled%\"}"
      printf '%s\t%s\n' "$pending_file" "$enabled"
      pending_file=''
      continue
    fi
  done <"$INDEX_FILE"

  if [[ -n "$pending_file" ]]; then
    printf '%s\ttrue\n' "$pending_file"
  fi
}

# ==============================================================================
# UPSTREAM CLONE
# ==============================================================================

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

# ==============================================================================
# OVERLAYS
# ==============================================================================

_sync_overlay_disable_model_invocation() {
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

_sync_overlay_idea_refine_path() {
  local idea_refine_skill="$1"

  [[ -f "$idea_refine_skill" ]] || return 0

  sed -i \
    -e 's|bash .cursor/skills/idea-refine/scripts/idea-refine.sh|'"$IDEA_REFINE_SCRIPT"'|g' \
    -e 's|bash skills/idea-refine/scripts/idea-refine.sh|'"$IDEA_REFINE_SCRIPT"'|g' \
    -e 's|bash /mnt/skills/user/idea-refine/scripts/idea-refine.sh|'"$IDEA_REFINE_SCRIPT"'|g' \
    "$idea_refine_skill"
}

# Apply overlays to a skill tree rooted at dest (skills root or single skill dir).
_sync_apply_overlays_tree() {
  local dest="$1"
  shift
  local -a overlays=("$@")
  local overlay skill_file

  [[ ${#overlays[@]} -eq 0 ]] && return 0

  for overlay in "${overlays[@]}"; do
    case "$overlay" in
    disable-model-invocation)
      while IFS= read -r -d '' skill_file; do
        _sync_overlay_disable_model_invocation "$skill_file"
      done < <(find "$dest" -name SKILL.md -print0)
      ;;
    idea-refine-path)
      if [[ -f "$dest/idea-refine/SKILL.md" ]]; then
        _sync_overlay_idea_refine_path "$dest/idea-refine/SKILL.md"
      elif [[ -f "$dest/SKILL.md" && "$(basename "$dest")" == "idea-refine" ]]; then
        _sync_overlay_idea_refine_path "$dest/SKILL.md"
      fi
      ;;
    *)
      _sync_error "unknown overlay: $overlay"
      exit 1
      ;;
    esac
  done
}

# ==============================================================================
# CLAIM / PATH HELPERS
# ==============================================================================

_sync_is_skills_root() {
  local dest="$1"
  [[ "$dest" == "home/.cursor/skills" || "$dest" == */.cursor/skills ]]
}

_sync_claim() {
  local skill="$1"
  local source_name="$2"

  if [[ -n "${CLAIMED_BY[$skill]:-}" ]]; then
    _sync_warn "skill '$skill' already claimed by ${CLAIMED_BY[$skill]}; skipping (source: $source_name)"
    return 1
  fi
  CLAIMED_BY[$skill]="$source_name"
  return 0
}

_sync_rsync_dir() {
  local src="$1"
  local dst="$2"
  local -a rsync_args=(-a --delete --itemize-changes)

  if [[ "$DRY_RUN" == true ]]; then
    rsync_args+=(--dry-run)
  fi

  mkdir -p "$(dirname "$dst")"
  printf 'syncing %s -> %s\n' "$src" "$dst"
  rsync "${rsync_args[@]}" "$src/" "$dst/"
}

# ==============================================================================
# BUILD EXPECTED (for --check)
# ==============================================================================

_sync_build_expected_skill() {
  local src_dir="$1"
  local expected_dir="$2"
  shift 2
  local -a overlays=("$@")

  mkdir -p "$expected_dir"
  rsync -a "$src_dir/" "$expected_dir/"
  _sync_apply_overlays_tree "$expected_dir" "${overlays[@]}"
}

# ==============================================================================
# PROCESS ONE SOURCE
# ==============================================================================

_sync_process_source() {
  local config_file="$1"
  local name repo branch source destination
  local clone_root src_path dest_abs
  local skill_dir skill_name
  local -a overlays=()
  local expected_root drift_report expected_skill local_skill
  local drifted=false

  name="$(_sync_yaml_get "$config_file" name)" || {
    _sync_error "missing name in $config_file"
    exit 1
  }
  repo="$(_sync_yaml_get "$config_file" repo)" || {
    _sync_error "missing repo in $config_file"
    exit 1
  }
  branch="$(_sync_yaml_get "$config_file" branch || true)"
  branch="${branch:-main}"
  source="$(_sync_yaml_get "$config_file" source)" || {
    _sync_error "missing source in $config_file"
    exit 1
  }
  destination="$(_sync_yaml_get "$config_file" destination)" || {
    _sync_error "missing destination in $config_file"
    exit 1
  }

  mapfile -t overlays < <(_sync_yaml_overlays "$config_file")

  if [[ -n "$SOURCE_FILTER" && "$name" != "$SOURCE_FILTER" ]]; then
    return 0
  fi

  _sync_ensure_clone "$name" "$repo" "$branch"
  clone_root="$CACHE_ROOT/$name"
  src_path="$clone_root/$source"
  dest_abs="$REPO_ROOT/$destination"

  if [[ ! -d "$src_path" ]]; then
    _sync_error "upstream source path not found: $src_path"
    exit 1
  fi

  if [[ "$CHECK" == true ]]; then
    expected_root="$(mktemp -d)"
    drift_report="$(mktemp)"
  fi

  if _sync_is_skills_root "$destination"; then
    # Multi-skill root: claim each top-level dir under upstream source/
    while IFS= read -r -d '' skill_dir; do
      skill_name="$(basename "$skill_dir")"
      if ! _sync_claim "$skill_name" "$name"; then
        continue
      fi

      if [[ "$CHECK" == true ]]; then
        expected_skill="$expected_root/$skill_name"
        local_skill="$dest_abs/$skill_name"
        _sync_build_expected_skill "$skill_dir" "$expected_skill" "${overlays[@]}"
        if [[ ! -d "$local_skill" ]]; then
          _sync_error "missing managed skill: $destination/$skill_name (source: $name)"
          drifted=true
          continue
        fi
        if ! diff -rq "$local_skill" "$expected_skill" >>"$drift_report" 2>&1; then
          drifted=true
        fi
      else
        _sync_rsync_dir "$skill_dir" "$dest_abs/$skill_name"
        if [[ "$DRY_RUN" != true ]]; then
          _sync_apply_overlays_tree "$dest_abs/$skill_name" "${overlays[@]}"
        fi
      fi
    done < <(find "$src_path" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
  else
    # Single skill destination
    skill_name="$(basename "$destination")"
    if ! _sync_claim "$skill_name" "$name"; then
      [[ "$CHECK" == true ]] && rm -rf "$expected_root" "$drift_report"
      return 0
    fi

    if [[ "$CHECK" == true ]]; then
      expected_skill="$expected_root/$skill_name"
      _sync_build_expected_skill "$src_path" "$expected_skill" "${overlays[@]}"
      if [[ ! -d "$dest_abs" ]]; then
        _sync_error "missing managed skill: $destination (source: $name)"
        drifted=true
      elif ! diff -rq "$dest_abs" "$expected_skill" >>"$drift_report" 2>&1; then
        drifted=true
      fi
    else
      _sync_rsync_dir "$src_path" "$dest_abs"
      if [[ "$DRY_RUN" != true ]]; then
        _sync_apply_overlays_tree "$dest_abs" "${overlays[@]}"
      fi
    fi
  fi

  if [[ "$CHECK" == true ]]; then
    if [[ "$drifted" == true ]]; then
      _sync_error "skills drift detected for source '$name'"
      if [[ -s "$drift_report" ]]; then
        cat "$drift_report" >&2
      fi
      rm -rf "$expected_root" "$drift_report"
      return 1
    fi
    rm -rf "$expected_root" "$drift_report"
  fi

  if [[ "$CHECK" != true && "$DRY_RUN" != true ]]; then
    printf 'source %s: done\n' "$name"
  fi
  return 0
}

# ==============================================================================
# LIST SOURCES
# ==============================================================================

_sync_list_sources_json() {
  local file enabled name config_path
  local -a names=()
  local first=true

  while IFS=$'\t' read -r file enabled; do
    [[ "$enabled" == "true" ]] || continue
    config_path="$UPSTREAMS_DIR/$file"
    [[ -f "$config_path" ]] || continue
    name="$(_sync_yaml_get "$config_path" name)" || continue
    names+=("$name")
  done < <(_sync_index_entries)

  printf '['
  for name in "${names[@]}"; do
    if [[ "$first" == true ]]; then
      first=false
    else
      printf ','
    fi
    printf '"%s"' "$name"
  done
  printf ']\n'
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
