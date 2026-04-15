#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."

echo "=== ImageTalk installer ==="
echo

if [ ! -f .settings.env ]; then
    echo "ERROR: .settings.env not found."
    echo "       Copy .settings.env.example to .settings.env and set IMAGETALK_ROOT first."
    exit 1
fi

echo "[1/5] Loading settings..."
while IFS='=' read -r key value; do
    [ -z "$key" ] && continue
    case "$key" in \#*) continue ;; esac
    export "$key=$value"
done < .settings.env

if [ -z "${IMAGETALK_ROOT:-}" ]; then
    echo "ERROR: IMAGETALK_ROOT is not set in .settings.env"
    exit 1
fi
if [ ! -d "$IMAGETALK_ROOT" ]; then
    echo "ERROR: IMAGETALK_ROOT path does not exist: $IMAGETALK_ROOT"
    exit 1
fi
echo "      IMAGETALK_ROOT = $IMAGETALK_ROOT"

echo "[2/5] Checking Docker..."
if ! docker info >/dev/null 2>&1; then
    echo "ERROR: Docker is not running or not installed."
    echo "       Install Docker Desktop from https://www.docker.com/products/docker-desktop/ and start it."
    exit 1
fi
echo "      Docker is running."

echo "[3/5] Checking host Ollama..."
if ! command -v ollama >/dev/null 2>&1; then
    echo "ERROR: ollama not found in PATH."
    echo "       Install Ollama from https://ollama.com/download and start it."
    exit 1
fi
if ! ollama list >/dev/null 2>&1; then
    echo "ERROR: Ollama is installed but the daemon is not responding."
    echo "       Start the Ollama app, then re-run this script."
    exit 1
fi
echo "      Ollama is running."

echo "[4/5] Pulling Docker images..."
docker compose --env-file .settings.env -f docker-compose.macos.yml pull

echo "[5/5] Pulling Ollama models on the host (first run may take a while)..."
for model in "$EMBEDDING_MODEL" "$DESCRIBE_MODEL" "$TALKING_MODEL"; do
    echo "      Pulling $model ..."
    ollama pull "$model"
done

echo
echo "=== Installation complete ==="
echo "Next: run scripts/start.sh"
