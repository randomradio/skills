# Goal-Driven Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Restructure the skills repo into `plugins/randomradio/` with goal-driven master/subagent execution as the core work loop, replacing long-horizon-planner and superpowers.

**Architecture:** CE-style plugin layout (`.claude-plugin/`, `skills/`, `agents/`, `references/`) with `rr:` namespace. The core `rr:work` skill uses a goal-driven master/subagent loop where the master monitors and evaluates criteria while the subagent does all implementation work using inner tools (TDD, debugging, etc.).

**Tech Stack:** Claude Code plugin system, SKILL.md with YAML frontmatter, markdown agent definitions

---

## File Structure

```
plugins/randomradio/
├── .claude-plugin/
│   └── plugin.json                         # Plugin manifest
├── skills/
│   ├── work/
│   │   ├── SKILL.md                        # rr:work — goal-driven execution
│   │   └── references/
│   │       ├── goal-driven-loop.md         # The loop pattern reference
│   │       └── shipping-workflow.md        # Quality gates + ship
│   ├── plan/
│   │   └── SKILL.md                        # rr:plan — structured planning
│   ├── brainstorm/
│   │   └── SKILL.md                        # rr:brainstorm — requirements exploration
│   ├── review/
│   │   └── SKILL.md                        # rr:review — persona-based code review
│   ├── debug/
│   │   └── SKILL.md                        # rr:debug — systematic debugging
│   ├── tdd/
│   │   └── SKILL.md                        # rr:tdd — test-driven development
│   └── quick-shoutout/
│       ├── SKILL.md                        # rr:quick-shoutout — moved from top-level
│       ├── scripts/                        # (copied from existing)
│       └── references/                     # (copied from existing)
├── agents/
│   ├── review/
│   │   ├── adversarial-reviewer.md
│   │   ├── security-reviewer.md
│   │   ├── performance-reviewer.md
│   │   ├── architecture-reviewer.md
│   │   ├── correctness-reviewer.md
│   │   ├── maintainability-reviewer.md
│   │   └── testing-reviewer.md
│   └── research/
│       ├── best-practices-researcher.md
│       └── framework-docs-researcher.md
└── references/
    └── plugin-conventions.md               # Shared conventions
```

---

### Task 1: Plugin Scaffold

**Files:**
- Create: `plugins/randomradio/.claude-plugin/plugin.json`
- Create: `plugins/randomradio/references/plugin-conventions.md`

- [ ] **Step 1: Create plugin directory structure**

```bash
mkdir -p plugins/randomradio/.claude-plugin
mkdir -p plugins/randomradio/skills
mkdir -p plugins/randomradio/agents/review
mkdir -p plugins/randomradio/agents/research
mkdir -p plugins/randomradio/references
```

- [ ] **Step 2: Write plugin.json**

Create `plugins/randomradio/.claude-plugin/plugin.json`:

```json
{
  "name": "randomradio",
  "version": "1.0.0",
  "description": "Goal-driven development tools with structured planning, review, and autonomous execution.",
  "author": {
    "name": "randomradio"
  },
  "repository": "https://github.com/randomradio/skills",
  "license": "MIT",
  "keywords": [
    "goal-driven",
    "autonomous-execution",
    "code-review",
    "planning",
    "tdd",
    "debugging"
  ]
}
```

- [ ] **Step 3: Write plugin conventions reference**

Create `plugins/randomradio/references/plugin-conventions.md`:

```markdown
# Plugin Conventions

## Skill Structure

Every skill follows this layout:

```
skills/<skill-name>/
├── SKILL.md              # Entry point with YAML frontmatter
├── references/           # On-demand loaded docs (save tokens)
└── scripts/              # Shell scripts (optional)
```

## SKILL.md Format

```yaml
---
name: rr:<skill-name>
description: When to use this skill
argument-hint: "[optional argument description]"
---
```

## Namespace

All skills use `rr:` prefix. Invoked as `/rr:<skill-name>` or `rr:<skill-name>`.

## Agent Format

```yaml
---
name: <agent-name>
description: When this agent is selected
model: inherit
tools: Read, Grep, Glob, Bash
---
```

## References

Load references only when needed during execution, not at skill load time.
Use: "Read `references/<file>.md` before proceeding to Phase N."

## Arguments

Use `#$ARGUMENTS` as the template variable for skill arguments.
```

- [ ] **Step 4: Commit scaffold**

```bash
git add plugins/randomradio/.claude-plugin/plugin.json plugins/randomradio/references/plugin-conventions.md
git commit -m "feat: scaffold plugins/randomradio with plugin.json and conventions"
```

---

### Task 2: Core Skill — `rr:work` (Goal-Driven Execution)

**Files:**
- Create: `plugins/randomradio/skills/work/SKILL.md`
- Create: `plugins/randomradio/skills/work/references/goal-driven-loop.md`
- Create: `plugins/randomradio/skills/work/references/shipping-workflow.md`

- [ ] **Step 1: Create work skill directories**

```bash
mkdir -p plugins/randomradio/skills/work/references
```

- [ ] **Step 2: Write `rr:work` SKILL.md**

Create `plugins/randomradio/skills/work/SKILL.md`:

```markdown
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
```

- [ ] **Step 3: Write goal-driven-loop.md reference**

Create `plugins/randomradio/skills/work/references/goal-driven-loop.md`:

```markdown
# Goal-Driven Loop Reference

