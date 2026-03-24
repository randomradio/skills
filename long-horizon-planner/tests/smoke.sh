#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/scripts/run_long_horizon_loop.sh"
FIXTURE="$ROOT_DIR/tests/fixtures/codex"
CLAUDE_FIXTURE="$ROOT_DIR/tests/fixtures/claude"
INIT_SCRIPT="$ROOT_DIR/scripts/init_long_horizon_workspace.sh"

pass_count=0
fail_count=0
last_stub_state_dir=""

pass() {
  pass_count=$((pass_count + 1))
  printf '[PASS] %s\n' "$1"
}

fail() {
  fail_count=$((fail_count + 1))
  printf '[FAIL] %s\n' "$1" >&2
}

contains_fixed() {
  local pattern="$1"
  local file_path="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q --fixed-strings -- "$pattern" "$file_path"
  else
    grep -Fq -- "$pattern" "$file_path"
  fi
}

expect_success() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

expect_contains() {
  local name="$1"
  local pattern="$2"
  local file_path="$3"
  if contains_fixed "$pattern" "$file_path"; then
    pass "$name"
  else
    fail "$name"
  fi
}

quietly() {
  "$@" >/dev/null 2>&1
}

make_repo() {
  local repo_dir="$1"
  mkdir -p "$repo_dir"
  git -C "$repo_dir" init -q
  git -C "$repo_dir" config user.email "smoke@example.com"
  git -C "$repo_dir" config user.name "Smoke"
  printf 'initial\n' > "$repo_dir/README.md"
  git -C "$repo_dir" add README.md
  git -C "$repo_dir" commit -qm "init"

  "$INIT_SCRIPT" --root "$repo_dir" >/dev/null

  cat > "$repo_dir/docs/long-horizon/Prompt.md" <<'EOF_PROMPT'
# Prompt

Last updated: 2026-03-24

## Objective
- Implement feature X with tests and ship-ready quality.

## Why This Matters
- Enables long-horizon delivery confidence.

## Acceptance Criteria
- [ ] The requested behavior is implemented.
- [ ] Verification confirms shippable state.
EOF_PROMPT
}

run_loop() {
  local scenario="$1"
  shift
  last_stub_state_dir="$tmp_dir/stub-$RANDOM-$RANDOM"
  CODEX_STUB_SCENARIO="$scenario" \
    CODEX_STUB_STATE_DIR="$last_stub_state_dir" \
    "$SCRIPT" --codex-bin "$FIXTURE" "$@"
}

run_loop_claude() {
  local scenario="$1"
  shift
  last_stub_state_dir="$tmp_dir/stub-claude-$RANDOM-$RANDOM"
  CODEX_STUB_SCENARIO="$scenario" \
    CODEX_STUB_STATE_DIR="$last_stub_state_dir" \
    "$SCRIPT" --engine-bin "$CLAUDE_FIXTURE" "$@"
}

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

expect_success "runner script is executable" test -x "$SCRIPT"
expect_success "runner help works" quietly "$SCRIPT" --help

repo_complete="$tmp_dir/repo-complete"
state_complete="$repo_complete/.codex/long-horizon-loop"
make_repo "$repo_complete"
expect_success "complete run succeeds" quietly run_loop review_ship_complete --cwd "$repo_complete" --engine codex --max-iterations 2 --progress-scope .
expect_contains "complete stop reason recorded" "task_complete" "$state_complete/run-summary.md"
expect_success "complete marker exists" test -f "$state_complete/.loop-complete"
expect_contains "review result is SHIP" "SHIP" "$state_complete/review-result.txt"
expect_contains "planner loop status synced" "Stop reason: task_complete" "$repo_complete/docs/long-horizon/Plans.md"
expect_contains "documentation runtime notes synced" "Reviewer outcome: SHIP" "$repo_complete/docs/long-horizon/Documentation.md"

repo_claude="$tmp_dir/repo-claude"
state_claude="$repo_claude/.codex/long-horizon-loop"
make_repo "$repo_claude"
expect_success "claude engine complete run succeeds" quietly run_loop_claude review_ship_complete --cwd "$repo_claude" --engine claude --max-iterations 2 --progress-scope .
expect_contains "claude engine stop reason recorded" "task_complete" "$state_claude/run-summary.md"
expect_contains "claude engine review result is SHIP" "SHIP" "$state_claude/review-result.txt"

repo_blocked="$tmp_dir/repo-blocked"
state_blocked="$repo_blocked/.codex/long-horizon-loop"
make_repo "$repo_blocked"
expect_success "blocked run stops as blocked" quietly run_loop blocked_confirmed --cwd "$repo_blocked" --engine codex --max-iterations 2 --progress-scope .
expect_contains "blocked stop reason recorded" "task_blocked" "$state_blocked/run-summary.md"
expect_success "blocked marker exists" test -f "$state_blocked/RALPH-BLOCKED.md"

repo_noop="$tmp_dir/repo-noop"
state_noop="$repo_noop/.codex/long-horizon-loop"
make_repo "$repo_noop"
expect_success "no-op without justification is blocked by progress gate" quietly run_loop review_ship_nochange --cwd "$repo_noop" --engine codex --max-iterations 1 --progress-scope .
expect_contains "progress gate block event logged" "progress_gate_block" "$state_noop/events.log"
expect_contains "no-op run stops at max iterations" "max_iterations_reached" "$state_noop/run-summary.md"

repo_resume="$tmp_dir/repo-resume"
state_resume="$repo_resume/.codex/long-horizon-loop"
make_repo "$repo_resume"
expect_success "timeout run leaves resumable state" quietly run_loop always_timeout --cwd "$repo_resume" --engine codex --max-iterations 1 --idle-timeout-seconds 1 --hard-timeout-seconds 2 --timeout-retries 0
expect_success "resume run completes" quietly run_loop review_ship_complete --cwd "$repo_resume" --engine codex --resume --max-iterations 2 --idle-timeout-seconds 10 --hard-timeout-seconds 30
expect_contains "resume completion stop reason" "task_complete" "$state_resume/run-summary.md"

printf '\nSmoke tests complete: %s passed, %s failed\n' "$pass_count" "$fail_count"

if [[ "$fail_count" -gt 0 ]]; then
  exit 1
fi
