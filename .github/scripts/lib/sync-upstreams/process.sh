#!/usr/bin/env bash
# Claim, rsync, and per-source sync / drift-check.
# Sourced by sync-upstreams.sh — not executable on its own.

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
  shift 2
  local -a excludes=("$@")
  local -a rsync_args=(-a --delete --itemize-changes)
  local pattern

  for pattern in "${excludes[@]}"; do
    rsync_args+=(--exclude="$pattern")
  done
  # Drop excluded leftovers already present on the destination
  if [[ ${#excludes[@]} -gt 0 ]]; then
    rsync_args+=(--delete-excluded)
  fi

  if [[ "$DRY_RUN" == true ]]; then
    rsync_args+=(--dry-run)
  fi

  mkdir -p "$(dirname "$dst")"
  printf 'syncing %s -> %s\n' "$src" "$dst"
  rsync "${rsync_args[@]}" "$src/" "$dst/"
}

_sync_build_expected_skill() {
  local src_dir="$1"
  local expected_dir="$2"
  shift 2
  local -a overlays=()
  local -a excludes=()
  local arg in_excludes=false
  local -a rsync_args=(-a)
  local pattern

  for arg in "$@"; do
    if [[ "$arg" == "--" ]]; then
      in_excludes=true
      continue
    fi
    if [[ "$in_excludes" == true ]]; then
      excludes+=("$arg")
    else
      overlays+=("$arg")
    fi
  done

  for pattern in "${excludes[@]}"; do
    rsync_args+=(--exclude="$pattern")
  done

  mkdir -p "$expected_dir"
  rsync "${rsync_args[@]}" "$src_dir/" "$expected_dir/"
  _sync_apply_overlays_tree "$expected_dir" "${overlays[@]}"
}

_sync_check_skill_dir() {
  local src_dir="$1"
  local local_skill="$2"
  local expected_skill="$3"
  local dest_label="$4"
  local source_name="$5"
  shift 5
  local drift_report="$1"
  shift
  local -a overlay_and_exclude=("$@")

  _sync_build_expected_skill "$src_dir" "$expected_skill" "${overlay_and_exclude[@]}"
  if [[ ! -d "$local_skill" ]]; then
    _sync_error "missing managed skill: $dest_label (source: $source_name)"
    return 1
  fi
  if ! diff -rq "$local_skill" "$expected_skill" >>"$drift_report" 2>&1; then
    return 1
  fi
  return 0
}

_sync_write_skill_dir() {
  local src_dir="$1"
  local dest_abs="$2"
  shift 2
  local -a excludes=()
  local -a overlays=()
  local arg in_overlays=false

  # args: excludes... -- overlays...
  for arg in "$@"; do
    if [[ "$arg" == "--" ]]; then
      in_overlays=true
      continue
    fi
    if [[ "$in_overlays" == true ]]; then
      overlays+=("$arg")
    else
      excludes+=("$arg")
    fi
  done

  _sync_rsync_dir "$src_dir" "$dest_abs" "${excludes[@]}"
  if [[ "$DRY_RUN" != true ]]; then
    _sync_apply_overlays_tree "$dest_abs" "${overlays[@]}"
  fi
}

_sync_process_source() {
  local config_file="$1"
  local name repo branch source destination
  local clone_root src_path dest_abs
  local skill_dir skill_name
  local -a overlays=()
  local -a excludes=()
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

  mapfile -t overlays < <(_sync_yaml_list "$config_file" overlays)
  mapfile -t excludes < <(_sync_yaml_list "$config_file" exclude)

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
    while IFS= read -r -d '' skill_dir; do
      skill_name="$(basename "$skill_dir")"
      if ! _sync_claim "$skill_name" "$name"; then
        continue
      fi

      if [[ "$CHECK" == true ]]; then
        expected_skill="$expected_root/$skill_name"
        local_skill="$dest_abs/$skill_name"
        if ! _sync_check_skill_dir "$skill_dir" "$local_skill" "$expected_skill" \
          "$destination/$skill_name" "$name" "$drift_report" \
          "${overlays[@]}" -- "${excludes[@]}"; then
          drifted=true
        fi
      else
        _sync_write_skill_dir "$skill_dir" "$dest_abs/$skill_name" \
          "${excludes[@]}" -- "${overlays[@]}"
      fi
    done < <(find "$src_path" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)
  else
    skill_name="$(basename "$destination")"
    if ! _sync_claim "$skill_name" "$name"; then
      [[ "$CHECK" == true ]] && rm -rf "$expected_root" "$drift_report"
      return 0
    fi

    if [[ "$CHECK" == true ]]; then
      expected_skill="$expected_root/$skill_name"
      if ! _sync_check_skill_dir "$src_path" "$dest_abs" "$expected_skill" \
        "$destination" "$name" "$drift_report" \
        "${overlays[@]}" -- "${excludes[@]}"; then
        drifted=true
      fi
    else
      _sync_write_skill_dir "$src_path" "$dest_abs" \
        "${excludes[@]}" -- "${overlays[@]}"
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
