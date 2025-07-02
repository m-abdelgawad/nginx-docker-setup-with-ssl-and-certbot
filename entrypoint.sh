#!/bin/bash
set -e

CERT_DEST="/etc/nginx/certs"
DOMAIN="automagicdeveloper.com"

# List only the sub-domain prefixes here. "" == root domain.
SUBDOMAIN_PREFIXES=(
  "" "www" "myreads" "lifehub" "enjaz"
  "replicabot" "aistoreassistant" "polarity" "clientnest"
)

# Build the -d flags for Certbot
DOMAINS=""
for prefix in "${SUBDOMAIN_PREFIXES[@]}"; do
  if [[ -z "$prefix" ]]; then
    DOMAINS+=" -d $DOMAIN"
  else
    DOMAINS+=" -d ${prefix}.${DOMAIN}"
  fi
done
echo "Domains variable value is: $DOMAINS"

obtain_certificates() {
  echo "No SSL certificates found. Obtaining new ones…"
  nginx -s stop || true
  certbot certonly --standalone --preferred-challenges http \
    --non-interactive --agree-tos --email muhammadabdelgawwad@gmail.com \
    $DOMAINS || {
      echo "Certbot failed. Check DNS / firewall."
      exit 1
    }
  cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem "$CERT_DEST"/fullchain.pem
  cp /etc/letsencrypt/live/$DOMAIN/privkey.pem  "$CERT_DEST"/privkey.pem
}

[[ -f "$CERT_DEST/fullchain.pem" && -f "$CERT_DEST/privkey.pem" ]] || obtain_certificates

crond -f -l 2 &
echo "Starting Nginx…"
exec nginx -g "daemon off;"