## The Pattern

A goal-driven system with 1 master agent + 1 subagent for solving any problem with verifiable criteria.

**Source:** https://github.com/lidangzzz/goal-driven

## System Description

The system contains a master agent and a subagent. You are the master agent.

### Subagent

The subagent's goal is to complete the task assigned by the master agent. The goal defined is the final and the only goal for the subagent. The subagent should:
- Break down the task into smaller sub-tasks
- Monitor its own progress on each sub-task
- Continue working until the criteria for success are met
- Use available techniques (TDD, debugging, etc.) as inner tools

### Master Agent

The master agent is responsible for overseeing the entire process. The ONLY tasks the master agent does:

1. **Create** subagents to complete the task
2. **Evaluate** — if the subagent finishes or fails, check criteria for success. If met, stop. If not met, ask the subagent to continue.
3. **Monitor** — check subagent activity periodically. If inactive, verify goal status. If not reached, restart a new subagent to replace the inactive one.
4. **Persist** — this process continues until criteria are met. DO NOT STOP until the user stops manually or criteria are satisfied.

### Pseudocode

```
create a subagent to complete the goal

while (criteria are not met) {
    check the activity of the subagent
    if (the subagent is inactive or declares that it has reached the goal) {
        check if the current goal is reached and verify the status
        if (criteria are not met) {
            restart a new subagent with the same name to replace the inactive subagent
        }
        else {
            stop all subagents and end the process
        }
    }
}
```

## Key Properties

1. **Verifiable criteria** — the loop only works if criteria can be objectively checked
2. **Stateless execution** — no durable state files. The goal and criteria are the only state.
3. **Fresh starts** — each new subagent starts fresh, with feedback from previous attempts
4. **Master never implements** — the master only creates, monitors, evaluates, restarts
5. **Inner tool freedom** — the subagent chooses its own approach (TDD, debugging, etc.)
```

- [ ] **Step 4: Write shipping-workflow.md reference**

Create `plugins/randomradio/skills/work/references/shipping-workflow.md`:

```markdown
# Shipping Workflow

Load this file only when all Phase 2 work is complete and execution transitions to Phase 3.

## Phase 3: Quality Check

### 1. Run Core Quality Checks

```bash
# Run full test suite (use project's test command)
# Examples: npm test, pytest, go test, cargo test, etc.

# Run linting (use project's lint command)
# Examples: npm run lint, ruff check, golangci-lint run, etc.
```

### 2. Code Review

Every change gets reviewed before shipping. Depth scales with risk.

**Full review (default):** Invoke `rr:review` for multi-file changes, changes to existing behavior, cross-cutting changes, or anything with novel logic. Pass `plan:<path>` when available.

**Self-review:** Permitted only when ALL four criteria are true:
- Purely additive (new files only, no existing behavior modified)
- Single concern (one skill, one component)
- Pattern-following (mirrors existing example, no novel logic)
- Plan-faithful (no scope growth, no surprising decisions)

### 3. Final Validation

- [ ] All tasks marked completed
- [ ] Tests pass and new behavior has test coverage
- [ ] Linting passes
- [ ] Code follows existing patterns
- [ ] No console errors or warnings

## Phase 4: Ship It

### 1. Commit

Ensure all work is committed with clear, conventional messages:
```bash
git add <specific-files>
git commit -m "feat: <description>"
```

### 2. Create PR

```bash
git push -u origin <branch-name>
gh pr create --title "<short title>" --body "$(cat <<'EOF'
## Summary
- <key changes>

## Test Plan
- <how to verify>

## Criteria Verified
- <which criteria from the goal were met and how>
EOF
)"
```

### 3. Notify User

- Summarize what was completed
- Link to PR
- Note any follow-up work
- Suggest next steps if applicable

## Quality Checklist

Before creating PR:

- [ ] All criteria from the goal verified and passing
- [ ] Tests pass AND new/changed behavior has test coverage
- [ ] Linting passes
- [ ] Code follows existing patterns
- [ ] Commit messages are clear and conventional
- [ ] PR description includes summary, test plan, and criteria verification
```

- [ ] **Step 5: Commit work skill**

```bash
git add plugins/randomradio/skills/work/
git commit -m "feat: add rr:work skill with goal-driven master/subagent loop"
```

---

### Task 3: `rr:plan` Skill

**Files:**
- Create: `plugins/randomradio/skills/plan/SKILL.md`

- [ ] **Step 1: Create plan skill directory**

```bash
mkdir -p plugins/randomradio/skills/plan
```

- [ ] **Step 2: Write `rr:plan` SKILL.md**

Create `plugins/randomradio/skills/plan/SKILL.md`:

```markdown
---
name: rr:plan
description: "Create structured implementation plans for multi-step tasks. Use when you have requirements or a spec and need to plan the implementation before coding. Produces a durable plan document with bite-sized TDD tasks."
argument-hint: "[spec path, feature description, or requirements]"
---

