#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# CONFIG
# ==============================================================================

readonly SCRIPT_NAME="${0##*/}"
readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly HOME_SRC="$REPO_ROOT/home"
readonly CONFIG_SRC="$REPO_ROOT/config"
readonly TARGET_HOME="${DOTFILES_HOME:-$HOME}"
readonly TARGET_CONFIG="${XDG_CONFIG_HOME:-$TARGET_HOME/.config}"
readonly STAMP="$(date +%Y%m%d-%H%M%S)"
readonly BACKUP_DIR="$TARGET_HOME/.dotfiles-backup/$STAMP"

# ==============================================================================
# LOGGING
# ==============================================================================

_link_error() {
  printf '[%s] %s\n' "$SCRIPT_NAME" "$*" >&2
}

# ==============================================================================
# SYMLINK HELPERS
# ==============================================================================

_link_backup_path() {
  local dest="$1"
  local relative="${dest#"$TARGET_HOME"/}"
  printf '%s/%s\n' "$BACKUP_DIR" "$relative"
}

_link_one() {
  local src="$1"
  local dest="$2"
  local current backup_path

  if [[ -e "$dest" || -L "$dest" ]]; then
    if [[ -L "$dest" ]]; then
      current="$(readlink "$dest")"
      if [[ "$current" == "$src" ]]; then
        return 0
      fi
    fi

    backup_path="$(_link_backup_path "$dest")"
    mkdir -p "$(dirname "$backup_path")"
    mv "$dest" "$backup_path"
  fi

  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
}

_link_children() {
  local src_dir="$1"
  local dest_dir="$2"
  local entry

  shopt -s nullglob dotglob
  for entry in "$src_dir"/*; do
    _link_one "$entry" "$dest_dir/$(basename "$entry")"
  done
  shopt -u nullglob dotglob
}

_link_home_tree() {
  local entry name

  if [[ ! -d "$HOME_SRC" ]]; then
    _link_error "home source not found: $HOME_SRC"
    return 1
  fi

  shopt -s nullglob dotglob
  for entry in "$HOME_SRC"/*; do
    name="$(basename "$entry")"

    if [[ "$name" == ".cursor" ]]; then
      continue
    fi

    _link_one "$entry" "$TARGET_HOME/$name"
  done
  shopt -u nullglob dotglob

  if [[ -d "$HOME_SRC/.cursor" ]]; then
    mkdir -p "$TARGET_HOME/.cursor"
    _link_children "$HOME_SRC/.cursor" "$TARGET_HOME/.cursor"
  fi
}

_link_config_tree() {
  if [[ ! -d "$CONFIG_SRC" ]]; then
    return 0
  fi

  mkdir -p "$TARGET_CONFIG"
  _link_children "$CONFIG_SRC" "$TARGET_CONFIG"
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
  mkdir -p "$BACKUP_DIR" "$TARGET_CONFIG"
  _link_home_tree
  _link_config_tree
  printf 'linked dotfiles from %s\n' "$REPO_ROOT"
  printf 'backup: %s\n' "$BACKUP_DIR"
}

main "$@"
