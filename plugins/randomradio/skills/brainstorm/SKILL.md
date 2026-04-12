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
