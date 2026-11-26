#!/usr/bin/env bash
# On oleg_vm: user artem writes snippet, user work runs this script.
set -eu
SNIP="${1:-}"
N8N_DIR="${N8N_DIR:-/home/work/n8n}"

if [[ -z "$SNIP" || ! -r "$SNIP" ]]; then
  echo "Usage: artem creates snippet: /home/artem/container-bridge-v2/fix-proxy-and-policy.sh pattern ->" >&2
  echo "  artem@pub: tmp snippet from /home/artem/vpn-proxy.conf (HTTP_PROXY lines)" >&2
  echo "  work@pub: bash $0 /tmp/n8n-vpn-proxy-snippet.env.<pid>" >&2
  exit 1
fi

mkdir -p "$N8N_DIR"
{
  echo "N8N_HOST=0.0.0.0"
  echo "N8N_PORT=5678"
  echo "N8N_PROTOCOL=http"
  echo "N8N_SECURE_COOKIE=false"
  echo "WEBHOOK_URL=http://127.0.0.1:49980/"
  echo "GENERIC_TIMEZONE=Europe/Moscow"
  echo "TZ=Europe/Moscow"
  echo "N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false"
  grep -E '^HTTP_PROXY=|^HTTPS_PROXY=|^ALL_PROXY=|^NO_PROXY=' "$SNIP"
} > "$N8N_DIR/n8n.env"
chmod 600 "$N8N_DIR/n8n.env"

podman rm -f n8n 2>/dev/null || true
podman run -d --name n8n \
  --cpus=4 \
  --memory=4g \
  --memory-swap=4g \
  -p 127.0.0.1:49980:5678 \
  -v n8n-data:/home/node/.n8n \
  --env-file "$N8N_DIR/n8n.env" \
  docker.io/n8nio/n8n:1.70.1

sleep 3
curl -s -o /dev/null -w "n8n:%{http_code}\n" http://127.0.0.1:49980/
echo "Outbound: VPN HTTPS proxy (vpn-proxy.conf). UI: ssh -L 49980:127.0.0.1:49980 oleg_vm_work"