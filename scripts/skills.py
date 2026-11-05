#!/usr/bin/env python3
"""Tooling for this skills repo. Standard library only.

Usage:
  python3 scripts/skills.py list                     List every skill, grouped by pack
  python3 scripts/skills.py validate                 Check every SKILL.md against the spec and repo rules
  python3 scripts/skills.py sync-marketplace         Regenerate .claude-plugin/marketplace.json from skills/
  python3 scripts/skills.py sync-marketplace --check Fail if marketplace.json is out of date (used in CI)

Layout this script expects:
  skills/<pack>/README.md            Pack description: first paragraph after the "# " heading
  skills/<pack>/<skill>/SKILL.md     One skill per folder; folder name == frontmatter `name`
"""

from __future__ import annotations

import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SKILLS_DIR = ROOT / "skills"
MARKETPLACE = ROOT / ".claude-plugin" / "marketplace.json"
# Skills are written here, never copied in; see CREDITS.md and scripts/fetch-reference.sh.

# Limits from the Agent Skills spec (agentskills.io) plus repo conventions.
NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
NAME_MAX = 64
DESCRIPTION_MAX = 1024
BODY_LINES_WARN = 500
# Pack order in the marketplace; packs not listed here are appended alphabetically.
PACK_ORDER = ["core", "engineering", "ai-engineering", "startup", "personal"]

DEFAULT_MARKETPLACE_HEADER = {
    "name": "zhenyang-skills",
    "owner": {"name": "zhenyang0405"},
    "metadata": {
        "description": "Personal agent skills for engineering, AI engineering, startups and life.",
        "version": "0.1.0",
    },
}


@dataclass
class Skill:
    pack: str
    dir: Path
    meta: dict
    body: str
    errors: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)

    @property
    def name(self) -> str:
        return self.dir.name

    @property
    def rel(self) -> str:
        return self.dir.relative_to(ROOT).as_posix()


# --------------------------------------------------------------------------- frontmatter


def _unquote(value: str) -> str:
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "'\"":
        return value[1:-1]
    return value


def _parse_simple_yaml(text: str) -> dict:
    """Parse the small YAML subset used in SKILL.md frontmatter.

    Supports `key: value`, quoted scalars, `>`/`|` block scalars, plain scalars that
    continue on indented lines, and nested mappings (kept as raw text).
    """
    result: dict = {}
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        line = lines[i]
        if not line.strip() or line.lstrip().startswith("#"):
            i += 1
            continue
        if line[0].isspace():
            raise ValueError(f"unexpected indentation: {line!r}")
        if ":" not in line:
            raise ValueError(f"expected 'key: value': {line!r}")
        key, _, value = line.partition(":")
        key, value = key.strip(), value.strip()
        block: list[str] = []
        i += 1
        while i < len(lines) and (not lines[i].strip() or lines[i][0].isspace()):
            block.append(lines[i])
            i += 1
        while block and not block[-1].strip():
            block.pop()
        stripped = [b.strip() for b in block]
        if value in (">", ">-", ">+"):
            result[key] = " ".join(s for s in stripped if s)
        elif value in ("|", "|-", "|+"):
            result[key] = "\n".join(stripped)
        elif value == "":
            result[key] = "\n".join(block)  # nested mapping or list: keep raw
        else:
            result[key] = " ".join([_unquote(value)] + [s for s in stripped if s])
    return result


def parse_frontmatter(text: str) -> tuple[dict, str]:
    if not text.startswith("---"):
        raise ValueError("SKILL.md must start with '---' YAML frontmatter")
    parts = re.split(r"^---[ \t]*$", text, maxsplit=2, flags=re.MULTILINE)
    if len(parts) < 3:
        raise ValueError("frontmatter is not closed with '---'")
    raw, body = parts[1], parts[2]
    try:
        import yaml  # type: ignore

        meta = yaml.safe_load(raw) or {}
        if not isinstance(meta, dict):
            raise ValueError("frontmatter must be a YAML mapping")
    except ImportError:
        meta = _parse_simple_yaml(raw)
    return meta, body


# --------------------------------------------------------------------------- discovery


