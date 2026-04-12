---
name: rr:git-worktree
description: "Manage Git worktrees for isolated parallel development. Create, list, switch, and clean up worktrees. Auto-copies .env files and handles branch safety."
argument-hint: "[create <branch>|list|remove <branch>|clean]"
---

# Git Worktree

Manage Git worktrees for isolated, parallel development. Each worktree is an independent checkout sharing the same git history.

<worktree_input> #$ARGUMENTS </worktree_input>

## Commands

### Create

```bash
# Parse branch name from input
branch="<branch-name>"
worktree_dir="../$(basename $(pwd))-$branch"

# Create worktree
git worktree add "$worktree_dir" -b "$branch" 2>/dev/null || \
git worktree add "$worktree_dir" "$branch"

# Copy environment files
for f in .env .env.local .env.development; do
  [[ -f "$f" ]] && cp "$f" "$worktree_dir/$f"
done

# Trust dev tool configs
if command -v git >/dev/null; then
  cd "$worktree_dir"
  # Mark as safe directory
  git config --global --add safe.directory "$(pwd)"
fi
```

Report: "Worktree created at `$worktree_dir` on branch `$branch`"

### List

```bash
git worktree list
```

Show all worktrees with their branches and status.

### Remove

```bash
branch="<branch-name>"
worktree_path=$(git worktree list | grep "$branch" | awk '{print $1}')

# Check for uncommitted changes
if git -C "$worktree_path" diff --quiet && git -C "$worktree_path" diff --cached --quiet; then
  git worktree remove "$worktree_path"
  echo "Removed worktree for $branch"
else
  echo "WARNING: Worktree has uncommitted changes. Use --force to remove anyway."
fi
```

### Clean

Remove worktrees for branches that have been merged or deleted:

```bash
git worktree list | while read path branch rest; do
  branch_name=$(echo "$branch" | tr -d '[]')
  # Check if branch still exists on remote
  if ! git rev-parse --verify "refs/heads/$branch_name" >/dev/null 2>&1; then
    echo "Stale worktree: $path ($branch_name deleted)"
  fi
done

# After confirmation:
git worktree prune
```

## Branch Safety

- Never create a worktree on main/master
- Warn if the branch already exists (will checkout, not create)
- Always copy .env files to new worktrees
- Check for uncommitted changes before removing

## When to Use

- Parallel feature development
- Testing a fix while keeping current work intact
- Running long tests in isolation
- Code review with full IDE support
