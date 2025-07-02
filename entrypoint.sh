#!/usr/bin/env bash
set -euo pipefail

DOMAIN_ROOT="automagicdeveloper.com"
CERT_DEST="/etc/nginx/certs"
NGINX_CONF="/etc/nginx/conf.d/default.conf"

# ───────────────────────────────────────────────────────────────
# Build the -d list for certbot by reading the map{} in default.conf
# ───────────────────────────────────────────────────────────────
readarray -t HOSTS < <(grep -oP "[a-z0-9.-]+\.${DOMAIN_ROOT}" "${NGINX_CONF}" | sort -u)
HOSTS+=("${DOMAIN_ROOT}")   # include bare domain

DOMAINS=""
for h in "${HOSTS[@]}"; do DOMAINS+=" -d ${h}"; done
echo "[entrypoint] Certbot domains:${DOMAINS}"

# ───────────────────────────────────────────────────────────────
# Obtain certificate on first run (HTTP-01 challenge)
# ───────────────────────────────────────────────────────────────
if [[ ! -f "${CERT_DEST}/fullchain.pem" || ! -f "${CERT_DEST}/privkey.pem" ]]; then
    echo "[entrypoint] No cert found – running certbot"
    nginx -s stop || true
    certbot certonly --standalone --preferred-challenges http \
        --non-interactive --agree-tos --email muhammadabdelgawwad@gmail.com \
        ${DOMAINS}
    cp /etc/letsencrypt/live/${DOMAIN_ROOT}/fullchain.pem "${CERT_DEST}/fullchain.pem"
    cp /etc/letsencrypt/live/${DOMAIN_ROOT}/privkey.pem  "${CERT_DEST}/privkey.pem"
fi

# ───────────────────────────────────────────────────────────────
# Kick off cron (for renewals) and run Nginx in foreground
# ───────────────────────────────────────────────────────────────
crond -b
echo "[entrypoint] Starting Nginx…"
exec nginx -g "daemon off;"
