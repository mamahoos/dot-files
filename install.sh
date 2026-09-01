#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# CONFIG
# ==============================================================================

readonly SCRIPT_NAME="${0##*/}"
readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HOME_SRC="$REPO_ROOT/home"
readonly CONFIG_SRC="$REPO_ROOT/config"
readonly TARGET_HOME="${DOTFILES_HOME:-$HOME}"
readonly TARGET_CONFIG="${XDG_CONFIG_HOME:-$TARGET_HOME/.config}"
readonly TARGET_DATA="${XDG_DATA_HOME:-$TARGET_HOME/.local/share}"
readonly STAMP="$(date +%Y%m%d-%H%M%S)"
readonly BACKUP_DIR="$TARGET_HOME/.dotfiles-backup/$STAMP"
readonly SHELL_ONLY_FILES=(
  .gitconfig
  .gitmessage
  .bashrc
  .bash_aliases
  .bash_functions
  .bash_prompt
  .inputrc
  .nanorc
)

SHELL_ONLY=0

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

    if [[ "$name" == ".cursor" || "$name" == ".ssh" || "$name" == ".gnupg" ]]; then
      continue
    fi

    _link_one "$entry" "$TARGET_HOME/$name"
  done
  shopt -u nullglob dotglob

  if [[ -d "$HOME_SRC/.cursor" ]]; then
    mkdir -p "$TARGET_HOME/.cursor"
    _link_children "$HOME_SRC/.cursor" "$TARGET_HOME/.cursor"
  fi

  if [[ -d "$HOME_SRC/.gnupg" ]]; then
    mkdir -p "$TARGET_HOME/.gnupg"
    chmod 700 "$TARGET_HOME/.gnupg"
    if [[ -e "$HOME_SRC/.gnupg/gpg.conf" ]]; then
      _link_one "$HOME_SRC/.gnupg/gpg.conf" "$TARGET_HOME/.gnupg/gpg.conf"
    fi
  fi

  if [[ -d "$HOME_SRC/.ssh" ]]; then
    mkdir -p "$TARGET_HOME/.ssh"
    chmod 700 "$TARGET_HOME/.ssh"
    shopt -s nullglob dotglob
    for entry in "$HOME_SRC/.ssh"/*; do
      name="$(basename "$entry")"
      case "$name" in
      config | config.example | .gitignore | config.d) ;;
      *) continue ;;
      esac
      _link_one "$entry" "$TARGET_HOME/.ssh/$name"
    done
    shopt -u nullglob dotglob
  fi
}

_link_config_tree() {
  if [[ ! -d "$CONFIG_SRC" ]]; then
    return 0
  fi

  mkdir -p "$TARGET_CONFIG"
  _link_children "$CONFIG_SRC" "$TARGET_CONFIG"
}

# GNOME/GTK look up Icon=com.mitchellh.ghostty in hicolor, not ~/.config/ghostty.
# Do not symlink all of ~/.local — only this app icon.
_link_ghostty_icon() {
  local src dest name sz
  src="$CONFIG_SRC/ghostty/icons/com.mitchellh.ghostty.png"
  if [[ ! -f "$src" ]]; then
    return 0
  fi

  name="com.mitchellh.ghostty.png"
  for sz in 48 256 512 1024; do
    dest="$TARGET_DATA/icons/hicolor/${sz}x${sz}/apps/$name"
    _link_one "$src" "$dest"
  done
}

_link_shell_only() {
  local name

  for name in "${SHELL_ONLY_FILES[@]}"; do
    if [[ ! -e "$HOME_SRC/$name" ]]; then
      _link_error "source missing: $HOME_SRC/$name"
      return 1
    fi
    _link_one "$HOME_SRC/$name" "$TARGET_HOME/$name"
  done
}

_parse_args() {
  while (($#)); do
    case "$1" in
    --shell-only)
      SHELL_ONLY=1
      shift
      ;;
    *)
      _link_error "unknown option: $1 (try --shell-only)"
      return 1
      ;;
    esac
  done
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
  _parse_args "$@" || return 1

  mkdir -p "$BACKUP_DIR"

  if ((SHELL_ONLY)); then
    _link_shell_only
    printf 'linked shell dotfiles from %s\n' "$REPO_ROOT"
  else
    mkdir -p "$TARGET_CONFIG"
    _link_home_tree
    _link_config_tree
    _link_ghostty_icon
    printf 'linked dotfiles from %s\n' "$REPO_ROOT"
  fi

  printf 'backup: %s\n' "$BACKUP_DIR"
}

main "$@"
