---
name: rr:codex-first
description: "Route implementation work to Codex CLI; Claude specs, reviews, verifies."
---

# Codex First

Claude Code sessions only. Codex/other harnesses: skip; never self-delegate.

Rationale: Claude (Fable/Opus) tokens metered + expensive; Codex flat-rate. GPT-5.5+ is usually the better and faster model at writing/implementing code; Claude wins at ergonomics — judgment, design, spec-writing, review, orchestration. So Codex types, Claude thinks and verifies.

## Route

Delegate to Codex (default for hands-on work):

- implementation from a frozen spec; refactors; mechanical migrations
- bug fixes with known repro; test writing; coverage fills
- CI fixes, dependency bumps, scripts/tooling
- bulk codebase exploration where raw reading ≫ the answer

Keep in Claude:

- design, API design, architecture, naming, UX judgment
- tasks where writing the spec IS the work (ambiguity = design)
- tiny edits (~<20 lines, single obvious change) — delegation overhead loses
- anything needing session tools: MCP (browser/computer-use/chronicle), 1Password, secrets
- destructive/irreversible ops, releases, pushes, GitHub mutations — Claude-side per git rules
- review of Codex output — never delegated, never skipped

Mixed task: Claude designs first, freezes spec, delegates build-out.
Heuristic: prompt reads as a work order → delegate; writing it forces decisions → design, Claude.

## Invoke

Precondition: `git status -sb` clean in the target repo — stash or commit first. The post-run diff must be attributable to Codex alone, and a failed run gets reverted, not layered on.

Prompt via temp file, never inline quoting. `-o` paired with the prompt file — unique per task, parallel-safe:

```bash
P=$(mktemp); cat >"$P" <<'EOF'
<goal, repo + key paths, constraints ("don't touch X"), non-goals, proof expected, output shape>
EOF
command codex exec --yolo -C <repo> \
  -c model_reasoning_effort="high" \
  -o "$P.out" - <"$P" 2>/dev/null
```

- `--yolo` is the house default; Codex may run commands/tests freely. Keep prompts scoped to the target repo.
- `command codex` bypasses the interactive zsh wrapper; if not on PATH: `fnm exec --using default -- codex`
- stderr suppressed (thinking noise bloats context); drop `2>/dev/null` only to debug a failing run
- read the `-o` file for the result; don't parse the JSONL stream
- long runs: Bash run_in_background, read `-o` file on exit; don't kill quiet runs <30 min
- parallel independent tasks OK: separate repos/dirs; `-o` derives from each task's own $P
- outside a git repo add `--skip-git-repo-check`

Follow-up fixes — cheaper than fresh runs, keeps context. `resume` has no `-C`; run from the repo dir and spell the long flag:

```bash
(cd <repo> && command codex exec resume --last \
  --dangerously-bypass-approvals-and-sandbox \
  -o "$P.out" - <"$P2" 2>/dev/null)
```

`--last` is cwd-filtered but grabs the *newest* session in that repo — safe only when this session is the sole Codex run there. If anything else touched the repo (parallel task, interactive Codex), resume by id instead: the UUID is in the newest session filename —

```bash
ls -t ~/.codex/sessions/*/*/*/rollout-*.jsonl | head -3   # uuid is in the filename; grep the file for your prompt text to confirm
command codex exec resume <uuid> ...
```

## Prompt contract

Codex starts with zero session context. Every prompt: goal, exact repo/paths, constraints, non-goals, proof expected (exact test command), output shape. Spec quality decides success. Two standing lines in every prompt:

- "Your final message must be the complete report — files changed, test output, open questions. Nothing before it is captured." (`-o` writes only the last message; a final "Done ✅" loses the report.)
- "If the spec is ambiguous or you're blocked, stop and put your questions in the final message instead of guessing." (Turns a bad guess into a cheap resume round.)

## Verify (Claude, always)

- `git status -sb` + read the full diff; judge like a contributor PR
- run focused tests yourself or demand proof output; Codex claims are advisory
- iterate via resume; after 2 failed rounds, take over — decide keep-or-revert first: default `git checkout` back to clean and do it directly; build on the partial diff only if it's verifiably sound
- normal closeout still applies: `/code-review` before ship

## Economics

Win = generation + exploration tokens moved to Codex; Claude spends only on spec + diff review. Don't ping-pong trivia through delegation; don't re-read what Codex already summarized.
