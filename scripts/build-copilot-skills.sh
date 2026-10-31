#!/usr/bin/env bash
# Regenerates .copilot/skills, the copy Copilot cloud reads from the dotfiles repo (it runs no
# scripts). Runs install.sh into a throwaway $HOME and copies the result. Needs Node.js and rsync.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
home="$(mktemp -d)"
trap 'rm -rf "$home"' EXIT

HOME="$home" XDG_STATE_HOME="$home/.state" npm_config_cache="$home/.npm" \
  "$DOTFILES/install.sh" github-copilot >/dev/null

mkdir -p "$DOTFILES/.copilot/skills"
rsync -a --delete "$home/.agents/skills/" "$DOTFILES/.copilot/skills/"
echo "Built $(find "$DOTFILES/.copilot/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ') skills into .copilot/skills"
