#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."

if [ ! -f .settings.env ]; then
    echo "ERROR: .settings.env not found. Run scripts/install.sh first."
    exit 1
fi

docker compose --env-file .settings.env -f docker-compose.macos.yml pull
docker compose --env-file .settings.env -f docker-compose.macos.yml up -d
