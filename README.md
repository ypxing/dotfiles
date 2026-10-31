# dotfiles

One place for my agent skills: my own, plus pinned third-party sources such as
[ypxing/coding-crew](https://github.com/ypxing/coding-crew). Installed with the standard
[`npx skills`](https://github.com/vercel-labs/skills) CLI for Claude Code, GitHub Copilot, Codex, Pi and Cursor.

## Contents

- `skills/<name>/SKILL.md` — my personal skills. Edit here. They install last, so they win a name clash.
- `sources.txt` — third-party sources, one per line: `<owner/repo>#<tag> [skill,skill,...]`. No list means every skill.
- `pi-packages.txt` — Pi packages, pinned (`npm:<name>@<version>`). Installed with `pi install` when `pi` is selected and on PATH.
- `claude-plugins.txt` — Claude Code plugins, pinned (`<owner/repo>#<tag> <plugin>@<marketplace>`). Installed with
  `claude plugin` when `claude-code` is selected and on PATH; a moved pin reinstalls the plugin at the new tag.
  claude-hud needs `/claude-hud:setup` once per machine to point the status line at it.
- `claude/claude-hud.json` — claude-hud settings, copied to `~/.claude/plugins/claude-hud/config.json` with claude-code.
  Edit here, not with `/claude-hud:configure`: the next `install.sh` replaces a differing local file (kept as `.bak`).
- `install.sh [agent...]` — installs all of the above, user level; skills via `npx skills add -g --copy`. Default agents:
  `claude-code github-copilot codex pi cursor`. Needs Node.js. Safe to re-run.
- `.copilot/skills/` — generated copy for Copilot cloud, which runs no scripts. Don't edit; rebuild with
  `scripts/build-copilot-skills.sh`. The **Check skills** workflow fails when it's stale.
- `scripts/bump-sources.sh` — moves each pinned source, Pi package and Claude plugin to its latest release.
- `.github/workflows/update-skills.yml` — daily, opens a PR when any pin has a new release.

Where skills land: Claude Code in `~/.claude/skills/`; Copilot, Codex, Pi and Cursor share `~/.agents/skills/`.

## Local

```bash
git clone https://github.com/ypxing/dotfiles ~/dotfiles && ~/dotfiles/install.sh
~/dotfiles/install.sh claude-code codex     # only some agents
```

`install.sh` adds and updates skills but doesn't delete ones dropped from a source; use `npx skills remove -g <name>`.

## Copilot cloud agent

GitHub settings → Copilot → Cloud → enable dotfiles and select this repo. Copilot copies the repo into the sandbox's
home directory, so `.copilot/skills/` lands in `~/.copilot/skills/`. No script runs; changes apply when a sandbox is
created or resumed. Doesn't apply to sessions running on GitHub Actions. See
[the docs](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/personalize-cloud-sessions).

## Claude Code cloud (and other cloud agents with a setup script)

The repo is private, so the environment needs a read-only token. Create a fine-grained PAT scoped to this repo only
(Contents: read), store it as the env var `DOTFILES_TOKEN`, and add this to the environment's setup script:

```bash
git clone --depth 1 "https://x-access-token:${DOTFILES_TOKEN}@github.com/ypxing/dotfiles" ~/dotfiles && ~/dotfiles/install.sh claude-code
```

Use `codex`, `cursor` etc. instead of `claude-code` for other agents' cloud environments.

## Updating

- **Third-party source:** cut a release there. Within a day the workflow opens a PR here (or run **Update skills**
  from the Actions tab). Review the diff and merge; nothing reaches cloud sessions before that.
- **Add a source:** add a line to `sources.txt`, run `scripts/build-copilot-skills.sh`, commit both.
- **Personal skill:** edit `skills/`, run `scripts/build-copilot-skills.sh`, commit both.
