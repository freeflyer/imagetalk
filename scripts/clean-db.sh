#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/.."

if [ ! -f .settings.env ]; then
    echo "ERROR: .settings.env not found."
    exit 1
fi

if [ -n "$(docker compose --env-file .settings.env -f docker-compose.macos.yml ps -q 2>/dev/null)" ]; then
    echo "ERROR: ImageTalk containers are still running."
    echo "       Stop them first: scripts/stop.sh"
    exit 1
fi

echo "This will permanently delete:"
echo "  - data/postgres  (Postgres database: catalogue, metadata)"
echo "  - data/qdrant    (Qdrant vector index: image embeddings)"
echo
echo "Your images in IMAGETALK_ROOT are NOT touched."
echo "The next start will initialize empty store, and you will need to resync the folders with your collection from scratch."
echo
read -r -p "Proceed? [y/N]: " _confirm
case "$_confirm" in
    y|Y) ;;
    *)
        echo "Cancelled."
        exit 0
        ;;
esac

rm -rf data/postgres data/qdrant

echo "Done."
