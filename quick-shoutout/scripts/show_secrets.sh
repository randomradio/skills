#!/usr/bin/env bash
set -euo pipefail

TYPE="fullstack"

usage() {
  cat <<USAGE
Usage:
  show_secrets.sh --type <api|skills|fullstack|stage-dev>

Examples:
  show_secrets.sh --type api
  show_secrets.sh --type fullstack
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --type)
      TYPE="$2"
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

print_common() {
  cat <<'COMMON'
Common required secrets:
- CLOUDFLARE_ACCOUNT_ID

Recommended token strategy:
- Start with one token for speed: CLOUDFLARE_API_TOKEN
- Move to split tokens later for least privilege:
  - CLOUDFLARE_API_TOKEN_WORKERS
  - CLOUDFLARE_API_TOKEN_PAGES
  - CLOUDFLARE_API_TOKEN_DNS (only if automation edits DNS)
COMMON
}

case "$TYPE" in
  api)
    print_common
    cat <<'EOF_API'

API app secrets:
- Required:
  - CLOUDFLARE_API_TOKEN or CLOUDFLARE_API_TOKEN_WORKERS
- Optional:
  - CLOUDFLARE_API_TOKEN_DNS

Token permissions:
- Account: Workers Scripts Edit, Account Settings Read
- Zone: Workers Routes Edit
- Zone (optional): DNS Edit
EOF_API
    ;;
  skills)
    print_common
    cat <<'EOF_SKILLS'

Skills app secrets:
- Required:
  - CLOUDFLARE_API_TOKEN or CLOUDFLARE_API_TOKEN_PAGES

Token permissions:
- Account: Cloudflare Pages Edit, Account Settings Read
EOF_SKILLS
    ;;
  fullstack)
    print_common
    cat <<'EOF_FULL'

Fullstack app secrets:
- Required:
  - Workers deploy token
  - Pages deploy token
- Optional:
  - DNS token if CI edits records

Token permissions:
- Workers token:
  - Account: Workers Scripts Edit, Account Settings Read
  - Zone: Workers Routes Edit
- Pages token:
  - Account: Cloudflare Pages Edit, Account Settings Read
- DNS token (optional):
  - Zone: DNS Edit
EOF_FULL
    ;;
  stage-dev)
    print_common
    cat <<'EOF_STAGE'

Stage/dev extras:
- Required for shared tunnel service:
  - CLOUDFLARE_TUNNEL_TOKEN
- Required for machine-local tunnel:
  - cloudflared tunnel login (local cert)
  - tunnel credentials JSON file

Recommended:
- Protect *.stg.latentvibe.com and *.dev.latentvibe.com with Cloudflare Access policies.
EOF_STAGE
    ;;
  *)
    echo "Unsupported type: $TYPE" >&2
    usage
    exit 1
    ;;
esac
