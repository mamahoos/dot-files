#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# CONFIG
# ==============================================================================

readonly SCRIPT_NAME="${0##*/}"
readonly REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
readonly SERVER_BRANCH='server'
readonly MAIN_REF='origin/main'
readonly SERVER_GITCONFIG='home/.gitconfig'
readonly SERVER_BASHRC_OVERLAY='home/.bashrc.server'
readonly SERVER_BASHRC_TEMPLATE="${SERVER_BASHRC_TEMPLATE:-$REPO_ROOT/.github/server-overlays/home/.bashrc.server}"

# ==============================================================================
# LOGGING
# ==============================================================================

_sync_die() {
  printf '[%s] %s\n' "$SCRIPT_NAME" "$*" >&2
  git -C "$REPO_ROOT" merge --abort >/dev/null 2>&1 || true
  exit 1
}

# ==============================================================================
# VALIDATION
# ==============================================================================

_sync_validate_branch() {
  local branch

  branch="$(git -C "$REPO_ROOT" branch --show-current)"
  [[ "$branch" == "$SERVER_BRANCH" ]] || _sync_die "expected branch ${SERVER_BRANCH}, got ${branch:-detached HEAD}"
}

_sync_validate_clean() {
  if ! git -C "$REPO_ROOT" diff --quiet ||
    ! git -C "$REPO_ROOT" diff --cached --quiet; then
    _sync_die "working tree must be clean before syncing"
  fi
}

_sync_validate_server_profile() {
  local commit_signing
  local tag_signing

  grep -Fq 'source "$HOME/.bashrc.server"' "$REPO_ROOT/home/.bashrc" ||
    _sync_die "shared bashrc no longer loads the server overlay"
  grep -Fq 'PROMPT_SHOW_HOST=1' "$REPO_ROOT/$SERVER_BASHRC_OVERLAY" ||
    _sync_die "server overlay does not enable user@host"
  grep -Fq 'PROMPT_SHOW_HOST' "$REPO_ROOT/home/.bash_prompt" ||
    _sync_die "shared prompt no longer supports the host policy"

  commit_signing="$(git -C "$REPO_ROOT" config --file "$SERVER_GITCONFIG" --get commit.gpgSign || true)"
  tag_signing="$(git -C "$REPO_ROOT" config --file "$SERVER_GITCONFIG" --get tag.gpgSign || true)"
  [[ "$commit_signing" == 'false' ]] || _sync_die "server commit signing must remain disabled"
  [[ "$tag_signing" == 'false' ]] || _sync_die "server tag signing must remain disabled"
}

_sync_restore_server_files() {
  git -C "$REPO_ROOT" restore \
    --source=HEAD \
    --staged \
    --worktree \
    -- "$SERVER_GITCONFIG" ||
    _sync_die "could not restore server Git config"

  [[ -f "$REPO_ROOT/$SERVER_BASHRC_TEMPLATE" ]] ||
    _sync_die "server bashrc overlay template is missing"
  install -D -m 0644 \
    "$REPO_ROOT/$SERVER_BASHRC_TEMPLATE" \
    "$REPO_ROOT/$SERVER_BASHRC_OVERLAY" ||
    _sync_die "could not install server bashrc overlay"
  git -C "$REPO_ROOT" add -- "$SERVER_GITCONFIG" "$SERVER_BASHRC_OVERLAY" ||
    _sync_die "could not stage server overlay files"
}

_sync_validate_conflicts() {
  local conflicts

  conflicts="$(git -C "$REPO_ROOT" diff --name-only --diff-filter=U)"
  if [[ -n "$conflicts" ]]; then
    printf '[%s] unresolved conflicts:\n%s\n' "$SCRIPT_NAME" "$conflicts" >&2
    _sync_die "merge has conflicts outside the protected server overlay"
  fi
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
  local merge_conflicts=''
  local merge_status=0

  cd "$REPO_ROOT"
  _sync_validate_branch
  _sync_validate_clean

  git fetch origin main || _sync_die "could not fetch origin/main"

  if git merge-base --is-ancestor "$MAIN_REF" HEAD; then
    printf '[%s] server already contains %s\n' "$SCRIPT_NAME" "$MAIN_REF"
    _sync_validate_server_profile
    return 0
  fi

  git merge --no-commit --no-ff "$MAIN_REF" || merge_status=$?
  merge_conflicts="$(git diff --name-only --diff-filter=U)"
  _sync_restore_server_files
  _sync_validate_conflicts
  _sync_validate_server_profile

  if ((merge_status != 0)) && [[ -z "$merge_conflicts" ]]; then
    _sync_die "merge failed with exit ${merge_status}"
  fi

  git commit -m "$(
    cat <<'EOF'
Merge origin/main into server, preserve server profile

Sync shared dotfiles and prompt capabilities from main.
Keep server Git signing policy and apply the server prompt overlay.
EOF
  )" || _sync_die "could not create server sync commit"
}

main "$@"
