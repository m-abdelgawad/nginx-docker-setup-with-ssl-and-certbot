FROM nginx:1.26-alpine

LABEL maintainer="Mohamed Abdelgawwad <muhammadabdelgawwad@gmail.com>"

RUN apk add --no-cache certbot certbot-nginx bash grep sed coreutils tzdata dcron

# config + snippets
COPY nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY nginx/snippets/*.conf     /etc/nginx/snippets/
COPY entrypoint.sh             /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443
ENTRYPOINT ["/entrypoint.sh"]