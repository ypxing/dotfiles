#!/usr/bin/env bash
# Rebuilds .copilot/skills from a ypxing/coding-crew release and records the tag in .coding-crew-version.
# Usage: scripts/update-skills.sh [tag]   (default: latest release). Needs gh, jq, bash >= 4.
set -euo pipefail

REPO=ypxing/coding-crew
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TAG="${1:-$(gh release view -R "$REPO" --json tagName --jq .tagName)}"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir "$work/src" "$work/home" "$work/out"

gh release download "$TAG" -R "$REPO" --archive tar.gz -D "$work/src"
tar -xzf "$work"/src/*.tar.gz -C "$work/src"
src="$(find "$work/src" -mindepth 1 -maxdepth 1 -type d)"

# Claude and Copilot builds are identical; Copilot's layout is what the dotfiles feature reads.
(cd "$work/home" && HOME="$work/home" COPILOT_HOME="$work/out" bash "$src/install.sh" copilot >/dev/null)

rsync -a --delete "$work/out/skills/" "$DOTFILES/.copilot/skills/"
echo "$TAG" > "$DOTFILES/.coding-crew-version"
echo "Updated skills to $REPO $TAG"
