FROM nginx:latest

RUN apt-get update && \
    apt-get install -y certbot cron && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/certbot && chown -R www-data:www-data /var/www/certbot

COPY default.conf /etc/nginx/conf.d/default.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Cron job for cert renewals
# This will attempt to renew every 12 hours. If renewal occurs, it copies the certificates and reloads nginx.
RUN echo "0 */12 * * * /usr/bin/certbot renew --quiet && cp -L /etc/letsencrypt/live/automagicdeveloper.com/fullchain.pem /etc/nginx/certs/fullchain.pem && cp -L /etc/letsencrypt/live/automagicdeveloper.com/privkey.pem /etc/nginx/certs/privkey.pem && nginx -s reload" > /etc/cron.d/certbot-renew
RUN chmod 0644 /etc/cron.d/certbot-renew && crontab /etc/cron.d/certbot-renew

CMD ["/entrypoint.sh"]