#!/usr/bin/env bash
# Copy a third-party skill into this repo, pinned to an exact commit.
#
# Third-party skills are untrusted until reviewed. This script only downloads and
# copies files; it never runs anything from the downloaded skill. Read every file
# it lists before you commit.
#
# Usage:
#   scripts/vendor.sh <owner/repo> <path/to/skill> <pack> [--ref REF] [--force]
#
#   owner/repo      GitHub repository, e.g. mattpocock/skills
#   path/to/skill   Folder inside that repo that contains SKILL.md
#   pack            Destination pack under skills/, e.g. engineering
#   --ref REF       Branch, tag or commit to pin (default: the repo's default branch)
#   --force         Replace an existing copy (use this to update a vendored skill)
#
# Examples:
#   scripts/vendor.sh mattpocock/skills skills/productivity/grill-me core
#   scripts/vendor.sh hamelsmu/evals-skills skills/error-analysis ai-engineering --ref v1.2.0
#
# The skill lands in skills/<pack>/<skill-name>/ and a row is recorded in SOURCES.md
# (upstream, commit, license, date). If the license file lives at the upstream repo
# root, it is copied in as LICENSE.upstream so the notice travels with the skill.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCES="$REPO_ROOT/SOURCES.md"

usage() { sed -n '2,/^$/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }
die() { echo "error: $*" >&2; exit 1; }

positional=()
ref=""
force=0
while [ $# -gt 0 ]; do
  case "$1" in
    --ref)   [ $# -ge 2 ] || die "--ref needs a value"; ref="$2"; shift 2 ;;
    --force) force=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) die "unknown option: $1 (see --help)" ;;
    *) positional+=("$1"); shift ;;
  esac
done
[ "${#positional[@]}" -eq 3 ] || { usage; exit 2; }

upstream="${positional[0]}"
skill_path="${positional[1]%/}"
pack="${positional[2]}"
name="$(basename "$skill_path")"
dest="$REPO_ROOT/skills/$pack/$name"

[[ "$upstream" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || die "expected owner/repo, got: $upstream"
[ -d "$REPO_ROOT/skills/$pack" ] || die "unknown pack: $pack (packs: $(ls "$REPO_ROOT/skills" | tr '\n' ' '))"
if [ -e "$dest" ] && [ "$force" -ne 1 ]; then
  die "$dest already exists (use --force to replace it)"
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "Fetching $upstream ($skill_path) ..."
git clone --quiet --filter=blob:none --no-checkout "https://github.com/$upstream.git" "$tmp/repo"
git -C "$tmp/repo" sparse-checkout set --cone "$skill_path"
if [ -n "$ref" ]; then
  git -C "$tmp/repo" checkout --quiet "$ref"
else
  git -C "$tmp/repo" checkout --quiet "$(git -C "$tmp/repo" symbolic-ref --short HEAD)"
fi
commit="$(git -C "$tmp/repo" rev-parse HEAD)"
src="$tmp/repo/$skill_path"

[ -f "$src/SKILL.md" ] || die "no SKILL.md at $upstream/$skill_path (commit ${commit:0:12})"

# License: prefer one inside the skill folder, else the repo root (cone mode checks out root files).
license_file=""
for f in "$src"/LICENSE* "$src"/LICENCE* "$tmp/repo"/LICENSE* "$tmp/repo"/LICENCE*; do
  [ -f "$f" ] && { license_file="$f"; break; }
done
if [ -n "$license_file" ]; then
  license="$(grep -m1 -v '^[[:space:]]*$' "$license_file" | sed 's/^[[:space:]#]*//; s/[[:space:]]*$//' | cut -c1-60)"
else
  license="NONE FOUND - check before use"
fi

rm -rf "$dest"
mkdir -p "$dest"
cp -R "$src"/. "$dest"/
if [ -n "$license_file" ] && [ "$(dirname "$license_file")" != "$src" ]; then
  cp "$license_file" "$dest/LICENSE.upstream"
fi

# Record provenance in SOURCES.md (replacing any previous row for this skill).
row="| \`$name\` | $pack | [$upstream/$skill_path](https://github.com/$upstream/tree/$commit/$skill_path) | \`${commit:0:12}\` | $license | $(date +%F) | no |"
tmp_sources="$tmp/SOURCES.md"
grep -v "^| \`$name\` |" "$SOURCES" > "$tmp_sources" || true
echo "$row" >> "$tmp_sources"
cp "$tmp_sources" "$SOURCES"

echo
echo "Vendored $name → skills/$pack/$name at ${commit:0:12} (license: $license)"
echo
echo "REVIEW BEFORE COMMITTING: read every file below, especially scripts and any"
echo "instruction that fetches URLs, installs packages or touches credentials."
(cd "$dest" && find . -type f | sort | while read -r f; do
  flag=""
  case "$f" in *.sh|*.py|*.js|*.ts|*.mjs|*.cjs|*.rb|*.ps1) flag="  <- executable code" ;; esac
  [ -x "$f" ] && flag="  <- executable code"
  echo "  $f$flag"
done)
echo

python3 "$REPO_ROOT/scripts/skills.py" sync-marketplace
python3 "$REPO_ROOT/scripts/skills.py" validate || true
