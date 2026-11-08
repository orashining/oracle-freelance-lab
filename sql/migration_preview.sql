-- Read-only preview: candidates for importing into CUSTOMERS.
-- A row with the same normalized email as an existing customer is excluded.
WITH clean AS (
    SELECT import_id, TRIM(customer_name) AS customer_name,
           LOWER(TRIM(email)) AS email, TRIM(city) AS city,
           credit, UPPER(TRIM(status)) AS status
    FROM customers_stage
),
valid_rows AS (
    SELECT * FROM clean
    WHERE customer_name IS NOT NULL
      AND email IS NOT NULL
      AND credit IS NOT NULL AND credit >= 0
      AND status IN ('ACTIVE', 'INACTIVE', 'BLOCKED')
),
ranked AS (
    SELECT v.*,
           ROW_NUMBER() OVER (PARTITION BY email ORDER BY import_id) AS rn
    FROM valid_rows v
)
SELECT r.import_id, r.customer_name, r.email, r.city, r.credit, r.status
FROM ranked r
WHERE r.rn = 1
  AND NOT EXISTS (
      SELECT 1 FROM customers c
      WHERE LOWER(TRIM(c.email)) = r.email
  )
ORDER BY r.import_id;
