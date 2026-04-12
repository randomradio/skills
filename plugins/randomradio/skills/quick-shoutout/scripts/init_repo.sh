#!/usr/bin/env bash
set -euo pipefail

APP_NAME=""
APP_TYPE=""
DEV_USER="${USER:-dev}"
REPO_ROOT="$(pwd)"
FORCE=0
NON_INTERACTIVE=0

usage() {
  cat <<USAGE
Usage:
  init_repo.sh --app <name> --type <api|skills|fullstack|stage-dev> [--user <dev-user>] [--repo-root <path>] [--force] [--non-interactive]

Examples:
  init_repo.sh --app notes --type api --repo-root .
  init_repo.sh --app notes --type fullstack --user alice --repo-root .
  init_repo.sh --non-interactive --app notes --type skills
USAGE
}

prompt_if_empty() {
  local var_name="$1"
  local prompt="$2"
  local default_value="${3:-}"
  local current_value
  current_value="${!var_name}"

  if [[ -n "$current_value" ]]; then
    return 0
  fi

  if [[ "$NON_INTERACTIVE" -eq 1 ]]; then
    echo "Missing required argument for non-interactive mode: $var_name" >&2
    exit 1
  fi

  if [[ -n "$default_value" ]]; then
    read -r -p "$prompt [$default_value]: " current_value
    current_value="${current_value:-$default_value}"
  else
    read -r -p "$prompt: " current_value
  fi

  if [[ -z "$current_value" ]]; then
    echo "Value is required: $var_name" >&2
    exit 1
  fi

  printf -v "$var_name" '%s' "$current_value"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app)
      APP_NAME="$2"
      shift 2
      ;;
    --type)
      APP_TYPE="$2"
      shift 2
      ;;
    --user)
      DEV_USER="$2"
      shift 2
      ;;
    --repo-root)
      REPO_ROOT="$2"
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

prompt_if_empty APP_NAME "App name (lowercase, hyphenated)"
prompt_if_empty APP_TYPE "App type (api|skills|fullstack|stage-dev)"
prompt_if_empty DEV_USER "Developer username for dev tunnel" "${USER:-dev}"
prompt_if_empty REPO_ROOT "Repository root path" "$(pwd)"

if ! [[ "$APP_NAME" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "Invalid app name: $APP_NAME (use lowercase letters, digits, and hyphens)" >&2
  exit 1
fi

case "$APP_TYPE" in
  api|skills|fullstack|stage-dev)
    ;;
  *)
    echo "Unsupported --type: $APP_TYPE" >&2
    exit 1
    ;;
esac

REPO_ROOT="$(cd "$REPO_ROOT" && pwd)"
mkdir -p "$REPO_ROOT/.github/workflows" "$REPO_ROOT/cloudflare" "$REPO_ROOT/scripts"

write_file() {
  local target="$1"
  mkdir -p "$(dirname "$target")"

  if [[ -e "$target" && "$FORCE" -ne 1 ]]; then
    echo "skip  $target (already exists; use --force to overwrite)"
    return 1
  fi

  cat > "$target"
  echo "write $target"
  return 0
}

worker_name="${APP_NAME}-api"
api_prod="api.${APP_NAME}.latentvibe.com"
api_staging="api.${APP_NAME}.stg.latentvibe.com"
web_prod="${APP_NAME}.latentvibe.com"
web_staging="${APP_NAME}.stg.latentvibe.com"
pages_project="${APP_NAME}-web"
pages_dist_dir="dist"
build_command="npm run build"

if [[ "$APP_TYPE" == "skills" ]]; then
  web_prod="skills.latentvibe.com"
  web_staging="skills.stg.latentvibe.com"
  pages_project="${APP_NAME}-skills"
fi

if [[ "$APP_TYPE" == "stage-dev" ]]; then
  build_command="none"
fi

write_file "$REPO_ROOT/latentvibe.yml" <<EOF_YAML || true
app_name: $APP_NAME
app_type: $APP_TYPE

