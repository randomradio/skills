#!/usr/bin/env bash
set -euo pipefail

FORCE=0
NON_INTERACTIVE=0
TARGET_DIR=""
SKILL_NAME="long-horizon-planner"

usage() {
  cat <<USAGE
Usage:
  install_skill.sh [--target-dir <path>] [--force] [--non-interactive]

Behavior:
- If --target-dir is omitted, auto-picks first existing skills directory from:
  1) \$CODEX_HOME/skills
  2) ~/.codex/skills
  3) ~/.claude/skills
- If none exists, defaults to ~/.codex/skills
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-dir)
      TARGET_DIR="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --non-interactive)
      NON_INTERACTIVE=1
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

if [[ "$NON_INTERACTIVE" -ne 1 && ! -t 0 ]]; then
  NON_INTERACTIVE=1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ -z "$TARGET_DIR" ]]; then
  candidates=()
  if [[ -n "${CODEX_HOME:-}" ]]; then
    candidates+=("${CODEX_HOME}/skills")
  fi
  candidates+=("$HOME/.codex/skills" "$HOME/.claude/skills")

  for c in "${candidates[@]}"; do
    if [[ -d "$c" ]]; then
      TARGET_DIR="$c"
      break
    fi
  done

  if [[ -z "$TARGET_DIR" ]]; then
    TARGET_DIR="$HOME/.codex/skills"
  fi
fi

TARGET_DIR="$(mkdir -p "$TARGET_DIR" && cd "$TARGET_DIR" && pwd)"
DEST="$TARGET_DIR/$SKILL_NAME"

if [[ -e "$DEST" && "$FORCE" -ne 1 ]]; then
  if [[ "$NON_INTERACTIVE" -eq 1 ]]; then
    echo "Destination already exists: $DEST (use --force)" >&2
    exit 1
  fi
  read -r -p "Skill already exists at $DEST. Overwrite? [y/N]: " yn
  if [[ "$yn" != "y" && "$yn" != "Y" ]]; then
    echo "Aborted"
    exit 1
  fi
  FORCE=1
fi

if [[ -e "$DEST" && "$FORCE" -eq 1 ]]; then
  rm -rf "$DEST"
fi

mkdir -p "$DEST"

if command -v rsync >/dev/null 2>&1; then
  rsync -a --exclude '.DS_Store' "$SKILL_DIR/" "$DEST/"
else
  cp -R "$SKILL_DIR/." "$DEST/"
fi

cat <<EOF_DONE
Installed skill to: $DEST

Next:
1. Use the skill by name: long-horizon-planner
2. In a repo, scaffold plan docs:
   $DEST/scripts/init_long_horizon_workspace.sh --root .
EOF_DONE