# Plan

Create a detailed, executable implementation plan. Answer "HOW to build it." Research first, plan thoroughly, never code.

<plan_input> #$ARGUMENTS </plan_input>

## Core Principle

80% planning, 20% execution. A good plan makes execution mechanical.

**NEVER CODE. Research, decide, and write the plan.**

## Execution Flow

| Phase | Name | Purpose |
|-------|------|---------|
| 0 | Source & Scope | Find input, assess complexity |
| 1 | Research | Understand codebase, patterns, constraints |
| 2 | Architecture | Design the approach |
| 3 | Task Decomposition | Break into bite-sized TDD tasks |
| 4 | Self-Review | Check for gaps, placeholders, inconsistencies |
| 5 | Handoff | Save plan, offer execution options |

---

### Phase 0: Source & Scope

Parse `<plan_input>`:

- **Spec doc path**: Read the spec, extract requirements
- **Feature description**: Clarify scope, identify what needs research
- **Requirements list**: Organize into must-have vs nice-to-have

Assess complexity:
- **Small** (1-3 files, clear approach): Lightweight plan, fewer tasks
- **Medium** (4-10 files, some unknowns): Standard plan with research phase
- **Large** (10+ files, significant unknowns): Suggest decomposing into sub-plans

### Phase 1: Research

Use parallel sub-agents when available:

1. **Codebase research**: Find 3+ similar implementations in the project. Identify patterns, conventions, test patterns, utilities.
2. **Framework research**: Check official docs for any libraries/frameworks involved. Look for version-specific constraints or best practices.
3. **Existing test patterns**: How are similar features tested? What test utilities exist?

Compile findings into a research summary before designing.

### Phase 2: Architecture

1. **Map file structure**: Which files will be created or modified?
2. **Design units**: Each file has one clear responsibility with well-defined interfaces
3. **Identify dependencies**: What order must things be built in?
4. **Choose approach**: Present 2-3 options with trade-offs, recommend one

### Phase 3: Task Decomposition

Break into bite-sized tasks. Each task is one implementation unit.

**Each step is one action (2-5 minutes):**
- "Write the failing test" — step
- "Run it to verify it fails" — step
- "Implement minimal code to pass" — step
- "Run tests to verify they pass" — step
- "Commit" — step

**Task format:**

```markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file`
- Modify: `exact/path/to/existing:line-range`
- Test: `tests/exact/path/to/test`

**Goal:** [What this task accomplishes]
**Criteria:** [How to verify this task is done]

- [ ] Step 1: Write failing test
  [complete test code]
- [ ] Step 2: Verify test fails
  Run: `[exact command]` Expected: FAIL
- [ ] Step 3: Write implementation
  [complete implementation code]
- [ ] Step 4: Verify test passes
  Run: `[exact command]` Expected: PASS
- [ ] Step 5: Commit
  `git commit -m "feat: [description]"`
```

**No placeholders.** Every step has the actual code. No "TBD", "TODO", "similar to Task N", "add appropriate handling".

### Phase 4: Self-Review

1. **Spec coverage**: Can you point to a task for each requirement?
2. **Placeholder scan**: Any TBD, TODO, vague steps?
3. **Type consistency**: Do names/signatures match across tasks?
4. **Dependency order**: Can tasks be executed in order without forward references?

Fix issues inline.

### Phase 5: Handoff

Save plan to `docs/plans/YYYY-MM-DD-<feature-name>.md`

**Plan header format:**

```markdown
# [Feature] Implementation Plan

**Goal:** [One sentence]
**Architecture:** [2-3 sentences]
**Tech Stack:** [Key technologies]

---
```

Offer execution:

> "Plan saved to `docs/plans/<filename>.md`. Ready to execute with `rr:work`?"
```

- [ ] **Step 3: Commit plan skill**

```bash
git add plugins/randomradio/skills/plan/SKILL.md
git commit -m "feat: add rr:plan skill for structured implementation planning"
```

---

### Task 4: `rr:brainstorm` Skill

**Files:**
- Create: `plugins/randomradio/skills/brainstorm/SKILL.md`

- [ ] **Step 1: Create brainstorm skill directory**

```bash
mkdir -p plugins/randomradio/skills/brainstorm
```

- [ ] **Step 2: Write `rr:brainstorm` SKILL.md**

Create `plugins/randomradio/skills/brainstorm/SKILL.md`:

