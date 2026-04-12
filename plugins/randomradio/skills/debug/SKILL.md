---
name: rr:debug
description: "Systematically find root causes and fix bugs. Use when debugging errors, investigating test failures, reproducing bugs, or when stuck after failed fix attempts. Also use when the user says 'debug this', 'why is this failing', 'fix this bug', or pastes stack traces or error messages."
argument-hint: "[error message, test path, issue reference, or description of broken behavior]"
---

# Debug

Find root causes, then fix them. Investigate the full causal chain before proposing any fix.

<bug_description> #$ARGUMENTS </bug_description>

## Core Principle

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**

If you haven't completed Phase 1, you cannot propose fixes.

## Execution Flow

| Phase | Name | Purpose |
|-------|------|---------|
| 0 | Triage | Parse input, fetch issue if referenced |
| 1 | Investigate | Reproduce, trace code path |
| 2 | Root Cause | Form hypotheses, test them, causal chain gate |
| 3 | Fix | Test-first fix (only if user approves) |
| 4 | Close | Summary, handoff options |

---

### Phase 0: Triage

Parse the input:
- **Issue reference** (`#123`, GitHub URL): Fetch with `gh issue view`
- **Stack trace / error message**: Extract key information
- **Test path**: Run the test to reproduce
- **Description**: Proceed to investigation

Do not ask questions by default — investigate first. Only ask when genuine ambiguity blocks investigation.

**Prior-attempt awareness:** If the user indicates failed prior attempts, ask what they tried before investigating.

### Phase 1: Investigate

#### 1.1 Reproduce

Confirm the bug exists. Run the test, trigger the error, follow reproduction steps.

- **Does not reproduce after 2-3 attempts:** Check for intermittent/timing issues
- **Cannot reproduce:** Document what was tried and conditions that appear missing

#### 1.2 Trace the Code Path

Read relevant source files. Follow execution from entry point to error:

- Start at the error
- Ask "where did this value come from?" and "who called this?"
- Trace upstream until finding where valid state became invalid
- Do not stop at the first function that looks wrong — the root cause is where bad state originates, not where it is first observed
- Check recent changes: `git log --oneline -10 -- [file]`
- If looks like a regression: consider `git bisect`

#### 1.3 Multi-Component Systems

For systems with multiple components (API -> service -> database):

**Add diagnostic instrumentation at each boundary:**
```
For EACH component boundary:
  - Log what enters
  - Log what exits
  - Verify environment/config propagation
  - Check state at each layer

Run once to gather evidence showing WHERE it breaks
THEN investigate that specific component
```

### Phase 2: Root Cause

Form hypotheses ranked by likelihood. For each:
- What is wrong and where (file:line)
- The causal chain: trigger -> step -> step -> symptom
- For uncertain links: a prediction that must be true if the hypothesis is correct

**Causal chain gate:** Do NOT proceed to Phase 3 until you can explain the full causal chain with no gaps.

Present findings to user:
- The root cause (causal chain summary with file:line references)
- The proposed fix and which files would change
- Which tests to add or modify

Offer next steps:
1. **Fix it now** — proceed to Phase 3
2. **Rethink the design** (`rr:brainstorm`) — when root cause reveals a design problem
3. **Done** — diagnosis only

**Smart escalation — 3 failed hypotheses:**

| Pattern | Diagnosis | Next move |
|---------|-----------|-----------|
| Hypotheses point to different subsystems | Architecture problem | Present findings, suggest `rr:brainstorm` |
| Evidence contradicts itself | Wrong mental model | Re-read code without assumptions |
| Works locally, fails in CI/prod | Environment problem | Focus on env differences |
| Fix works but prediction was wrong | Symptom fix, not root cause | Keep investigating |

### Phase 3: Fix

**Only if user chose to fix.**

1. Write a failing test that captures the bug
2. Verify it fails for the right reason
3. Implement the minimal fix — root cause only
4. Verify the test passes
5. Run broader test suite for regressions

**3 failed fix attempts = STOP.** Question the architecture. Discuss with user before attempting more.

### Phase 4: Close

```markdown
## Debug Summary
**Problem**: [What was broken]
**Root Cause**: [Full causal chain with file:line references]
**Fix**: [What was changed — or "diagnosis only"]
**Tests Added**: [What tests prevent recurrence]
**Confidence**: [High/Medium/Low]
```

Handoff options:
1. Commit the fix
2. Document as a learning
3. Done
