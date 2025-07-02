
# Nginx Docker Setup with SSL & Certbot — **Multi‑App Gateway**

> Last updated 2025-07-02

This repository ships a production‑ready **Nginx reverse‑proxy** in Docker,
fronting any number of backend applications running on the *same* host.
Certificates are issued & renewed automatically via **Let’s Encrypt (Certbot)**.

---

## Table of Contents
1. [Project layout](#project-layout)
2. [Quick start](#quick-start)
3. [Adding a new application](#adding-a-new-application)
   * [Single‑container backend (e.g. Django all‑in‑one)](#a-single-container-backend)
   * [Split SPA – frontend & API in separate containers](#a-split-spa-frontend--api)
4. [Certificate lifecycle](#certificate-lifecycle)
5. [FAQ / troubleshooting](#faq--troubleshooting)
6. [Contact](#contact)

---

## Project layout
```
.
├── docker-compose.yml        # runs Nginx + (your) apps
├── Dockerfile                # custom Nginx image with certbot & cron
├── entrypoint.sh             # first‑run cert bootstrap + cron
├── nginx
│  └── conf.d
│      ├── default.conf      # *all* server blocks live here
│      └── snippets          # DRY includes shared by every block
│          ├── ssl_base.conf
│          ├── performance.conf
│          └── proxy_headers.conf
└── certs/                    # mounted; certbot writes here
```
*Why snippets?* They eliminate ~140 duplicated lines by factoring out
common SSL / gzip / header directives.

---

## Quick start
```bash
# 1 – clone & edit env values to taste
git clone <your‑repo>
cd nginx-docker-setup-with-ssl-and-certbot

# 2 – ensure ports 80/443 are open & DNS A‑records point to this host

# 3 – boot the gateway
docker compose up --build -d
```
On first run `entrypoint.sh` will:
1. Request certificates for every sub‑domain listed in `SUBDOMAIN_PREFIXES`.
2. Copy `fullchain.pem` & `privkey.pem` into `./certs`.
3. Start **crond** + Nginx.

Subsequent `up`/`restart` calls start immediately if valid certs exist.

---

## Adding a new application
You always touch **two** files — nothing else.

| Step | File | What to change |
|------|------|----------------|
| 1.  | `entrypoint.sh` | Append the sub‑domain **prefix** to `SUBDOMAIN_PREFIXES`.     `""` means apex domain.<br>`"blog"` → `blog.example.com` |
| 2.  | `nginx/conf.d/default.conf` | Drop a new `server {{ … }}` block (see templates below). |

### A. Single‑container backend
> Example: Django serving both HTML & API on port `8000`.

```nginx
# ─── Blog (Django mono‑container) ─────────────────────────────
server {
    listen 443 ssl;
    http2  on;
    server_name blog.automagicdeveloper.com;

    # Docker‑DNS name of the container *defined in docker‑compose.yml*
    set $backend blog;

    # Shared directives
    include /etc/nginx/conf.d/snippets/ssl_base.conf;
    include /etc/nginx/conf.d/snippets/performance.conf;

    location / {
        proxy_pass http://$backend:8000;
        include /etc/nginx/conf.d/snippets/proxy_headers.conf;
        # optional: auth header pass‑through
        proxy_pass_request_headers on;
        proxy_set_header Authorization $http_authorization;
    }
}
```
**Cheat‑sheet**  
*Change only* `server_name`, `$backend`, and (rarely) `:port`.

### B. Split SPA – frontend & API
> Example: React on port `80`, Django REST on port `8000`.  
> Path `/api/*` goes to the backend, everything else to the SPA.

```nginx
# ─── TaskBoard SPA ────────────────────────────────────────────
server {
    listen 443 ssl;
    http2  on;
    server_name taskboard.automagicdeveloper.com;

    # Docker service names
    set $fe taskboard-frontend;
    set $api taskboard-backend;

    include /etc/nginx/conf.d/snippets/ssl_base.conf;
    include /etc/nginx/conf.d/snippets/performance.conf;

    # Static SPA
    location / {
        proxy_pass http://$fe:80;
        include /etc/nginx/conf.d/snippets/proxy_headers.conf;
    }

    # JSON API
    location /api/ {
        rewrite ^/api/(.*)$ /$1 break;   # strip /api/ before proxying
        proxy_pass http://$api:8000;
        include /etc/nginx/conf.d/snippets/proxy_headers.conf;
        proxy_pass_request_headers on;   # keep JWT / session cookies
        proxy_set_header Authorization $http_authorization;
    }
}
```

> **Tip:** The `$fe`/`$api` variables mean Nginx starts even if those
> containers are *not* up yet – Docker DNS resolves them lazily.

After editing, reload:

```bash
docker compose up --build -d   # or: docker compose restart nginx
```

---

## Certificate lifecycle
* **First run**: Certbot uses the **stand‑alone** plugin on port 80.  
  Nginx is halted until issuance succeeds.
* **Renewals**: `crond` runs twice daily (`certbot renew`).
* **Files**: Live certs are stored under `/etc/letsencrypt/live/`,
  then copied into the mounted `certs/` volume.  
  If you move servers, just copy `certs/` plus
  `./nginx/conf.d` and you’re good to go.

---

## FAQ / troubleshooting
| Symptom | Fix |
|---------|-----|
| `open() “…ssl_base.conf” failed` | Ensure `include /etc/nginx/conf.d/snippets/...` **absolute path** matches your volume mount. |
| `certificate has expired` | Container clock skew or firewall blocking outbound :80/443 to Let’s Encrypt. |
| Browser shows `Bad Gateway (502)` | Check that the backend container name & port in `proxy_pass` are correct, and that the service is healthy (`docker compose ps`). |

---

## Contact
**Mohamed AbdelGawad**  
✉︎ [muhammadabdelgawwad@gmail.com](mailto:muhammadabdelgawwad@gmail.com)
