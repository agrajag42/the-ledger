#!/bin/bash
# Deploy stock-proxy Worker to Cloudflare
# Run this OUTSIDE Claude Code sandbox (regular Terminal)
set -e

cd "$(dirname "$0")"

export CLOUDFLARE_API_TOKEN="$(security find-generic-password -a ethanpease -s cloudflare-api-token -w)"

echo "Verifying token..."
curl -s "https://api.cloudflare.com/client/v4/user/tokens/verify" \
  -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" | python3 -m json.tool

echo ""
echo "Deploying worker..."
npx wrangler deploy

echo ""
echo "Done! Your worker URL will be printed above (something like https://stock-proxy.xxx.workers.dev)"
echo "Paste that URL back to Claude so he can update the HTML."