worker_name: $worker_name
worker_route_production: $api_prod/*
worker_route_staging: $api_staging/*

pages_project: $pages_project
pages_dist_dir: $pages_dist_dir
pages_domain_production: $web_prod
pages_domain_staging: $web_staging

build_command: $build_command

dev_tunnel_hostname: ${APP_NAME}.${DEV_USER}.dev.latentvibe.com
dev_local_url: http://localhost:3000
EOF_YAML

if [[ "$APP_TYPE" == "api" || "$APP_TYPE" == "fullstack" ]]; then
  write_file "$REPO_ROOT/wrangler.toml" <<EOF_WRANGLER || true
name = "$worker_name"
main = "src/index.ts"
compatibility_date = "2026-03-23"

[env.production]
name = "${worker_name}-production"
routes = ["$api_prod/*"]

[env.staging]
name = "${worker_name}-staging"
routes = ["$api_staging/*"]
EOF_WRANGLER
fi

write_file "$REPO_ROOT/cloudflare/tunnel.dev.yml" <<EOF_TUNNEL || true
tunnel: ${APP_NAME}-dev
credentials-file: ${HOME}/.cloudflared/${APP_NAME}-dev.json

ingress:
  - hostname: ${APP_NAME}.${DEV_USER}.dev.latentvibe.com
    service: http://localhost:3000
  - service: http_status:404
EOF_TUNNEL

write_file "$REPO_ROOT/scripts/publish.sh" <<'EOF_PUBLISH' || true
#!/usr/bin/env bash
set -euo pipefail

TARGET_ENV="${1:-production}"
if [[ "$TARGET_ENV" != "production" && "$TARGET_ENV" != "staging" ]]; then
  echo "Usage: scripts/publish.sh [production|staging]" >&2
  exit 1
fi

if [[ ! -f latentvibe.yml ]]; then
  echo "Missing latentvibe.yml" >&2
  exit 1
fi

config_get() {
  local key="$1"
  local value
  value="$(grep -E "^${key}:" latentvibe.yml | head -n1 | sed -E "s/^${key}:[[:space:]]*//")"
  echo "$value"
}

APP_TYPE="$(config_get app_type)"
PAGES_PROJECT="$(config_get pages_project)"
PAGES_DIST_DIR="$(config_get pages_dist_dir)"
BUILD_COMMAND="$(config_get build_command)"

if [[ "$APP_TYPE" == "api" || "$APP_TYPE" == "fullstack" ]]; then
  npx wrangler deploy --env "$TARGET_ENV"
fi

if [[ "$APP_TYPE" == "skills" || "$APP_TYPE" == "fullstack" ]]; then
  if [[ "$BUILD_COMMAND" != "none" ]]; then
    eval "$BUILD_COMMAND"
  fi

  if [[ ! -d "$PAGES_DIST_DIR" ]]; then
    echo "Missing frontend output directory: $PAGES_DIST_DIR" >&2
    exit 1
  fi

  BRANCH_NAME="$(git rev-parse --abbrev-ref HEAD)"
  npx wrangler pages deploy "$PAGES_DIST_DIR" --project-name "$PAGES_PROJECT" --branch "$BRANCH_NAME"
fi

if [[ "$APP_TYPE" == "stage-dev" ]]; then
  echo "stage-dev type selected: no deploy target configured in publish.sh"
  echo "Use tunnel workflow via: make tunnel-dev"
fi
EOF_PUBLISH
chmod +x "$REPO_ROOT/scripts/publish.sh"

write_file "$REPO_ROOT/Makefile" <<'EOF_MAKE' || true
.PHONY: publish publish-staging tunnel-dev

publish:
	./scripts/publish.sh production

publish-staging:
	./scripts/publish.sh staging

tunnel-dev:
	cloudflared tunnel --config cloudflare/tunnel.dev.yml run
EOF_MAKE

write_file "$REPO_ROOT/.github/workflows/latentvibe-publish.yml" <<'EOF_WORKFLOW' || true
name: latentvibe-publish

on:
  push:
    branches:
      - main
      - staging
  workflow_dispatch:

permissions:
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    env:
      CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
      CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: "22"

      - name: Install dependencies
        run: |
          if [ -f pnpm-lock.yaml ]; then
            corepack enable
            pnpm install --frozen-lockfile
          elif [ -f package-lock.json ]; then
            npm ci
          elif [ -f yarn.lock ]; then
            yarn install --frozen-lockfile
          else
            echo "No lockfile detected; skipping dependency install"
          fi

      - name: Set deploy target
        run: |
          if [ "${GITHUB_REF_NAME}" = "main" ]; then
            echo "TARGET_ENV=production" >> "$GITHUB_ENV"
          else
            echo "TARGET_ENV=staging" >> "$GITHUB_ENV"
          fi

      - name: Publish app
        run: ./scripts/publish.sh "$TARGET_ENV"
EOF_WORKFLOW

cat <<EOF_DONE

Scaffold completed for $APP_NAME ($APP_TYPE).

Next steps:
1. Add GitHub Actions secrets:
   - CLOUDFLARE_ACCOUNT_ID
   - CLOUDFLARE_API_TOKEN
2. Create Cloudflare resources:
   - Worker routes (api/fullstack)
   - Pages project (skills/fullstack)
3. Configure tunnel for dev:
   - cloudflared tunnel login
   - cloudflared tunnel create ${APP_NAME}-dev
   - cloudflared tunnel route dns ${APP_NAME}-dev ${APP_NAME}.${DEV_USER}.dev.latentvibe.com
4. Commit generated files.
EOF_DONE
