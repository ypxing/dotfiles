# dotfiles

Personal skills for Claude Code and GitHub Copilot cloud agents. One copy, in `.copilot/skills/`.

## Contents

- `.copilot/skills/` — skills built from a [ypxing/coding-crew](https://github.com/ypxing/coding-crew) release. Generated: don't edit by hand.
- `.coding-crew-version` — the release they were built from.
- `install.sh` — symlinks each skill into `~/.claude/skills/` (honours `CLAUDE_CONFIG_DIR`). Idempotent.
- `scripts/update-skills.sh [tag]` — rebuilds `.copilot/skills/` from a release (default latest).
- `.github/workflows/update-skills.yml` — daily, opens a PR when coding-crew has a new release.

## Copilot cloud agent

GitHub settings → Copilot → Cloud → enable dotfiles and select this repo. Copilot copies the repo into the sandbox's home directory, so the skills land in `~/.copilot/skills/`. No script runs; changes apply when a sandbox is created or resumed. Doesn't apply to sessions running on GitHub Actions. See [the docs](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/personalize-cloud-sessions).

## Claude Code cloud agent

The repo is private, so the cloud environment needs a read-only token. Create a fine-grained
PAT scoped to this repo only (Contents: read), store it as the env var `DOTFILES_TOKEN`, and add
this to the environment's setup script:

```bash
git clone --depth 1 "https://x-access-token:${DOTFILES_TOKEN}@github.com/ypxing/dotfiles" ~/dotfiles && ~/dotfiles/install.sh
```

## Local

```bash
git clone https://github.com/ypxing/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

## Updating

Change skills in coding-crew and cut a release. Within a day the workflow opens a PR here
(or run **Update skills** from the Actions tab now). Review the diff and merge; nothing reaches
cloud sessions before that.
