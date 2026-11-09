#!/usr/bin/env bash
# Start again from zero: remove the container and its data, then create them again.
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose down -v
"$(dirname "$0")/start.sh"
