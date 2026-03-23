# Secrets And Tokens

Use this checklist when bootstrapping a repo.

## Global CI Secrets (GitHub)

- `CLOUDFLARE_ACCOUNT_ID`: Cloudflare account identifier.
- `CLOUDFLARE_API_TOKEN`: Single-token mode for low friction.

Optional split-token mode:
- `CLOUDFLARE_API_TOKEN_WORKERS`: token used only for Worker deploys.
- `CLOUDFLARE_API_TOKEN_PAGES`: token used only for Pages deploys.
- `CLOUDFLARE_API_TOKEN_DNS`: token used only for DNS automation (if used).

## Recommended Token Scope Design

Prefer least privilege and scope tokens to one account and relevant zone(s).

Single-token mode (quick start):
- Account permissions:
  - Workers Scripts: Edit
  - Cloudflare Pages: Edit
  - Account Settings: Read
- Zone permissions (only where needed):
  - Workers Routes: Edit (for route-based Worker deploys)
  - DNS: Edit (only if CI changes DNS records)

Split-token mode (recommended for long-term):
- Workers token:
  - Account: Workers Scripts Edit, Account Settings Read
  - Zone: Workers Routes Edit
- Pages token:
  - Account: Cloudflare Pages Edit, Account Settings Read
- DNS token (optional):
  - Zone: DNS Edit

## Tunnel Credentials

For named tunnels on developer machines:
- Run `cloudflared tunnel login` once per machine (creates local cert).
- Run `cloudflared tunnel create <name>` to mint tunnel credentials JSON.
- Store credentials file path in `cloudflare/tunnel.dev.yml`.

For remote-managed tunnel runners (CI/server):
- `CLOUDFLARE_TUNNEL_TOKEN` (or service-specific tunnel token).

## App-Type Secret Matrix

API app:
- Required: `CLOUDFLARE_ACCOUNT_ID`, Workers deploy token.
- Optional: DNS token if automation updates DNS.

Skills app:
- Required: `CLOUDFLARE_ACCOUNT_ID`, Pages deploy token.

Fullstack app:
- Required: `CLOUDFLARE_ACCOUNT_ID`, Workers token, Pages token (or one combined token).

Stage/dev app:
- Required for staging CI: same as app type above.
- Required for shared tunnel runtime: tunnel token or machine tunnel credentials.

## Local Developer Prerequisites

- Node.js + package manager used by the repo.
- `wrangler` CLI authenticated via API token environment variables.
- `cloudflared` installed for tunnel workflows.
