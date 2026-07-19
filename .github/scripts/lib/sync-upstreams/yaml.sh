#!/usr/bin/env bash
# Constrained YAML helpers for .github/upstreams/*.yml
# Sourced by sync-upstreams.sh — not executable on its own.

# Read a top-level scalar key from a flat YAML file (key: value).
_sync_yaml_get() {
  local file="$1"
  local key="$2"
  local line value

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^${key}:[[:space:]]*(.*)$ ]]; then
      value="${BASH_REMATCH[1]}"
      value="${value#\"}"
      value="${value%\"}"
      value="${value#\'}"
      value="${value%\'}"
      printf '%s\n' "$value"
      return 0
    fi
  done <"$file"
  return 1
}

# Print list items under a top-level key (lines "  - value").
_sync_yaml_list() {
  local file="$1"
  local key="$2"
  local in_list=false
  local line item

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^${key}:[[:space:]]*$ ]]; then
      in_list=true
      continue
    fi
    if [[ "$in_list" == true ]]; then
      if [[ "$line" =~ ^[[:space:]]+-[[:space:]]+(.+)$ ]]; then
        item="${BASH_REMATCH[1]}"
        item="${item#\"}"
        item="${item%\"}"
        printf '%s\n' "$item"
        continue
      fi
      if [[ "$line" =~ ^[a-zA-Z_] ]]; then
        break
      fi
    fi
  done <"$file"
}

# Emit "file<TAB>enabled" rows from upstreams.yml in order.
_sync_index_entries() {
  local line file enabled
  local pending_file=''

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    if [[ "$line" =~ ^[[:space:]]+-[[:space:]]+file:[[:space:]]*(.+)$ ]]; then
      if [[ -n "$pending_file" ]]; then
        printf '%s\ttrue\n' "$pending_file"
      fi
      pending_file="${BASH_REMATCH[1]}"
      pending_file="${pending_file#\"}"
      pending_file="${pending_file%\"}"
      continue
    fi
    if [[ -n "$pending_file" && "$line" =~ ^[[:space:]]+enabled:[[:space:]]*(.+)$ ]]; then
      enabled="${BASH_REMATCH[1]}"
      enabled="${enabled#\"}"
      enabled="${enabled%\"}"
      printf '%s\t%s\n' "$pending_file" "$enabled"
      pending_file=''
      continue
    fi
  done <"$INDEX_FILE"

  if [[ -n "$pending_file" ]]; then
    printf '%s\ttrue\n' "$pending_file"
  fi
}

# Print enabled source names as a JSON array.
_sync_list_sources_json() {
  local file enabled name config_path
  local -a names=()
  local first=true

  while IFS=$'\t' read -r file enabled; do
    [[ "$enabled" == "true" ]] || continue
    config_path="$UPSTREAMS_DIR/$file"
    [[ -f "$config_path" ]] || continue
    name="$(_sync_yaml_get "$config_path" name)" || continue
    names+=("$name")
  done < <(_sync_index_entries)

  printf '['
  for name in "${names[@]}"; do
    if [[ "$first" == true ]]; then
      first=false
    else
      printf ','
    fi
    printf '"%s"' "$name"
  done
  printf ']\n'
}
