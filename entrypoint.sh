#!/bin/bash
set -e

CERT_DEST="/etc/nginx/certs"
DOMAIN="automagicdeveloper.com"
DOMAINS="-d automagicdeveloper.com -d www.automagicdeveloper.com -d replicabot.automagicdeveloper.com"

obtain_certificates() {
    echo "Obtaining new SSL certificates..."
    nginx -s stop || true
    certbot certonly --standalone --preferred-challenges http \
        --non-interactive --agree-tos --email muhammadabdelgawwad@gmail.com \
        $DOMAINS
    # Copy obtained certificates to /etc/nginx/certs
    cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem $CERT_DEST/fullchain.pem
    cp /etc/letsencrypt/live/$DOMAIN/privkey.pem $CERT_DEST/privkey.pem
}

renew_certificates() {
    echo "Checking and renewing SSL certificates if needed..."
    certbot renew --quiet
    # After renewal, ensure certificates are copied
    cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem $CERT_DEST/fullchain.pem
    cp /etc/letsencrypt/live/$DOMAIN/privkey.pem $CERT_DEST/privkey.pem
}

if [ ! -f "${CERT_DEST}/fullchain.pem" ] || [ ! -f "${CERT_DEST}/privkey.pem" ]; then
    obtain_certificates
else
    echo "SSL certificates found."
    renew_certificates
fi

echo "Starting Nginx..."
nginx -g "daemon off;"
