---
name: rr:git-commit-push-pr
description: "Go from working tree changes to an open PR in one step. Smart commit splitting, adaptive PR descriptions, and convention detection. Also supports updating existing PR descriptions."
argument-hint: "[optional: 'update' to update existing PR description]"
---

# Git Commit Push PR

From working tree to open PR. Handles convention detection, logical commit splitting, adaptive PR descriptions.

<gcp_input> #$ARGUMENTS </gcp_input>

## Mode Detection

- **`update`** in input: Update description of existing PR on current branch
- **Default**: Create new commits and PR

---

## Create Mode

### Step 1: Detect Conventions

```bash
# Check for commit conventions in project docs
grep -i "commit" CLAUDE.md AGENTS.md CONTRIBUTING.md 2>/dev/null

# Analyze recent commit history for patterns
git log --oneline -20
```

Detect: conventional commits, ticket prefixes, emoji prefixes, or freeform style. Follow what the project uses.

### Step 2: Stage and Split

Review all changes:
```bash
git status
git diff --stat
```

**Split logic** — create separate commits when changes span different concerns:
- Feature code vs test code
- Multiple independent fixes
- Config changes vs implementation

For single-concern changes, one commit is fine. Don't split for the sake of splitting.

### Step 3: Write Commit Messages

Follow detected conventions. Each message should:
- Explain **why**, not just what
- Reference issue numbers if applicable
- Be concise (subject under 72 chars)

### Step 4: Push

```bash
git push -u origin $(git branch --show-current)
```

If branch doesn't exist on remote yet, this creates it.

### Step 5: Create PR

**Adaptive description sizing:**

| Change type | Description depth |
|-------------|-------------------|
| Typo / 1-liner | 1-2 sentences |
| Bug fix | Problem, cause, fix, test |
| Feature | Summary, approach, key decisions, test plan |
| Architectural | Full narrative: motivation, alternatives considered, migration notes |

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
<scaled to change complexity>

## Test Plan
<how to verify>

## Key Decisions
<only for non-trivial changes>
EOF
)"
```

### Step 6: Report

Output the PR URL and a brief summary of what was created.

---

## Update Mode

When input contains `update`:

1. Find the current PR:
   ```bash
   gh pr view --json number,title,body
   ```
2. Analyze all commits on the branch (not just latest)
3. Regenerate description using adaptive sizing
4. Update:
   ```bash
   gh pr edit <number> --body "<new body>"
   ```
