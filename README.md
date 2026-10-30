# dotfiles

Personal skills for Claude Code and GitHub Copilot cloud agents. One copy, in `.copilot/skills/`.

## Contents

- `.copilot/skills/` — personal skills (coding-crew, from [ypxing/coding-crew](https://github.com/ypxing/coding-crew))
- `install.sh` — symlinks each skill into `~/.claude/skills/` (honours `CLAUDE_CONFIG_DIR`). Idempotent.
- `sync-from-local.sh` — copies the current machine's `~/.claude/skills/` into this repo.

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

Edit skills in `~/.claude/skills/`, then run `./sync-from-local.sh` and commit.
