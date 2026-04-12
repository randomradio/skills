---
name: rr:resolve-pr-feedback
description: "Evaluate and fix PR review feedback, then reply and resolve threads. Use when a PR has review comments to address. Supports full mode (all threads) and targeted mode (single thread URL)."
argument-hint: "[PR number, PR URL, or thread URL for targeted resolution]"
---

# Resolve PR Feedback

Evaluate PR review threads, implement fixes, reply with explanations, and resolve threads.

<pr_input> #$ARGUMENTS </pr_input>

## Execution Flow

| Phase | Name | Purpose |
|-------|------|---------|
| 0 | Discover | Find unresolved review threads |
| 1 | Analyze | Classify and cluster feedback |
| 2 | Resolve | Fix, reply, or escalate each thread |
| 3 | Push & Report | Commit fixes, push, summarize |

---

### Phase 0: Discover

**Targeted mode** (input is a thread URL):
- Extract PR number and thread ID
- Fetch that specific thread

**Full mode** (input is PR number or URL):
- Fetch all review threads:
  ```bash
  gh pr view <number> --json reviewDecision,reviews,comments
  gh api repos/{owner}/{repo}/pulls/<number>/comments
  ```
- Filter to unresolved threads only
- Skip threads authored by the current user (self-comments)

If no unresolved threads found, report "All clear" and exit.

### Phase 1: Analyze

For each thread:
1. Read the full comment chain (original + replies)
2. Classify the feedback type: bug, style, architecture, question, nit, request
3. Assess validity: is the concern correct?

**Cluster analysis** (full mode only):
- Group related threads by theme (e.g., "3 comments about error handling")
- Detect systemic patterns — if 3+ threads point to the same underlying issue, flag it as a systemic concern rather than resolving individually

### Phase 2: Resolve

Dispatch a sub-agent per thread (or per cluster for systemic issues). Each agent uses the `pr-comment-resolver` persona from `agents/workflow/`.

**Verdict classification:**

| Verdict | Meaning | Action |
|---------|---------|--------|
| `fixed` | Implemented exactly as requested | Code change + reply |
| `fixed-differently` | Addressed the concern differently | Code change + explanation |
| `replied` | Answered a question or explained why current approach is better | Reply only |
| `not-addressing` | Disagree with feedback, explained why | Reply with rationale |
| `needs-human` | Too complex or risky for automated resolution | Flag for user |

Default to **fixing** — agent time is cheap, reviewer time is expensive.

### Phase 3: Push & Report

1. Commit all fixes:
   ```bash
   git add -A
   git commit -m "fix: address PR review feedback"
   ```

2. Push:
   ```bash
   git push
   ```

3. Report summary:
   ```markdown
   ## PR Feedback Resolution

   | Thread | Verdict | Action |
   |--------|---------|--------|
   | [comment summary] | fixed | [what was changed] |
   | [comment summary] | replied | [response summary] |
   | [comment summary] | needs-human | [why] |

   **Systemic patterns detected:** [if any]
   ```

## Safety Rules

- Never force-push
- Never resolve threads without either fixing or explaining
- Flag `needs-human` when: security implications, architectural disagreement, unclear requirements
- If multiple threads touch the same file, check for conflicts before committing
