# dotfiles

Personal config for Claude Code, mainly so cloud agents get my skills.

## Contents

- `claude/skills/` — personal Claude Code skills (coding-crew, from [ypxing/coding-crew](https://github.com/ypxing/coding-crew))
- `install.sh` — symlinks each skill into `~/.claude/skills/` (honours `CLAUDE_CONFIG_DIR`). Idempotent.
- `sync-from-local.sh` — copies the current machine's `~/.claude/skills/` into this repo.

## Cloud agents

Add this to the cloud environment's setup script:

```bash
git clone --depth 1 https://github.com/ypxing/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

The same `install.sh` works for GitHub Codespaces' dotfiles feature.

## Local

```bash
git clone https://github.com/ypxing/dotfiles ~/dotfiles && ~/dotfiles/install.sh
```

Edit skills in `~/.claude/skills/`, then run `./sync-from-local.sh` and commit.
