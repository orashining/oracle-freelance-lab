# Clean installation and smoke-test results

**Test date:** 08/11/2026  
**Environment:** Oracle AI Database Free 26ai, local Windows development machine, PDB `FREEPDB1`  
**Isolation:** A new temporary schema (`PORTFOLIO_TEST`) with no pre-existing objects.

## Test setup

The temporary user was granted only the privileges needed to install this sample schema: `CREATE SESSION`, `CREATE TABLE`, `CREATE SEQUENCE`, `CREATE PROCEDURE`, and `CREATE TRIGGER`, along with tablespace quota. Identity columns require sequence-creation privileges in this local setup.

SQL*Plus was launched with its working directory set to the repository root so that `@@sql/...` relative includes could be found.

## Verified output

- Four `CREATE TABLE` statements succeeded.
- `ORDER_PKG` specification and body compiled.
- `TRG_ORDER_STATUS_HISTORY` compiled.
- Seven expected database objects were `VALID`.
- `USER_ERRORS` returned zero rows for the package and trigger.
- Transactional smoke test passed:
  - `create_order` created a new order.
  - `pay_order` marked it `COMPLETED` and deducted the expected credit.
  - Trigger logged one `NEW` → `COMPLETED` history row.
  - Attempting to cancel a completed order raised expected application error `-20002`.
  - All synthetic smoke-test data was rolled back.
- SQL*Plus exited with code **0**.

Relevant confirmation:

```text
PASS - 7 objects valid; no compiler errors
PASS - create_order, pay_order, credit, trigger, cancellation guard
PASS - all synthetic test records rolled back
SQLPLUS_EXIT_CODE=0
```

## Cleanup

After the successful run, the `PORTFOLIO_TEST` user was dropped with `CASCADE`. A subsequent query showed **0 remaining users** with that name. The temporary password-bearing script was deleted. The original `FREELANCE_LAB` schema was not modified.

## Scope and limitations

This test validates clean schema installation and the specific package/trigger behavior listed above. It does **not** independently certify the `migration_*.sql` examples, a production deployment, high concurrency, or the generality of the performance benchmark. Earlier exercises in `FREELANCE_LAB` measured a 100-iteration count-query timing difference and demonstrated sequential migration idempotency; see [BENCHMARKS.md](BENCHMARKS.md).
