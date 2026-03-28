---
name: long-horizon-planner
description: Plan and steer long-running coding tasks with durable control docs, then execute either an objective-first work/review loop or delegated milestone workflows such as Superpowers with resumable state when needed.
---

# Long Horizon Planner

## Overview

Use this as a hybrid long-horizon system:
- control plane: `Prompt.md`, `Plans.md`, `Implement.md`, `Documentation.md`
- execution plane option A: objective-first loop runner in `.codex/long-horizon-loop/`
- execution plane option B: delegated milestone execution via Superpowers-style workflows

The planning docs remain source of truth. Loop artifacts provide reliable execution telemetry and resume support. Delegated milestone plans provide detailed task decomposition and execution structure without turning `Plans.md` into a giant task list.

## Update Check On Invocation

When this skill is loaded, run:

```bash
./scripts/check_for_updates.sh --quiet
```

If status is `update_available`, tell the user to run:
- `$randomradio-upgrade`
- or `~/.codex/skills/randomradio-upgrade/scripts/upgrade_skills.sh --skills long-horizon-planner`

## Quick Start

Initialize planning docs in a repo:

```bash
./scripts/init_long_horizon_workspace.sh --root .
```

Validate planning docs shape:

```bash
./scripts/validate_long_horizon_workspace.sh --root .
```

Run objective-first loop execution:

```bash
./scripts/run_long_horizon_loop.sh \
  --cwd . \
  --engine codex \
  --max-iterations 20 \
  --validate-cmd "npm test"
```

Resume an interrupted run:

```bash
./scripts/run_long_horizon_loop.sh --cwd . --engine codex --resume
```

Stop a running loop safely:

```bash
touch ./.codex/long-horizon-loop/STOP
```

Install this skill into Codex skills:

```bash
./scripts/install_skill.sh --target-dir "$HOME/.codex/skills" --force
```

## Modes

1. Planning mode
- Capture objective, acceptance criteria, constraints, and scope in `Prompt.md`.
- Decompose milestones and verification in `Plans.md`.
- Maintain execution contract in `Implement.md`, including which execution workflow should handle the active milestone.
- Keep `Documentation.md` synchronized with shipped behavior.

2. Execution mode
- Run `run_long_horizon_loop.sh` for mandatory work/review iterations.
- Work phase emits machine-readable work JSON.
- Review phase emits machine-readable decision JSON (`SHIP`/`REVISE`/`BLOCKED`).
- Optional verification commands are evidence, not the task definition.
- Runtime state lives in `.codex/long-horizon-loop/` and supports resume.

3. Delegated milestone mode
- Keep `Prompt.md`, `Plans.md`, `Implement.md`, and `Documentation.md` as the durable control plane.
- For the active non-trivial milestone, create a detailed milestone plan using Superpowers `writing-plans`.
- Execute that milestone using Superpowers `subagent-driven-development` when subagents are available.
- Use Superpowers `executing-plans` when running inline or when subagents are not desired.
- Fold milestone outcomes, verification evidence, and scope changes back into the long-horizon files after execution.

## Execution Contract (v0.1)

- Engine interface is pluggable; v0.1 ships `codex` and `claude` implementations.
- `--engine claude` is supported for non-interactive structured runs when `claude` CLI is available.
- Completion is strict dual-gate:
  - work reports `COMPLETE`
  - reviewer decides `SHIP`
  - optional verification (if configured) passes
  - progress gate passes or no-change is explicitly justified
- Blocking is explicit:
  - worker reports `BLOCKED` with reason
  - reviewer confirms blocker is genuine/external
  - runner writes `RALPH-BLOCKED.md` and stops `task_blocked`

## Planner Sync Behavior

The runner auto-syncs planner docs each iteration when they exist:
- `Plans.md` -> `## Loop Status`
- `Documentation.md` -> `## Runtime Execution Notes`

At startup, if no explicit prompt/objective is supplied, the runner seeds objective and acceptance criteria from:
- `docs/long-horizon/Prompt.md` sections `## Objective` and `## Acceptance Criteria`

## Milestone Delegation Pattern

Treat the long-horizon files as the durable system of record and the delegated milestone plan as a separate execution artifact for one active slice of work.

Recommended sequence:

1. Choose one active milestone from `Plans.md`.
2. Confirm or refine scope in `Prompt.md` and `Plans.md`.
3. In `Implement.md`, record the execution mode for this milestone.
4. If the milestone is non-trivial, create a detailed execution artifact under `docs/superpowers/plans/` or an equivalent location.
5. Execute that plan using Superpowers or the loop runner, depending on fit.
6. Reconcile implementation results, verification outcomes, blockers, and scope changes back into the long-horizon files.

Do not let both systems own the same plan document. `Plans.md` owns roadmap and milestone state. The delegated milestone artifact owns the step-by-step implementation details for the current milestone.

## Delegation Contract

When Superpowers is available, use this division of responsibility:

- `long-horizon-planner`: roadmap, checkpoints, resumability, decision log, verification ledger
- `superpowers/writing-plans`: detailed task decomposition for the active milestone
- `superpowers/subagent-driven-development`: preferred execution mode for milestone plans
- `superpowers/executing-plans`: fallback execution mode when subagents are unavailable or not desired

If Superpowers is not available, keep using the long-horizon files alone, but preserve the same layering: roadmap in `Plans.md`, step-by-step execution in a separate milestone-specific artifact or loop run state.

## Core Runtime Files

Under `.codex/long-horizon-loop/`:
- `state.env`
- `objective.md`
- `acceptance-criteria.md`
- `feedback.md`
- `work-summary.md`
- `review-feedback.md`
- `review-result.txt`
- `RALPH-BLOCKED.md`
- `.loop-complete`
- `work-schema.json`
- `review-schema.json`
- `iteration-history.md`
- `run-summary.md`
- `events.log` / `events.jsonl`
- `validation/`
- `codex/iteration-<n>-<phase>-attempt-<m>.jsonl`

## References

- `references/openai-long-horizon-notes.md`
- `references/loop-runbook.md`
