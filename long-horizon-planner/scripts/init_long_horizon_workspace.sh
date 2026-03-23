#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"
PLAN_DIR="docs/long-horizon"
FORCE=0

usage() {
  cat <<USAGE
Usage:
  init_long_horizon_workspace.sh [--root <path>] [--dir <relative-path>] [--force]

Options:
  --root   Repository root (default: current directory)
  --dir    Planning docs directory relative to root (default: docs/long-horizon)
  --force  Overwrite existing planning files
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$2"
      shift 2
      ;;
    --dir)
      PLAN_DIR="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

ROOT_DIR="$(cd "$ROOT_DIR" && pwd)"
TARGET_DIR="$ROOT_DIR/$PLAN_DIR"
mkdir -p "$TARGET_DIR"

write_file() {
  local path="$1"

  if [[ -e "$path" && "$FORCE" -ne 1 ]]; then
    echo "skip  $path (already exists; use --force to overwrite)"
    return 1
  fi

  cat > "$path"
  echo "write $path"
  return 0
}

TODAY="$(date +%F)"

write_file "$TARGET_DIR/Prompt.md" <<EOF_PROMPT || true
# Prompt

Last updated: $TODAY

## Objective
- [Fill in the concrete outcome]

## Why This Matters
- [Describe business/user impact]

## Acceptance Criteria
- [ ] [User-visible behavior]
- [ ] [Engineering quality bar]
- [ ] [Ship-readiness bar]

## Scope
In scope:
- [ ] [In-scope item 1]
- [ ] [In-scope item 2]

Out of scope:
- [ ] [Out-of-scope item 1]
- [ ] [Out-of-scope item 2]

## Constraints
- Environment:
- Tooling:
- Time:
- Compliance/security:

## Assumptions and Unknowns
Assumptions:
- [ ] [Assumption 1]

Unknowns:
- [ ] [Unknown 1]
EOF_PROMPT

write_file "$TARGET_DIR/Plans.md" <<EOF_PLANS || true
# Plans

Last updated: $TODAY

## Verification Checklist
- [ ] lint
- [ ] typecheck
- [ ] tests
- [ ] build
- [ ] scenario/manual verification

## Milestones

### Milestone 01 - [Name]
Scope:
- [ ] [Concrete slice of work]

Key files/modules:
- [path/to/file]

Acceptance criteria:
- [ ] [Outcome]

Verification commands:
- [command]

Status:
- [ ] not started
- [ ] in progress
- [ ] complete

### Milestone 02 - [Name]
Scope:
- [ ] [Concrete slice of work]

Key files/modules:
- [path/to/file]

Acceptance criteria:
- [ ] [Outcome]

Verification commands:
- [command]

Status:
- [ ] not started
- [ ] in progress
- [ ] complete

### Milestone 03 - [Name]
Scope:
- [ ] [Concrete slice of work]

Key files/modules:
- [path/to/file]

Acceptance criteria:
- [ ] [Outcome]

Verification commands:
- [command]

Status:
- [ ] not started
- [ ] in progress
- [ ] complete

## Risk Register
- Risk: [risk statement]
  Impact: [high|medium|low]
  Mitigation: [plan]

## Decision Log
- $TODAY: [Decision], reason: [Reason]

## Next Milestone
- [Current milestone owner + next action]
EOF_PLANS

write_file "$TARGET_DIR/Implement.md" <<EOF_IMPLEMENT || true
# Implement

Last updated: $TODAY

## Execution Contract
- Do not pause after each milestone for confirmation unless blocked.
- Treat Prompt.md and Plans.md as source of truth.
- If scope changes, update Plans.md before continuing.

## Iteration Loop
1. Pick the highest-priority incomplete milestone.
2. Implement the smallest coherent change to satisfy milestone acceptance.
3. Run milestone verification commands.
4. Fix failures immediately.
5. Update Plans.md status and decision log.
6. Continue to the next milestone.

## Bug Handling
1. Reproduce with a focused test when possible.
2. Implement minimal fix.
3. Re-run relevant verification.
4. Record bug and fix note in Plans.md.

## Blocked Protocol
When blocked:
- Record blocker and attempted mitigations in Plans.md.
- Propose one unblocking path with concrete next action.
- Continue with parallel non-blocked milestones when possible.

## Stop Conditions
Stop only when all are true:
- Milestones marked complete.
- Verification checklist fully green.
- Documentation reflects shipped behavior.
EOF_IMPLEMENT

write_file "$TARGET_DIR/Documentation.md" <<EOF_DOCS || true
# Documentation

Last updated: $TODAY

## What This Project Delivers
- [Short product/feature summary]

## Local Setup
- Prerequisites:
- Install:
- Start:

## Verification Commands
- Lint:
- Typecheck:
- Tests:
- Build:

## Architecture Snapshot
- Core modules:
- Data flow:
- Operational constraints:

## Milestone Status
- Milestone 01:
- Milestone 02:
- Milestone 03:

## Troubleshooting
- Issue: [symptom]
  Fix: [resolution]
EOF_DOCS

cat <<EOF_DONE

Long-horizon planning workspace initialized at:
  $TARGET_DIR

Files:
- Prompt.md
- Plans.md
- Implement.md
- Documentation.md

Next:
1. Fill Prompt.md objective and acceptance criteria.
2. Expand Plans.md milestones and verification commands.
3. Start implementation with Implement.md as the operating contract.
EOF_DONE
