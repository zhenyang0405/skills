# Skills

My personal library of [Agent Skills](https://agentskills.io) for software engineering, AI engineering, startups and personal life. Every skill is a folder with a `SKILL.md`, so the same repo works with Claude Code, Codex, Cursor, Gemini CLI, GitHub Copilot, OpenCode and other agents that support the standard.

**Every skill here is my own.** I study the best open-source skills, then write my own version that fits me and doesn't overlap with anything else in the repo. Nothing is installed from or delegated to other people's skills. What each skill learned from is credited in [CREDITS.md](CREDITS.md).

## Layout

```
profile/PROFILE.md   short always-on profile, loaded in every session
skills/
  core/              always-on: personal context, planning, debugging, verification
  engineering/       specs, TDD, architecture, review, security, shipping
  ai-engineering/    context engineering, agents, evals, RAG, fine-tuning
  startup/           validation, discovery, positioning, GTM, fundraising
  personal/          learning, writing, finance, career, life admin
    <pack>/README.md            what the pack covers + skills to learn from
    <pack>/<skill>/SKILL.md     one skill per folder
templates/skill/     starting point for a new skill
scripts/
  install.sh         link skills (and the profile) into your agents
  fetch-reference.sh download someone else's skill into .reference/ to study
  skills.py          validate skills, regenerate the plugin marketplace
CREDITS.md           what each skill learned from
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
~/code/skills/scripts/install.sh --profile
```

This links the **core** pack into Claude Code (`~/.claude/skills`) and Codex (`~/.agents/skills`), and loads `profile/PROFILE.md` in every session. Global installs stay small on purpose: every installed skill's description is loaded in every session and competes to trigger. Add other packs where you need them:

```bash
~/code/skills/scripts/install.sh --project ~/code/my-startup --pack startup,engineering
```

```bash
~/code/skills/scripts/install.sh --agent all --pack all
```

```bash
~/code/skills/scripts/install.sh --uninstall --agent all --profile
```

Run `scripts/install.sh --help` for every option. Start a new agent session afterwards.

### 2. `npx skills` (any agent, no clone)

```bash
npx skills add zhenyang0405/skills --skill my-context
```

Add `-g` to install globally or `-a claude-code` to pick an agent.

### 3. Claude Code plugin marketplace (packs you can turn on and off)

```
/plugin marketplace add zhenyang0405/skills
/plugin install core@zhenyang-skills
```

Each pack that contains at least one skill becomes a plugin (`core`, `engineering`, …).

## Write a skill

1. **Study.** Find good skills for the job (each pack's README lists some), and download them to read:
   ```bash
   scripts/fetch-reference.sh mattpocock/skills skills/engineering/tdd
   ```
   Files land in `.reference/`, which is gitignored and never installed.
2. **Write your own.** Copy the template and rename it. The folder name must match `name:` in the frontmatter.
   ```bash
   cp -R templates/skill skills/engineering/tdd
   ```
   Take the ideas and structure, write the text yourself, tailor it with `my-context`, and cut anything you won't use.
3. **Credit.** Add a row to [CREDITS.md](CREDITS.md), including the industry sources it's grounded in.
4. **Test.** Write 2–3 realistic test cases in the skill's `evals/` folder and run them with and without the skill using the `skill-creator` skill. A skill ships only when it clearly beats no skill. The full loop is in [AGENTS.md](AGENTS.md).
5. **Check.**
   ```bash
   python3 scripts/skills.py sync-marketplace && python3 scripts/skills.py validate
   ```

## Personal context and privacy

- `profile/PROFILE.md`: a few lines that load in every session (who you are, how you like answers, default stack). It's tracked, so keep it non-sensitive.
- `skills/core/my-context`: the longer detail (background, goals, stack, projects), loaded only when relevant. Keep sensitive details in `*.private.md` files next to the templates, e.g. `about-me.private.md`. They are gitignored but still visible to local agents through the symlinks.

## Conventions

See [AGENTS.md](AGENTS.md): the rules agents (and you) follow when editing this repo.
