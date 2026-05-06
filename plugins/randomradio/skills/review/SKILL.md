---
name: rr:review
description: "Structured code review using calibrated reviewer personas, P0-P3 severity, action routing, report-only/headless safeguards, and stable findings. Use before merging, after substantial changes, or when requesting code review."
argument-hint: "[mode:autofix|mode:report-only|mode:headless] [base:<ref>] [plan:<path>] [scope:diff|branch|files]"
---

# Review

Run a structured code review with confidence-gated findings and clear action routing. Prefer high-signal bugs, regressions, missing tests, and standards violations over style commentary.

<review_input> #$ARGUMENTS </review_input>

## Argument Parsing

Parse `<review_input>` for optional tokens:

| Token | Effect |
|-------|--------|
| `mode:autofix` | Apply only safe automatic fixes; report residual work |
| `mode:report-only` | Strictly read-only review; no edits, artifacts, commits, pushes, or PRs |
| `mode:headless` | Programmatic output; apply safe automatic fixes once, return structured residual findings |
| `base:<ref>` | Use this ref or SHA as the diff base |
| `plan:<path>` | Load this plan for requirements verification |
| `scope:diff` | Review staged + unstaged changes |
| `scope:branch` | Review current branch against merge base |
| `scope:files` | Review explicit files named in the remaining input |

Stop before dispatch if multiple mode tokens are provided.

## Mode Rules

| Mode | Behavior |
|------|----------|
| **Interactive** | Review, apply `safe_auto` fixes when clearly local, present findings, ask before gated/manual work |
| **Autofix** | No questions. Apply only `safe_auto -> review-fixer`, re-check once, report residual actionable work |
| **Report-only** | No questions and no writes. Safe to run alongside other read-only checks |
| **Headless** | No questions. Requires determinable scope. Apply `safe_auto` once, emit structured findings, end with `Review complete` |

In `mode:report-only` or `mode:headless`, do not switch the shared checkout with `git checkout` or `gh pr checkout`. If the requested target is not already checked out, stop and ask the caller to use an isolated worktree or pass `base:<ref>`.

## Severity Scale

| Level | Meaning | Action |
|-------|---------|--------|
| **P0** | Critical breakage, exploitable vulnerability, data loss/corruption | Must fix before merge |
| **P1** | High-impact defect likely hit in normal usage, breaking contract | Should fix |
| **P2** | Moderate issue with meaningful downside | Fix if straightforward |
| **P3** | Low-impact, narrow scope, minor improvement | User's discretion |

## Action Routing

| Route | Meaning |
|-------|---------|
| `safe_auto` | Local deterministic fix suitable for automatic application |
| `gated_auto` | Concrete fix exists but changes behavior, contracts, permissions, or another sensitive boundary |
| `manual` | Actionable work that should be handed off or handled deliberately |
| `advisory` | Rollout note, known risk, or future improvement |

Only findings routed `safe_auto -> review-fixer` may be applied automatically. If reviewers disagree, keep the more conservative severity and route.

## Execution Flow

### 1. Determine Scope

Compute file list, diff, untracked files, and base:

```bash
# Fast path when base:<ref> is provided
BASE_ARG="<base-ref>"
BASE=$(git merge-base HEAD "$BASE_ARG" 2>/dev/null) || BASE="$BASE_ARG"
git diff --name-only "$BASE"
git diff -U10 "$BASE"

# Default branch path
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null
git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD origin/master
```

For `scope:diff`, include staged and unstaged changes. For `scope:files`, review only named files and their relevant diffs.

### 2. Load Intent

Build a short intent summary from:

- `plan:<path>` if provided
- PR metadata or branch name when available
- Commit messages on the current branch
- The changed files and diff when no better source exists

If a plan is provided, verify the diff covers each relevant requirement. Uncovered requirements are review findings, not side notes.

### 3. Select Reviewers

**Always selected:**
- `correctness-reviewer` -- logic errors, edge cases, broken behavior
- `testing-reviewer` -- missing or weak tests
- `maintainability-reviewer` -- clarity, duplication, coupling
- `project-standards-reviewer` -- AGENTS.md/CLAUDE.md and repo conventions
- `learnings-researcher` -- relevant `docs/solutions/` learnings

**Conditionally selected:**

| Condition | Reviewer |
|-----------|----------|
| >=50 changed non-generated lines, auth, payments, data mutation, external APIs | `adversarial-reviewer` |
| Database queries, loops, caching, async, performance-sensitive paths | `performance-reviewer` |
| Auth, authorization, crypto, user input, external data | `security-reviewer` |
| API routes, request/response types, serializers, exported signatures | `api-contract-reviewer` |
| Error handling, retries, timeouts, jobs, async handlers | `reliability-reviewer` |
| Cross-module boundaries, new services, architecture shifts | `architecture-reviewer` |
| Existing PR review comments or threads | `previous-comments-reviewer` |
| Final simplification pass after substantive implementation | `code-simplicity-reviewer` |

If optional external reviewers are installed, add them when relevant: `agent-native-reviewer`, data-migration reviewers, CLI readiness reviewers, or stack-specific language/framework reviewers.

### 4. Dispatch or Run Reviewers

Use platform delegation only when available. Otherwise, run the same reviewer perspectives sequentially in the main thread.

Each reviewer receives:
- Mode
- Base ref
- File list
- Diff
- Intent summary
- Plan path and standards file paths when available
- Instruction to return compact structured findings with severity, route, confidence, evidence, and suggested fix

Reviewer agents are read-only with respect to project files. In non-report modes, they may write full JSON notes under `/tmp/randomradio/rr-review/<run-id>/`; report-only mode writes nothing.

### 5. Merge Findings

1. Deduplicate same file + nearby line + same root issue
2. Suppress findings below 0.60 confidence, except P0 findings at 0.50+
3. Resolve disagreements by keeping the highest severity and most conservative route
4. Sort by severity, confidence, file path, and line
5. Assign stable finding numbers once; reuse those numbers after autofix or residual summaries
6. Discard findings that recommend deleting intentional workflow artifacts in `docs/plans/` or `docs/solutions/`

### 6. Present Results

Interactive/report output uses tables:

```markdown
## Code Review: [branch-name]

### P0 -- Critical
| # | File | Issue | Reviewer(s) | Confidence | Route |
|---|------|-------|-------------|------------|-------|

### P1 -- High
...

### Coverage
- Reviewers run: [list]
- Suppressed: [count]
- Plan coverage: [pass/fail/unknown]

### Learnings & Past Solutions
- [Relevant docs/solutions/ links or "none found"]
```

Headless output groups findings by route and ends with `Review complete`.

### 7. Autofix and Residual Work

For interactive, autofix, and headless modes:

1. Apply only `safe_auto -> review-fixer`
2. Run focused verification for changed files
3. Re-review touched lines once
4. Report residual `gated_auto` and `manual` findings with stable numbers

Autofix/headless never commit, push, or create a PR. Parent workflows own shipping.

### 8. Post-Review Options

Offer only options that match the mode:

1. Apply selected gated fixes
2. File residual todos with `rr:todo-create`
3. Proceed to `rr:git-commit-push-pr`
4. Report only, no further action
