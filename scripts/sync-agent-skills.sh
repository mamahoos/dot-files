#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
upstream="${AGENT_SKILLS_DIR:-$HOME/dev/vendor/agent-skills}"
dest="$repo_root/.cursor/skills"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--pull] [--dry-run]

Sync .cursor/skills from addyosmani/agent-skills (local vendor checkout).

Environment:
  AGENT_SKILLS_DIR  Upstream repo path (default: ~/dev/vendor/agent-skills)

Options:
  --pull     Run 'git pull --ff-only' in the upstream repo first
  --dry-run  Show what would change without writing files
EOF
}

pull=false
dry_run=false
while [ $# -gt 0 ]; do
  case "$1" in
    --pull) pull=true ;;
    --dry-run) dry_run=true ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if [ ! -d "$upstream/skills" ]; then
  echo "Upstream skills not found: $upstream/skills" >&2
  exit 1
fi

if [ "$pull" = true ]; then
  echo "Pulling $upstream ..."
  git -C "$upstream" pull --ff-only
fi

rsync_args=(-a --delete --itemize-changes)
if [ "$dry_run" = true ]; then
  rsync_args+=(--dry-run)
fi

echo "Syncing skills from $upstream/skills -> $dest"
rsync "${rsync_args[@]}" "$upstream/skills/" "$dest/"

apply_local_overlay() {
  local skill_file script_path
  while IFS= read -r -d '' skill_file; do
    if ! grep -q '^disable-model-invocation:' "$skill_file"; then
      awk '
        /^description:/ && !added {
          print
          print "disable-model-invocation: true"
          added = 1
          next
        }
        { print }
      ' "$skill_file" >"${skill_file}.tmp"
      mv "${skill_file}.tmp" "$skill_file"
    fi
  done < <(find "$dest" -name SKILL.md -print0)

  script_path="$dest/idea-refine/SKILL.md"
  if [ -f "$script_path" ]; then
    sed -i 's|bash skills/idea-refine/scripts/idea-refine.sh|bash .cursor/skills/idea-refine/scripts/idea-refine.sh|g' "$script_path"
    sed -i 's|bash /mnt/skills/user/idea-refine/scripts/idea-refine.sh|bash .cursor/skills/idea-refine/scripts/idea-refine.sh|g' "$script_path"
  fi
}

if [ "$dry_run" = false ]; then
  apply_local_overlay
  echo "Applied local overlay (disable-model-invocation, idea-refine path)."
fi

echo "Done. Review with: git diff --stat .cursor/skills"
