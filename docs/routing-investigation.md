# Figuring Out ethanpease.com Routing

## The Problem

`ethanpease.com` routes paths to different Cloud Run services (e.g. `/travel/2026/europe` -> `travel-europe-2026` Cloud Run service). We need to add a route for `/friends/ledger` -> `the-ledger` Cloud Run service. But the routing mechanism is unknown.

## The New Service (Ready to Go)

- **Cloud Run service:** `the-ledger` in `us-west1` on `punchline-ethan-20260308`
- **Cloud Run URL:** `https://the-ledger-549200120767.us-west1.run.app`
- **Target path:** `/friends/ledger`

## Investigation Steps

### 1. Check Cloudflare (most likely)

You already use Cloudflare for the stock-proxy Worker. The domain is probably managed there.

```bash
# Log into Cloudflare dashboard: https://dash.cloudflare.com
# Look for:
#   - DNS records for ethanpease.com (is it proxied through CF?)
#   - Workers Routes (is there a Worker doing path-based routing?)
#   - Redirect Rules or Transform Rules
#   - Page Rules
```

If there's a **Cloudflare Worker** doing routing, you'd add a route like:
```
ethanpease.com/friends/ledger/* -> https://the-ledger-549200120767.us-west1.run.app
```

If it's **DNS + Cloud Run direct** (CNAME to Cloud Run), that only works for one service per domain, so there must be a proxy layer.

### 2. Check DNS

```bash
# From a non-Apple-sandbox terminal:
dig ethanpease.com
dig ethanpease.com CNAME
dig ethanpease.com NS

# If nameservers are *.ns.cloudflare.com -> Cloudflare manages DNS
# If CNAME points to *.run.app -> direct Cloud Run mapping
```

### 3. Check Cloudflare API (from unsandboxed terminal)

```bash
CF_TOKEN="$(security find-generic-password -a ethanpease -s cloudflare-api-token -w)"

# List zones
curl -s "https://api.cloudflare.com/client/v4/zones" \
  -H "Authorization: Bearer $CF_TOKEN" | python3 -m json.tool

# If ethanpease.com zone found, get its ID, then:
ZONE_ID="<from above>"

# List DNS records
curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
  -H "Authorization: Bearer $CF_TOKEN" | python3 -m json.tool

# List Workers routes
curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/workers/routes" \
  -H "Authorization: Bearer $CF_TOKEN" | python3 -m json.tool
```

### 4. Once You Find the Routing Mechanism

**If Cloudflare Worker route:** Add a new route mapping `ethanpease.com/friends/ledger/*` to the Cloud Run backend, either in the existing Worker or as a new route.

**If Cloudflare redirect/transform rules:** Add a rule for `/friends/ledger/*` proxying to the Cloud Run URL.

**If something else entirely:** Document it in `/Developer/personal/CLAUDE.md` so we know for next time.

## What's Already Done

- Cloud Run service `the-ledger` is deployed and serving
- Nginx is configured to serve the HTML at `/friends/ledger/`
- Code is on `github.com/agrajag42/the-ledger`
