#!/usr/bin/env bash
# Start the PostgreSQL container (created and filled at the first start) and wait until it is ready.
set -euo pipefail
cd "$(dirname "$0")/.."
[ -f .env ] || cp .env.example .env
docker compose up -d
echo "Waiting for PostgreSQL..."
for _ in $(seq 1 60); do
  if docker compose exec -T postgres psql -U "${PG_USER:-postgres}" -d shop -tAc "SELECT count(*) FROM orders" >/dev/null 2>&1; then
    echo "Ready: shop.orders has $(docker compose exec -T postgres psql -U "${PG_USER:-postgres}" -d shop -tAc "SELECT count(*) FROM orders") rows."
    exit 0
  fi
  sleep 2
done
echo "PostgreSQL is not ready after 2 minutes: docker compose logs postgres" >&2
exit 1
