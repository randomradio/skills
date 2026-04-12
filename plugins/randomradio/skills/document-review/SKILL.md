---
name: rr:document-review
description: "Review requirements, specs, or plan documents through multi-persona analysis. Use when a document needs quality review before implementation. Supports headless mode for automated pipelines."
argument-hint: "[document path] [mode:interactive|headless]"
---

# Document Review

Multi-persona review of planning documents — specs, requirements, and implementation plans. Like `rr:review` for code, but for documents.

<doc_input> #$ARGUMENTS </doc_input>

## Execution Flow

| Phase | Name | Purpose |
|-------|------|---------|
| 0 | Load | Read document, detect type |
| 1 | Select Personas | Choose reviewers based on content |
| 2 | Dispatch | Parallel sub-agent review |
| 3 | Synthesize | Merge findings, present results |

---

### Phase 0: Load

Read the document from `<doc_input>`. Detect document type:
- **Spec/Requirements**: Focus on completeness, feasibility, clarity
- **Implementation Plan**: Focus on coherence, task ordering, gap detection
- **Architecture Decision**: Focus on trade-offs, alternatives, risks

### Phase 1: Select Personas

**Always active:**
- **coherence-reviewer** — internal consistency, terminology drift, contradictions
- **feasibility-reviewer** — will this survive contact with reality?

**Conditionally active (based on document content):**

| Condition | Persona |
|-----------|---------|
| 5+ requirements or implementation units | **adversarial-document-reviewer** |
| UI/UX decisions, user-facing changes | **design-lens-reviewer** |
| Authentication, data handling, external APIs | **security-lens-reviewer** |
| Scope seems large or abstractions seem premature | **scope-guardian-reviewer** |
| User-facing product decisions | **product-lens-reviewer** |

Reviewer agent definitions are in `agents/document-review/`.

### Phase 2: Dispatch

Dispatch selected reviewers as parallel sub-agents. Each receives:
- The full document content
- Document type classification
- Instructions to return structured findings

### Phase 3: Synthesize

Merge findings from all reviewers:

1. Deduplicate overlapping concerns
2. Sort by severity (Critical → Warning → Observation)
3. Group by document section when possible

**Interactive mode (default):**
```markdown
## Document Review: [filename]

### Critical Issues
1. **[Issue]** — Section: [section] — [Description]. Suggestion: [Fix]

### Warnings
1. **[Issue]** — Section: [section] — [Description]

### Observations
1. **[Observation]** — [Description]

### Strengths
- [What's working well in the document]
```

**Headless mode:** Return raw JSON findings for programmatic consumption.

### Post-Review

Offer next steps:
1. Fix identified issues in the document
2. Proceed to implementation (`rr:plan` or `rr:work`)
3. Request deeper review on specific sections
