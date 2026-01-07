# Vibe Kanban Image Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task.

**Goal:** Build and publish a stable Docker image for `BloopAI/vibe-kanban` (GHCR), plus compose examples for end users.

**Architecture:** A thin packaging repo that pins an upstream release tag (`UPSTREAM_REF`), fetches upstream during CI, builds a multi-arch image, and publishes it to GHCR with predictable tags.

**Tech Stack:** Docker BuildKit/buildx, GitHub Actions, docker compose.

### Task 1: Pin upstream release ref

**Files:**
- Create: `UPSTREAM_REF`

**Step: Set current upstream tag**
- Write latest upstream release tag into `UPSTREAM_REF` (e.g. `v0.0.144-20260106131405`).

### Task 2: Add stable Dockerfile + entrypoint

**Files:**
- Create: `docker/Dockerfile`
- Create: `docker/entrypoint.sh`

**Step: Build from upstream source**
- Use a multi-stage build (Node + Rust builder, Alpine runtime).
- Default runtime env: `HOST=0.0.0.0`, `PORT=8080`, `XDG_DATA_HOME=/data`.

**Step: Verification**
- Run: `./scripts/fetch-upstream.sh "$(cat UPSTREAM_REF)"`
- Run: `docker build -f docker/Dockerfile -t vibe-kanban:local .`
- Expected: image builds successfully.

### Task 3: Add compose examples

**Files:**
- Create: `compose/docker-compose.yml`
- Create: `compose/docker-compose.ferron.yml`
- Create: `compose/.env.example`
- Create: `compose/ferron/ferron.kdl`

**Step: Verification**
- Run: `cp compose/.env.example compose/.env`
- Run: `docker compose -f compose/docker-compose.yml --env-file compose/.env config`
- Expected: rendered config has valid image/ports/volumes.

### Task 4: Add docs

**Files:**
- Modify: `README.md`
- Create: `README-REMOTE.md`

**Step: Document remote workflow + security boundary**
- Encourage tunnel + Remote-SSH.
- Don’t recommend Docker socket mounts by default.

### Task 5: Add CI workflows

**Files:**
- Create: `.github/workflows/build.yml`
- Create: `.github/workflows/bump.yml`

**Step: Verification**
- `build.yml` builds multi-arch and pushes to GHCR on main/tag.
- `bump.yml` schedules and opens PR when upstream has a newer release tag.
