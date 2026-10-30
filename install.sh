#!/usr/bin/env bash
# Installs these dotfiles into $HOME. Safe to re-run.
# Cloud agents: call this from the environment's setup script (see README).
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

mkdir -p "$CLAUDE_DIR/skills"
for skill in "$DOTFILES"/.copilot/skills/*/; do
  name="$(basename "$skill")"
  target="$CLAUDE_DIR/skills/$name"
  # Replace only links/dirs we own; keep anything else the user has.
  if [ -L "$target" ] || [ ! -e "$target" ]; then
    ln -sfn "${skill%/}" "$target"
  else
    echo "skip $name: $target exists and is not a symlink" >&2
  fi
done

echo "Installed $(ls -d "$DOTFILES"/.copilot/skills/*/ | wc -l | tr -d ' ') skills into $CLAUDE_DIR/skills"
