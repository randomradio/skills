---
name: rr:todo-resolve
description: "Batch-resolve approved (ready) todos using parallel agents. Implements fixes, commits, and marks todos as complete. Use after rr:todo-triage has approved items."
argument-hint: "[optional: specific todo IDs to resolve, e.g. '001,003']"
---

# Todo Resolve

Batch-resolve todos that have been triaged and marked as `ready`. Each todo is resolved by a sub-agent, committed, and marked complete.

<resolve_input> #$ARGUMENTS </resolve_input>

## Execution Flow

### Step 1: Find Ready Todos

```bash
grep -l "status: ready" .context/todos/*.md 2>/dev/null
```

If `<resolve_input>` specifies IDs, filter to only those. If no ready todos found, report and exit.

### Step 2: Order by Priority and Dependencies

1. Sort by priority (p1 first)
2. Check dependencies — don't resolve a todo whose `depends_on` items aren't complete
3. Group independent todos for parallel execution

### Step 3: Resolve Each Todo

For each ready todo, dispatch a sub-agent with:
- The todo's full content (description + acceptance criteria)
- Relevant file paths (if mentioned in the todo)
- Instructions to implement, test, and commit

The sub-agent should:
1. Implement the change described in the todo
2. Verify acceptance criteria are met
3. Commit with message: `fix: resolve todo #<ID> — <title>`

### Step 4: Mark Complete

After successful resolution, update the todo file:

```yaml
status: complete
resolved: YYYY-MM-DD
```

### Step 5: Report

```markdown
## Todo Resolution Summary

| ID | Title | Status |
|----|-------|--------|
| #001 | Setup auth module | Resolved |
| #003 | Fix pagination bug | Resolved |
| #002 | Add rate limiting | Skipped (depends on #001) |
```

### Step 6: Document Learnings

If any resolution involved non-obvious debugging or decisions, suggest running `rr:compound` to capture the learning.

## Safety

- Never resolve a todo whose dependencies aren't complete
- If a resolution fails after 2 attempts, mark as `blocked` with reason
- Push only if user confirms
