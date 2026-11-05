#!/usr/bin/env bash
# Link this repo's skills into your agents' skill folders.
#
# Each skill folder is symlinked (not copied), so `git pull` in this repo updates
# every agent at once, and *.private.md files stay on your machine.
#
# Usage:
#   scripts/install.sh [options]
#
# Options:
#   --agent LIST     Comma-separated targets (default: claude,codex)
#                      claude    ~/.claude/skills               (Claude Code)
#                      codex     ~/.agents/skills               (Codex and other .agents readers)
#                      cursor    ~/.cursor/skills
#                      gemini    ~/.gemini/skills
#                      copilot   ~/.copilot/skills
#                      opencode  ~/.config/opencode/skills
#                      windsurf  ~/.codeium/windsurf/skills
#                      all       every target above
#   --pack LIST      Packs to link, e.g. core,engineering, or "all" (default: core)
#                    Keep global installs small; add other packs per project.
#   --project DIR    Install into a project instead of globally
#                    (DIR/.claude/skills, DIR/.agents/skills, DIR/.windsurf/skills)
#   --profile        Also load profile/PROFILE.md in every session (global only):
#                      claude  adds an @import line to ~/.claude/CLAUDE.md
#                      codex   links ~/.codex/AGENTS.md   (only if it doesn't exist)
#                      gemini  links ~/.gemini/GEMINI.md  (only if it doesn't exist)
#   --uninstall      Remove links that point into this repo (other skills are untouched);
#                    with --profile, also remove the profile
#   --dry-run        Print what would happen without changing anything
#   -h, --help       Show this help
#
# Examples:
#   scripts/install.sh --profile                        # core pack + profile → Claude Code + Codex
#   scripts/install.sh --agent all --pack all           # everything → every agent
#   scripts/install.sh --project ~/code/my-startup --pack startup,engineering
#   scripts/install.sh --uninstall --agent all --profile

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
PROFILE="$REPO_ROOT/profile/PROFILE.md"
ALL_AGENTS="claude,codex,cursor,gemini,copilot,opencode,windsurf"

agents="claude,codex"
packs=""
project=""
mode="install"
profile=0
dry_run=0

usage() { sed -n '2,/^$/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }
die() { echo "error: $*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --agent)     [ $# -ge 2 ] || die "--agent needs a value"; agents="$2"; shift 2 ;;
    --pack)      [ $# -ge 2 ] || die "--pack needs a value"; packs="$2"; shift 2 ;;
    --project)   [ $# -ge 2 ] || die "--project needs a value"; project="$2"; shift 2 ;;
    --profile)   profile=1; shift ;;
    --uninstall) mode="uninstall"; shift ;;
    --dry-run)   dry_run=1; shift ;;
    -h|--help)   usage; exit 0 ;;
    *)           die "unknown option: $1 (see --help)" ;;
  esac
done

[ "$agents" = "all" ] && agents="$ALL_AGENTS"
# Install defaults to the core pack; uninstall defaults to every pack.
if [ -z "$packs" ]; then
  if [ "$mode" = "install" ]; then packs="core"; else packs="all"; fi
fi
[ "$packs" = "all" ] && packs=""

if [ -n "$project" ]; then
  [ -d "$project" ] || die "project folder not found: $project"
  project="$(cd "$project" && pwd)"
  [ "$profile" -eq 0 ] || die "--profile is global only; drop --project to install it"
fi

global_dir() {
  case "$1" in
    claude)   echo "$HOME/.claude/skills" ;;
    codex)    echo "$HOME/.agents/skills" ;;
    cursor)   echo "$HOME/.cursor/skills" ;;
    gemini)   echo "$HOME/.gemini/skills" ;;
    copilot)  echo "$HOME/.copilot/skills" ;;
    opencode) echo "$HOME/.config/opencode/skills" ;;
    windsurf) echo "$HOME/.codeium/windsurf/skills" ;;
    *) return 1 ;;
  esac
}

project_dir() {
  case "$1" in
    claude)   echo "$project/.claude/skills" ;;
    windsurf) echo "$project/.windsurf/skills" ;;
    codex|cursor|gemini|copilot|opencode) echo "$project/.agents/skills" ;;
    *) return 1 ;;
  esac
}

run() {
  if [ "$dry_run" -eq 1 ]; then echo "  [dry-run] $*"; else "$@"; fi
}

# Resolve target folders, de-duplicated (several agents share .agents/skills in project mode).
targets=""
IFS=',' read -r -a agent_list <<< "$agents"
for agent in "${agent_list[@]}"; do
  if [ -n "$project" ]; then
    dir="$(project_dir "$agent")" || die "unknown agent: $agent"
  else
    dir="$(global_dir "$agent")" || die "unknown agent: $agent"
  fi
  case $'\n'"$targets"$'\n' in
    *$'\n'"$dir"$'\n'*) ;;
    *) targets="${targets:+$targets$'\n'}$dir" ;;
  esac
done

if [ -n "$packs" ]; then
  IFS=',' read -r -a pack_list <<< "$packs"
  for p in "${pack_list[@]}"; do
    [ -d "$SKILLS_DIR/$p" ] || die "unknown pack: $p (packs: $(ls "$SKILLS_DIR" | tr '\n' ' '))"
  done
