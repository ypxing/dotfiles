#!/usr/bin/env bash
# Moves each pinned GitHub source in sources.txt to its latest release tag. Needs gh.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="$(mktemp)"
trap 'rm -f "$out"' EXIT

while IFS= read -r line; do
  read -r source skills _ <<<"$line"
  if [[ "$source" =~ ^([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)#(.+)$ ]]; then
    repo="${BASH_REMATCH[1]}" tag="${BASH_REMATCH[2]}"
    latest="$(gh release view -R "$repo" --json tagName --jq .tagName 2>/dev/null)" ||
      { echo "warning: $repo has no release, keeping #$tag" >&2; latest="$tag"; }
    if [ "$latest" != "$tag" ]; then
      echo "$repo: $tag -> $latest"
      line="$repo#$latest${skills:+ $skills}"
    fi
  fi
  printf '%s\n' "$line" >> "$out"
done < "$DOTFILES/sources.txt"

cat "$out" > "$DOTFILES/sources.txt"
