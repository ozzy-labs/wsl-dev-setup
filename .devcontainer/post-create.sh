#!/usr/bin/env bash
set -euo pipefail

# Replace broken symlinks with pre-resolved content from initialize.sh.
# Sidecar files (*.__resolved__) contain the actual content that was
# resolved on the host where symlink targets are accessible.
for dir in ~/.aws ~/.config/gh; do
  for resolved in "$dir"/*.__resolved__; do
    [[ -f "$resolved" ]] || continue
    target="${resolved%.__resolved__}"
    if [[ -L "$target" && ! -e "$target" ]]; then
      rm "$target"
      mv "$resolved" "$target"
    else
      rm "$resolved"
    fi
  done
done

# Run project-specific setup if available
if [[ -f scripts/setup.sh ]]; then
  bash scripts/setup.sh
fi
