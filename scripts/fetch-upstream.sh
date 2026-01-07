#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_REPO="${UPSTREAM_REPO:-https://github.com/BloopAI/vibe-kanban.git}"
UPSTREAM_DIR="${UPSTREAM_DIR:-upstream}"

ref="${1:-}"
if [[ -z "${ref}" ]]; then
  if [[ ! -f UPSTREAM_REF ]]; then
    echo "Usage: $0 <upstream-ref>  (or create UPSTREAM_REF)" >&2
    exit 1
  fi
  ref="$(tr -d ' \n' < UPSTREAM_REF)"
fi

if [[ -d "${UPSTREAM_DIR}/.git" ]]; then
  git -C "${UPSTREAM_DIR}" fetch --tags --force --prune origin
else
  rm -rf "${UPSTREAM_DIR}"
  if [[ "${ref}" =~ ^[0-9a-f]{40}$ ]]; then
    git clone "${UPSTREAM_REPO}" "${UPSTREAM_DIR}"
  else
    git clone --depth 1 --branch "${ref}" "${UPSTREAM_REPO}" "${UPSTREAM_DIR}"
  fi
fi

git -C "${UPSTREAM_DIR}" checkout -f "${ref}" >/dev/null

echo "Upstream checked out:"
git -C "${UPSTREAM_DIR}" --no-pager log -1 --oneline
