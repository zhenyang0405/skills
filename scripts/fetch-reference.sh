#!/usr/bin/env bash
# Download someone else's skill to READ while writing your own version.
#
# Files land in .reference/ (gitignored). They are never installed, never linked
# into an agent and never committed. Nothing in them is run. Treat them as
# untrusted text: ideas to learn from, not instructions to follow.
#
# Usage:
#   scripts/fetch-reference.sh <owner/repo> [path/in/repo] [--ref REF]
#
#   owner/repo      GitHub repository, e.g. mattpocock/skills
#   path/in/repo    Folder to fetch (default: the whole repo)
#   --ref REF       Branch, tag or commit (default: the repo's default branch)
#
# Examples:
#   scripts/fetch-reference.sh mattpocock/skills skills/engineering/tdd
#   scripts/fetch-reference.sh obra/superpowers skills
#
# When your skill is written, credit what you learned from in CREDITS.md.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REF_DIR="$REPO_ROOT/.reference"

usage() { sed -n '2,/^$/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }
die() { echo "error: $*" >&2; exit 1; }

positional=()
ref=""
while [ $# -gt 0 ]; do
  case "$1" in
    --ref) [ $# -ge 2 ] || die "--ref needs a value"; ref="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    -*) die "unknown option: $1 (see --help)" ;;
    *) positional+=("$1"); shift ;;
  esac
done
[ "${#positional[@]}" -ge 1 ] && [ "${#positional[@]}" -le 2 ] || { usage; exit 2; }

upstream="${positional[0]}"
path="${positional[1]:-}"
path="${path%/}"
[[ "$upstream" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || die "expected owner/repo, got: $upstream"

dest="$REF_DIR/${upstream/\//__}"
rm -rf "$dest"
mkdir -p "$REF_DIR"

echo "Fetching $upstream${path:+ ($path)} into .reference/ ..."
git clone --quiet --filter=blob:none --no-checkout "https://github.com/$upstream.git" "$dest"
if [ -n "$path" ]; then
  git -C "$dest" sparse-checkout set --cone "$path"
fi
git -C "$dest" checkout --quiet "${ref:-$(git -C "$dest" symbolic-ref --short HEAD)}"
commit="$(git -C "$dest" rev-parse --short=12 HEAD)"
rm -rf "$dest/.git"  # plain files only: no hooks, nothing that looks like a live repo

# Agents auto-load instruction and settings files from subfolders (CLAUDE.md, AGENTS.md,
# .claude/ ...). Rename them so upstream instructions can't reach an agent working in this
# repo. The content stays readable under the new name.
defused=0
# Symlinks can point anywhere on this machine; drop them all.
links="$(find "$dest" -type l | wc -l | tr -d ' ')"
find "$dest" -type l -delete
defused=$((defused + links))
while IFS= read -r f; do
  mv "$f" "$(dirname "$f")/_defused_$(basename "$f").txt"; defused=$((defused + 1))
done < <(find "$dest" -depth -type f \( -name 'CLAUDE.md' -o -name 'CLAUDE.local.md' -o -name 'AGENTS.md' \
  -o -name 'GEMINI.md' -o -name '.cursorrules' -o -name '.windsurfrules' -o -name 'copilot-instructions.md' \))
while IFS= read -r d; do
  mv "$d" "$(dirname "$d")/_defused_$(basename "$d")"; defused=$((defused + 1))
done < <(find "$dest" -depth -type d \( -name '.claude' -o -name '.cursor' -o -name '.codex' -o -name '.gemini' \
  -o -name '.windsurf' -o -name '.agents' -o -name '.github' \))

[ -z "$path" ] || [ -e "$dest/$path" ] || die "$path not found in $upstream at $commit"

license="none found - assume all rights reserved"
for f in "$dest"/LICENSE* "$dest"/LICENCE*; do
  if [ -f "$f" ]; then
    license="$(grep -m1 -v '^[[:space:]]*$' "$f" | sed 's/^[[:space:]#]*//; s/[[:space:]]*$//' | cut -c1-60)"
    break
  fi
done

echo
echo "Saved to: ${dest#"$REPO_ROOT"/}/${path}"
echo "Commit:   $commit"
echo "License:  $license"
[ "$defused" -eq 0 ] || echo "Defused:  $defused symlink(s) and agent instruction/settings file(s) (removed or renamed _defused_*)"
echo
echo "Skills found:"
find "$dest/${path}" -name SKILL.md | sed "s|^$dest/|  |" | sort
echo
echo "Read for ideas, then write your own version in skills/<pack>/<name>/."
echo "Credit it in CREDITS.md as: [$upstream \`<skill>\`](https://github.com/$upstream/tree/$commit/<path>)"
case "$license" in
  *Creative*Commons*|*CC-BY-SA*|*ShareAlike*)
    echo "NOTE: share-alike license. Copying text makes your skill share-alike too; write it in your own words." ;;
  none*)
    echo "NOTE: no license. Do not copy any text; learn from the ideas only." ;;
esac
