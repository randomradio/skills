---
name: rr:compound-refresh
description: "Maintain quality of docs/solutions/ knowledge base over time. Reviews existing learnings against the current codebase, classifies as Keep/Update/Consolidate/Replace/Delete. Use periodically or when docs feel stale."
argument-hint: "[mode:interactive|autofix] [scope:all|category]"
---

# Compound Refresh

Maintain the quality of your `docs/solutions/` knowledge base. Prevents knowledge rot by reviewing existing documents against the current codebase.

<refresh_input> #$ARGUMENTS </refresh_input>

## Why This Matters

Knowledge compounds, but stale knowledge misleads. A solution document that references a deleted function or a deprecated API is worse than no document — it wastes time and creates false confidence.

## Mode Detection

Parse `<refresh_input>`:
- **`mode:interactive`** (default): Present findings, ask before changes
- **`mode:autofix`**: Apply safe changes automatically, flag uncertain ones
- **`scope:all`**: Review entire `docs/solutions/`
- **`scope:<category>`**: Review only `docs/solutions/<category>/`

## Execution Flow

### Step 1: Inventory

```bash
find docs/solutions -name "*.md" -type f | sort
```

Count documents by category. If no `docs/solutions/` exists, report "Nothing to refresh" and exit.

### Step 2: Review Each Document

For each document, check:

1. **Code references still valid?**
   - Grep for file paths mentioned in the doc
   - Check if referenced functions/classes still exist
   - Verify configuration keys are still used

2. **Solution still applicable?**
   - Has the underlying framework/library changed?
   - Was the root cause fixed upstream?
   - Is the workaround still necessary?

3. **Cross-document overlap?**
   - Does another document cover the same topic?
   - Are there contradictions between documents?

### Step 3: Classify

For each document, assign a verdict:

| Verdict | Meaning | Action |
|---------|---------|--------|
| **Keep** | Still accurate and useful | No change |
| **Update** | Core insight valid, details stale | Update references, paths, examples |
| **Consolidate** | Overlaps with another document | Merge into one, delete the other |
| **Replace** | Problem was fixed differently | Rewrite with current solution |
| **Delete** | No longer relevant | Remove (with confirmation) |

### Step 4: Apply

**Interactive mode:**
```markdown
## Compound Refresh Report

### Keep (N documents)
- [title] — still accurate

### Update (N documents)
1. [title] — [what needs updating]

### Consolidate (N documents)
1. [title A] + [title B] — [overlap description]

### Delete (N documents)
1. [title] — [why no longer relevant]
```

Ask for approval before making changes.

**Autofix mode:**
- Apply Updates automatically
- Apply Deletes automatically for documents where ALL code references are gone
- Flag Consolidate and uncertain Deletes for human review

### Step 5: Commit

```bash
git add docs/solutions/
git commit -m "docs: refresh compound knowledge base — [summary of changes]"
```

## Recommended Cadence

- After major refactoring
- After dependency upgrades
- Monthly, if the knowledge base has 10+ documents
- When someone reports a misleading solution
