#!/bin/sh
set -eu

: "${HOST:=0.0.0.0}"
: "${PORT:=8080}"

export HOST PORT

exec "$@"

