#!/usr/bin/env bash
# Moves each pinned GitHub repo in sources.txt and claude-plugins.txt to its latest release tag (and, for a plugin, the
# commit sha it resolves to), and each Pi package in pi-packages.txt to its latest npm version. Needs gh and npm.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
out="$(mktemp)"
trap 'rm -f "$out"' EXIT

for file in sources.txt claude-plugins.txt; do
  : > "$out"
  while IFS= read -r line || [ -n "$line" ]; do
    read -r source rest _ <<<"$line"
    if [[ "$source" =~ ^([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)#(.+)$ ]]; then
      repo="${BASH_REMATCH[1]}" tag="${BASH_REMATCH[2]}"
      latest="$(gh release view -R "$repo" --json tagName --jq .tagName 2>/dev/null)" ||
        { echo "warning: $repo has no release, keeping #$tag" >&2; latest="$tag"; }
      if [ "$latest" != "$tag" ]; then
        echo "$repo: $tag -> $latest"
        if [ "$file" = claude-plugins.txt ]; then
          # A plugin line also pins the commit its tag resolves to.
          sha="$(gh api "repos/$repo/commits/$latest" --jq .sha)"
          line="$repo#$latest $rest $sha"
        else
          line="$repo#$latest${rest:+ $rest}"
        fi
      fi
    fi
    printf '%s\n' "$line" >> "$out"
  done < "$DOTFILES/$file"

  cat "$out" > "$DOTFILES/$file"
done
: > "$out"

while IFS= read -r line || [ -n "$line" ]; do
  if [[ "$line" =~ ^npm:(@?[^@[:space:]]+)@([^[:space:]]+)$ ]]; then
    name="${BASH_REMATCH[1]}" version="${BASH_REMATCH[2]}"
    latest="$(npm view "$name" version 2>/dev/null)" ||
      { echo "warning: npm view $name failed, keeping $version" >&2; latest="$version"; }
    if [ "$latest" != "$version" ]; then
      echo "$name: $version -> $latest"
      line="npm:$name@$latest"
    fi
  fi
  printf '%s\n' "$line" >> "$out"
done < "$DOTFILES/pi-packages.txt"

cat "$out" > "$DOTFILES/pi-packages.txt"
