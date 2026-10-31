#!/usr/bin/env bash
# Installs the skills from sources.txt and skills/ with npx skills, user level, plus pi-packages.txt
# for pi and claude-plugins.txt for claude-code. Safe to re-run.
# Usage: ./install.sh [agent...]   (default: every agent in DEFAULT_AGENTS; names as in `npx skills add -a`)
# Cloud agents: call this from the environment's setup script (see README).
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_CLI="skills@1.7.4"
DEFAULT_AGENTS="claude-code github-copilot codex pi cursor"
export DISABLE_TELEMETRY=1

command -v npx >/dev/null || { echo "install.sh needs Node.js (npx)" >&2; exit 1; }

agents=" ${*:-$DEFAULT_AGENTS} "
agent_flags=()
for agent in $agents; do agent_flags+=(-a "$agent"); done

add() { npx -y "$SKILLS_CLI" add "$@" -g "${agent_flags[@]}" --copy -y </dev/null; }

# Reads <file> without comments or blank lines; tolerates a missing final newline and no entries.
entries() { grep -v -e '^#' -e '^[[:space:]]*$' "$DOTFILES/$1" || true; }

entries sources.txt | while read -r source skills _; do
  [[ "$source" == *'#'* ]] || echo "warning: $source has no #tag, installing its default branch" >&2
  if [ -n "$skills" ]; then add "$source" --skill ${skills//,/ }; else add "$source" --skill '*'; fi
done

# Personal skills go last, so they win a name clash with a source.
if compgen -G "$DOTFILES/skills/*/SKILL.md" >/dev/null; then
  add "$DOTFILES/skills" --skill '*'
fi

if [[ "$agents" == *" pi "* ]]; then
  if command -v pi >/dev/null; then
    entries pi-packages.txt | while read -r package _; do pi install "$package" </dev/null; done
  else
    echo "skip pi packages: pi not on PATH" >&2
  fi
fi

if [[ "$agents" == *" claude-code "* ]]; then
  if command -v claude >/dev/null; then
    entries claude-plugins.txt | while read -r marketplace plugin _; do
      name="${plugin#*@}" ref=""
      [[ "$marketplace" == *'#'* ]] && ref="${marketplace#*#}"
      # Re-adding a marketplace with a new #tag is a no-op, so a moved pin needs remove + add.
      current="$(claude plugin marketplace list --json </dev/null | node -e '
        const m = JSON.parse(require("fs").readFileSync(0, "utf8")).find(m => m.name === process.argv[1]);
        console.log(m ? m.ref || "" : "-")' "$name")"
      if [ "$current" != "-" ] && [ "$current" != "$ref" ]; then
        claude plugin marketplace remove "$name" </dev/null
      fi
      claude plugin marketplace add "$marketplace" </dev/null
      claude plugin install "$plugin" </dev/null
    done
  else
    echo "skip Claude plugins: claude not on PATH" >&2
  fi

  # claude-hud settings: the repo copy wins; a differing local file is kept as config.json.bak.
  hud="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/plugins/claude-hud/config.json"
  if ! cmp -s "$DOTFILES/claude/claude-hud.json" "$hud"; then
    mkdir -p "$(dirname "$hud")"
    [ -f "$hud" ] && cp "$hud" "$hud.bak"
    cp "$DOTFILES/claude/claude-hud.json" "$hud"
  fi
fi
