---
name: rr:git-commit
description: "Create well-crafted git commits following repository conventions. Auto-detects commit style from history and project docs. Considers logical commit splitting. Use when committing changes without creating a PR."
argument-hint: "[optional commit message hint]"
---

# Git Commit

Create clean, convention-following git commits. Auto-detects the project's commit style and follows it.

<commit_input> #$ARGUMENTS </commit_input>

## Step 1: Detect Conventions

```bash
# Check project docs for commit conventions
grep -i "commit" CLAUDE.md AGENTS.md CONTRIBUTING.md 2>/dev/null

# Analyze recent commits for patterns
git log --oneline -20
```

Detect style: conventional commits (`feat:`, `fix:`), ticket prefixes (`PROJ-123`), emoji prefixes, or freeform. Follow what the project uses.

## Step 2: Review Changes

```bash
git status
git diff --stat
git diff --cached --stat
```

Assess what's changed. Look for:
- Multiple independent concerns that should be separate commits
- Test files that should be committed alongside their implementation
- Config changes that should be separate from feature code

## Step 3: Split if Needed

Create separate commits when changes span different concerns:
- Feature code vs test code (if tests are for a different feature)
- Multiple independent bug fixes
- Config/infrastructure vs application logic
- Unrelated formatting changes

For single-concern changes, one commit is fine. Don't split for the sake of splitting.

## Step 4: Stage and Commit

For each logical commit:

```bash
git add <specific-files>
git commit -m "<message following detected conventions>"
```

**Commit message rules:**
- Subject under 72 characters
- Explain **why**, not just what
- Reference issue numbers if applicable
- Follow the project's detected convention
- If `<commit_input>` provides a hint, incorporate it

## Step 5: Verify

```bash
git log --oneline -5
```

Confirm commits look clean and follow conventions.

## Safety

- Never commit to default branch without explicit user consent
- Warn if committing to main/master
- Never use `--no-verify` to bypass hooks
- Never commit files that likely contain secrets (.env, credentials.json, etc.)
