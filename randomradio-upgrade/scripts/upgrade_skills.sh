#!/usr/bin/env bash
set -euo pipefail

# Upgrade randomradio plugin across platforms.
# Supports: Claude Code (native plugin), Codex (flat skills dir), both, or auto-detect.

REPO_URL="https://github.com/randomradio/skills.git"
REPO_BRANCH="master"
CACHE_DIR="$HOME/.cache/randomradio-skills/repo"
PLUGIN_DIR="plugins/randomradio"
TARGET=""        # claude, codex, all, or auto (default)
CODEX_DIR=""     # explicit codex skills dir
DRY_RUN=0
VERBOSE=0

usage() {
  cat <<USAGE
Usage:
  upgrade_skills.sh [options]

Options:
  --target <target>     Target platform: claude, codex, all, auto (default: auto)
  --codex-dir <path>    Explicit Codex skills directory
  --repo-url <url>      Git repo URL (default: $REPO_URL)
  --branch <name>       Git branch (default: $REPO_BRANCH)
  --cache-dir <path>    Local cache directory
  --dry-run             Show what would happen without making changes
  --verbose             Show detailed output
  -h, --help            Show this help

Targets:
  auto    Detect installed platforms and upgrade all found
  claude  Claude Code only (plugin update)
  codex   Codex only (flat skills copy)
  all     All supported platforms
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)     TARGET="$2";    shift 2 ;;
    --codex-dir)  CODEX_DIR="$2"; shift 2 ;;
    --repo-url)   REPO_URL="$2";  shift 2 ;;
    --branch)     REPO_BRANCH="$2"; shift 2 ;;
    --cache-dir)  CACHE_DIR="$2"; shift 2 ;;
    --dry-run)    DRY_RUN=1;      shift ;;
    --verbose)    VERBOSE=1;      shift ;;
    -h|--help)    usage; exit 0 ;;
    *)            echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

# --- Helpers ---

log()  { echo "[INFO] $*"; }
warn() { echo "[WARN] $*" >&2; }
dry()  { echo "[DRY]  $*"; }
verb() { [[ "$VERBOSE" -eq 1 ]] && echo "       $*" || true; }

has_claude() { command -v claude >/dev/null 2>&1; }
has_codex()  { command -v codex >/dev/null 2>&1 || [[ -d "$HOME/.codex/skills" ]]; }

# --- Step 1: Refresh cache ---

