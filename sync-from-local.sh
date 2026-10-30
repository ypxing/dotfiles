#!/usr/bin/env bash
# Refreshes .copilot/skills from this machine's ~/.claude/skills (skips Anthropic's synced/ skills).
set -euo pipefail
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
rsync -a --delete --exclude synced "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills/" "$DOTFILES/.copilot/skills/"
git -C "$DOTFILES" status --short
