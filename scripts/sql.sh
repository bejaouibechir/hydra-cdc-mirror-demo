#!/usr/bin/env bash
# Run one of the db/*.sql scripts in the container:  scripts/sql.sh changes
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose exec -T postgres psql -U "${PG_USER:-postgres}" -d postgres -v ON_ERROR_STOP=1 -q < "db/$1.sql"
