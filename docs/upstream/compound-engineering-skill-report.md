# Compound Engineering Skill Lineage

Generated: 2026-07-06T15:36:27.350Z

This report compares published RandomRadio skills against configured upstream
skills when the upstream skills are installed locally. RandomRadio remains the
source of record; upstream is a comparison source for selective non-breaking
updates.

## Local Contracts

- Published skill frontmatter names stay under the rr: namespace.
- RandomRadio install, registry, market, and release behavior stay repo-owned.
- Upstream updates are reviewed before adoption; local changes are preserved when they are part of the RandomRadio contract.

## Status

| Skill | Mode | Provider | Upstream skill | Status | Similarity | Compatibility | Update policy | Sync decision |
|---|---|---|---|---|---:|---|---|---|
| brainstorm | fork | Compound Engineering | ce-brainstorm | diverged | 1% | passed | prefer-upstream-with-local-contracts | review upstream, preserve local contract |
| compound | fork | Compound Engineering | ce-compound | diverged | 1% | passed | prefer-upstream-with-local-contracts | review upstream, preserve local contract |
| compound-refresh | fork | Compound Engineering | ce-compound-refresh | diverged | 1% | passed | prefer-upstream-with-local-contracts | review upstream, preserve local contract |
| debug | fork | Compound Engineering | ce-debug | diverged | 9% | passed | prefer-upstream-with-local-contracts | review upstream, preserve local contract |
| document-review | fork | Compound Engineering | ce-doc-review | diverged | 2% | passed | prefer-upstream-with-local-contracts | review upstream, preserve local contract |
| git-commit | fork | Compound Engineering | ce-commit | diverged | 3% | passed | prefer-upstream-with-local-contracts | review upstream, preserve local contract |
| git-commit-push-pr | fork | Compound Engineering | ce-commit-push-pr | diverged | 4% | passed | prefer-upstream-with-local-contracts | review upstream, preserve local contract |
| git-worktree | fork | Compound Engineering | ce-worktree | diverged | 2% | passed | prefer-upstream-with-local-contracts | review upstream, preserve local contract |
| ideate | fork | Compound Engineering | ce-ideate | diverged | 1% | passed | prefer-upstream-with-local-contracts | review upstream, preserve local contract |
| plan | fork | Compound Engineering | ce-plan | diverged | 0% | passed | prefer-upstream-with-local-contracts | review upstream, preserve local contract |
| plantuml-qpr-render | original | - | - | repo-owned | - | repo-owned | repo-owned | update in repo |
| quick-shoutout | original | - | - | repo-owned | - | repo-owned | repo-owned | update in repo |
| resolve-pr-feedback | fork | Compound Engineering | ce-resolve-pr-feedback | diverged | 1% | passed | prefer-upstream-with-local-contracts | review upstream, preserve local contract |
| review | fork | Compound Engineering | ce-code-review | diverged | 2% | passed | prefer-upstream-with-local-contracts | review upstream, preserve local contract |
| skills-market-publish | original | - | - | repo-owned | - | repo-owned | repo-owned | update in repo |
| tdd | original | - | - | repo-owned | - | repo-owned | repo-owned | update in repo |
| todo-create | original | - | - | repo-owned | - | repo-owned | repo-owned | update in repo |
| todo-resolve | original | - | - | repo-owned | - | repo-owned | repo-owned | update in repo |
| todo-triage | original | - | - | repo-owned | - | repo-owned | repo-owned | update in repo |
| work | fork | Compound Engineering | ce-work | diverged | 1% | passed | prefer-upstream-with-local-contracts | review upstream, preserve local contract |

## Skill Deltas

### brainstorm

| Field | Value |
|---|---|
| Local name | `rr:brainstorm` |
| Upstream name | `ce-brainstorm` |
| Local hash | `00fb9d939735` |
| Upstream hash | `63ac671124cb` |
| Compatibility | passed |
| Sync decision | review upstream, preserve local contract |

Preserve:

- Keep the public `rr:brainstorm` identity and handoff to `rr:plan`.
- Keep the lightweight RandomRadio spec path under `docs/specs/`.
- Keep the simplified scope triage instead of requiring the full CE brainstorm artifact pipeline.

