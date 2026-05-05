#!/bin/bash
set -e

CERT_DEST="/etc/nginx/certs"
DOMAIN="automagicdeveloper.com"

# List only the sub-domain prefixes here. "" == root domain.
SUBDOMAIN_PREFIXES=(
  ""
  "www"
  "enjaz"
  "replicabot"
  "aistoreassistant"
  "n8n"
  "litellm"
  "walletscraper"
  "egypt-gold-tracker"
  "admin"
  "salzegy"
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

# Obtain certs if missing, or if they expire within 7 days (604800 seconds)
if [[ ! -f "$CERT_DEST/fullchain.pem" || ! -f "$CERT_DEST/privkey.pem" ]]; then
  obtain_certificates
elif ! openssl x509 -checkend 604800 -noout -in "$CERT_DEST/fullchain.pem"; then
  echo "Certificate expires within 7 days or is already expired. Renewing now…"
  obtain_certificates
else
  echo "Certificate is valid for more than 7 days. Skipping renewal."
fi

# Schedule cert renewal: daily at 03:00.
# certbot is a no-op when the cert has >7 days left (--days 7 threshold).
echo "0 3 * * * /renew_certs.sh >> /var/log/certbot-renew.log 2>&1" | crontab -

crond -f -l 2 &
echo "Starting Nginx…"
exec nginx -g "daemon off;"
