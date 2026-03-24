#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_NAME="long-horizon-planner"
REPO_URL="https://github.com/randomradio/skills.git"
REPO_BRANCH="master"
META_FILE="$SKILL_DIR/.randomradio-skill-meta"
QUIET=0

usage() {
  cat <<USAGE
Usage:
  check_for_updates.sh [--repo-url <url>] [--branch <name>] [--meta-file <path>] [--quiet]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-url)
      REPO_URL="$2"
      shift 2
      ;;
    --branch)
      REPO_BRANCH="$2"
      shift 2
      ;;
    --meta-file)
      META_FILE="$2"
      shift 2
      ;;
    --quiet)
      QUIET=1
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

installed_commit="unknown"
if [[ -f "$META_FILE" ]]; then
  installed_commit="$(grep -E '^INSTALL_COMMIT=' "$META_FILE" | head -n 1 | cut -d= -f2- || true)"
  installed_commit="${installed_commit:-unknown}"
fi

latest_commit="unknown"
if latest_ref="$(git ls-remote "$REPO_URL" "refs/heads/$REPO_BRANCH" 2>/dev/null || true)"; then
  latest_commit="$(echo "$latest_ref" | awk 'NR==1 {print $1}')"
  latest_commit="${latest_commit:-unknown}"
fi

status="unknown"
if [[ "$installed_commit" != "unknown" && "$latest_commit" != "unknown" ]]; then
  if [[ "$installed_commit" == "$latest_commit" ]]; then
    status="up_to_date"
  else
    status="update_available"
  fi
fi

upgrade_base="${CODEX_HOME:-$HOME/.codex}/skills/randomradio-upgrade/scripts/upgrade_skills.sh"

if [[ "$QUIET" -eq 0 ]]; then
  echo "skill=$SKILL_NAME"
  echo "status=$status"
  echo "installed_commit=$installed_commit"
  echo "latest_commit=$latest_commit"
  echo "upgrade_command=$upgrade_base --skills $SKILL_NAME"

  if [[ "$status" == "update_available" ]]; then
    echo "[INFO] Update available for $SKILL_NAME"
  elif [[ "$status" == "up_to_date" ]]; then
    echo "[INFO] $SKILL_NAME is up to date"
  else
    echo "[INFO] Version status unknown (install metadata or network missing)"
  fi
else
  echo "status=$status"
  echo "installed_commit=$installed_commit"
  echo "latest_commit=$latest_commit"
fi
