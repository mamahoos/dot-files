#!/usr/bin/env bash
set -euo pipefail

repo="${1:-$HOME/dev/personal/dot-files}"
stamp="$(date +%Y%m%d-%H%M%S)"
backup_dir="$HOME/.dotfiles-backup/$stamp"

mkdir -p "$backup_dir"
mkdir -p "$HOME/.config/btop"
mkdir -p "$HOME/.config/htop"

link_one() {
  local src="$1"
  local dest="$2"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -L "$dest" ]; then
      local cur
      cur="$(readlink "$dest")"
      if [ "$cur" = "$src" ]; then
        return
      fi
    fi
    mkdir -p "$backup_dir/$(dirname "${dest#$HOME/}")"
    mv "$dest" "$backup_dir/${dest#$HOME/}"
  fi
  ln -s "$src" "$dest"
}

link_one "$repo/bash/.bashrc" "$HOME/.bashrc"
link_one "$repo/bash/.bash_aliases" "$HOME/.bash_aliases"
link_one "$repo/bash/.profile" "$HOME/.profile"
link_one "$repo/git/.gitconfig" "$HOME/.gitconfig"
link_one "$repo/config/btop/btop.conf" "$HOME/.config/btop/btop.conf"
link_one "$repo/config/htop/htoprc" "$HOME/.config/htop/htoprc"