def pack_dirs() -> list[Path]:
    if not SKILLS_DIR.is_dir():
        return []
    packs = [p for p in SKILLS_DIR.iterdir() if p.is_dir() and not p.name.startswith(".")]
    order = {name: i for i, name in enumerate(PACK_ORDER)}
    return sorted(packs, key=lambda p: (order.get(p.name, len(order)), p.name))


def pack_description(pack: Path) -> str:
    readme = pack / "README.md"
    if not readme.is_file():
        return f"{pack.name} skills"
    paragraph: list[str] = []
    seen_heading = False
    for line in readme.read_text(encoding="utf-8").splitlines():
        if line.startswith("# "):
            seen_heading = True
            continue
        if not seen_heading:
            continue
        if line.strip():
            paragraph.append(line.strip())
        elif paragraph:
            break
    return " ".join(paragraph) or f"{pack.name} skills"


def load_skills() -> list[Skill]:
    skills: list[Skill] = []
    for pack in pack_dirs():
        for skill_dir in sorted(p for p in pack.iterdir() if p.is_dir()):
            skill_md = skill_dir / "SKILL.md"
            if not skill_md.is_file():
                continue
            try:
                meta, body = parse_frontmatter(skill_md.read_text(encoding="utf-8"))
                skills.append(Skill(pack.name, skill_dir, meta, body))
            except ValueError as exc:
                s = Skill(pack.name, skill_dir, {}, "")
                s.errors.append(f"frontmatter: {exc}")
                skills.append(s)
    return skills


# --------------------------------------------------------------------------- commands


def cmd_list() -> int:
    skills = load_skills()
    if not skills:
        print("No skills yet. Copy templates/skill/ into skills/<pack>/<name>/ to add one.")
        return 0
    current = None
    for s in skills:
        if s.pack != current:
            current = s.pack
            print(f"\n[{current}]")
        desc = str(s.meta.get("description", "")).strip()
        print(f"  {s.name:<32} {desc[:90]}{'…' if len(desc) > 90 else ''}")
    print()
    return 0


def validate_skill(s: Skill) -> None:
    name = s.meta.get("name")
    desc = s.meta.get("description")

    if not name:
        s.errors.append("missing `name` in frontmatter")
    else:
        name = str(name)
        if name != s.name:
            s.errors.append(f"`name: {name}` must match folder name `{s.name}`")
        if len(name) > NAME_MAX:
            s.errors.append(f"`name` is longer than {NAME_MAX} characters")
        if not NAME_RE.match(name):
            s.errors.append("`name` must be lowercase letters, digits and single hyphens")

    if not desc or not str(desc).strip():
        s.errors.append("missing `description` (it is what makes the skill trigger)")
    else:
        desc = str(desc).strip()
        if len(desc) > DESCRIPTION_MAX:
            s.errors.append(f"`description` is {len(desc)} chars; max is {DESCRIPTION_MAX}")
        if "<" in desc and ">" in desc and re.search(r"<[^>]+>", desc):
            s.warnings.append("`description` still contains a <placeholder>")
        if not re.search(r"\b(use|when)\b", desc, re.IGNORECASE):
            s.warnings.append("`description` should say *when* to use the skill (e.g. 'Use when …')")

    body_lines = s.body.count("\n")
    if body_lines > BODY_LINES_WARN:
        s.warnings.append(
            f"SKILL.md body is {body_lines} lines; keep it under {BODY_LINES_WARN} "
            "and move detail into references/"
        )

    # Every relative link in the body should point at a file that exists.
    for target in re.findall(r"\]\(([^)#\s]+)\)", s.body):
        if re.match(r"^[a-z]+:", target) or target.startswith("/"):
            continue
        if not (s.dir / target).exists():
            s.errors.append(f"broken link to `{target}`")


def credited_skills() -> set[str]:
    """Skill names in the first column of the CREDITS.md table, written as `name`."""
    credits = ROOT / "CREDITS.md"
    if not credits.is_file():
        return set()
    names = set()
    for line in credits.read_text(encoding="utf-8").splitlines():
        m = re.match(r"^\|\s*`([a-z0-9-]+)`\s*\|", line)
        if m:
            names.add(m.group(1))
    return names