```markdown
---
name: rr:brainstorm
description: "Explore requirements and design before planning. Use when starting new features, investigating what to build, or when scope is unclear. Collaborative dialogue to answer WHAT to build before HOW."
argument-hint: "[idea, feature request, or problem to explore]"
---

# Brainstorm

Collaborative requirements exploration. Answer "WHAT to build" through natural dialogue before planning HOW.

<brainstorm_input> #$ARGUMENTS </brainstorm_input>

## Core Principle

No implementation without design. No design without understanding requirements.

## Process

### Phase 0: Assess & Route

1. **Check project context**: Read relevant files, docs, recent commits
2. **Assess scope**: Is this one thing or multiple independent subsystems?
   - If multiple: Flag immediately. Decompose into sub-projects before diving into details.
   - If one: Proceed to Phase 1.
3. **Check complexity**:
   - **Trivial** (config change, obvious fix): Skip brainstorm, suggest `rr:plan` directly
   - **Clear scope** (well-defined feature): Lightweight brainstorm, 2-3 questions
   - **Ambiguous** (unclear requirements, multiple approaches): Full brainstorm

### Phase 1: Collaborative Dialogue

Ask questions **one at a time** to understand:

- **Purpose**: What problem does this solve? Who benefits?
- **Constraints**: What must it work with? Performance, compatibility, scale?
- **Success criteria**: How do we know it's done? What's the verifiable outcome?
- **Non-goals**: What is explicitly out of scope?

Prefer multiple choice when possible. Open-ended when exploring unknowns.

### Phase 2: Explore Approaches

Once you understand the problem:

1. **Propose 2-3 approaches** with trade-offs
2. **Lead with your recommendation** and explain why
3. **Cover**: architecture, data flow, key components, testing strategy
4. **Be opinionated**: Don't present options without a recommendation

### Phase 3: Present Design

Present the design section by section, scaled to complexity:
- Simple: A few sentences per section
- Complex: Up to 200-300 words per section

Ask after each section: "Does this look right?"

Sections to cover:
- Architecture and component overview
- Data flow
- Error handling approach
- Testing strategy
- Key decisions and their rationale

### Phase 4: Handoff

Once design is approved:

1. Save spec to `docs/specs/YYYY-MM-DD-<topic>-design.md`
2. Commit the spec
3. Suggest: "Spec saved. Ready to create an implementation plan with `rr:plan`?"

## Interaction Rules

- **One question per message**
- **Multiple choice preferred** when options are known
- **YAGNI ruthlessly** — remove unnecessary features from designs
- **Be a thinking partner**, not a requirements scribe
- **Challenge assumptions** — if something seems over-engineered, say so
```

- [ ] **Step 3: Commit brainstorm skill**

```bash
git add plugins/randomradio/skills/brainstorm/SKILL.md
git commit -m "feat: add rr:brainstorm skill for requirements exploration"
```

---

### Task 5: `rr:review` Skill

**Files:**
- Create: `plugins/randomradio/skills/review/SKILL.md`

- [ ] **Step 1: Create review skill directory**

```bash
mkdir -p plugins/randomradio/skills/review
```

- [ ] **Step 2: Write `rr:review` SKILL.md**

Create `plugins/randomradio/skills/review/SKILL.md`:

```markdown
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
| API routes, request/response types, serialization | **api-contract-reviewer** (not yet available — skip) |
| SQL migrations, schema changes, data backfills | **data-migrations-reviewer** (not yet available — skip) |
| Performance-sensitive paths, database queries, loops | **performance-reviewer** |
| Authentication, authorization, crypto, user input handling | **security-reviewer** |
| Test files changed or new test files | **testing-reviewer** |
| Cross-module changes, new services, architecture shifts | **architecture-reviewer** |

### 3. Dispatch Reviewer Sub-Agents

Dispatch selected reviewers as parallel sub-agents. Each reviewer receives:
- The diff content
- Intent summary (from plan if available, or inferred from commit messages)
- Instructions to return findings as structured JSON

### 4. Merge Findings

1. Collect findings from all reviewers
2. Deduplicate: same file + same line + similar description = merge, keep highest severity
3. Sort by severity (Critical → Warning → Observation)

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
```

- [ ] **Step 3: Commit review skill**

```bash
git add plugins/randomradio/skills/review/SKILL.md
git commit -m "feat: add rr:review skill with persona-based code review"
```

---

### Task 6: `rr:debug` Skill

**Files:**
- Create: `plugins/randomradio/skills/debug/SKILL.md`

- [ ] **Step 1: Create debug skill directory**

```bash
mkdir -p plugins/randomradio/skills/debug
```

- [ ] **Step 2: Write `rr:debug` SKILL.md**

Create `plugins/randomradio/skills/debug/SKILL.md`:

