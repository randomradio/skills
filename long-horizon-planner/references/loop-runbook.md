# Long Horizon Loop Runbook

Use this runbook for v0.1 objective-first execution with `run_long_horizon_loop.sh`.

## Standard run

```bash
~/.codex/skills/long-horizon-planner/scripts/run_long_horizon_loop.sh \
  --cwd /path/to/repo \
  --engine codex \
  --objective-file /path/to/repo/.codex/long-horizon-loop/objective.md \
  --acceptance-file /path/to/repo/.codex/long-horizon-loop/acceptance-criteria.md \
  --feedback-file /path/to/repo/.codex/long-horizon-loop/feedback.md \
  --progress-scope "src/" \
  --validate-cmd "npm run lint" \
  --validate-cmd "npm run test" \
  --max-iterations 40
```

## Resume

```bash
~/.codex/skills/long-horizon-planner/scripts/run_long_horizon_loop.sh \
  --cwd /path/to/repo \
  --engine codex \
  --resume
```

Run with Claude engine:

```bash
~/.codex/skills/long-horizon-planner/scripts/run_long_horizon_loop.sh \
  --cwd /path/to/repo \
  --engine claude \
  --engine-bin claude \
  --max-iterations 40
```

## Stop

```bash
touch /path/to/repo/.codex/long-horizon-loop/STOP
```

## Key stop reasons

- `task_complete`: strict dual-gate success (`COMPLETE` + `SHIP` + verification/progress gate).
- `task_blocked`: reviewer confirmed genuine external blocker.
- `max_iterations_reached`: run exhausted iteration cap.
- `max_stagnant_iterations_reached`: repeated identical work/review outputs.
- `max_consecutive_failures_reached`: repeated runtime failures.
- `stop_file_detected`: sentinel stop file detected.

## Runtime files

- `.codex/long-horizon-loop/run-summary.md`
- `.codex/long-horizon-loop/iteration-history.md`
- `.codex/long-horizon-loop/events.log`
- `.codex/long-horizon-loop/review-result.txt`
- `.codex/long-horizon-loop/RALPH-BLOCKED.md`
- `.codex/long-horizon-loop/.loop-complete`

## Planner sync

When `docs/long-horizon/Plans.md` and `docs/long-horizon/Documentation.md` exist, each iteration updates:
- `Plans.md` section: `## Loop Status`
- `Documentation.md` section: `## Runtime Execution Notes`