def cmd_validate() -> int:
    skills = load_skills()
    for s in skills:
        validate_skill(s)

    # Skill names must be unique across packs: installs flatten packs into one folder.
    by_name: dict[str, list[Skill]] = {}
    for s in skills:
        by_name.setdefault(s.name, []).append(s)
    for name, group in by_name.items():
        if len(group) > 1:
            where = ", ".join(g.rel for g in group)
            for g in group:
                g.errors.append(f"duplicate skill name `{name}` ({where})")

    # Every skill should say in CREDITS.md what it learned from (or `original`).
    credited = credited_skills()
    for s in skills:
        if s.name not in credited:
            s.warnings.append("no row in CREDITS.md (add what inspired it, or `original`)")

    # A SKILL.md directly in a pack folder would shadow the skills inside it for `npx skills`.
    stray = [p / "SKILL.md" for p in pack_dirs() if (p / "SKILL.md").exists()]

    errors = sum(len(s.errors) for s in skills) + len(stray)
    warnings = sum(len(s.warnings) for s in skills)
    for path in stray:
        print(f"ERROR {path.relative_to(ROOT)}: pack folders must not contain SKILL.md (use README.md)")
    for s in skills:
        for e in s.errors:
            print(f"ERROR {s.rel}: {e}")
        for w in s.warnings:
            print(f"warn  {s.rel}: {w}")

    stale = marketplace_is_stale(skills)
    if stale:
        print("ERROR .claude-plugin/marketplace.json is out of date: run `python3 scripts/skills.py sync-marketplace`")
        errors += 1

    print(f"\n{len(skills)} skill(s), {errors} error(s), {warnings} warning(s)")
    return 1 if errors else 0


def build_marketplace(skills: list[Skill]) -> dict:
    header = dict(DEFAULT_MARKETPLACE_HEADER)
    if MARKETPLACE.is_file():
        try:
            existing = json.loads(MARKETPLACE.read_text(encoding="utf-8"))
            for key in ("name", "owner", "metadata"):
                if key in existing:
                    header[key] = existing[key]
        except json.JSONDecodeError:
            pass

    plugins = []
    for pack in pack_dirs():
        members = [s for s in skills if s.pack == pack.name and not s.errors]
        if not members:
            continue  # empty packs are not published as plugins
        plugins.append(
            {
                "name": pack.name,
                "description": pack_description(pack),
                "source": "./",
                "strict": False,
                "skills": [f"./{s.rel}" for s in members],
            }
        )
    return {**header, "plugins": plugins}


def render_marketplace(data: dict) -> str:
    return json.dumps(data, indent=2, ensure_ascii=False) + "\n"


def marketplace_is_stale(skills: list[Skill]) -> bool:
    wanted = render_marketplace(build_marketplace(skills))
    current = MARKETPLACE.read_text(encoding="utf-8") if MARKETPLACE.is_file() else ""
    return wanted != current


def cmd_sync_marketplace(check: bool) -> int:
    skills = load_skills()
    rendered = render_marketplace(build_marketplace(skills))
    current = MARKETPLACE.read_text(encoding="utf-8") if MARKETPLACE.is_file() else ""
    if check:
        if rendered != current:
            print("marketplace.json is out of date: run `python3 scripts/skills.py sync-marketplace`")
            return 1
        print("marketplace.json is up to date")
        return 0
    if rendered == current:
        print("marketplace.json already up to date")
        return 0
    MARKETPLACE.parent.mkdir(parents=True, exist_ok=True)
    MARKETPLACE.write_text(rendered, encoding="utf-8")
    print(f"wrote {MARKETPLACE.relative_to(ROOT)}")
    return 0


def main(argv: list[str]) -> int:
    if not argv or argv[0] in ("-h", "--help", "help"):
        print(__doc__)
        return 0
    cmd, rest = argv[0], argv[1:]
    if cmd == "list":
        return cmd_list()
    if cmd == "validate":
        return cmd_validate()
    if cmd == "sync-marketplace":
        return cmd_sync_marketplace(check="--check" in rest)
    print(f"unknown command: {cmd}\n{__doc__}", file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
