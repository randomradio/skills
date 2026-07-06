# Skills

Development tools organized as a Claude Code plugin at `plugins/randomradio/`.

## Quick Start

Install the plugin:
```bash
claude plugin add ./plugins/randomradio
```

## Available Skills

| Skill | Purpose |
|-------|---------|
| `rr:work` | Goal-driven execution with inline/task-list defaults and optional delegation |
| `rr:plan` | Structured implementation planning with TDD tasks |
| `rr:brainstorm` | Requirements exploration before planning |
| `rr:review` | Persona-based code review with parallel sub-agents |
| `rr:debug` | Systematic root cause debugging |
| `rr:tdd` | Test-driven development discipline |
| `rr:plantuml-qpr-render` | Render PlantUML via qpr with controlled project/global preview artifacts |
| `rr:skills-market-publish` | Publish skills and the public skills market through CI, GitHub Pages, and Cloudflare DNS |
| `rr:quick-shoutout` | Publish apps to latentvibe.com via Cloudflare |
| `rr:compound` | Capture solved problems as schema-backed `docs/solutions/` learnings |
| `rr:compound-refresh` | Refresh stale or overlapping solution docs |
| `rr:git-commit-push-pr` | Commit, push, and open a PR with repo conventions |

## Skills Market

The static catalog for `skills.icyzhao.com` lives in `site/`.

```bash
node site/scripts/build-registry.mjs
cd site && python3 -m http.server 4173
```

GitHub Actions validates the install/update scripts, checks that
`site/registry.json` is current, and deploys `site/` to GitHub Pages on pushes
to `master`. Configure the repository Pages source as **GitHub Actions** and set
the custom domain to `skills.icyzhao.com`.

## Workflow

```
rr:brainstorm → rr:plan → rr:work → rr:review → ship
```

## Core Pattern: Goal-Driven Execution

`rr:work` uses a goal-driven loop adapted for both Codex and Claude Code:

1. Define **Goal** and verifiable **Criteria**
2. Execute small units inline or from a task list by default
3. Delegate only when the platform supports it and the user asked for agents
4. Loop until all criteria are met

The worker keeps evidence close: tests, behavioral checks, file changes, and any criteria that still fail.

## Plugin Structure

```
plugins/randomradio/
├── .claude-plugin/plugin.json     # Plugin manifest
├── skills/                        # Skill definitions (SKILL.md + references/)
├── agents/
│   ├── review/                    # reviewer personas (correctness, standards, security, etc.)
│   └── research/                  # Research agents (best-practices, framework-docs)
└── references/                    # Shared conventions
```

## Other Tools

| Directory | Purpose |
|-----------|---------|
| `randomradio-upgrade/` | Skill package manager — upgrade all skills from GitHub |
