# dotfiles

Personal config for Claude Code, mainly so cloud agents get my skills.

## Contents

- `claude/skills/` — personal Claude Code skills (coding-crew, from [ypxing/coding-crew](https://github.com/ypxing/coding-crew))
- `install.sh` — symlinks each skill into `~/.claude/skills/` (honours `CLAUDE_CONFIG_DIR`). Idempotent.
- `sync-from-local.sh` — copies the current machine's `~/.claude/skills/` into this repo.

## Cloud agents

The repo is private, so the cloud environment needs a read-only token. Create a fine-grained
PAT scoped to this repo only (Contents: read), store it as the env var `DOTFILES_TOKEN`, and add
this to the environment's setup script:

```bash
git clone --depth 1 "https://x-access-token:${DOTFILES_TOKEN}@github.com/ypxing/dotfiles" ~/dotfiles && ~/dotfiles/install.sh
```

The same `install.sh` works for GitHub Codespaces' dotfiles feature.

## Local

```bash
git clone https://github.com/ypxing/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

Edit skills in `~/.claude/skills/`, then run `./sync-from-local.sh` and commit.
