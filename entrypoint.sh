#!/bin/bash
set -e

CERT_DEST="/etc/nginx/certs"

# Acquire certificates for domains
# Add all required domains here:
DOMAINS="-d automagicdeveloper.com -d www.automagicdeveloper.com -d replicabot.automagicdeveloper.com"

obtain_certificates() {
    echo "Obtaining new SSL certificates..."
    nginx -s stop || true
    certbot certonly --standalone --preferred-challenges http \
        --non-interactive --agree-tos --email muhammadabdelgawwad@gmail.com \
        --cert-path ${CERT_DEST}/fullchain.pem --key-path ${CERT_DEST}/privkey.pem \
        $DOMAINS
}

renew_certificates() {
    echo "Checking and renewing SSL certificates if needed..."
    certbot renew --quiet \
        --cert-path ${CERT_DEST}/fullchain.pem --key-path ${CERT_DEST}/privkey.pem
}

if [ ! -f "${CERT_DEST}/fullchain.pem" ] || [ ! -f "${CERT_DEST}/privkey.pem" ]; then
    obtain_certificates
else
    echo "SSL certificates found."
    renew_certificates
fi

echo "Starting Nginx..."
nginx -g "daemon off;"
