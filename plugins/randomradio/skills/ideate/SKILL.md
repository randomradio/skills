---
name: rr:ideate
description: "Generate and critically evaluate project improvement ideas grounded in the actual codebase. Use before brainstorming to explore what could be improved. Precedes rr:brainstorm in the workflow."
argument-hint: "[optional: focus area, constraint, or 'top N' for volume control]"
---

# Ideate

Generate improvement ideas grounded in reality, not imagination. Every idea must trace back to something observable in the codebase, issues, or team knowledge.

<ideate_input> #$ARGUMENTS </ideate_input>

## Workflow Position

```
rr:ideate → rr:brainstorm → rr:plan → rr:work → rr:review → rr:compound
```

Ideation answers "WHAT COULD we build?" Brainstorming answers "WHAT SHOULD we build?"

## Execution Flow

| Phase | Name | Purpose |
|-------|------|---------|
| 0 | Scope | Parse input, determine focus and volume |
| 1 | Research | Scan codebase, learnings, issues |
| 2 | Generate | Divergent ideation with multiple frames |
| 3 | Filter | Adversarial evaluation |
| 4 | Present | Ranked ideas with evidence |

---

### Phase 0: Scope

Parse `<ideate_input>`:
- **Focus area** (e.g., "performance", "developer experience"): Constrain research
- **Volume** (e.g., "top 3", "give me 20"): Control output count (default: 5-10)
- **Empty**: Full codebase scan, default volume

### Phase 1: Research

Use parallel sub-agents when available:

1. **Codebase scan**: Find TODOs, FIXMEs, complex functions, duplicated patterns, stale dependencies
2. **Learnings search**: Check `docs/solutions/` for recurring problems (via `learnings-researcher` agent)
3. **Issue intelligence** (optional): Check GitHub issues for pain patterns (via `issue-intelligence-analyst` agent)

Compile a research digest before generating ideas.

### Phase 2: Generate

Apply multiple ideation frames to the research:

| Frame | Approach |
|-------|----------|
| **Pain-driven** | What causes the most friction? What breaks most often? |
| **Opportunity-driven** | What's working well that could work better? Where are quick wins? |
| **Subtraction-driven** | What could be removed? What complexity isn't earning its keep? |
| **User-driven** | What would make the next developer's life easier? |

Each frame generates 3-5 raw ideas grounded in evidence from Phase 1.

### Phase 3: Filter

Apply adversarial filtering to each idea:

| Question | Fail signal |
|----------|-------------|
| Can you point to evidence in the codebase? | "I think..." without file references |
| What's the smallest useful version? | Requires 3+ weeks of work for any value |
| Who benefits and how soon? | Benefits are vague or far-future |
| What breaks if we don't do this? | Nothing — it's a nice-to-have disguised as important |

Remove ideas that fail 2+ questions. Be ruthless.

### Phase 4: Present

Output ranked ideas:

```markdown
## Ideation: [focus area or "Full Codebase"]

### 1. [Idea title]
**Evidence:** [file:line or issue reference showing the problem]
**Impact:** [who benefits, how soon]
**Effort:** [small/medium/large]
**Smallest useful version:** [what's the MVP?]

### 2. [Idea title]
...
```

Offer next step:
> "Want to brainstorm any of these further with `rr:brainstorm`?"
