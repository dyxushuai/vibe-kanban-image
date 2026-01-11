# syntax=docker/dockerfile:1.6

# This repo intentionally vendors a "stable build" Dockerfile instead of relying on upstream's,
# so upstream changes can't break image builds without a review here.

FROM node:24-alpine3.20 AS builder

RUN apk add --no-cache \
    build-base \
    clang-dev \
    curl \
    llvm-dev \
    perl

# Allow linking libclang on musl
ENV RUSTFLAGS="-C target-feature=-crt-static"
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse

# Install Rust (rustup)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

ARG POSTHOG_API_KEY
ARG POSTHOG_API_ENDPOINT

ENV VITE_PUBLIC_POSTHOG_KEY=$POSTHOG_API_KEY
ENV VITE_PUBLIC_POSTHOG_HOST=$POSTHOG_API_ENDPOINT

WORKDIR /app

# Keep Cargo outputs in one place (and match the /app/target cache mount + runtime COPY path).
ENV CARGO_TARGET_DIR=/app/target

# Dependency cache layer
COPY upstream/package*.json upstream/pnpm-lock.yaml upstream/pnpm-workspace.yaml upstream/.npmrc ./
COPY upstream/frontend/package*.json ./frontend/
COPY upstream/npx-cli/package*.json ./npx-cli/

RUN corepack enable && pnpm config set store-dir /pnpm/store
RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile

# Source
COPY upstream/. .

# Build
RUN mkdir -p frontend/dist
RUN --mount=type=cache,target=/root/.cargo/registry \
    --mount=type=cache,target=/root/.cargo/git \
    --mount=type=cache,target=/app/target \
    cd crates/server && cargo run --locked --bin generate_types
RUN cd frontend && pnpm run build
RUN --mount=type=cache,target=/root/.cargo/registry \
    --mount=type=cache,target=/root/.cargo/git \
    --mount=type=cache,target=/app/target \
    cd crates/server && cargo build --locked --release --bin server && \
    install -m 0755 /app/target/release/server /usr/local/bin/server

FROM alpine:3.20 AS runtime

RUN apk add --no-cache \
    ca-certificates \
    git \
    libgcc \
    tini \
    wget

RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

COPY --from=builder /usr/local/bin/server /usr/local/bin/server
COPY docker/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
    mkdir -p /repos /data && \
    chown -R appuser:appgroup /repos /data

USER appuser

ENV HOST=0.0.0.0
ENV PORT=8080
# Persist Vibe Kanban state (db.sqlite, config.json, credentials.json) under /data via XDG.
ENV XDG_DATA_HOME=/data

EXPOSE 8080
WORKDIR /repos

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider "http://127.0.0.1:${PORT}/api/health" || exit 1

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
CMD ["server"]