Missing required markers:

- None.

Local-only headings:

- Brainstorm
- Core Principle
- Process
- Phase 0: Assess & Route
- Phase 1: Collaborative Dialogue
- Phase 3: Present Design

Upstream-only headings:

- Brainstorm a Feature or Improvement
- Core Principles
- Output Guidance
- Feature Description
- Execution Flow
- Phase 0: Resume, Assess, and Route
- Phase 1: Understand the Idea
- Phase 2.5: Synthesis Summary

### compound

| Field | Value |
|---|---|
| Local name | `rr:compound` |
| Upstream name | `ce-compound` |
| Local hash | `7dbcd002e521` |
| Upstream hash | `e8c8a4018ef3` |
| Compatibility | passed |
| Sync decision | review upstream, preserve local contract |

Preserve:

- Keep `rr:compound` identity and the repo-owned schema-backed `docs/solutions/` output.
- Keep local support files under the RandomRadio skill directory.
- Keep discoverability checks that mention `AGENTS.md`, `CLAUDE.md`, and `README.md`.

Missing required markers:

- None.

Local-only headings:

- Compound
- Execution Flow
- 1. Identify the Learning
- 2. Classify Track and Category
- 3. Search for Existing Docs
- 4. Assemble the Document
- 5. Write One Primary File
- 6. Discoverability Check

Upstream-only headings:

- /ce-compound
- Usage
- CONCEPTS.md bootstrap requests
- Mode Detection
- Pre-resolved context
- Execution Strategy
- Full Mode
- Phase 0.5: Auto Memory Scan

### compound-refresh

| Field | Value |
|---|---|
| Local name | `rr:compound-refresh` |
| Upstream name | `ce-compound-refresh` |
| Local hash | `b5eeff601da3` |
| Upstream hash | `8c1633e7b6d4` |
| Compatibility | passed |
| Sync decision | review upstream, preserve local contract |

Preserve:

- Keep `rr:compound-refresh` identity and `mode:interactive|autofix` interface.
- Keep the RandomRadio Keep/Update/Consolidate/Replace/Delete report shape.
- Keep all writes scoped to `docs/solutions/` unless the user asks otherwise.

Missing required markers:

- None.

Local-only headings:

- Why This Matters
- Execution Flow
- Step 1: Inventory
- Step 2: Review Each Document
- Step 3: Classify
- Step 4: Apply
- Compound Refresh Report
- Keep (N documents)

Upstream-only headings:

- Headless mode rules
- CONCEPTS.md bootstrap requests
- Interaction Principles
- Refresh Order
- Maintenance Model
- Core Rules
- Scope Selection
- Phase 0: Assess and Route

### debug

| Field | Value |
|---|---|
| Local name | `rr:debug` |
| Upstream name | `ce-debug` |
| Local hash | `50649044ca3a` |
| Upstream hash | `ad9b8d0e6051` |
| Compatibility | passed |
| Sync decision | review upstream, preserve local contract |

Preserve:

- Keep `rr:debug` identity and concise root-cause execution loop.
- Keep RandomRadio handoffs to `rr:brainstorm` for design problems.
- Keep the structured Debug Summary output.

Missing required markers:

- None.

Local-only headings:

- Debug
- Core Principle
- Phase 4: Close

Upstream-only headings:

- Debug and Fix
- Core Principles
- Phase 4: Handoff

### document-review

| Field | Value |
|---|---|
| Local name | `rr:document-review` |
| Upstream name | `ce-doc-review` |
| Local hash | `7c77226f6b5c` |
| Upstream hash | `3fa8169feb73` |
| Compatibility | passed |
| Sync decision | review upstream, preserve local contract |

Preserve:

- Keep `rr:document-review` identity and `mode:interactive|headless` interface.
- Keep reviewer agents referenced from RandomRadio agent paths.
- Keep programmatic headless output support.

Missing required markers:

- None.

Local-only headings:

- Execution Flow
- Phase 0: Load
- Phase 1: Select Personas
- Phase 2: Dispatch
- Phase 3: Synthesize
- Document Review: [filename]
- Critical Issues
- Warnings

