#!/bin/bash

CERT_DEST="/etc/nginx/certs"
DOMAIN="automagicdeveloper.com"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting certificate renewal check…"

# --pre-hook   : stop Nginx so certbot can bind port 80 (standalone challenge)
# --post-hook  : restart Nginx whether or not renewal happened
# --deploy-hook: ONLY fires when a cert was actually renewed; copies new certs
#                and reloads Nginx; sleep 2 guards against the nginx PID-file
#                race between post-hook startup and the reload signal
certbot renew \
  --standalone \
  --preferred-challenges http \
  --non-interactive \
  --days 7 \
  --pre-hook    "nginx -s stop || true" \
  --post-hook   "nginx || true" \
  --deploy-hook "cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem $CERT_DEST/fullchain.pem && \
                 cp /etc/letsencrypt/live/$DOMAIN/privkey.pem  $CERT_DEST/privkey.pem && \
                 sleep 2 && nginx -s reload || true"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Certificate renewal check complete."
