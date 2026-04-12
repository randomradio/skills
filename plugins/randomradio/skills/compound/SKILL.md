---
name: rr:compound
description: "Document a recently solved problem to compound your team's knowledge. Use after debugging sessions, bug fixes, or when the user says 'that worked', 'it's fixed', or 'document this'."
argument-hint: "[optional brief context about what was solved]"
---

# Compound

Coordinate parallel subagents to document a recently solved problem. Each documented solution compounds your team's knowledge — the first time you solve a problem takes research, document it and the next occurrence takes minutes.

<compound_input> #$ARGUMENTS </compound_input>

## Purpose

Captures problem solutions while context is fresh, creating structured documentation in `docs/solutions/` with YAML frontmatter for searchability.

## Step 1: Load Context

Read the **conversation history** to identify the most recently solved problem. Look for:
- Error messages that were debugged
- Configuration issues that were fixed
- Behavioral bugs that were traced and resolved
- Performance problems that were optimized
- Architecture decisions that were made after investigation

If `<compound_input>` contains a context hint, use it to focus the search.

If no recent solution is obvious, ask the user what they'd like to document.

## Step 2: Classify the Learning

Determine the category:

| Category | Directory | Signal |
|----------|-----------|--------|
| Bug fix | `docs/solutions/bugs/` | Error was traced to root cause and fixed |
| Configuration | `docs/solutions/config/` | Settings, environment, or deployment issue |
| Architecture | `docs/solutions/architecture/` | Design decision or structural change |
| Performance | `docs/solutions/performance/` | Optimization or bottleneck resolution |
| Integration | `docs/solutions/integration/` | Third-party service or API issue |
| Workflow | `docs/solutions/workflow/` | Development process improvement |

## Step 3: Check for Duplicates

Search `docs/solutions/` for existing documents covering the same problem:

```bash
grep -r "[key terms from the problem]" docs/solutions/ 2>/dev/null
```

If a related document exists:
- **Same problem, same solution:** Skip — tell the user it's already documented
- **Same problem, different solution:** Update the existing document with the new approach
- **Related but distinct:** Proceed with new document, add cross-reference

## Step 4: Write the Document

Create the file at `docs/solutions/<category>/YYYY-MM-DD-<descriptive-slug>.md`:

```markdown
---
title: [Clear problem title]
date: YYYY-MM-DD
category: [bug|config|architecture|performance|integration|workflow]
tags: [relevant, technology, tags]
severity: [low|medium|high|critical]
time_to_resolve: [approximate time spent]
---

## Problem

[What went wrong — symptoms, error messages, observed behavior]

## Root Cause

[Why it went wrong — the actual underlying issue]

## Solution

[What fixed it — specific steps, code changes, configuration]

## Prevention

[How to prevent recurrence — tests added, monitoring, process changes]

## Key Insight

[The non-obvious learning — what would help someone encountering this next time]
```

## Step 5: Ensure Discoverability

Check if `docs/solutions/` is referenced in project documentation:

```bash
grep -r "docs/solutions" CLAUDE.md AGENTS.md README.md 2>/dev/null
```

If not referenced anywhere, suggest adding a pointer so future sessions can find the knowledge store.

## Step 6: Commit

```bash
git add docs/solutions/<category>/<filename>.md
git commit -m "docs: compound learning — [brief description]"
```

## Auto-Invoke Triggers

Consider invoking this skill when you hear:
- "that worked", "it's fixed", "finally"
- "we should document this"
- "next time we'll know"
- After any debugging session longer than 15 minutes
