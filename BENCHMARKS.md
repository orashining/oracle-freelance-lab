# Oracle Query Performance — Local Lab Results

## Query workload

A generated `PERF_ORDERS` table contained approximately 100,000 rows. A composite index was built on `(status, order_date)`.

Two approaches to the same filtered `COUNT(*)` query were compared:

```sql
SELECT /*+ FULL(p) */ COUNT(*)
FROM perf_orders p
WHERE p.status = 'COMPLETED'
  AND p.order_date >= DATE '2026-10-01'
  AND p.order_date < DATE '2026-11-01';

SELECT /*+ INDEX(p IDX_PERF_STATUS_DATE) */ COUNT(*)
FROM perf_orders p
WHERE p.status = 'COMPLETED'
  AND p.order_date >= DATE '2026-10-01'
  AND p.order_date < DATE '2026-11-01';
```

## Execution-plan estimates

| Plan | Access path | Optimizer cost |
| --- | --- | ---: |
| `SELECT *` without hint | Full table scan | 134 |
| `SELECT *` with index hint | Index range scan + table rowid lookups | 2,210 |
| `COUNT(*)` without hint | Index range scan, no table rowid lookups | 11 |
| `COUNT(*)` with full-scan hint | Full table scan | 134 |

Estimated matching rows: 2,198. Actual count in the benchmark: 2,124.

## Elapsed-time trial

After warm-up, the same `COUNT(*)` predicate was executed 100 times with each hint:

| Access path | Total elapsed time (100 executions) |
| --- | ---: |
| Forced full table scan | 410 ms |
| Forced index range scan | 30 ms |

In this local trial, the index scan was approximately **13.7× faster** for this specific `COUNT(*)` workload.

**Interpretation:** The index supports a cheap count over matching entries. Retrieving all table columns can be much more expensive because of table rowid lookups. Optimizer cost is not elapsed time; these measured timings were a single small, warm-cache run and should not be generalized to production without repeats, logical-read analysis, and representative data volumes.
