---
name: rr:work
description: "Execute development work using a goal-driven loop with verifiable criteria. Use when implementing features, fixing bugs, executing plans, or any task with testable success criteria. Defaults to inline/task-list execution; delegation is optional when the platform and user intent allow it."
argument-hint: "[plan doc path, goal description, or bare prompt]"
---

# Work

Execute development work systematically using a goal-driven loop. Define the goal, make the criteria verifiable, work in small units, and evaluate evidence before calling the work done.

<work_input> #$ARGUMENTS </work_input>

## Core Principle

Define verifiable criteria. Work in the smallest useful units. Evaluate against objective evidence. Continue until criteria are met or a real blocker is surfaced.

## Execution Flow

| Phase | Name | Purpose |
|-------|------|---------|
| 0 | Input Triage | Parse input, extract goal + criteria |
| 1 | Setup | Branch, todo list, choose strategy |
| 2 | Goal-Driven Loop | Execute units, verify, adapt |
| 3 | Ship | Quality check, PR, notify |

---

## Phase 0: Input Triage

Parse `<work_input>` to determine what you're working with:

**If plan doc path** (file ending in `.md` or path containing `docs/plans/`):
1. Read the plan document
2. Extract **Goal** from the plan header
3. Extract or infer **Criteria** from the plan's success criteria, test scenarios, and verification steps
4. Build task list from the plan's steps

**If goal string** (contains clear objective language):
1. Extract the **Goal** directly
2. Ask the user for **Criteria for success** -- specific, verifiable conditions

**If bare prompt** (ambiguous or short):
1. Assess complexity:
   - **Trivial** (1-2 file changes, obvious fix): Execute inline, skip the loop ceremony
   - **Small** (clear scope, 3-5 changes): Infer goal and criteria, then confirm only if risky
   - **Large** (multi-file, unclear scope): Suggest `rr:brainstorm` or `rr:plan` first; if the user wants to proceed, build a task list and continue

**Hard gate:** Do NOT proceed to Phase 2 without both a **Goal** and **verifiable Criteria**. Criteria must be objectively checkable -- not "works well" but "all tests pass", "endpoint returns 200 with valid JSON", or "function handles empty input without error".

---

## Phase 1: Setup

1. **Branch and working tree**

   ```bash
   git status --short
   git branch --show-current
   ```

   If already on a feature branch, continue there. If on `main`/`master`, create a descriptive branch unless the user explicitly asked to work on the default branch.

2. **Todo list**

   Create a compact task list from the plan or inferred units. Include verification tasks and mark dependencies.

3. **Choose execution strategy**

   | Strategy | Use when |
   |----------|----------|
   | **Inline** | Default for trivial work, bare prompts, work needing tight feedback, or platforms where delegation is unavailable |
   | **Task-list serial** | Default for most multi-file work; execute one unit at a time in the main thread |
   | **Optional delegation** | Only when the platform exposes delegation and the user explicitly asked for agents, parallel agents, or delegated work |

   Delegated work must be independent and non-overlapping. Keep blocking work local.

---

## Phase 2: Goal-Driven Execution Loop

Read `references/goal-driven-loop.md` before entering the loop. Use the loop locally unless optional delegation is allowed.

### 2.1: Execute the Next Unit

For each unit:

1. Read the relevant files and local patterns
2. Find existing tests for touched implementation files
3. Make the smallest coherent change
4. Add or update tests when behavior changes
5. Run targeted verification
6. Record evidence for each criterion

### 2.2: Optional Delegation Contract

Only delegate when allowed by the current platform and requested by the user. If delegating, give each worker a bounded, non-overlapping unit:

```
Goal: [the extracted goal]

Criteria for success:
[the extracted criteria, each on its own line]

Context:
- Branch: [current branch]
- Key files: [relevant file paths from plan or codebase exploration]
- Plan reference: [plan doc path if exists]
- Assigned unit: [specific unit and write scope]

Available techniques:
- Use TDD (rr:tdd) when the unit is behavior-bearing
- Use systematic debugging (rr:debug) when the unit is a bug investigation
- Follow existing patterns in the codebase

Work until the assigned criteria are met, then report changed files and verification evidence.
```

After a worker returns, review its changed files and verify criteria yourself before continuing.

### 2.3: Evaluate Against Criteria

```
while (criteria are not met):
    execute or integrate the next unit
    run the relevant verification
    mark each criterion PASS/FAIL with evidence
    if a criterion fails:
        identify the smallest remaining correction
    else:
        exit loop -> Phase 3
```

For each criterion, check objectively:

- **Test-based criteria**: Run the test commands. Pass/fail is binary.
- **Behavioral criteria**: Exercise the feature. Does it produce expected output?
- **Structural criteria**: Check file existence, code patterns, type signatures.

If ANY criterion is not met, the loop continues. Document which criteria passed and which failed before making more changes.

### 2.4: Restart or Refocus

When the previous attempt did not satisfy the criteria, write down:

```
Previous attempt status:
- [criterion 1]: PASS/FAIL -- [evidence]
- [criterion 2]: PASS/FAIL -- [evidence]

What still needs work:
- [specific remaining work based on failed criteria]

Progress so far:
- [summary of what was accomplished]
- [files that were created/modified]
- [tests that are passing]
```

### Loop Safety

- **Max iterations**: After 5 attempts without progress on any criterion, STOP and present findings to the user. Ask for guidance.
- **Blocked detection**: If progress needs external input, missing access, or a real architectural decision, stop and ask the user.
- **No-change detection**: If an attempt changes nothing, investigate why before trying again.

---

## Phase 3: Ship

Read `references/shipping-workflow.md` before proceeding.

1. **Final verification**: Run all relevant test/lint/build commands
2. **Code review**: Self-review for trivial changes, invoke `rr:review` for anything substantial
3. **Commit**: Ensure all work is committed with clear messages
4. **Create PR**: Push branch and create PR with summary when that is part of the requested workflow
5. **Notify user**: Summarize what was completed, verification evidence, and follow-up work

---

## Common Pitfalls

- **Vague criteria**: "Make it work" is not a criterion. Push for specifics.
- **Unnecessary delegation**: Inline/task-list execution is the default. Use agents only when they are available, requested, and materially useful.
- **Skipping evaluation**: Always check criteria objectively. "Looks good" is not evaluation.
- **Infinite loops**: 5 attempts without progress = stop and ask.
- **Over-engineering criteria**: Match criteria complexity to task complexity. A one-line bug fix needs simple criteria.
