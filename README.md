# Hydra ETL — a PostgreSQL mirror that loses nothing

A complete, ready-to-run demo of the PostgreSQL CDC source of [Hydra ETL](https://github.com/bejaouibechir/Hydra) (0.20+): the inserts, updates and deletes of `shop.orders` are read through PostgreSQL's logical replication and applied to `analytics.orders`, including when a load fails in the middle.

Everything is here: the PostgreSQL database (Docker), its creation and seed scripts, the Hydra ETL project and the SQL for every step. Download the code with `git clone`, or take [`hydra-cdc-mirror-demo.zip`](hydra-cdc-mirror-demo.zip).

```
docker-compose.yml        PostgreSQL 16 with wal_level=logical, created and filled at the first start
.env.example              connection settings, shared by Docker and Hydra ETL (copied to .env)
db/
  initdb.sql              creates the shop and analytics databases and the shop.orders table
  seed.sql                fills shop.orders with 1,000 orders
  changes.sql             a day of activity: 20 new orders, 3 refunds, 1 deleted order
  break.sql               500 updates and one wrong order, refused by the mirror
  repair.sql              fixes the wrong order
  check.sql               compares shop.orders and analytics.orders
scripts/                  start, reset and run a SQL file (bash and PowerShell)
jobs/orders_mirror/       the Hydra ETL job: CDC source, PostgreSQL destination in upsert
workflows/                sync.yaml and thread.yaml
```

## Requirements

- Docker with Docker Compose (Docker Desktop on Windows and macOS)
- Python 3.9 or later

Port 5433 is used so that it does not conflict with a PostgreSQL already running on 5432. To change it, edit `PG_PORT` in `.env`.

## 1. Get the project and install Hydra ETL

```bash
git clone https://github.com/bejaouibechir/hydra-cdc-mirror-demo.git
cd hydra-cdc-mirror-demo
pip install "hydra-etl[postgres]>=0.20"
```

## 2. Start the database

Linux, macOS, Git Bash:

```bash
./scripts/start.sh
```

Windows PowerShell:

```powershell
.\scripts\start.ps1
```

The first start creates `.env` from `.env.example`, the container `hydra-cdc-pg`, the `shop` and `analytics` databases, and 1,000 orders. It ends with `Ready: shop.orders has 1000 rows.`

On PowerShell, if scripts are blocked: `Set-ExecutionPolicy -Scope Process Bypass`, then run the script again.

## 3. First run: the whole table

```bash
hdrctl run .
./scripts/sql.sh check          # PowerShell: .\scripts\sql.ps1 check
```

Hydra ETL creates the publication and the replication slot, copies the 1,000 orders, and creates `analytics.orders` with the same types and `order_id` as primary key. Both tables: 1,000 rows, total 453855.00.

## 4. A day of changes

```bash
./scripts/sql.sh changes        # PowerShell: .\scripts\sql.ps1 changes
hdrctl run .
./scripts/sql.sh check
```

Only the 24 changes are read. Both tables: 1,019 rows, 3 refunded, total 454582.31.

## 5. A failure in the middle of the load

The mirror refuses negative amounts. The shop records 500 updates, then one order at -15.00:

```bash
./scripts/sql.sh break          # PowerShell: .\scripts\sql.ps1 break
hdrctl run .
./scripts/sql.sh check
```

The run fails on the negative amount (`CheckViolation`). `analytics.orders` is exactly as before: 1,019 rows, total 454582.31. None of the 500 updates was applied, and the replication slot did not move.

## 6. Fix and run again: nothing was lost

```bash
./scripts/sql.sh repair         # PowerShell: .\scripts\sql.ps1 repair
hdrctl run .
./scripts/sql.sh check
```

Both tables: 1,020 rows, total 455097.31. The 500 updates of the failed run were read again and applied.

## Start again from zero

```bash
./scripts/reset.sh              # PowerShell: .\scripts\reset.ps1
```

This removes the container and its data, then creates them again (1,000 orders, no slot, no mirror).

## Without Docker

On your own PostgreSQL 11 or later:

1. Set `wal_level = logical` (`ALTER SYSTEM SET wal_level = logical;`, then restart PostgreSQL).
2. Create the databases and the data: `psql -U postgres -f db/initdb.sql` then `psql -U postgres -f db/seed.sql`.
3. Copy `.env.example` to `.env` and set `PG_HOST`, `PG_PORT`, `PG_USER` (a role with `REPLICATION`) and `PG_PASSWORD`.
4. Follow steps 3 to 6, running the SQL files with `psql -U postgres -f db/<name>.sql`.

## How it works

- `jobs/orders_mirror/sources.yaml`: `type: postgresql_cdc` reads the changes of `public.orders`. Each row carries `_op` (`snapshot`, `insert`, `update`, `delete`), `_lsn` and `_commit_time`.
- `jobs/orders_mirror/destinations.yaml`: PostgreSQL in `upsert` on `order_id`. The last change of each key wins, deletes are applied by key, and the three tracking columns are not written. `atomic: true` makes the load all or nothing.
- The changes are read without being consumed. The replication slot only moves on after the destination has published: a failed load reads the same changes again at the next run.

When you are done: `docker compose down -v` removes the container, its data and the replication slot with it.

## License

MIT
