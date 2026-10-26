<!--
 - SPDX-FileCopyrightText: 2026 MyStickCloud
 - SPDX-License-Identifier: AGPL-3.0-or-later
-->
# MyStickCloud server (Docker)

Runs a stable Nextcloud release with the MyStickCloud branding from `themes/mystickcloud`.

## Start

```sh
cd docker
cp .env.example .env      # then edit .env and set strong passwords
docker compose up -d
```

Open http://localhost:8080 and log in with the admin user from `.env`.
The first start installs Nextcloud, which takes a few minutes.

## Branding

`hooks/apply-branding.sh` runs on every container start and sets:

- theme `mystickcloud` (`themes/mystickcloud`)
- name, slogan and URL
- primary colour `#1E5EFF`, background colour `#0B1F3A`
- logo, header logo and favicon

To change the branding, edit the files in `themes/mystickcloud` or the hook,
then run `docker compose restart app`.

## Going public

Set `NEXTCLOUD_TRUSTED_DOMAINS` in `.env` to your domain and put the server behind
HTTPS (for example a reverse proxy with Let's Encrypt, or a Cloudflare tunnel).
