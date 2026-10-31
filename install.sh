#!/usr/bin/env bash
# Installs the skills from sources.txt and skills/ with npx skills, user level. Safe to re-run.
# Usage: ./install.sh [agent...]   (default: every agent in DEFAULT_AGENTS; names as in `npx skills add -a`)
# Cloud agents: call this from the environment's setup script (see README).
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_CLI="skills@1.7.4"
DEFAULT_AGENTS="claude-code github-copilot codex pi cursor"
export DISABLE_TELEMETRY=1

command -v npx >/dev/null || { echo "install.sh needs Node.js (npx)" >&2; exit 1; }

agent_flags=()
for agent in ${*:-$DEFAULT_AGENTS}; do agent_flags+=(-a "$agent"); done

add() { npx -y "$SKILLS_CLI" add "$@" -g "${agent_flags[@]}" --copy -y </dev/null; }

while read -r source skills _; do
  case "$source" in ''|'#'*) continue ;; esac
  [[ "$source" == *'#'* ]] || echo "warning: $source has no #tag, installing its default branch" >&2
  if [ -n "$skills" ]; then add "$source" --skill ${skills//,/ }; else add "$source" --skill '*'; fi
done < "$DOTFILES/sources.txt"

# Personal skills go last, so they win a name clash with a source.
if compgen -G "$DOTFILES/skills/*/SKILL.md" >/dev/null; then
  add "$DOTFILES/skills" --skill '*'
fi