```markdown
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
- Check recent changes: `git log --oneline -10 -- [file]`
- If looks like a regression: consider `git bisect`

#### 1.3 Multi-Component Systems

For systems with multiple components (API → service → database):

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
- The causal chain: trigger → step → step → symptom
- For uncertain links: a prediction that must be true if the hypothesis is correct

**Causal chain gate:** Do NOT proceed to Phase 3 until you can explain the full causal chain with no gaps.

**3 failed hypotheses = escalate.** Diagnose why:

| Pattern | Diagnosis | Next move |
|---------|-----------|-----------|
| Hypotheses point to different subsystems | Architecture problem | Present findings, suggest `rr:brainstorm` |
| Evidence contradicts itself | Wrong mental model | Re-read code without assumptions |
| Works locally, fails in CI/prod | Environment problem | Focus on env differences |
| Fix works but prediction was wrong | Symptom fix, not root cause | Keep investigating |

### Phase 3: Fix

**Only if user chose to fix.** Present findings first and ask.

1. Write a failing test that captures the bug
2. Verify it fails for the right reason
3. Implement the minimal fix — root cause only
4. Verify the test passes
5. Run broader test suite for regressions

**3 failed fix attempts = STOP.** Question the architecture. Discuss with user.

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
```

- [ ] **Step 3: Commit debug skill**

```bash
git add plugins/randomradio/skills/debug/SKILL.md
git commit -m "feat: add rr:debug skill for systematic root cause debugging"
```

---

### Task 7: `rr:tdd` Skill

**Files:**
- Create: `plugins/randomradio/skills/tdd/SKILL.md`

- [ ] **Step 1: Create tdd skill directory**

```bash
mkdir -p plugins/randomradio/skills/tdd
```

- [ ] **Step 2: Write `rr:tdd` SKILL.md**

Create `plugins/randomradio/skills/tdd/SKILL.md`:

```markdown
---
name: rr:tdd
description: "Use when implementing any feature or bugfix, before writing implementation code. Enforces test-first red-green-refactor discipline."
---

# Test-Driven Development

Write the test first. Watch it fail. Write minimal code to pass.

## The Iron Law

```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST
```

Write code before the test? Delete it. Start over. No exceptions.

## When to Use

**Always:** New features, bug fixes, refactoring, behavior changes.

**Exceptions (ask user):** Throwaway prototypes, generated code, configuration files.

## Red-Green-Refactor

### RED — Write Failing Test

Write one minimal test showing what should happen.

Requirements:
- One behavior per test
- Clear name describing the behavior
- Real code, not mocks (unless unavoidable)

### Verify RED — Watch It Fail (MANDATORY)

```bash
# Run the test
[project test command] path/to/test
```

Confirm:
- Test fails (not errors)
- Failure message is expected
- Fails because feature missing, not typos

### GREEN — Minimal Code

Write the simplest code to pass the test. Nothing more.

Don't add features, refactor other code, or "improve" beyond the test.

### Verify GREEN — Watch It Pass (MANDATORY)

```bash
# Run the test
[project test command] path/to/test
```

Confirm:
- Test passes
- Other tests still pass
- Output pristine

### REFACTOR — Clean Up

After green only:
- Remove duplication
- Improve names
- Extract helpers

Keep tests green. Don't add behavior.

## Red Flags — STOP and Start Over

- Code before test
- Test passes immediately (you're testing existing behavior)
- Can't explain why test failed
- "Just this once" rationalization
- "I'll test after" thinking
- "Too simple to test"

**All of these mean: Delete code. Start over with TDD.**

## Debugging Integration

Bug found? Write failing test reproducing it. Follow TDD cycle. Test proves fix and prevents regression. Never fix bugs without a test.

## Verification Checklist

Before marking work complete:

- [ ] Every new function/method has a test
- [ ] Watched each test fail before implementing
- [ ] Each test failed for expected reason
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass
- [ ] Tests use real code (mocks only if unavoidable)
```

- [ ] **Step 3: Commit tdd skill**

```bash
git add plugins/randomradio/skills/tdd/SKILL.md
git commit -m "feat: add rr:tdd skill for test-driven development discipline"
```

---

### Task 8: Move `quick-shoutout` into Plugin

**Files:**
- Move: `quick-shoutout/` → `plugins/randomradio/skills/quick-shoutout/`
- Modify: `plugins/randomradio/skills/quick-shoutout/SKILL.md` (update name prefix)

- [ ] **Step 1: Copy quick-shoutout into plugin**

```bash
cp -r quick-shoutout plugins/randomradio/skills/quick-shoutout
```

- [ ] **Step 2: Update SKILL.md frontmatter to use rr: prefix**

Edit `plugins/randomradio/skills/quick-shoutout/SKILL.md`:

Change:
```yaml
name: quick-shoutout
```
To:
```yaml
name: rr:quick-shoutout
```

- [ ] **Step 3: Commit**

```bash
git add plugins/randomradio/skills/quick-shoutout/
git commit -m "feat: move quick-shoutout into plugins/randomradio with rr: prefix"
```

---

### Task 9: Review Agent Personas

**Files:**
- Create: `plugins/randomradio/agents/review/adversarial-reviewer.md`
- Create: `plugins/randomradio/agents/review/security-reviewer.md`
- Create: `plugins/randomradio/agents/review/performance-reviewer.md`
- Create: `plugins/randomradio/agents/review/architecture-reviewer.md`
- Create: `plugins/randomradio/agents/review/correctness-reviewer.md`
- Create: `plugins/randomradio/agents/review/maintainability-reviewer.md`
- Create: `plugins/randomradio/agents/review/testing-reviewer.md`

