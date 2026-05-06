---
name: rr:compound
description: "Document a recently solved problem to compound your team's knowledge. Use after debugging sessions, bug fixes, workflow discoveries, architecture decisions, or when the user says 'that worked', 'it's fixed', or 'document this'."
argument-hint: "[optional brief context about what was solved]"
---

# Compound

Document a recently solved problem as a schema-backed learning in `docs/solutions/`.

<compound_input> #$ARGUMENTS </compound_input>

## Purpose

Capture solutions while context is fresh so future agents can search durable, versioned knowledge instead of rediscovering the same answer.

## Support Files

Read these on demand; they are the source of truth for new learning docs:

- `references/schema.yaml` -- canonical frontmatter fields, enum values, and bug-vs-knowledge track rules
- `references/yaml-schema.md` -- category mapping and YAML safety rules
- `assets/resolution-template.md` -- section order for bug-track and knowledge-track docs

Do not invent frontmatter fields, enum values, categories, or section order from memory.

## Execution Flow

### 1. Identify the Learning

Read the conversation and local repo context to identify the most recently solved problem. Look for:

- Error messages that were debugged
- Broken behavior traced to a root cause
- Configuration or environment issues that were fixed
- Performance bottlenecks that were resolved
- Architecture, convention, or workflow decisions made after investigation

If `<compound_input>` contains a context hint, use it to focus the search. If no recent solution is obvious, ask the user what to document.

### 2. Classify Track and Category

Read `references/schema.yaml` and determine:

- **Track**: bug or knowledge, based on `problem_type`
- **Problem type**: the narrowest matching enum
- **Component**: the closest schema enum
- **Category directory**: from `references/yaml-schema.md`
- **Filename**: `[sanitized-problem-slug]-[YYYY-MM-DD].md`

Bug-track docs require `symptoms`, `root_cause`, and `resolution_type`. Knowledge-track docs require only the shared fields plus useful optional context such as `applies_when`.

### 3. Search for Existing Docs

Search `docs/solutions/` before writing:

```bash
rg -n "<keywords>|<module>|<error text>" docs/solutions 2>/dev/null
```

Assess overlap across:

- Problem statement
- Root cause
- Solution approach
- Referenced files or modules
- Prevention guidance

Use this decision table:

| Overlap | Action |
|---------|--------|
| High: same problem, root cause, and solution | Update the existing doc in place; add `last_updated: YYYY-MM-DD` |
| Moderate: related area but distinct angle | Create a new doc and cross-reference the related doc |
| Low or none | Create a new doc |

### 4. Assemble the Document

Read `assets/resolution-template.md` and use the template for the selected track. Preserve the template section order unless the user explicitly asks otherwise.

Include:

- A precise title
- Schema-valid frontmatter
- The observed problem or context
- What failed or what changed during investigation
- The actual solution with code snippets when useful
- Why the solution works
- Prevention, test, or workflow guidance
- Related docs/issues when found

Validate frontmatter against `references/schema.yaml` and the YAML safety rules in `references/yaml-schema.md`. Quote array items that start with YAML indicator characters or contain `: `.

### 5. Write One Primary File

Write either:

- The updated existing doc, or
- A new file at `docs/solutions/<category>/<filename>.md`

Only the final learning doc is the primary output. If discoverability needs a small instruction-file edit, that is maintenance, not a second learning artifact.

### 6. Discoverability Check

Check whether `AGENTS.md`, `CLAUDE.md`, or `README.md` would help a future agent discover `docs/solutions/`:

```bash
rg -n "docs/solutions|documented solutions|learnings" AGENTS.md CLAUDE.md README.md 2>/dev/null
```

The instruction file should communicate:

- A searchable knowledge store exists
- It is organized by category with YAML frontmatter such as `module`, `tags`, and `problem_type`
- It is relevant when implementing or debugging in documented areas

If this is missing, propose the smallest natural addition and get user consent before editing instruction files.

### 7. Refresh Decision

After writing the learning, consider `rr:compound-refresh` only when the new doc suggests older docs are stale, contradicted, overlapping, or superseded. Prefer a narrow scope hint, such as:

```text
rr:compound-refresh authentication
rr:compound-refresh docs/solutions/best-practices/example.md
```

Do not run a broad refresh automatically.

## Auto-Invoke Triggers

Consider invoking this skill when you hear:

- "that worked", "it's fixed", "finally"
- "we should document this"
- "next time we'll know"
- After any debugging session longer than 15 minutes
