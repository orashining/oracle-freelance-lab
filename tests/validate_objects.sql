-- Read-only verification after setup.sql in a NEW disposable Oracle schema.
-- Check all 7 expected user objects, including the package specification and body.
SET LINESIZE 160
SET PAGESIZE 100
COLUMN OBJECT_NAME FORMAT A36
COLUMN OBJECT_TYPE FORMAT A18

SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN (
    'CUSTOMERS', 'ORDERS', 'ORDER_STATUS_HISTORY', 'CUSTOMERS_STAGE',
    'ORDER_PKG', 'TRG_ORDER_STATUS_HISTORY'
)
  AND object_type IN ('TABLE','PACKAGE','PACKAGE BODY','TRIGGER')
ORDER BY object_type, object_name;

-- This query should return zero rows:
SELECT name, type, line, position, text
FROM user_errors
WHERE name IN ('ORDER_PKG','TRG_ORDER_STATUS_HISTORY')
ORDER BY name, type, sequence;
