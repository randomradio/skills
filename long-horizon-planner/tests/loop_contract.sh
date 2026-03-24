#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL_FILE="$ROOT_DIR/SKILL.md"
RUNBOOK_FILE="$ROOT_DIR/references/loop-runbook.md"
AGENT_FILE="$ROOT_DIR/agents/openai.yaml"
RUNNER_FILE="$ROOT_DIR/scripts/run_long_horizon_loop.sh"
INIT_FILE="$ROOT_DIR/scripts/init_long_horizon_workspace.sh"
VALIDATE_FILE="$ROOT_DIR/scripts/validate_long_horizon_workspace.sh"
CODEX_ADAPTER="$ROOT_DIR/scripts/lib/engines/codex.sh"
CLAUDE_ADAPTER="$ROOT_DIR/scripts/lib/engines/claude.sh"

pass_count=0
fail_count=0

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

expect_executable() {
  local name="$1"
  local file_path="$2"
  if [[ -x "$file_path" ]]; then
    pass "$name"
  else
    fail "$name"
  fi
}

expect_executable "runner script is executable" "$RUNNER_FILE"
expect_executable "codex adapter is executable" "$CODEX_ADAPTER"
expect_executable "claude adapter is executable" "$CLAUDE_ADAPTER"
expect_contains "skill references execution mode" "Execution mode" "$SKILL_FILE"
expect_contains "skill references run script" "run_long_horizon_loop.sh" "$SKILL_FILE"
expect_contains "skill references engine flag" "--engine codex" "$SKILL_FILE"
expect_contains "skill references claude engine" "--engine claude" "$SKILL_FILE"
expect_contains "skill references loop state dir" ".codex/long-horizon-loop" "$SKILL_FILE"
expect_contains "skill references planner sync section" "## Loop Status" "$SKILL_FILE"
expect_contains "runbook includes resume" "--resume" "$RUNBOOK_FILE"
expect_contains "runbook includes stop file" "STOP" "$RUNBOOK_FILE"
expect_contains "agent default prompt references loop" "objective-first" "$AGENT_FILE"
expect_contains "init script includes loop status template" "## Loop Status" "$INIT_FILE"
expect_contains "init script includes runtime notes template" "## Runtime Execution Notes" "$INIT_FILE"
expect_contains "workspace validator recognizes loop status" "check_optional_heading \"\$PLANS\" '^## Loop Status\$'" "$VALIDATE_FILE"

printf '\nLoop contract tests complete: %s passed, %s failed\n' "$pass_count" "$fail_count"

if [[ "$fail_count" -gt 0 ]]; then
  exit 1
fi