fi

in_packs() {
  [ -z "$packs" ] && return 0
  case ",$packs," in *",$1,"*) return 0 ;; *) return 1 ;; esac
}

# Collect skills: skills/<pack>/<skill>/SKILL.md
skill_paths=()
while IFS= read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  in_packs "$(basename "$(dirname "$skill_dir")")" || continue
  skill_paths+=("$skill_dir")
done < <(find "$SKILLS_DIR" -mindepth 3 -maxdepth 3 -name SKILL.md | sort)

points_into_repo() {
  case "$(readlink "$1")" in "$SKILLS_DIR"/*) return 0 ;; *) return 1 ;; esac
}

linked=0 skipped=0 removed=0

while IFS= read -r target; do
  [ -n "$target" ] || continue
  echo "→ $target"

  if [ "$mode" = "uninstall" ]; then
    [ -d "$target" ] || continue
    for entry in "$target"/*; do
      [ -L "$entry" ] && points_into_repo "$entry" || continue
      in_packs "$(basename "$(dirname "$(readlink "$entry")")")" || continue
      run rm "$entry"; echo "  removed $(basename "$entry")"; removed=$((removed + 1))
    done
    continue
  fi

  run mkdir -p "$target"

  # Prune links to skills that were deleted or renamed in this repo.
  if [ -d "$target" ]; then
    for entry in "$target"/*; do
      if [ -L "$entry" ] && points_into_repo "$entry" && [ ! -e "$entry" ]; then
        run rm "$entry"; echo "  pruned stale link $(basename "$entry")"; removed=$((removed + 1))
      fi
    done
  fi

  for src in ${skill_paths[@]+"${skill_paths[@]}"}; do
    name="$(basename "$src")"
    link="$target/$name"
    if [ -L "$link" ]; then
      if [ "$(readlink "$link")" = "$src" ]; then
        continue  # already installed
      elif points_into_repo "$link"; then
        run rm "$link"  # moved to another pack: relink below
      else
        echo "  skip $name: $link links somewhere else"; skipped=$((skipped + 1)); continue
      fi
    elif [ -e "$link" ]; then
      echo "  skip $name: $link already exists and is not managed by this repo"
      skipped=$((skipped + 1)); continue
    fi
    run ln -s "$src" "$link"; echo "  linked $name"; linked=$((linked + 1))
  done
done <<< "$targets"

# ---------------------------------------------------------------- always-on profile

profile_claude() {
  local file="$HOME/.claude/CLAUDE.md" line="@$PROFILE"
  if [ "$mode" = "uninstall" ]; then
    if [ -f "$file" ] && grep -qxF "$line" "$file"; then
      if [ "$dry_run" -eq 1 ]; then
        echo "  [dry-run] remove '$line' from $file"
      else
        grep -vxF -e "$line" -e "# Personal profile (skills repo)" "$file" > "$file.tmp" || true
        mv "$file.tmp" "$file"
      fi
      echo "  profile: removed import from $file"
    fi
    return
  fi
  if [ -f "$file" ] && grep -qxF "$line" "$file"; then
    return  # already imported
  fi
  if [ "$dry_run" -eq 1 ]; then
    echo "  [dry-run] append '$line' to $file"
  else
    mkdir -p "$(dirname "$file")"
    { [ -s "$file" ] && echo; echo "# Personal profile (skills repo)"; echo "$line"; } >> "$file"
  fi
  echo "  profile: imported into $file"
}

profile_link() {  # $1 = memory file that has no import syntax: link it if free
  local file="$1"
  if [ "$mode" = "uninstall" ]; then
    if [ -L "$file" ] && [ "$(readlink "$file")" = "$PROFILE" ]; then
      run rm "$file"; echo "  profile: removed $file"
    fi
    return
  fi
  if [ -L "$file" ] && [ "$(readlink "$file")" = "$PROFILE" ]; then
    return
  elif [ -e "$file" ] || [ -L "$file" ]; then
    echo "  profile: $file already exists; paste profile/PROFILE.md into it by hand"
    return
  fi
  run mkdir -p "$(dirname "$file")"
  run ln -s "$PROFILE" "$file"; echo "  profile: linked $file"
}

if [ "$profile" -eq 1 ]; then
  [ -f "$PROFILE" ] || die "missing $PROFILE"
  echo "→ profile"
  for agent in "${agent_list[@]}"; do
    case "$agent" in
      claude) profile_claude ;;
      codex)  profile_link "$HOME/.codex/AGENTS.md" ;;
      gemini) profile_link "$HOME/.gemini/GEMINI.md" ;;
      *)      echo "  profile: $agent has no global memory file this script manages; add it in $agent's settings" ;;
    esac
  done
fi

if [ "$mode" = "uninstall" ]; then
  echo "Done: $removed link(s) removed."
else
  echo "Done: ${#skill_paths[@]} skill(s) selected, $linked newly linked, $skipped skipped, $removed pruned."
  echo "Start a new agent session to pick up changes."
fi
