# Remote deployment guide

Upstream's recommended remote workflow is:

1) Keep the UI private (localhost / private network)
2) Expose it via a tunnel (Cloudflare Tunnel / ngrok)
3) Use SSH / VSCode Remote-SSH to edit the project on the server

## Option A: Tunnel (recommended)

Run Vibe Kanban on the server, bound to localhost only:

- In `compose/docker-compose.yml`, change the port mapping to:
  - `127.0.0.1:${PORT}:${PORT}`
  - `PORT` defaults to `8080` (set it in `compose/.env` if you need a different port)

Then expose it:

- Cloudflare Tunnel:
  - `cloudflared tunnel --url http://127.0.0.1:${PORT}`
- ngrok:
  - `ngrok http 127.0.0.1:${PORT}`

## Option B: Reverse proxy + TLS (example)

This repo includes a Pingap example with **manual TLS** (file-based certs):

- `docker compose -f compose/docker-compose.pingap.yml --env-file compose/.env up -d`

You must edit the Pingap config:

- Replace the domain (e.g. `kanban.example.com`) in:
  - `compose/pingap/conf/locations.toml`
  - `compose/pingap/conf/certificates.toml`
- Place your TLS cert/key files at:
  - `compose/pingap/certs/fullchain.pem`
  - `compose/pingap/certs/privkey.pem`

After updating certs, restart the proxy:

- `docker compose -f compose/docker-compose.pingap.yml --env-file compose/.env restart pingap`

## Editor integration (Remote SSH)

In the Vibe Kanban UI:

- Settings → Editor Integration → Remote SSH
  - Remote SSH Host: your server hostname / IP
  - Remote SSH User: your SSH username (optional)

Then use the "Open in VSCode" actions (requires the VSCode Remote-SSH extension locally).
