# Remote deployment guide

Upstream's recommended remote workflow is:

1) Keep the UI private (localhost / private network)
2) Expose it via a tunnel (Cloudflare Tunnel / ngrok)
3) Use SSH / VSCode Remote-SSH to edit the project on the server

## Option A: Tunnel (recommended)

Run Vibe Kanban on the server, bound to localhost only:

- In `compose/docker-compose.yml`, change the port mapping to:
  - `127.0.0.1:${PORT}:${PORT}`

Then expose it:

- Cloudflare Tunnel:
  - `cloudflared tunnel --url http://127.0.0.1:${PORT}`
- ngrok:
  - `ngrok http 127.0.0.1:${PORT}`

## Option B: Reverse proxy + auth (example)

This repo includes a Ferron example with automatic TLS + Basic Auth:

- `docker compose -f compose/docker-compose.ferron.yml --env-file compose/.env up -d`

You must edit `compose/ferron/ferron.kdl`:

- Replace the domain (e.g. `kanban.example.com`)
- For automatic TLS: set `auto_tls_contact` (email) and leave `auto_tls` enabled
- (Optional) if you're behind Cloudflare / another HTTPS proxy: use `auto_tls_challenge "http-01"`
- (Optional) for manual TLS: set `tls "<cert>" "<key>"` and mount `./compose/ferron/tls` → `/etc/ferron/tls` (see `compose/docker-compose.ferron.yml`)
- (Optional) enable Basic Auth by uncommenting `status`/`user` lines

To generate a password hash (paste it into `user "admin" "<hash>"`):

- `docker run --rm -it ferronserver/ferron:2 /usr/sbin/ferron-passwd`

## Editor integration (Remote SSH)

In the Vibe Kanban UI:

- Settings → Editor Integration → Remote SSH
  - Remote SSH Host: your server hostname / IP
  - Remote SSH User: your SSH username (optional)

Then use the "Open in VSCode" actions (requires the VSCode Remote-SSH extension locally).
