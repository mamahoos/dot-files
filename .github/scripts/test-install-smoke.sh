#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# CONFIG
# ==============================================================================

readonly SCRIPT_NAME="${0##*/}"
readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
readonly INSTALL_SH="$REPO_ROOT/install.sh"

FAKE_ROOT=''

# ==============================================================================
# LOGGING
# ==============================================================================

_smoke_error() {
  printf '[%s] %s\n' "$SCRIPT_NAME" "$*" >&2
}

# ==============================================================================
# HELPERS
# ==============================================================================

_smoke_cleanup() {
  if [[ -n "$FAKE_ROOT" && -d "$FAKE_ROOT" ]]; then
    rm -rf "$FAKE_ROOT"
  fi
}

_smoke_assert_link() {
  local dest="$1"
  local expected="$2"
  local actual

  if [[ ! -L "$dest" ]]; then
    _smoke_error "expected symlink: $dest"
    return 1
  fi

  actual="$(readlink "$dest")"
  if [[ "$actual" != "$expected" ]]; then
    _smoke_error "bad link $dest: got $actual, want $expected"
    return 1
  fi
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
  local dest_home dest_config dest_shell cursor_child config_child
  local cursor_entries=() config_entries=()

  if [[ ! -x "$INSTALL_SH" ]]; then
    _smoke_error "install script missing or not executable: $INSTALL_SH"
    return 1
  fi

  FAKE_ROOT="$(mktemp -d)"
  trap _smoke_cleanup EXIT

  dest_home="$FAKE_ROOT/home"
  dest_config="$dest_home/.config"
  mkdir -p "$dest_home"

  export DOTFILES_HOME="$dest_home"
  export XDG_CONFIG_HOME="$dest_config"

  "$INSTALL_SH"

  _smoke_assert_link "$dest_home/.bashrc" "$REPO_ROOT/home/.bashrc"
  _smoke_assert_link "$dest_home/.gitconfig" "$REPO_ROOT/home/.gitconfig"
  _smoke_assert_link "$dest_home/.gitmessage" "$REPO_ROOT/home/.gitmessage"
  _smoke_assert_link "$dest_home/gpg-public-key.asc" "$REPO_ROOT/home/gpg-public-key.asc"
  if [[ -L "$dest_home/.gnupg" ]]; then
    _smoke_error "linked entire .gnupg directory"
    return 1
  fi
  _smoke_assert_link "$dest_home/.gnupg/gpg.conf" "$REPO_ROOT/home/.gnupg/gpg.conf"

  dest_shell="$FAKE_ROOT/shell-home"
  mkdir -p "$dest_shell"
  DOTFILES_HOME="$dest_shell" XDG_CONFIG_HOME="$dest_shell/.config" "$INSTALL_SH" --shell-only >/dev/null
  _smoke_assert_link "$dest_shell/.gitconfig" "$REPO_ROOT/home/.gitconfig"
  _smoke_assert_link "$dest_shell/.gitmessage" "$REPO_ROOT/home/.gitmessage"
  if [[ -e "$dest_shell/.cursor" ]]; then
    _smoke_error "--shell-only linked .cursor"
    return 1
  fi
  if [[ -e "$dest_shell/gpg-public-key.asc" ]]; then
    _smoke_error "--shell-only linked gpg-public-key.asc"
    return 1
  fi
  if [[ -e "$dest_shell/.gnupg" ]]; then
    _smoke_error "--shell-only linked .gnupg"
    return 1
  fi

  shopt -s nullglob
  cursor_entries=("$REPO_ROOT/home/.cursor"/*)
  config_entries=("$REPO_ROOT/config"/*)
  shopt -u nullglob

  if ((${#cursor_entries[@]} == 0)); then
    _smoke_error "no children under home/.cursor"
    return 1
  fi
  cursor_child="${cursor_entries[0]}"
  _smoke_assert_link "$dest_home/.cursor/$(basename "$cursor_child")" "$cursor_child"

  if ((${#config_entries[@]} == 0)); then
    _smoke_error "no children under config/"
    return 1
  fi
  config_child="${config_entries[0]}"
  _smoke_assert_link "$dest_config/$(basename "$config_child")" "$config_child"

  printf 'install smoke ok\n'
}

main "$@"
