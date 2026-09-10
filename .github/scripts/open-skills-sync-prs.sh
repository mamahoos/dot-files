#!/usr/bin/env bash
set -euo pipefail

# Open one chore/sync-* PR per enabled upstream source.
# Intended for Agent skills sync CI: reset to origin/main between sources
# so each PR stays isolated.
#
# Env:
#   GH_TOKEN          PAT with Contents + Pull requests (required by gh)
#   TRIGGER_LABEL     Text included in the PR body (required)

readonly SCRIPT_NAME="${0##*/}"

if [[ -z "${GH_TOKEN:-}" ]]; then
  printf '[%s] GH_TOKEN is required\n' "$SCRIPT_NAME" >&2
  exit 1
fi
if [[ -z "${TRIGGER_LABEL:-}" ]]; then
  printf '[%s] TRIGGER_LABEL is required\n' "$SCRIPT_NAME" >&2
  exit 1
fi

command -v jq >/dev/null 2>&1 || {
  printf '[%s] missing dependency: jq\n' "$SCRIPT_NAME" >&2
  exit 1
}
command -v gh >/dev/null 2>&1 || {
  printf '[%s] missing dependency: gh\n' "$SCRIPT_NAME" >&2
  exit 1
}

git config user.name mamahoos
git config user.email 62762296+mamahoos@users.noreply.github.com

mapfile -t sources < <(./.github/scripts/sync-upstreams.sh --list-sources | jq -r '.[]')
if [[ ${#sources[@]} -eq 0 ]]; then
  printf '[%s] no enabled sources\n' "$SCRIPT_NAME"
  exit 0
fi

git fetch origin main

for src_name in "${sources[@]}"; do
  git checkout -B "chore/sync-${src_name}" origin/main
  git push origin --delete "chore/sync-${src_name}" || true

  ./.github/scripts/sync-upstreams.sh --pull --source "${src_name}"
  sha="$(git -C ".cache/upstreams/${src_name}" rev-parse HEAD)"

  git add -- home/.cursor/skills
  if git diff --cached --quiet; then
    printf '[%s] no changes for %s\n' "$SCRIPT_NAME" "$src_name"
    continue
  fi

  git commit -m "chore(cursor): sync ${src_name} from upstream"
  git push -u origin "chore/sync-${src_name}"

  body="$(
    cat <<EOF
Automated sync of \`${src_name}\` at \`${sha}\`.

Triggered by: ${TRIGGER_LABEL}

Review the diff and merge if it looks good.

CI runs on this PR via \`SKILLS_SYNC_TOKEN\` (\`lint\`, \`check-skills-drift\`, \`Gitleaks\`).
EOF
  )"

  gh pr create \
    --head "chore/sync-${src_name}" \
    --base main \
    --title "chore(cursor): sync ${src_name} from upstream" \
    --body "${body}" \
    --label chore \
    --label automated \
    --assignee mamahoos
done
