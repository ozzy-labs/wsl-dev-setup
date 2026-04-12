#!/usr/bin/env bash
set -euo pipefail

# Ensure bind-mount sources exist on the host before container creation.
# Docker creates missing sources as directories, which breaks file mounts.

# Directories
mkdir -p "$HOME/.aws" "$HOME/.claude" "$HOME/.claude/projects" "$HOME/.config/gh" "$HOME/.gemini"

# Files (create only if missing)
[[ -f "$HOME/.claude/.credentials.json" ]] || touch "$HOME/.claude/.credentials.json"
[[ -f "$HOME/.claude.json" ]] || touch "$HOME/.claude.json"
[[ -f "$HOME/.claude/settings.json" ]] || touch "$HOME/.claude/settings.json"
[[ -f "$HOME/.zsh_history" ]] || touch "$HOME/.zsh_history"
[[ -f "$HOME/.gitconfig" ]] || touch "$HOME/.gitconfig"
[[ -f "$HOME/.gitconfig.local" ]] || touch "$HOME/.gitconfig.local"

# Pre-resolve symlinks in directories that will be bind-mounted.
# Dotfile managers (e.g. stow) create symlinks pointing to host paths
# that don't exist inside the container. Save resolved content as sidecar
# files so post-create.sh can replace the broken symlinks.
for dir in "$HOME/.aws" "$HOME/.config/gh"; do
  while IFS= read -r link; do
    if [[ -f "$link" ]]; then
      cp -L "$link" "${link}.__resolved__"
    fi
  done < <(find "$dir" -maxdepth 1 -type l 2>/dev/null)
done
