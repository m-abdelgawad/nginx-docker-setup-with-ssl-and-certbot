# Alpine image with Nginx + Certbot + cron
FROM nginx:1.25-alpine

RUN apk add --no-cache certbot curl bash dcron

# Copy full Nginx configuration (default.conf + snippets)
COPY nginx/conf.d /etc/nginx/conf.d
# Copy the bootstrap script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
