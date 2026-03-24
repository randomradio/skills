#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(pwd)"
PLAN_DIR="docs/long-horizon"

usage() {
  cat <<USAGE
Usage:
  validate_long_horizon_workspace.sh [--root <path>] [--dir <relative-path>]

Options:
  --root   Repository root (default: current directory)
  --dir    Planning docs directory relative to root (default: docs/long-horizon)
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

fail() {
  echo "[FAIL] $1" >&2
  exit 1
}

check_file() {
  local path="$1"
  [[ -f "$path" ]] || fail "Missing file: $path"
}

check_heading() {
  local path="$1"
  local pattern="$2"
  grep -Eq "$pattern" "$path" || fail "Missing expected section in $path: $pattern"
}

check_optional_heading() {
  local path="$1"
  local pattern="$2"
  if grep -Eq "$pattern" "$path"; then
    echo "[OK] Optional section present in $path: $pattern"
  fi
}

PROMPT="$TARGET_DIR/Prompt.md"
PLANS="$TARGET_DIR/Plans.md"
IMPLEMENT="$TARGET_DIR/Implement.md"
DOCS="$TARGET_DIR/Documentation.md"

check_file "$PROMPT"
check_file "$PLANS"
check_file "$IMPLEMENT"
check_file "$DOCS"

check_heading "$PROMPT" '^## Objective$'
check_heading "$PROMPT" '^## Acceptance Criteria$'
check_heading "$PLANS" '^## Milestones$'
check_heading "$PLANS" '^## Risk Register$'
check_heading "$IMPLEMENT" '^## Iteration Loop$'
check_heading "$DOCS" '^## Local Setup$'
check_heading "$DOCS" '^## Verification Commands$'
check_optional_heading "$PLANS" '^## Loop Status$'
check_optional_heading "$DOCS" '^## Runtime Execution Notes$'

echo "[OK] Long-horizon planning workspace validated: $TARGET_DIR"
