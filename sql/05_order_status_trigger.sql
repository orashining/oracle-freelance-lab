-- Extracted from the trigger embedded in the ORDERS SQLcl export.
-- Depends on ORDER_STATUS_HISTORY and ORDERS.
CREATE OR REPLACE EDITIONABLE TRIGGER trg_order_status_history
AFTER UPDATE OF status ON orders
FOR EACH ROW
WHEN (OLD.status <> NEW.status)
BEGIN
    INSERT INTO order_status_history (order_id, old_status, new_status)
    VALUES (:OLD.order_id, :OLD.status, :NEW.status);
END;
/
