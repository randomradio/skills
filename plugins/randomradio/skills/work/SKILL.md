---
name: rr:work
description: "Execute development work using a goal-driven master/subagent loop. Use when implementing features, fixing bugs, executing plans, or any task with verifiable success criteria. Accepts a plan doc path, goal string, or bare prompt."
argument-hint: "[plan doc path, goal description, or bare prompt]"
---

# Work

Execute development work systematically using a goal-driven master/subagent loop. You are the master agent. You create, monitor, and evaluate subagents — you never implement directly (except for trivial inline work).

<work_input> #$ARGUMENTS </work_input>

## Core Principle

Define verifiable criteria. Create a subagent. Monitor progress. Evaluate against criteria. Restart if needed. Never stop until criteria are met.

## Execution Flow

| Phase | Name | Purpose |
|-------|------|---------|
| 0 | Input Triage | Parse input, extract goal + criteria |
| 1 | Setup | Branch, todo list, choose strategy |
| 2 | Goal-Driven Loop | Master/subagent execution |
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
2. Ask the user for **Criteria for success** — specific, verifiable conditions

**If bare prompt** (ambiguous or short):
1. Assess complexity:
   - **Trivial** (1-2 file changes, obvious fix): Execute inline, skip the loop
   - **Small** (clear scope, 3-5 changes): Infer goal, ask for criteria
   - **Large** (multi-file, unclear scope): Suggest running `rr:brainstorm` then `rr:plan` first

**Hard gate:** Do NOT proceed to Phase 2 without both a **Goal** and **verifiable Criteria**. Criteria must be objectively checkable — not "works well" but "all tests pass", "endpoint returns 200 with valid JSON", "function handles empty input without error".

---

## Phase 1: Setup

1. **Branch**: Create a feature branch from current HEAD

   ```bash
   git checkout -b <descriptive-branch-name>
   ```

2. **Todo list**: If working from a plan, create a task for each implementation unit

3. **Choose execution strategy**:
   - **Inline**: Trivial work (1-2 tasks, bare prompts). Execute directly as master.
   - **Subagent**: Everything else. Proceed to Phase 2.

---

## Phase 2: Goal-Driven Execution Loop

Read `references/goal-driven-loop.md` before entering the loop.

You are the **master agent**. Your ONLY jobs are:

1. **Create** a subagent to work on the goal
2. **Monitor** subagent activity
3. **Evaluate** results against criteria
4. **Restart** with feedback if criteria not met

You do NOT implement. You do NOT write code. You orchestrate.

### 2.1: Create Subagent

Dispatch a subagent with this context:

```
Goal: [the extracted goal]

Criteria for success:
[the extracted criteria, each on its own line]

Context:
- Branch: [current branch]
- Key files: [relevant file paths from plan or codebase exploration]
- Plan reference: [plan doc path if exists]

Available techniques:
- Use TDD (rr:tdd) — write failing test first, then implement
- Use systematic debugging (rr:debug) — if you encounter bugs, investigate root cause before fixing
- Commit working code incrementally
- Follow existing patterns in the codebase

Work until the criteria for success are met, then report your status.
```

### 2.2: Monitor Loop

```
while (criteria are not met):
    monitor subagent activity
    if subagent is inactive or declares done:
        evaluate current state against criteria
        if criteria are NOT met:
            create new subagent with:
                - same goal and criteria
                - feedback on what's missing or wrong
                - summary of progress so far
        else:
            exit loop → Phase 3
```

### 2.3: Evaluate Against Criteria

For each criterion, check objectively:

- **Test-based criteria**: Run the test commands. Pass/fail is binary.
- **Behavioral criteria**: Exercise the feature. Does it produce expected output?
- **Structural criteria**: Check file existence, code patterns, type signatures.

If ANY criterion is not met, the loop continues. Document which criteria passed and which failed when restarting a subagent.

### 2.4: Restart with Feedback

When restarting a subagent:

```
Previous attempt status:
- [criterion 1]: PASS/FAIL — [evidence]
- [criterion 2]: PASS/FAIL — [evidence]

What still needs work:
- [specific remaining work based on failed criteria]

Progress so far:
- [summary of what was accomplished]
- [files that were created/modified]
- [tests that are passing]

Continue working toward the goal. Focus on the failing criteria.
```

### Loop Safety

- **Max iterations**: After 5 subagent restarts without progress on any criterion, STOP and present findings to the user. Ask for guidance.
- **Blocked detection**: If the subagent reports BLOCKED, verify the blocker. If genuine (needs external input, missing access, architectural issue), stop and ask the user.
- **No-change detection**: If a subagent completes but made no changes, investigate why before restarting.

---

## Phase 3: Ship

Read `references/shipping-workflow.md` before proceeding.

1. **Final verification**: Run all relevant test/lint/build commands
2. **Code review**: Self-review for trivial changes, invoke `rr:review` for anything substantial
3. **Commit**: Ensure all work is committed with clear messages
4. **Create PR**: Push branch and create PR with summary
5. **Notify user**: Summarize what was completed, link to PR, note any follow-up work

---

## Common Pitfalls

- **Vague criteria**: "Make it work" is not a criterion. Push for specifics.
- **Master doing implementation**: You orchestrate, subagents implement. The only exception is truly trivial inline work.
- **Skipping evaluation**: Always check criteria objectively. "Looks good" is not evaluation.
- **Infinite loops**: 5 restarts without progress = stop and ask.
- **Over-engineering criteria**: Match criteria complexity to task complexity. A one-line bug fix needs simple criteria.
