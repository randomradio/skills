# Shipping Workflow

Load this file only when all Phase 2 work is complete and execution transitions to Phase 3.

## Phase 3: Quality Check

### 1. Run Core Quality Checks

```bash
# Run full test suite (use project's test command)
# Examples: npm test, pytest, go test, cargo test, etc.

# Run linting (use project's lint command)
# Examples: npm run lint, ruff check, golangci-lint run, etc.
```

### 2. Code Review

Every change gets reviewed before shipping. Depth scales with risk.

**Full review (default):** Invoke `rr:review` for multi-file changes, changes to existing behavior, cross-cutting changes, or anything with novel logic. Pass `plan:<path>` when available.

**Self-review:** Permitted only when ALL four criteria are true:
- Purely additive (new files only, no existing behavior modified)
- Single concern (one skill, one component)
- Pattern-following (mirrors existing example, no novel logic)
- Plan-faithful (no scope growth, no surprising decisions)

### 3. Final Validation

- [ ] All tasks marked completed
- [ ] Tests pass and new behavior has test coverage
- [ ] Linting passes
- [ ] Code follows existing patterns
- [ ] No console errors or warnings

## Phase 4: Ship It

### 1. Commit

Ensure all work is committed with clear, conventional messages:
```bash
git add <specific-files>
git commit -m "feat: <description>"
```

### 2. Create PR

```bash
git push -u origin <branch-name>
gh pr create --title "<short title>" --body "$(cat <<'EOF'
## Summary
- <key changes>

## Test Plan
- <how to verify>

## Criteria Verified
- <which criteria from the goal were met and how>
EOF
)"
```

### 3. Notify User

- Summarize what was completed
- Link to PR
- Note any follow-up work
- Suggest next steps if applicable

## Quality Checklist

Before creating PR:

- [ ] All criteria from the goal verified and passing
- [ ] Tests pass AND new/changed behavior has test coverage
- [ ] Linting passes
- [ ] Code follows existing patterns
- [ ] Commit messages are clear and conventional
- [ ] PR description includes summary, test plan, and criteria verification
