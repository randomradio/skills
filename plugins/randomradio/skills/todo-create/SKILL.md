---
name: rr:todo-create
description: "Create file-based todos tracked in .context/todos/. Each todo is a markdown file with YAML frontmatter, sequential IDs, status, priority, and dependencies. Use when tracking work items that persist across sessions."
argument-hint: "[todo description]"
---

# Todo Create

Create persistent, file-based todos in `.context/todos/`. Unlike ephemeral task tools, these survive across sessions and can be searched, filtered, and resolved later.

<todo_input> #$ARGUMENTS </todo_input>

## File Structure

```
.context/todos/
├── 001-setup-auth-module.md
├── 002-add-rate-limiting.md
├── 003-fix-pagination-bug.md
└── .counter                    # Next ID counter
```

## Creating a Todo

### Step 1: Get Next ID

```bash
mkdir -p .context/todos
if [[ -f .context/todos/.counter ]]; then
  next_id=$(cat .context/todos/.counter)
else
  next_id=1
fi
printf "%03d" "$next_id"
```

### Step 2: Parse Input

From `<todo_input>`, extract:
- **Title**: Short, imperative description
- **Priority**: p1 (critical), p2 (important), p3 (nice-to-have). Default: p2.
- **Dependencies**: Other todo IDs this blocks on
- **Context**: Any additional details

If input is ambiguous, ask one clarifying question.

### Step 3: Write Todo File

Create `.context/todos/<ID>-<slug>.md`:

```markdown
---
id: <ID>
title: <title>
status: pending
priority: <p1|p2|p3>
created: YYYY-MM-DD
depends_on: []
tags: []
---

## Description

<detailed description from input>

## Acceptance Criteria

- [ ] <verifiable criterion>

## Notes

<any additional context>
```

### Step 4: Update Counter

```bash
echo $((next_id + 1)) > .context/todos/.counter
```

### Step 5: Confirm

Report: "Created todo #<ID>: <title> (priority: <p>)"

## Batch Create

If input contains multiple items (numbered list, comma-separated), create one todo per item. Report all created IDs.

## Integration

- `rr:todo-triage` reviews pending todos for approval
- `rr:todo-resolve` batch-resolves approved todos
