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
#   --pack LIST      Only these packs, e.g. core,engineering (default: all packs)
#   --project DIR    Install into a project instead of globally
#                    (DIR/.claude/skills, DIR/.agents/skills, DIR/.windsurf/skills)
#   --uninstall      Remove links that point into this repo (other skills are untouched)
#   --dry-run        Print what would happen without changing anything
#   -h, --help       Show this help
#
# Examples:
#   scripts/install.sh                                  # all packs → Claude Code + Codex
#   scripts/install.sh --agent all --pack core          # core pack → every agent
#   scripts/install.sh --project ~/code/my-startup --pack startup
#   scripts/install.sh --uninstall --agent all

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
ALL_AGENTS="claude,codex,cursor,gemini,copilot,opencode,windsurf"

agents="claude,codex"
packs=""
project=""
mode="install"
dry_run=0

usage() { sed -n '2,/^$/p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }
die() { echo "error: $*" >&2; exit 1; }

while [ $# -gt 0 ]; do
  case "$1" in
    --agent)     [ $# -ge 2 ] || die "--agent needs a value"; agents="$2"; shift 2 ;;
    --pack)      [ $# -ge 2 ] || die "--pack needs a value"; packs="$2"; shift 2 ;;
    --project)   [ $# -ge 2 ] || die "--project needs a value"; project="$2"; shift 2 ;;
    --uninstall) mode="uninstall"; shift ;;
    --dry-run)   dry_run=1; shift ;;
    -h|--help)   usage; exit 0 ;;
    *)           die "unknown option: $1 (see --help)" ;;
  esac
done

[ "$agents" = "all" ] && agents="$ALL_AGENTS"

if [ -n "$project" ]; then
  [ -d "$project" ] || die "project folder not found: $project"
  project="$(cd "$project" && pwd)"
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

# Collect skills: skills/<pack>/<skill>/SKILL.md
skill_paths=()
while IFS= read -r skill_md; do
  skill_dir="$(dirname "$skill_md")"
  pack="$(basename "$(dirname "$skill_dir")")"
  if [ -n "$packs" ]; then
    case ",$packs," in *",$pack,"*) ;; *) continue ;; esac
  fi
  skill_paths+=("$skill_dir")
done < <(find "$SKILLS_DIR" -mindepth 3 -maxdepth 3 -name SKILL.md | sort)

if [ -n "$packs" ]; then
  IFS=',' read -r -a pack_list <<< "$packs"
  for p in "${pack_list[@]}"; do
    [ -d "$SKILLS_DIR/$p" ] || die "unknown pack: $p (packs: $(ls "$SKILLS_DIR" | tr '\n' ' '))"
  done
fi

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
      [ -L "$entry" ] || continue
      if points_into_repo "$entry"; then
        if [ -n "$packs" ]; then
          pack="$(basename "$(dirname "$(readlink "$entry")")")"
          case ",$packs," in *",$pack,"*) ;; *) continue ;; esac
        fi
        run rm "$entry"; echo "  removed $(basename "$entry")"; removed=$((removed + 1))
      fi
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

if [ "$mode" = "uninstall" ]; then
  echo "Done: $removed link(s) removed."
else
  echo "Done: ${#skill_paths[@]} skill(s) available, $linked newly linked, $skipped skipped, $removed pruned."
  echo "Restart your agent (or start a new session) to pick up new skills."
fi