- [ ] **Step 1: Write adversarial-reviewer.md**

Create `plugins/randomradio/agents/review/adversarial-reviewer.md`:

```markdown
---
name: adversarial-reviewer
description: "Selected when diff is large (50+ lines) or touches high-risk domains (auth, payments, data mutations, external APIs). Constructs failure scenarios to break the implementation."
model: inherit
tools: Read, Grep, Glob, Bash
---

# Adversarial Reviewer

You read code by trying to break it. You construct specific scenarios that make it fail. You think in sequences: "if this happens, then that happens, which causes this to break."

## Depth Calibration

- **Quick** (under 50 lines, no risk signals): Assumption violation only. Max 3 findings.
- **Standard** (50-199 lines, minor risk): Assumption violation + composition failures + abuse cases.
- **Deep** (200+ lines, strong risk signals): All techniques including cascade construction.

## What You Hunt For

### 1. Assumption Violation
Identify assumptions about data shape, timing, ordering, value ranges. Construct scenarios where they break.

### 2. Composition Failures
Trace interactions across component boundaries where each component is correct alone but the combination fails. Contract mismatches, shared state mutations, ordering across boundaries.

### 3. Cascade Construction
Build multi-step failure chains: resource exhaustion cascades, state corruption propagation, recovery-induced failures.

### 4. Abuse Cases
Legitimate-seeming usage patterns that cause bad outcomes: repetition abuse, timing abuse, concurrent mutation, boundary walking.

## Confidence Calibration

- **High (0.80+):** Complete, concrete scenario traceable from code
- **Moderate (0.60-0.79):** Scenario depends on conditions you can see but can't fully confirm
- **Low (below 0.60):** Suppress — pure speculation

## Output

Return findings as JSON:
```json
{
  "reviewer": "adversarial",
  "findings": [],
  "residual_risks": [],
  "testing_gaps": []
}
```
```

- [ ] **Step 2: Write correctness-reviewer.md**

Create `plugins/randomradio/agents/review/correctness-reviewer.md`:

```markdown
---
name: correctness-reviewer
description: "Always selected. Reviews for logic errors, edge cases, off-by-one errors, null handling, and incorrect behavior."
model: inherit
tools: Read, Grep, Glob, Bash
---

# Correctness Reviewer

You verify that code does what it claims to do. You trace logic paths, check edge cases, and find where behavior diverges from intent.

## What You Hunt For

- **Logic errors**: Wrong conditionals, inverted checks, incorrect operator precedence
- **Edge cases**: Empty inputs, null/undefined values, zero-length collections, boundary values
- **Off-by-one errors**: Loop bounds, array indexing, pagination, range calculations
- **Type mismatches**: Implicit conversions, narrowing assignments, nullable access
- **Incomplete handling**: Switch/match missing cases, unhandled promise rejections, error paths that silently succeed
- **Incorrect state transitions**: Variables set but never read, state updated in wrong order

## Confidence Calibration

- **High (0.80+):** Can trace exact input that produces wrong output
- **Moderate (0.60-0.79):** Logic looks wrong but depends on runtime conditions
- **Low (below 0.60):** Suppress

## Output

```json
{
  "reviewer": "correctness",
  "findings": [],
  "testing_gaps": []
}
```
```

- [ ] **Step 3: Write maintainability-reviewer.md**

Create `plugins/randomradio/agents/review/maintainability-reviewer.md`:

```markdown
---
name: maintainability-reviewer
description: "Always selected. Reviews code clarity, naming, structure, duplication, and long-term maintainability."
model: inherit
tools: Read, Grep, Glob, Bash
---

# Maintainability Reviewer

You evaluate whether code will be understandable and changeable in 6 months by someone who didn't write it.

## What You Hunt For

- **Unclear naming**: Variables, functions, or types whose names don't communicate purpose
- **Excessive complexity**: Functions doing too many things, deep nesting, long parameter lists
- **Duplication**: Similar logic in multiple places that should be extracted
- **Dead code**: Unreachable branches, unused imports, commented-out code
- **Missing documentation**: Complex logic without explanation of why (not what)
- **Inconsistency**: Different patterns for the same thing in the same codebase

## What You Don't Flag

- Style preferences that don't affect comprehension
- Existing code not touched by this diff
- Opinions about framework choice

## Output

```json
{
  "reviewer": "maintainability",
  "findings": [],
  "testing_gaps": []
}
```
```

- [ ] **Step 4: Write security-reviewer.md**

Create `plugins/randomradio/agents/review/security-reviewer.md`:

