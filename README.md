This repo builds and publishes Docker images for `BloopAI/vibe-kanban`, without forking or modifying upstream.

## Quickstart (prebuilt image)

1. Copy env file:
   - `cp compose/.env.example compose/.env`
2. Edit `compose/.env`:
   - Set `PROJECTS_DIR` to the directory containing your git repos
3. Start:
   - `docker compose -f compose/docker-compose.yml --env-file compose/.env up -d`
4. Open:
   - `http://localhost:8080` (or whatever you set as `PORT` in `compose/.env`)

## Remote deployment

See `README-REMOTE.md` for a recommended workflow (tunnel UI + VSCode Remote-SSH).

## Building locally

This repo does not vendor upstream source. To build locally:

1. Fetch upstream into `upstream/`:
   - `./scripts/fetch-upstream.sh "$(cat UPSTREAM_REF)"`
2. Build:
   - `docker build -f docker/Dockerfile -t vibe-kanban:local .`

## Notes

- Container defaults: `HOST=0.0.0.0`, `PORT=8080`, `XDG_DATA_HOME=/data`.
- Image tags published by CI:
  - `${UPSTREAM_REF}` (exact upstream release tag)
  - `${UPSTREAM_REF%%-*}` (short version, e.g. `v0.0.144`)
  - `sha-<upstream-shortsha>`
  - `latest` (only when building the pinned `UPSTREAM_REF` on `main`)
- Security: avoid mounting Docker socket / `--privileged` by default; the `/repos` bind mount is already a high-trust boundary.
- Upstream may attempt to open a browser on startup; in headless environments it should only log a warning.
