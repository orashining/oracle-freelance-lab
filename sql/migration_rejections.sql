-- Diagnostic reasons for the specific training dataset AFTER its import.
-- This is NOT a historical audit log of migration decisions.
WITH ranked AS (
    SELECT s.*,
           ROW_NUMBER() OVER (
               PARTITION BY LOWER(TRIM(email))
               ORDER BY import_id
           ) AS rn
    FROM customers_stage s
),
checked AS (
    SELECT r.import_id, r.customer_name,
           CASE
               WHEN TRIM(r.customer_name) IS NULL THEN 'MISSING NAME'
               WHEN TRIM(r.email) IS NULL THEN 'MISSING EMAIL'
               WHEN r.credit IS NULL OR r.credit < 0 THEN 'INVALID CREDIT'
               WHEN r.status IS NULL
                 OR UPPER(TRIM(r.status)) NOT IN ('ACTIVE','INACTIVE','BLOCKED')
                   THEN 'INVALID STATUS'
               WHEN r.rn > 1 THEN 'DUPLICATE IN STAGING'
               WHEN EXISTS (
                   SELECT 1 FROM customers c
                   WHERE LOWER(TRIM(c.email)) = LOWER(TRIM(r.email))
                     AND TRIM(c.customer_name) <> TRIM(r.customer_name)
               ) THEN 'EMAIL CONFLICT WITH EXISTING CUSTOMER'
           END AS reason
    FROM ranked r
)
SELECT import_id, customer_name, reason
FROM checked
WHERE reason IS NOT NULL
ORDER BY import_id;
