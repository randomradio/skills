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
| Cloudflare proxy | DNS only |
| HTTPS | Enabled after GitHub certificate issuance |

## GitHub Pages Setup

1. Open `https://github.com/randomradio/skills/settings/pages`.
2. In **Build and deployment**, set **Source** to **GitHub Actions**.
3. In **Custom domain**, enter `skills.icyzhao.com` and save.
4. Do not add a committed `CNAME` file for this workflow. GitHub stores the
   custom domain setting for Actions-based Pages publishing.
5. Expect GitHub to show DNS check or certificate issuance as pending for a few
   minutes after DNS changes.

## Cloudflare DNS Setup

1. Open the Cloudflare zone for `icyzhao.com`.
2. Go to **DNS -> Records**.
3. Add or update:

```text
Type: CNAME
Name: skills
Target: randomradio.github.io
Proxy status: DNS only
TTL: Auto
```

Use **DNS only** for GitHub Pages validation. Proxied records can delay or break
GitHub's custom-domain and certificate checks.

## DNS Verification

Use the fastest available method:

```bash
dig +time=3 +tries=1 +short CNAME skills.icyzhao.com
curl -fsS --max-time 10 'https://dns.google/resolve?name=skills.icyzhao.com&type=CNAME'
curl -fsS --max-time 10 'https://cloudflare-dns.com/dns-query?name=skills.icyzhao.com&type=CNAME' -H 'accept: application/dns-json'
```

Expected CNAME:

```text
randomradio.github.io.
```

If direct `dig @1.1.1.1` or `dig @8.8.8.8` times out from the current network
but DNS-over-HTTPS succeeds, treat the public DNS record as visible and note the
local network limitation.

## HTTPS Follow-Up

GitHub may show:

- `DNS Check in Progress`
- `DNS check unsuccessful` while caches update
- `certificate has not yet been issued`

If DNS-over-HTTPS already returns the correct CNAME, wait and re-run **Check
again** in GitHub Pages settings. Enable **Enforce HTTPS** once GitHub makes the
checkbox available.
