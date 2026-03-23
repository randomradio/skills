# Domain Contract

Use this fixed naming model so every repo behaves identically.

## Hostname Layout

- Root site: `latentvibe.com` and `www.latentvibe.com`
- Per-app frontend (production): `<app>.latentvibe.com`
- Per-app API (production): `api.<app>.latentvibe.com`
- Per-app frontend (staging): `<app>.stg.latentvibe.com`
- Per-app API (staging): `api.<app>.stg.latentvibe.com`
- Developer tunnel hostname: `<app>.<user>.dev.latentvibe.com`
- Shared skills catalog: `skills.latentvibe.com`

## Branch Contract

- `main` -> production
- `staging` -> staging
- `feat/*` -> preview URL only

## DNS Guidance

- Use explicit DNS records for production/staging hostnames.
- Use wildcard DNS only for dev tunnel hostnames if needed (for example `*.dev.latentvibe.com`).
- Keep specific records for production hostnames so they always override wildcard behavior.

## Cloudflare Platform Constraints

- Cloudflare Pages custom domains do not support wildcard custom domains.
- Cloudflare Workers custom domains do not support wildcard matching.
- Cloudflare Workers Routes can still use wildcard route patterns.

## Security Defaults

- Protect `*.stg.latentvibe.com` and `*.dev.latentvibe.com` with Cloudflare Access.
- Keep public production hostnames open unless the app is private.
- Enforce HTTPS for all hostnames.