Upstream-only headings:

- Interactive mode rules
- Phase 0: Detect Mode
- Phase 1: Get and Analyze Document
- Classify Document Type
- Select Conditional Personas
- Phase 2: Announce and Dispatch Personas
- Announce the Review Team
- Build Agent List

### git-commit

| Field | Value |
|---|---|
| Local name | `rr:git-commit` |
| Upstream name | `ce-commit` |
| Local hash | `a9d2a30e8219` |
| Upstream hash | `92a05377e770` |
| Compatibility | passed |
| Sync decision | review upstream, preserve local contract |

Preserve:

- Keep `rr:git-commit` identity.
- Keep convention detection from project docs and recent commits.
- Keep logical commit splitting as an explicit step.

Missing required markers:

- None.

Local-only headings:

- Step 1: Detect Conventions
- Check project docs for commit conventions
- Analyze recent commits for patterns
- Step 2: Review Changes
- Step 3: Split if Needed
- Step 5: Verify
- Safety

Upstream-only headings:

- Context
- Context fallback
- Workflow
- Step 1: Gather context
- Step 2: Determine commit message convention
- Step 3: Consider logical commits
- Step 5: Confirm

### git-commit-push-pr

| Field | Value |
|---|---|
| Local name | `rr:git-commit-push-pr` |
| Upstream name | `ce-commit-push-pr` |
| Local hash | `2eff85df956d` |
| Upstream hash | `270c955b26cc` |
| Compatibility | passed |
| Sync decision | review upstream, preserve local contract |

Preserve:

- Keep `rr:git-commit-push-pr` identity.
- Keep create/update mode split.
- Keep PR body sections for Summary, Test Plan, and Key Decisions.

Missing required markers:

- None.

Local-only headings:

- Git Commit Push PR
- Mode Detection
- Create Mode
- Step 1: Detect Conventions
- Check for commit conventions in project docs
- Analyze recent commit history for patterns
- Step 2: Stage and Split
- Step 3: Write Commit Messages

Upstream-only headings:

- Git Commit, Push, and PR
- Mode
- Context
- Context fallback
- Step 1: Resolve branch and PR state
- Step 2: Determine conventions
- Step 3: Commit and push
- Step 4: Compose the PR title and body

### git-worktree

| Field | Value |
|---|---|
| Local name | `rr:git-worktree` |
| Upstream name | `ce-worktree` |
| Local hash | `b64953a452a2` |
| Upstream hash | `addaf5886460` |
| Compatibility | passed |
| Sync decision | review upstream, preserve local contract |

Preserve:

- Keep `rr:git-worktree` identity.
- Keep environment file copy behavior.
- Keep branch safety rules for uncommitted changes.

Missing required markers:

- None.

Local-only headings:

- Git Worktree
- Commands
- Create
- Parse branch name from input
- Create worktree
- Copy environment files
- Trust dev tool configs
- List

Upstream-only headings:

- Worktree Creation
- Creating a worktree
- Other worktree operations
- Dev tool trust behavior
- When to create a worktree
- Integration
- Troubleshooting

### ideate

| Field | Value |
|---|---|
| Local name | `rr:ideate` |
| Upstream name | `ce-ideate` |
| Local hash | `f93c8477c4e8` |
| Upstream hash | `8f23190c7f11` |
| Compatibility | passed |
| Sync decision | review upstream, preserve local contract |

Preserve:

- Keep `rr:ideate` identity and full RandomRadio workflow chain.
- Keep grounding in codebase, issues, and `docs/solutions/`.
- Keep handoff to `rr:brainstorm`.

Missing required markers:

- None.

Local-only headings:

- Ideate
- Workflow Position
- Phase 0: Scope
- Phase 1: Research
- Phase 2: Generate
- Phase 3: Filter
- Phase 4: Present
- Ideation: [focus area or "Full Codebase"]

Upstream-only headings:

- Generate Improvement Ideas
- Interaction Method
- Focus Hint
- Core Principles
- Phase 0: Resume and Scope
- Phase 1: Mode-Aware Grounding
- Phase 1.5: Topic-Surface Decomposition
- Phase 2: Divergent Ideation

### plan

