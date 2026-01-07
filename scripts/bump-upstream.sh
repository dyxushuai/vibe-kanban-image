#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_GITHUB_REPO="${UPSTREAM_GITHUB_REPO:-BloopAI/vibe-kanban}"

if [[ ! -f UPSTREAM_REF ]]; then
  echo "UPSTREAM_REF not found" >&2
  exit 1
fi

current_ref="$(tr -d ' \n' < UPSTREAM_REF)"

curl_args=(-fsSL)
curl_args+=(-H "Accept: application/vnd.github+json")
curl_args+=(-H "X-GitHub-Api-Version: 2022-11-28")
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  curl_args+=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
fi

latest_ref="$(
  curl "${curl_args[@]}" "https://api.github.com/repos/${UPSTREAM_GITHUB_REPO}/releases/latest" \
    | python3 -c 'import json,sys; print(json.load(sys.stdin)["tag_name"])'
)"

if [[ -z "${latest_ref}" ]]; then
  echo "Failed to resolve latest upstream release tag" >&2
  exit 1
fi

if [[ "${latest_ref}" == "${current_ref}" ]]; then
  echo "Up to date: ${current_ref}"
  exit 0
fi

echo "${latest_ref}" > UPSTREAM_REF

export latest_ref
python3 - <<'PY'
from pathlib import Path
import os

latest = os.environ["latest_ref"]
path = Path("compose/.env.example")
if not path.exists():
    raise SystemExit("compose/.env.example not found")

lines = []
for line in path.read_text().splitlines(True):
    if line.startswith("VIBE_KANBAN_TAG="):
        line = f"VIBE_KANBAN_TAG={latest}\n"
    lines.append(line)
path.write_text("".join(lines))
PY

echo "Updated upstream: ${current_ref} -> ${latest_ref}"
