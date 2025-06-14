#!/bin/bash
set -e

CERT_DEST="/etc/nginx/certs"
DOMAIN="automagicdeveloper.com"

# List only the subdomain prefixes here. An empty string "" means the root domain itself.
SUBDOMAIN_PREFIXES=(
  ""               # root domain → automagicdeveloper.com
  "www"
  "myreads"
  "lifehub"
  "enjaz"
  "replicabot"
  "aistoreassistant"
  "polarity"
  "clientnest"
)

# Construct the -d flags dynamically
DOMAINS=""
for prefix in "${SUBDOMAIN_PREFIXES[@]}"; do
    if [ -z "$prefix" ]; then
        DOMAINS+=" -d $DOMAIN"
    else
        DOMAINS+=" -d ${prefix}.${DOMAIN}"
    fi
done

echo "Domains variable value is: $DOMAINS"

# Function to initially obtain certificates if they don't exist
obtain_certificates() {
    echo "No SSL certificates found. Attempting to obtain new SSL certificates..."
    # Stop nginx if running (likely not running yet, but just in case)
    nginx -s stop || true

    # Attempt to obtain certificates from Let's Encrypt
    certbot certonly --standalone --preferred-challenges http \
        --non-interactive --agree-tos --email muhammadabdelgawwad@gmail.com \
        $DOMAINS || {
            echo "Certbot failed to obtain certificates. Check domain DNS and firewall settings."
            exit 1
        }

    # Verify that certbot created the certificates
    if [ ! -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ] || [ ! -f "/etc/letsencrypt/live/$DOMAIN/privkey.pem" ]; then
        echo "Certificates not found after certbot run. Exiting."
        exit 1
    fi

    # Copy obtained certificates
    cp /etc/letsencrypt/live/$DOMAIN/fullchain.pem $CERT_DEST/fullchain.pem
    cp /etc/letsencrypt/live/$DOMAIN/privkey.pem $CERT_DEST/privkey.pem
}

if [ ! -f "${CERT_DEST}/fullchain.pem" ] || [ ! -f "${CERT_DEST}/privkey.pem" ]; then
    obtain_certificates
else
    echo "SSL certificates found. Skipping certbot initialization."
fi

# Start cron in the background for renewals
service cron start

echo "Starting Nginx..."
exec nginx -g "daemon off;"