```markdown
---
name: security-reviewer
description: "Selected when diff touches authentication, authorization, crypto, user input handling, or external data processing."
model: inherit
tools: Read, Grep, Glob, Bash
---

# Security Reviewer

You hunt for vulnerabilities following OWASP Top 10 and common security anti-patterns.

## What You Hunt For

- **Injection**: SQL injection, command injection, XSS, template injection
- **Authentication/Authorization flaws**: Missing auth checks, privilege escalation paths, insecure session handling
- **Sensitive data exposure**: Secrets in code, PII in logs, sensitive data in error messages
- **Insecure deserialization**: Untrusted data used to construct objects
- **Misconfiguration**: Overly permissive CORS, debug mode in production, default credentials
- **Cryptographic issues**: Weak algorithms, hardcoded keys, insufficient randomness

## Confidence Calibration

- **High (0.80+):** Exploitable vulnerability visible in the code
- **Moderate (0.60-0.79):** Potential vulnerability depending on deployment context
- **Low (below 0.60):** Suppress

## Output

```json
{
  "reviewer": "security",
  "findings": [],
  "residual_risks": []
}
```
```

- [ ] **Step 5: Write performance-reviewer.md**

Create `plugins/randomradio/agents/review/performance-reviewer.md`:

```markdown
---
name: performance-reviewer
description: "Selected when diff touches database queries, loops over collections, API endpoints, or performance-sensitive paths."
model: inherit
tools: Read, Grep, Glob, Bash
---

# Performance Reviewer

You find performance issues that will hurt at scale.

## What You Hunt For

- **N+1 queries**: Loop with a query inside, missing eager loading, unbatched operations
- **Missing indexes**: Queries filtering/sorting on unindexed columns
- **Unbounded operations**: Loading entire tables, unlimited API responses, uncontrolled recursion
- **Memory issues**: Large object accumulation, missing cleanup, unnecessary copies
- **Algorithmic issues**: O(n²) where O(n) is possible, repeated computation, missing caching

## What You Don't Flag

- Micro-optimizations with no measurable impact
- Premature optimization of cold paths
- Style preferences disguised as performance concerns

## Output

```json
{
  "reviewer": "performance",
  "findings": [],
  "testing_gaps": []
}
```
```

- [ ] **Step 6: Write architecture-reviewer.md**

Create `plugins/randomradio/agents/review/architecture-reviewer.md`:

```markdown
---
name: architecture-reviewer
description: "Selected when diff touches cross-module boundaries, introduces new services, or makes structural changes."
model: inherit
tools: Read, Grep, Glob, Bash
---

# Architecture Reviewer

You evaluate changes for pattern compliance, design integrity, and architectural alignment.

## What You Hunt For

- **Dependency violations**: Wrong direction of imports, circular dependencies, layer violations
- **Boundary violations**: Logic in the wrong layer, leaky abstractions, inappropriate intimacy between components
- **Pattern inconsistency**: Different approaches for the same problem within the codebase
- **Missing abstractions**: Concrete dependencies where interfaces should exist, tight coupling
- **Scope creep**: Changes that expand the responsibility of a module beyond its charter

## What You Don't Flag

- Stylistic preferences
- Performance (performance-reviewer handles this)
- Correctness within a component (correctness-reviewer handles this)

## Output

```json
{
  "reviewer": "architecture",
  "findings": [],
  "residual_risks": []
}
```
```

- [ ] **Step 7: Write testing-reviewer.md**

Create `plugins/randomradio/agents/review/testing-reviewer.md`:

```markdown
---
name: testing-reviewer
description: "Selected when test files are changed or new test files are added."
model: inherit
tools: Read, Grep, Glob, Bash
---

# Testing Reviewer

You evaluate test quality, coverage, and reliability.

## What You Hunt For

- **Missing test coverage**: New behavior without corresponding tests, untested error paths
- **Weak assertions**: Tests that always pass, assertions that don't verify meaningful behavior
- **Test fragility**: Tests coupled to implementation details, timing-dependent tests, order-dependent tests
- **Missing edge cases**: Happy path only, no boundary values, no error scenarios
- **Test duplication**: Same scenario tested multiple times with slight variations
- **Mock abuse**: Mocking the thing under test, testing mock behavior instead of real behavior

## What You Don't Flag

- Test style preferences (arrange-act-assert vs given-when-then)
- Test file organization choices
- Test naming conventions (if consistent within the project)

## Output

```json
{
  "reviewer": "testing",
  "findings": [],
  "testing_gaps": []
}
```
```

- [ ] **Step 8: Commit all review agents**

```bash
git add plugins/randomradio/agents/review/
git commit -m "feat: add review agent personas for rr:review skill"
```

---

### Task 10: Research Agent Personas

**Files:**
- Create: `plugins/randomradio/agents/research/best-practices-researcher.md`
- Create: `plugins/randomradio/agents/research/framework-docs-researcher.md`

- [ ] **Step 1: Write best-practices-researcher.md**

Create `plugins/randomradio/agents/research/best-practices-researcher.md`:

