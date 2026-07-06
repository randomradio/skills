# Compound Engineering Skill Lineage

Generated: 2026-07-06T15:26:51.006Z

This report compares published RandomRadio skills against configured upstream
skills when the upstream skills are installed locally. RandomRadio remains the
source of record; upstream is a comparison source for selective non-breaking
updates.

## Local Contracts

- Published skill frontmatter names stay under the rr: namespace.
- RandomRadio install, registry, market, and release behavior stay repo-owned.
- Upstream updates are reviewed before adoption; local changes are preserved when they are part of the RandomRadio contract.

## Status

| Skill | Mode | Provider | Upstream skill | Status | Similarity | Update policy |
|---|---|---|---|---|---:|---|
| brainstorm | fork | Compound Engineering | ce-brainstorm | diverged | 1% | prefer-upstream-with-local-contracts |
| compound | fork | Compound Engineering | ce-compound | diverged | 1% | prefer-upstream-with-local-contracts |
| compound-refresh | fork | Compound Engineering | ce-compound-refresh | diverged | 1% | prefer-upstream-with-local-contracts |
| debug | fork | Compound Engineering | ce-debug | diverged | 9% | prefer-upstream-with-local-contracts |
| document-review | fork | Compound Engineering | ce-doc-review | diverged | 2% | prefer-upstream-with-local-contracts |
| git-commit | fork | Compound Engineering | ce-commit | diverged | 3% | prefer-upstream-with-local-contracts |
| git-commit-push-pr | fork | Compound Engineering | ce-commit-push-pr | diverged | 4% | prefer-upstream-with-local-contracts |
| git-worktree | fork | Compound Engineering | ce-worktree | diverged | 2% | prefer-upstream-with-local-contracts |
| ideate | fork | Compound Engineering | ce-ideate | diverged | 1% | prefer-upstream-with-local-contracts |
| plan | fork | Compound Engineering | ce-plan | diverged | 0% | prefer-upstream-with-local-contracts |
| plantuml-qpr-render | original | - | - | repo-owned | - | repo-owned |
| quick-shoutout | original | - | - | repo-owned | - | repo-owned |
| resolve-pr-feedback | fork | Compound Engineering | ce-resolve-pr-feedback | diverged | 1% | prefer-upstream-with-local-contracts |
| review | fork | Compound Engineering | ce-code-review | diverged | 2% | prefer-upstream-with-local-contracts |
| skills-market-publish | original | - | - | repo-owned | - | repo-owned |
| tdd | original | - | - | repo-owned | - | repo-owned |
| todo-create | original | - | - | repo-owned | - | repo-owned |
| todo-resolve | original | - | - | repo-owned | - | repo-owned |
| todo-triage | original | - | - | repo-owned | - | repo-owned |
| work | fork | Compound Engineering | ce-work | diverged | 1% | prefer-upstream-with-local-contracts |

## Validation

- None.

## Update Rule

For "fork" skills, compare upstream first, adopt upstream improvements by
default, and preserve local contracts explicitly. If a local divergence should
remain, document why in the skill or in the implementation commit.
