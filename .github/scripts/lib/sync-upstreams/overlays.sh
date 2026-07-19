#!/usr/bin/env bash
# Local overlays applied after materializing upstream skill trees.
# Sourced by sync-upstreams.sh — not executable on its own.

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
