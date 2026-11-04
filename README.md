# Skills

My personal library of [Agent Skills](https://agentskills.io) for software engineering, AI engineering, startups and personal life. Every skill is a folder with a `SKILL.md`, so the same repo works with Claude Code, Codex, Cursor, Gemini CLI, GitHub Copilot, OpenCode and other agents that support the standard.

## Layout

```
skills/
  core/              always-on: personal context, planning, debugging, verification
  engineering/       specs, TDD, architecture, review, security, shipping
  ai-engineering/    context engineering, agents, evals, RAG, fine-tuning
  startup/           validation, discovery, positioning, GTM, fundraising
  personal/          learning, writing, finance, career, life admin
    <pack>/README.md            what the pack covers + candidate skills
    <pack>/<skill>/SKILL.md     one skill per folder
templates/skill/     starting point for a new skill
scripts/
  install.sh         link skills into your agents' skill folders
  vendor.sh          copy a third-party skill in, pinned to a commit
  skills.py          validate skills, regenerate the plugin marketplace
SOURCES.md           where every third-party skill came from (repo, commit, license)
research/            background research behind this repo
.claude-plugin/marketplace.json   generated: one Claude Code plugin per pack
```

## Install

Pick one of three ways.

### 1. Symlink (recommended for your own machine)

Clone once, then link the skills into each agent. Links point back to this clone, so `git pull` updates every agent, and `*.private.md` files stay local.

```bash
git clone https://github.com/zhenyang0405/skills.git ~/code/skills
```

```bash
~/code/skills/scripts/install.sh
```

By default this links every pack into Claude Code (`~/.claude/skills`) and Codex (`~/.agents/skills`). Other options:

```bash
~/code/skills/scripts/install.sh --agent all --pack core,engineering
```

```bash
~/code/skills/scripts/install.sh --project ~/code/my-startup --pack startup
```

```bash
~/code/skills/scripts/install.sh --uninstall --agent all
```

Run `scripts/install.sh --help` for every option. Start a new agent session afterwards to pick up the skills.

### 2. `npx skills` (any agent, no clone)

```bash
npx skills add zhenyang0405/skills
```

Add `-g` to install globally, `-a claude-code` to pick an agent, or `--skill my-context` for a single skill.

### 3. Claude Code plugin marketplace (packs you can turn on and off)

```
/plugin marketplace add zhenyang0405/skills
/plugin install core@zhenyang-skills
```

Each pack that contains at least one skill becomes a plugin (`core`, `engineering`, …).

## Add a skill

1. Copy the template into a pack and rename it. The folder name must match `name:` in the frontmatter.
   ```bash
   cp -R templates/skill skills/engineering/my-new-skill
   ```
2. Write the `description` carefully. It is the only part the agent sees before deciding whether to load the skill.
3. Regenerate the marketplace and validate:
   ```bash
   python3 scripts/skills.py sync-marketplace && python3 scripts/skills.py validate
   ```

## Add a third-party skill

```bash
scripts/vendor.sh mattpocock/skills skills/productivity/grill-me core
```

This copies the skill at an exact commit, records it in [SOURCES.md](SOURCES.md), and lists every file for you to review. **Read every file before committing.** Malicious skills are common on public marketplaces. To update later, re-run with `--force` (optionally `--ref <tag-or-commit>`) and review the diff.

## Personal context and privacy

`skills/core/my-context` holds facts about you (background, goals, stack, projects) that other skills read. If this repo is public, keep sensitive details in `*.private.md` files next to the templates, e.g. `about-me.private.md`. They are gitignored but still visible to local agents through the symlinks.

## Conventions

See [AGENTS.md](AGENTS.md): the rules agents (and you) follow when editing this repo.
