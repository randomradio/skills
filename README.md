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
| `rr:work` | Goal-driven execution — master/subagent loop with verifiable criteria |
| `rr:plan` | Structured implementation planning with TDD tasks |
| `rr:brainstorm` | Requirements exploration before planning |
| `rr:review` | Persona-based code review with parallel sub-agents |
| `rr:debug` | Systematic root cause debugging |
| `rr:tdd` | Test-driven development discipline |
| `rr:quick-shoutout` | Publish apps to latentvibe.com via Cloudflare |

## Workflow

```
rr:brainstorm → rr:plan → rr:work → rr:review → ship
```

## Core Pattern: Goal-Driven Execution

`rr:work` uses a goal-driven master/subagent loop ([source](https://github.com/lidangzzz/goal-driven)):

1. Define **Goal** and verifiable **Criteria**
2. Master creates subagent to work toward the goal
3. Master monitors, evaluates against criteria, restarts if needed
4. Loop until all criteria are met

The subagent has full autonomy in approach (TDD, debugging, etc.). The master only orchestrates.

## Plugin Structure

```
plugins/randomradio/
├── .claude-plugin/plugin.json     # Plugin manifest
├── skills/                        # Skill definitions (SKILL.md + references/)
├── agents/
│   ├── review/                    # 7 reviewer personas (adversarial, security, etc.)
│   └── research/                  # Research agents (best-practices, framework-docs)
└── references/                    # Shared conventions
```

## Other Tools

| Directory | Purpose |
|-----------|---------|
| `randomradio-upgrade/` | Skill package manager — upgrade all skills from GitHub |
