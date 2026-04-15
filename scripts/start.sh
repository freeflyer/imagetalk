#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."

if [ ! -f .settings.env ]; then
    echo "ERROR: .settings.env not found. Run scripts/install.sh first."
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker is not running. Start Docker Desktop and try again."
    exit 1
fi

docker compose --env-file .settings.env -f docker-compose.macos.yml up -d

FRONTEND_PORT=$(grep -E '^FRONTEND_PORT=' .settings.env | head -n1 | cut -d= -f2)

echo
echo "=== ImageTalk is starting ==="
echo "Open http://localhost:$FRONTEND_PORT in your browser."
