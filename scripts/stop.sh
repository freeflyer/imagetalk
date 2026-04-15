#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."
docker compose --env-file .settings.env -f docker-compose.macos.yml down
