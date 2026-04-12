---
name: rr:review
description: "Structured code review using parallel reviewer personas. Use when completing tasks, before merging, or when requesting code review. Supports autofix, report-only, and headless modes."
argument-hint: "[mode:autofix|report|headless] [plan:<path>] [scope:diff|branch|files]"
---

# Review

Structured code review with tiered, persona-based reviewers dispatched as parallel sub-agents. Each reviewer hunts for specific categories of issues with calibrated confidence.

<review_input> #$ARGUMENTS </review_input>

## Severity Scale

| Level | Meaning | Action |
|-------|---------|--------|
| **Critical** | Will break in production, security vulnerability, data loss | Must fix before merge |
| **Warning** | Likely to cause problems, performance issue, poor pattern | Should fix, discuss if disagree |
| **Observation** | Improvement opportunity, style preference, minor concern | Consider for future |

## Mode Detection

Parse `<review_input>` for mode:

- **`mode:autofix`** — apply safe fixes automatically, surface complex issues as todos
- **`mode:report`** — produce findings report only, no changes
- **`mode:headless`** — JSON output for programmatic callers
- **Default (interactive)** — present findings, ask what to fix

## Execution Flow

### 1. Determine Scope

```bash
# Default: changes on current branch vs main
git diff main...HEAD --stat

# Or explicit scope from input
# scope:diff — staged + unstaged changes
# scope:branch — all commits on current branch
# scope:files — specific files listed in input
```

### 2. Assess Risk and Select Reviewers

**Always selected:**
- **correctness-reviewer** — logic errors, edge cases, off-by-ones
- **maintainability-reviewer** — code clarity, naming, structure

**Conditionally selected (based on diff content):**

| Condition | Reviewer |
|-----------|----------|
| 50+ changed lines OR touches auth/payments/data mutations | **adversarial-reviewer** |
| Performance-sensitive paths, database queries, loops | **performance-reviewer** |
| Authentication, authorization, crypto, user input handling | **security-reviewer** |
| Test files changed or new test files | **testing-reviewer** |
| Cross-module changes, new services, architecture shifts | **architecture-reviewer** |

### 3. Dispatch Reviewer Sub-Agents

Dispatch selected reviewers as parallel sub-agents. Each reviewer receives:
- The diff content
- Intent summary (from plan if available, or inferred from commit messages)
- Instructions to return findings as structured JSON

Reviewer agent definitions are in `agents/review/`.

### 4. Merge Findings

1. Collect findings from all reviewers
2. Deduplicate: same file + same line + similar description = merge, keep highest severity
3. Sort by severity (Critical > Warning > Observation)

### 5. Present Results

**Interactive mode:**
```markdown
## Code Review: [branch-name]

### Critical (N findings)
1. **[Title]** — `file:line` — [Description]. Fix: [How]

### Warnings (N findings)
1. **[Title]** — `file:line` — [Description]. Suggestion: [How]

### Observations (N findings)
1. **[Observation]** — [Description]

### What's Working Well
- [Positive observations]
```

**Autofix mode:** Apply fixes for findings where the fix is clear and safe. Surface remaining as todos.

**Headless mode:** Return raw JSON findings array.

### 6. Post-Review

If plan path was provided (`plan:<path>`):
- Check each plan requirement against the diff
- Flag any requirements not covered by the changes

Offer next steps:
1. Fix identified issues
2. Approve and proceed to ship
3. Request deeper review on specific areas
