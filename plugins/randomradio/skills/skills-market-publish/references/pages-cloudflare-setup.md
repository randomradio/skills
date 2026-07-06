# GitHub Pages and Cloudflare Setup

Use this reference for the one-time hosting setup or repair path for
`skills.icyzhao.com`.

## Target State

| Surface | Value |
|---|---|
| Repository | `randomradio/skills` |
| Pages source | GitHub Actions |
| Site artifact | `site/` uploaded by `.github/workflows/skills-market.yml` |
| Custom domain | `skills.icyzhao.com` |
| DNS record | `CNAME skills -> randomradio.github.io` |
| Cloudflare proxy | Proxied |
| Cloudflare SSL/TLS mode | Full |
| HTTPS | Cloudflare edge HTTPS, with HTTP redirected to HTTPS |

## GitHub Pages Setup

1. Open `https://github.com/randomradio/skills/settings/pages`.
2. In **Build and deployment**, set **Source** to **GitHub Actions**.
3. In **Custom domain**, enter `skills.icyzhao.com` and save.
4. Do not add a committed `CNAME` file for this workflow. GitHub stores the
   custom domain setting for Actions-based Pages publishing.
5. GitHub's native certificate status may stay pending or unavailable when
   Cloudflare is proxied. Treat the public `https://skills.icyzhao.com/` result
   as the production HTTPS gate.

## Cloudflare DNS Setup

1. Open the Cloudflare zone for `icyzhao.com`.
2. Go to **DNS -> Records**.
3. Add or update:

```text
Type: CNAME
Name: skills
Target: randomradio.github.io
Proxy status: Proxied
TTL: Auto
```

Keep the zone's **SSL/TLS encryption mode** on **Full**. Do not change the
zone-wide mode unless the task explicitly calls for it; this setting affects all
proxied hostnames in the zone.

Use **DNS only** only as a temporary repair mode when you specifically need
GitHub to re-run native custom-domain or certificate validation. Switch back to
**Proxied** after the validation or repair step so Cloudflare serves HTTPS for
the public market.

## DNS Verification

Use the fastest available method:

```bash
dig +time=3 +tries=1 +short CNAME skills.icyzhao.com
curl -fsS --max-time 10 'https://dns.google/resolve?name=skills.icyzhao.com&type=CNAME'
curl -fsS --max-time 10 'https://cloudflare-dns.com/dns-query?name=skills.icyzhao.com&type=CNAME' -H 'accept: application/dns-json'
```

When the record is **DNS only**, the expected CNAME is:

```text
randomradio.github.io.
```

When the record is **Proxied**, public DNS should return Cloudflare edge
addresses instead of the origin CNAME:

```bash
curl -fsS --max-time 10 'https://dns.google/resolve?name=skills.icyzhao.com&type=A'
```

If direct `dig @1.1.1.1` or `dig @8.8.8.8` times out from the current network
but DNS-over-HTTPS succeeds, treat the public DNS record as visible and note the
local network limitation.

## HTTPS Verification

Verify the public behavior, not just the GitHub settings page:

```bash
curl -I --max-time 30 https://skills.icyzhao.com/
curl -I --max-time 30 http://skills.icyzhao.com/
```

Expected result:

- `https://skills.icyzhao.com/` returns `HTTP/2 200` with `server: cloudflare`.
- `http://skills.icyzhao.com/` redirects to `https://skills.icyzhao.com/`.

GitHub may still show:

- `DNS Check in Progress`
- `DNS check unsuccessful`
- `certificate has not yet been issued`

Those GitHub-native HTTPS states are not blockers when Cloudflare proxied HTTPS
is verified externally. If you want GitHub's **Enforce HTTPS** checkbox enabled
too, temporarily set the Cloudflare record to **DNS only**, wait for GitHub's
certificate to issue, enable the checkbox, then decide whether to return the
record to **Proxied** for Cloudflare edge delivery.
