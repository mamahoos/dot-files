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

_idem_error() {
  printf '[%s] %s\n' "$SCRIPT_NAME" "$*" >&2
}

# ==============================================================================
# HELPERS
# ==============================================================================

_idem_cleanup() {
  if [[ -n "$FAKE_ROOT" && -d "$FAKE_ROOT" ]]; then
    rm -rf "$FAKE_ROOT"
  fi
}

_idem_backup_from_output() {
  local line backup=''

  while IFS= read -r line; do
    case "$line" in
    backup:\ *)
      backup="${line#backup: }"
      ;;
    esac
  done

  if [[ -z "$backup" ]]; then
    _idem_error "install output missing backup: line"
    return 1
  fi

  printf '%s\n' "$backup"
}

_idem_write_snapshot() {
  local root="$1"
  local out="$2"
  local link

  : >"$out"
  while IFS= read -r -d '' link; do
    printf '%s -> %s\n' "${link#"$root"/}" "$(readlink "$link")"
  done < <(find "$root" -type l -print0 | sort -z) >>"$out"
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
  local dest_home dest_config
  local snap1 snap2 second_out second_backup leftovers

  if [[ ! -x "$INSTALL_SH" ]]; then
    _idem_error "install script missing or not executable: $INSTALL_SH"
    return 1
  fi

  FAKE_ROOT="$(mktemp -d)"
  trap _idem_cleanup EXIT

  dest_home="$FAKE_ROOT/home"
  dest_config="$dest_home/.config"
  mkdir -p "$dest_home"

  export DOTFILES_HOME="$dest_home"
  export XDG_CONFIG_HOME="$dest_config"

  snap1="$FAKE_ROOT/snap1.txt"
  snap2="$FAKE_ROOT/snap2.txt"

  "$INSTALL_SH" >/dev/null
  _idem_write_snapshot "$dest_home" "$snap1"

  # STAMP is second-resolution; wait so the second backup dir is distinct.
  sleep 1

  second_out="$("$INSTALL_SH")"
  second_backup="$(_idem_backup_from_output <<<"$second_out")"
  _idem_write_snapshot "$dest_home" "$snap2"

  if ! diff -u "$snap1" "$snap2"; then
    _idem_error "symlink map changed after second install"
    return 1
  fi

  if [[ ! -d "$second_backup" ]]; then
    _idem_error "second backup dir missing: $second_backup"
    return 1
  fi

  leftovers="$(find "$second_backup" -mindepth 1 -print -quit)"
  if [[ -n "$leftovers" ]]; then
    _idem_error "second run backup is not empty: $second_backup"
    return 1
  fi

  printf 'install idempotent ok\n'
}

main "$@"