refresh_cache() {
  mkdir -p "$(dirname "$CACHE_DIR")"

  # Safety: if cache-dir has unpushed commits, use it as-is (local dev mode)
  if [[ -d "$CACHE_DIR/.git" ]]; then
    local ahead
    ahead="$(git -C "$CACHE_DIR" rev-list --count "origin/$REPO_BRANCH"..HEAD 2>/dev/null || echo 0)"
    if [[ "$ahead" -gt 0 ]]; then
      log "Local repo has $ahead unpushed commits — using as-is (no reset)"
      log "Commit: $(git -C "$CACHE_DIR" rev-parse --short HEAD)"
      return
    fi
  fi

  if [[ ! -d "$CACHE_DIR/.git" ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      dry "Would clone $REPO_URL -> $CACHE_DIR"
      return
    fi
    log "Cloning $REPO_URL -> $CACHE_DIR"
    git clone --depth 1 --branch "$REPO_BRANCH" "$REPO_URL" "$CACHE_DIR"
  else
    if [[ "$DRY_RUN" -eq 1 ]]; then
      dry "Would refresh cache at $CACHE_DIR"
      return
    fi
    log "Refreshing cache at $CACHE_DIR"
    git -C "$CACHE_DIR" fetch origin "$REPO_BRANCH" --depth 1
    git -C "$CACHE_DIR" checkout "$REPO_BRANCH" 2>/dev/null
    git -C "$CACHE_DIR" reset --hard "origin/$REPO_BRANCH"
  fi

  log "Commit: $(git -C "$CACHE_DIR" rev-parse --short HEAD)"
}

# --- Step 2: Claude Code upgrade ---

upgrade_claude() {
  log "=== Claude Code ==="

  if ! has_claude; then
    warn "Claude Code CLI not found, skipping"
    return
  fi

  # Check if marketplace is registered
  if ! claude plugin marketplace list 2>/dev/null | grep -q "randomradio-plugins"; then
    log "Registering local marketplace..."
    if [[ "$DRY_RUN" -eq 1 ]]; then
      dry "Would run: claude plugin marketplace add $CACHE_DIR/plugins"
    else
      claude plugin marketplace add "$CACHE_DIR/plugins" 2>/dev/null || true
    fi
  fi

  # Update marketplace to pick up new skills
  if [[ "$DRY_RUN" -eq 1 ]]; then
    dry "Would run: claude plugin marketplace update randomradio-plugins"
    dry "Would run: claude plugin update randomradio"
  else
    log "Updating marketplace..."
    claude plugin marketplace update randomradio-plugins 2>/dev/null || true

    # Install or update
    if claude plugin list 2>/dev/null | grep -q "randomradio@"; then
      log "Updating plugin..."
      claude plugin update randomradio 2>/dev/null || warn "Plugin update failed (may need restart)"
    else
      log "Installing plugin..."
      claude plugin install randomradio 2>/dev/null || warn "Plugin install failed"
    fi
  fi

  log "Claude Code: done"
}

# --- Step 3: Codex upgrade ---
# Codex uses flat skills dirs: ~/.codex/skills/<skill-name>/SKILL.md
# Both skills and agents get flattened into the same namespace.

upgrade_codex() {
  log "=== Codex ==="

  local codex_skills="$CODEX_DIR"
  if [[ -z "$codex_skills" ]]; then
    if [[ -n "${CODEX_HOME:-}" && -d "${CODEX_HOME}/skills" ]]; then
      codex_skills="${CODEX_HOME}/skills"
    elif [[ -d "$HOME/.codex/skills" ]]; then
      codex_skills="$HOME/.codex/skills"
    else
      codex_skills="$HOME/.codex/skills"
    fi
  fi

  codex_skills="$(mkdir -p "$codex_skills" && cd "$codex_skills" && pwd)"
  log "Target: $codex_skills"

  local plugin_root="$CACHE_DIR/$PLUGIN_DIR"
  if [[ ! -d "$plugin_root" ]]; then
    warn "Plugin directory not found at $plugin_root"
    return
  fi

  local count=0

  # Install skills: plugins/randomradio/skills/<name>/SKILL.md -> ~/.codex/skills/<name>/SKILL.md
  for skill_dir in "$plugin_root"/skills/*/; do
    [[ -d "$skill_dir" ]] || continue
    local name
    name="$(basename "$skill_dir")"
    local dest="$codex_skills/$name"

    if [[ "$DRY_RUN" -eq 1 ]]; then
      dry "Would install skill: $name -> $dest"
    else
      verb "Installing skill: $name"
      rm -rf "$dest"
      mkdir -p "$dest"
      if command -v rsync >/dev/null 2>&1; then
        rsync -a --exclude '.DS_Store' "$skill_dir" "$dest/"
      else
        cp -R "$skill_dir." "$dest/"
      fi
      # Rewrite rr: prefix out of SKILL.md name for Codex compatibility
      if [[ -f "$dest/SKILL.md" ]]; then
        sed -i '' 's/^name: rr:/name: rr-/' "$dest/SKILL.md" 2>/dev/null || true
      fi
    fi
    count=$((count + 1))
  done

  # Install agents: plugins/randomradio/agents/<category>/<name>.md -> ~/.codex/skills/<name>/SKILL.md
  for agent_file in "$plugin_root"/agents/*/*.md; do
    [[ -f "$agent_file" ]] || continue
    local name
    name="$(basename "$agent_file" .md)"
    local dest="$codex_skills/$name"

    if [[ "$DRY_RUN" -eq 1 ]]; then
      dry "Would install agent: $name -> $dest"
    else
      verb "Installing agent: $name"
      rm -rf "$dest"
      mkdir -p "$dest"
      cp "$agent_file" "$dest/SKILL.md"
    fi
    count=$((count + 1))
  done

  if [[ "$DRY_RUN" -eq 1 ]]; then
    dry "Would install $count items to $codex_skills"
  else
    log "Installed $count items to $codex_skills"
  fi

  log "Codex: done"
}

# --- Step 4: Self-upgrade ---
# Copy randomradio-upgrade itself into the target

upgrade_self() {
  local self_dir
  self_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  local cache_self="$CACHE_DIR/randomradio-upgrade"

  if [[ -d "$cache_self" && "$DRY_RUN" -eq 0 ]]; then
    log "Self-updating randomradio-upgrade..."
    if command -v rsync >/dev/null 2>&1; then
      rsync -a --exclude '.DS_Store' "$cache_self/" "$self_dir/"
    else
      cp -R "$cache_self/." "$self_dir/"
    fi
  fi
}

# --- Main ---

log "RandomRadio Upgrade"
log "Repo: $REPO_URL ($REPO_BRANCH)"

# Refresh cache
refresh_cache

# Detect targets
if [[ -z "$TARGET" || "$TARGET" == "auto" ]]; then
  targets=()
  has_claude && targets+=("claude")
  has_codex  && targets+=("codex")
  if [[ "${#targets[@]}" -eq 0 ]]; then
    warn "No supported platforms detected"
    exit 1
  fi
  log "Auto-detected: ${targets[*]}"
elif [[ "$TARGET" == "all" ]]; then
  targets=("claude" "codex")
else
  targets=("$TARGET")
fi

# Run upgrades
for t in "${targets[@]}"; do
  case "$t" in
    claude) upgrade_claude ;;
    codex)  upgrade_codex ;;
    *)      warn "Unknown target: $t" ;;
  esac
done

# Self-upgrade
upgrade_self

if [[ "$DRY_RUN" -eq 1 ]]; then
  log "Dry run complete"
else
  log "Upgrade complete"
fi
