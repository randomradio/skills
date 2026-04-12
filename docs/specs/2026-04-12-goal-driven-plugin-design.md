# Goal-Driven Plugin Design

**Date:** 2026-04-12
**Status:** Approved

## Summary

Replace the existing `long-horizon-planner`, absorb the best of `superpowers` and `compound-engineering`, and restructure the skills repo into a proper plugin at `plugins/randomradio/` with goal-driven execution as the core work loop.

## Motivation

- The goal-driven master/subagent pattern is simpler and more effective than the stateful durable-control-file approach in `long-horizon-planner`
- The compound-engineering plugin structure (`.claude-plugin/`, `skills/`, `agents/`, `references/`) is a proven organizational pattern
- Consolidating the best of CE, superpowers, and goal-driven into one plugin removes redundancy

## Directory Structure

```
plugins/randomradio/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── work/
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── goal-driven-loop.md
│   │       └── shipping-workflow.md
│   ├── plan/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── brainstorm/
│   │   └── SKILL.md
│   ├── review/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── debug/
│   │   └── SKILL.md
│   ├── quick-shoutout/
│   │   ├── SKILL.md
│   │   ├── scripts/
│   │   └── references/
│   └── tdd/
│       └── SKILL.md
├── agents/
│   ├── review/
│   └── research/
└── references/
```

## Skill Namespace

All skills use `rr:` prefix (e.g., `rr:work`, `rr:plan`, `rr:brainstorm`).

## Core Skill: `rr:work`

### Phase 0: Input Triage

- Accepts: plan doc path, goal string, or bare prompt
- Extracts or infers **Goal** and **Criteria for success**
- If no verifiable criteria provided, asks the user before proceeding

### Phase 1: Setup

- Create branch or worktree
- Build todo list from plan (if one exists)
- Choose execution strategy: inline (trivial) vs. subagent (anything else)

### Phase 2: Goal-Driven Execution Loop

```
Master agent creates subagent with:
  - Goal + Criteria
  - Available inner tools: TDD, debugging, plan reference
  - Repo context

while (criteria not met):
    monitor subagent activity (~5 min intervals)
    if subagent inactive or declares done:
        evaluate against criteria
        if criteria not met:
            restart subagent with feedback on what's missing
        else:
            exit loop -> Phase 3
```

The subagent is free to use any approach. The master only evaluates against criteria.

### Phase 3: Ship

- Load `references/shipping-workflow.md`
- Run verification commands
- Create PR
- Notify user

## Supporting Skills

### `rr:plan`

Structured planning skill adapted from CE's `ce:plan`. Creates implementation plans with:
- Research phase (parallel sub-agents for best practices, framework docs)
- Implementation units with goal, files, approach, test scenarios, verification
- Output: durable plan doc in `docs/plans/`

### `rr:brainstorm`

Requirements exploration adapted from CE's `ce:brainstorm`. Collaborative dialogue to explore requirements before planning. Produces a requirements document. Answers "WHAT to build."

### `rr:review`

Code review with tiered persona-based review using parallel sub-agents. Personas defined in `agents/review/`. Modes: autofix, report-only.

### `rr:debug`

Systematic debugging adapted from superpowers. Root cause investigation before fixes. 4 phases: investigate, analyze, propose fix, verify.

### `rr:tdd`

Test-driven development discipline from superpowers. Red-green-refactor cycle. No production code without a failing test first.

### `rr:quick-shoutout`

Moved from top-level. Publishing apps to latentvibe.com via Cloudflare. No changes to functionality.

## What Gets Removed

| Directory | Action |
|-----------|--------|
| `long-horizon-planner/` | Delete (replaced by `rr:work`) |
| `superpowers/` | Delete (best parts absorbed into plugin) |
| `quick-shoutout/` | Move into `plugins/randomradio/skills/quick-shoutout/` |
| `randomradio-upgrade/` | Keep at top-level (manages plugin installation) |

## Agent Personas

### `agents/review/`

Reviewer personas for `rr:review`: adversarial, security, performance, architecture, correctness, maintainability, testing.

### `agents/research/`

Research agents for `rr:plan`: best-practices-researcher, framework-docs-researcher.

## Plugin Manifest

```json
{
  "name": "randomradio",
  "version": "1.0.0",
  "description": "Goal-driven development tools with structured planning, review, and autonomous execution.",
  "author": {
    "name": "randomradio"
  }
}
```

## Key Design Decisions

1. **Goal-driven as outer loop** — the master agent only monitors and evaluates. The subagent has full autonomy in approach.
2. **Superpowers as inner tools** — TDD, debugging, etc. are available to the subagent but not enforced by the master.
3. **CE phase structure** — input triage and shipping phases wrap the goal-driven loop, providing structure without fighting the pattern.
4. **Stateless execution** — no durable control files. The goal and criteria are the only state. Progress is measured by criteria evaluation.
5. **Verifiable criteria required** — the loop cannot start without criteria that can be objectively checked. This is what makes the pattern work.
