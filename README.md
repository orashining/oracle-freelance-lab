# Oracle Customer & Order Management — SQL / PL/SQL

A small Oracle SQL/PLSQL portfolio project demonstrating customer/order workflows, row locking, validation, audit history, staging-table migration, and index performance analysis.

## Features

- `ORDER_PKG`: create orders, update statuses, and pay orders using credit validation, `SELECT ... FOR UPDATE`, a savepoint, and error handling.
- `CUSTOMERS`, `ORDERS`, `ORDER_STATUS_HISTORY`, `CUSTOMERS_STAGE`: actual table structures transcribed from SQLcl DDL exports supplied from the development environment.
- `TRG_ORDER_STATUS_HISTORY`: row-level trigger logging order status changes.
- Data-migration examples: normalization, validation, deduplication with `ROW_NUMBER()`, `MERGE`, and a diagnostic rejected-row report.
- Query performance example: full scan vs composite `(status, order_date)` index; see [BENCHMARKS.md](BENCHMARKS.md).

## Files

```text
oracle-freelance-lab/
├── README.md
├── BENCHMARKS.md
├── setup.sql
└── sql/
    ├── 01_customers.sql
    ├── 02_orders.sql
    ├── 03_order_status_history.sql
    ├── 04_customers_stage.sql
    ├── 05_order_status_trigger.sql
    ├── order_pkg_spec.sql
    ├── order_pkg_body.sql
    ├── migration_preview.sql
    ├── migration_merge.sql
    └── migration_rejections.sql
```

## Setup (in a new, disposable Oracle schema only)

**Do not execute `setup.sql` in `FREELANCE_LAB` or any existing schema.** It creates objects and is not an upgrade script. With a separate clean Oracle test user connected in SQLcl or SQL Developer **Run Script** mode, execute:

```sql
@setup.sql
```

The `setup.sql` script invokes files using relative `@@sql/...` paths. The table dependencies are ordered `CUSTOMERS` → `ORDERS` → `ORDER_STATUS_HISTORY`; the package and trigger are created after their dependencies.

After setup, check object compilation and constraints in Oracle. This portable copy **has not yet been independently compiled or clean-install tested**; it was prepared from verified source DDL. The original database remains untouched.

### Migration demo

1. Populate `CUSTOMERS_STAGE` with your own **synthetic** data (no customer information is bundled).
2. Execute `sql/migration_preview.sql` first (read-only).
3. Review `sql/migration_merge.sql` before running it with autocommit off.
4. Verify imported rows, and explicitly `COMMIT` or `ROLLBACK`.
5. Use `sql/migration_rejections.sql` only as a training diagnostic—not as a durable audit log.

The migration prevents duplicates on ordinary **sequential** reruns when normalized emails already exist. It does **not** guarantee concurrency-safe uniqueness; production code should use a suitable database-enforced key and persist per-row import outcomes.

## Oracle development evidence

In the local Oracle Database Free 26ai training environment, the user reported valid objects and tested error handling, row locking, a 2-row migration followed by a 0-row sequential rerun, and a full-scan/index benchmark. See [BENCHMARKS.md](BENCHMARKS.md). These are local exercise results, not independent clean-install or production certification.

## Portability and security notes

The table scripts preserve the original columns, identity modes, defaults, constraints and key relationships, while omitting owner-specific `FREELANCE_LAB` qualifiers, `USERS` tablespace/storage clauses and SQLcl's export-only `KUT$` lines. The historical primary key name `NEW_TABLE_PK` is intentionally preserved. The `ORDER_PKG` source was previously exported and reformatted for the starter project.

No passwords, actual customer rows, or database dumps are included. For production use, add a deployment strategy, migration audit, concurrency protection, regression tests, and workload-appropriate performance measurements.
