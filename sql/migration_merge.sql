-- DML: REVIEW PREVIEW FIRST. Run in a test schema with AUTOCOMMIT OFF.
-- No implicit COMMIT: verify results and COMMIT or ROLLBACK yourself.
-- A sequential rerun does not reinsert normalized emails already in CUSTOMERS.
-- Concurrent uniqueness is NOT enforced by this schema.
MERGE INTO customers c
USING (
    WITH clean AS (
        SELECT import_id, TRIM(customer_name) AS customer_name,
               LOWER(TRIM(email)) AS email, TRIM(city) AS city,
               credit, UPPER(TRIM(status)) AS status
        FROM customers_stage
    ),
    ranked AS (
        SELECT v.*,
               ROW_NUMBER() OVER (PARTITION BY email ORDER BY import_id) AS rn
        FROM clean v
        WHERE customer_name IS NOT NULL
          AND email IS NOT NULL
          AND credit IS NOT NULL AND credit >= 0
          AND status IN ('ACTIVE', 'INACTIVE', 'BLOCKED')
    )
    SELECT * FROM ranked WHERE rn = 1
) s
ON (LOWER(TRIM(c.email)) = s.email)
WHEN NOT MATCHED THEN
    INSERT (customer_name, email, city, credit, status)
    VALUES (s.customer_name, s.email, s.city, s.credit, s.status);
