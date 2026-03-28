#!/usr/bin/env bash
set -euo pipefail

FORCE=0
NON_INTERACTIVE=0
TARGET_DIR=""
PACK_NAME="superpowers"
REPO_URL="https://github.com/randomradio/skills.git"
REPO_BRANCH="master"

usage() {
  cat <<USAGE
Usage:
  install_skill.sh [--target-dir <path>] [--force] [--non-interactive]

Behavior:
- Installs the vendored Superpowers skill pack into the target skills directory
- The destination becomes <target-dir>/superpowers
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
PACK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

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
DEST="$TARGET_DIR/$PACK_NAME"

if [[ -e "$DEST" && "$FORCE" -ne 1 ]]; then
  if [[ "$NON_INTERACTIVE" -eq 1 ]]; then
    echo "Destination already exists: $DEST (use --force)" >&2
    exit 1
  fi
  read -r -p "Pack already exists at $DEST. Overwrite? [y/N]: " yn
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
  rsync -a --exclude '.DS_Store' "$PACK_DIR/" "$DEST/"
else
  cp -R "$PACK_DIR/." "$DEST/"
fi

INSTALL_COMMIT="unknown"
if git -C "$PACK_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  INSTALL_COMMIT="$(git -C "$PACK_DIR" rev-parse HEAD)"
fi

cat > "$DEST/.randomradio-skill-meta" <<EOF_META
SKILL_NAME=$PACK_NAME
INSTALL_COMMIT=$INSTALL_COMMIT
INSTALLED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
REPO_URL=$REPO_URL
REPO_BRANCH=$REPO_BRANCH
EOF_META

cat <<EOF_DONE
Installed vendored Superpowers pack to: $DEST

Next:
1. Restart Codex so it re-discovers the installed pack
2. Use the skills inside the \`superpowers\` namespace or by their folder names, depending on host discovery
EOF_DONE
