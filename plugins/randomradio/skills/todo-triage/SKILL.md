---
name: rr:todo-triage
description: "Interactive review of pending todos for approval, skip, or modification. Lightweight triage workflow before batch resolution with rr:todo-resolve."
argument-hint: "[optional: scope filter like 'p1' or tag name]"
---

# Todo Triage

Review pending todos interactively. Approve, skip, modify, or delete before batch resolution.

<triage_input> #$ARGUMENTS </triage_input>

## Execution Flow

### Step 1: Load Pending Todos

```bash
grep -l "status: pending" .context/todos/*.md 2>/dev/null
```

If `<triage_input>` specifies a filter (priority or tag), narrow the list.

Sort by: priority (p1 first), then creation date (oldest first).

### Step 2: Present Each Todo

For each pending todo, show:

```markdown
### #<ID>: <title>
**Priority:** <p1/p2/p3> | **Created:** <date> | **Depends on:** <IDs or none>
**Description:** <first 2-3 lines>

**Actions:** [Approve] [Skip] [Edit] [Delete] [Split]
```

Ask for the user's choice. One todo at a time.

### Step 3: Process Decision

| Action | Result |
|--------|--------|
| **Approve** | Set `status: ready` — queued for `rr:todo-resolve` |
| **Skip** | Leave as `pending` — review later |
| **Edit** | Update description, priority, or acceptance criteria |
| **Delete** | Remove the todo file |
| **Split** | Break into 2+ smaller todos, delete the original |

### Step 4: Summary

After reviewing all pending todos:

```markdown
## Triage Summary

- **Approved (ready):** N todos
- **Skipped:** N todos
- **Edited:** N todos
- **Deleted:** N todos
- **Split:** N todos (into M new)

Ready to resolve? Run `rr:todo-resolve`
```

## Quick Triage

If all pending todos are p1 and clearly actionable, offer: "All N pending todos are p1 with clear criteria. Approve all?"
