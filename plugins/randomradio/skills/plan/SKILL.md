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

````markdown
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
````

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
