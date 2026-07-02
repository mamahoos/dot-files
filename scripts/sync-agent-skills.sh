#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
upstream="${AGENT_SKILLS_DIR:-$HOME/dev/vendor/agent-skills}"
dest="$repo_root/.cursor/skills"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--pull] [--dry-run] [--check]

Sync .cursor/skills from addyosmani/agent-skills (local vendor checkout).

Environment:
  AGENT_SKILLS_DIR  Upstream repo path (default: ~/dev/vendor/agent-skills)

Options:
  --pull     Run 'git pull --ff-only' in the upstream repo first
  --dry-run  Show what would change without writing files
  --check    Exit 1 if local skills differ from upstream after overlay
EOF
}

pull=false
dry_run=false
check=false
while [ $# -gt 0 ]; do
  case "$1" in
    --pull) pull=true ;;
    --dry-run) dry_run=true ;;
    --check) check=true ;;
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

if [ "$check" = true ] && [ "$dry_run" = true ]; then
  echo "Use either --check or --dry-run, not both." >&2
  exit 1
fi

if [ ! -d "$upstream/skills" ]; then
  echo "Upstream skills not found: $upstream/skills" >&2
  exit 1
fi

if [ "$pull" = true ]; then
  echo "Pulling $upstream ..."
  git -C "$upstream" pull --ff-only
fi

apply_local_overlay() {
  local overlay_dest="$1"
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
  done < <(find "$overlay_dest" -name SKILL.md -print0)

  script_path="$overlay_dest/idea-refine/SKILL.md"
  if [ -f "$script_path" ]; then
    sed -i 's|bash skills/idea-refine/scripts/idea-refine.sh|bash .cursor/skills/idea-refine/scripts/idea-refine.sh|g' "$script_path"
    sed -i 's|bash /mnt/skills/user/idea-refine/scripts/idea-refine.sh|bash .cursor/skills/idea-refine/scripts/idea-refine.sh|g' "$script_path"
  fi
}

if [ "$check" = true ]; then
  tmp_dest="$(mktemp -d)"
  trap 'rm -rf "$tmp_dest"' EXIT

  rsync -a "$upstream/skills/" "$tmp_dest/"
  apply_local_overlay "$tmp_dest"

  if diff -rq "$dest" "$tmp_dest" >/tmp/skills-drift.diff; then
    echo "Skills are in sync with upstream."
    exit 0
  fi

  echo "Skills drift detected against upstream ($upstream)." >&2
  echo "Run locally: ./scripts/sync-agent-skills.sh --pull" >&2
  echo >&2
  cat /tmp/skills-drift.diff >&2
  exit 1
fi

rsync_args=(-a --delete --itemize-changes)
if [ "$dry_run" = true ]; then
  rsync_args+=(--dry-run)
fi

echo "Syncing skills from $upstream/skills -> $dest"
rsync "${rsync_args[@]}" "$upstream/skills/" "$dest/"

if [ "$dry_run" = false ]; then
  apply_local_overlay "$dest"
  echo "Applied local overlay (disable-model-invocation, idea-refine path)."
fi

echo "Done. Review with: git diff --stat .cursor/skills"