| Field | Value |
|---|---|
| Local name | `rr:plan` |
| Upstream name | `ce-plan` |
| Local hash | `253d6c861615` |
| Upstream hash | `ee58e1e77ff7` |
| Compatibility | passed |
| Sync decision | review upstream, preserve local contract |

Preserve:

- Keep `rr:plan` identity and RandomRadio plan path under `docs/plans/`.
- Keep TDD-oriented implementation units.
- Keep handoff to `rr:work`.

Missing required markers:

- None.

Local-only headings:

- Plan
- Core Principle
- Execution Flow
- Phase 0: Source & Scope
- Phase 1: Research
- Phase 2: Architecture
- Phase 3: Task Decomposition
- Task N: [Component Name]

Upstream-only headings:

- Create Technical Plan
- Interaction Method
- Feature Description
- Core Principles
- Plan Quality Bar
- Workflow
- Phase 0: Resume, Source, and Scope
- Phase 1: Gather Context

### resolve-pr-feedback

| Field | Value |
|---|---|
| Local name | `rr:resolve-pr-feedback` |
| Upstream name | `ce-resolve-pr-feedback` |
| Local hash | `c93fa062f995` |
| Upstream hash | `44ddcc660d28` |
| Compatibility | passed |
| Sync decision | review upstream, preserve local contract |

Preserve:

- Keep `rr:resolve-pr-feedback` identity.
- Keep workflow agent path under `agents/workflow/`.
- Keep default-to-fixing posture and safety rules for untrusted review text.

Missing required markers:

- None.

Local-only headings:

- Resolve PR Feedback
- Execution Flow
- Phase 0: Discover
- Phase 1: Analyze
- Phase 2: Resolve
- Phase 3: Push & Report
- Safety Rules

Upstream-only headings:

- Resolve PR Review Feedback
- Security
- Mode Detection
- Scripts
- Success Criteria

### review

| Field | Value |
|---|---|
| Local name | `rr:review` |
| Upstream name | `ce-code-review` |
| Local hash | `375557c4f105` |
| Upstream hash | `69a9c23b7a0d` |
| Compatibility | passed |
| Sync decision | review upstream, preserve local contract |

Preserve:

- Keep `rr:review` identity and `mode:autofix|mode:report-only|mode:headless` interface.
- Keep artifact output under `/tmp/randomradio/rr-review/`.
- Keep headless/autofix rule that parent workflows own commits, pushes, and PRs.

Missing required markers:

- None.

Local-only headings:

- Review
- Mode Rules
- Execution Flow
- 1. Determine Scope
- Fast path when base:<ref> is provided
- Default branch path
- 2. Load Intent
- 3. Select Reviewers

Upstream-only headings:

- Code Review
- When to Use
- Operating principles
- Output format
- Quick Review Short-Circuit
- Reviewers
- Review Scope
- Protected Artifacts

### work

| Field | Value |
|---|---|
| Local name | `rr:work` |
| Upstream name | `ce-work` |
| Local hash | `ef896adb16a1` |
| Upstream hash | `91c5d6bb6879` |
| Compatibility | passed |
| Sync decision | review upstream, preserve local contract |

Preserve:

- Keep `rr:work` identity and goal-driven loop.
- Keep inline/task-list execution as the default.
- Keep delegation optional and gated by platform support plus explicit user request.
- Keep RandomRadio reference files under `references/goal-driven-loop.md`.

Missing required markers:

- None.

Local-only headings:

- Work
- Core Principle
- Execution Flow
- Phase 1: Setup
- Phase 2: Goal-Driven Execution Loop
- 2.1: Execute the Next Unit
- 2.2: Optional Delegation Contract
- 2.3: Evaluate Against Criteria

Upstream-only headings:

- Work Execution Command
- Introduction
- Input Document
- Execution Workflow
- Phase 1: Quick Start
- Phase 2: Execute
- Phase 3-4: Quality Check and Finishing Work
- Key Principles


## Validation

- None.

## Update Rule

For "fork" skills, compare upstream first, adopt upstream improvements by
default, and preserve local contracts explicitly. If a local divergence should
remain, document why in the skill or in the implementation commit.