```markdown
---
name: best-practices-researcher
description: "Researches and synthesizes external best practices, documentation, and examples for any technology or framework."
model: inherit
tools: Read, Grep, Glob, Bash, WebSearch, WebFetch
---

# Best Practices Researcher

You discover, analyze, and synthesize best practices from authoritative sources.

## Research Methodology

### Phase 1: Check Local Knowledge First

1. Search for relevant SKILL.md files in the project's skill directories
2. Extract patterns, conventions, code examples from matching skills
3. If skills provide comprehensive guidance → summarize and deliver
4. If gaps remain → proceed to Phase 2

### Phase 2: Online Research

1. Search official documentation for the specific technology
2. Search for "[technology] best practices [current year]" for recent guides
3. Look for popular repositories demonstrating good practices
4. Check for industry-standard style guides

### Phase 3: Synthesize

1. Prioritize skill-based guidance (curated), then official docs, then community
2. Organize: "Must Have", "Recommended", "Optional"
3. Include code examples adapted to the project's style
4. Cite sources with authority level

## Source Attribution

- **Skill-based**: "The [skill] recommends..." (highest authority)
- **Official docs**: "Official documentation recommends..."
- **Community**: "Community consensus suggests..."
```

- [ ] **Step 2: Write framework-docs-researcher.md**

Create `plugins/randomradio/agents/research/framework-docs-researcher.md`:

```markdown
---
name: framework-docs-researcher
description: "Gathers comprehensive documentation and best practices for frameworks, libraries, or dependencies. Version-specific constraints and implementation patterns."
model: inherit
tools: Read, Grep, Glob, Bash, WebSearch, WebFetch
---

# Framework Docs Researcher

You gather technical documentation and version-specific implementation guidance.

## Workflow

### 1. Initial Assessment

- Identify the framework/library being researched
- Determine installed version from lockfiles
- Understand the specific feature or problem

### 2. Documentation Collection

- Start with official documentation
- Prioritize official sources over tutorials
- Collect version-specific constraints, deprecations, migration guides

### 3. Source Exploration

- Find key source files related to the feature
- Look for tests demonstrating usage patterns
- Check for configuration examples

### 4. Synthesis

Structure findings as:

1. **Summary**: Brief overview
2. **Version Info**: Current version and constraints
3. **Key Concepts**: Essential concepts for the feature
4. **Implementation Guide**: Step-by-step with code examples
5. **Best Practices**: From official docs and community
6. **Common Issues**: Known problems and solutions
7. **References**: Links to docs and source
```

- [ ] **Step 3: Commit research agents**

```bash
git add plugins/randomradio/agents/research/
git commit -m "feat: add research agent personas for rr:plan skill"
```

---

### Task 11: Cleanup — Remove Old Directories

**Files:**
- Delete: `long-horizon-planner/` (replaced by `rr:work`)
- Delete: `quick-shoutout/` (moved into plugin)
- Delete: `superpowers/` (absorbed into plugin)

- [ ] **Step 1: Verify plugin is complete**

```bash
# Verify all skill files exist
ls plugins/randomradio/skills/work/SKILL.md
ls plugins/randomradio/skills/plan/SKILL.md
ls plugins/randomradio/skills/brainstorm/SKILL.md
ls plugins/randomradio/skills/review/SKILL.md
ls plugins/randomradio/skills/debug/SKILL.md
ls plugins/randomradio/skills/tdd/SKILL.md
ls plugins/randomradio/skills/quick-shoutout/SKILL.md
ls plugins/randomradio/agents/review/adversarial-reviewer.md
ls plugins/randomradio/agents/research/best-practices-researcher.md
```

Expected: All files exist.

- [ ] **Step 2: Remove long-horizon-planner**

```bash
git rm -r long-horizon-planner/
```

- [ ] **Step 3: Remove top-level quick-shoutout**

```bash
git rm -r quick-shoutout/
```

- [ ] **Step 4: Remove superpowers**

```bash
git rm -r superpowers/
```

- [ ] **Step 5: Commit cleanup**

```bash
git commit -m "chore: remove long-horizon-planner, superpowers, and top-level quick-shoutout

Replaced by plugins/randomradio/ with goal-driven execution loop.
- long-horizon-planner → rr:work (goal-driven master/subagent)
- superpowers TDD/debug/review → rr:tdd, rr:debug, rr:review
- quick-shoutout → plugins/randomradio/skills/quick-shoutout"
```

---

### Task 12: Update README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Read current README**

```bash
cat README.md
```

- [ ] **Step 2: Update README to reflect new structure**

Update `README.md` to document the plugin structure, available skills with `rr:` prefix, and the goal-driven workflow:

```markdown
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

`rr:work` uses a goal-driven master/subagent loop:

1. Define **Goal** and verifiable **Criteria**
2. Master creates subagent to work toward the goal
3. Master monitors, evaluates against criteria, restarts if needed
4. Loop until all criteria are met

The subagent has full autonomy in approach (TDD, debugging, etc.). The master only orchestrates.

## Other Tools

| Directory | Purpose |
|-----------|---------|
| `randomradio-upgrade/` | Skill package manager — upgrade all skills from GitHub |
```

- [ ] **Step 3: Commit README**

```bash
git add README.md
git commit -m "docs: update README for plugins/randomradio structure"
```
