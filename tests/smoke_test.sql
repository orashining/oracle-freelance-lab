-- Smoke test only after setup.sql in a fresh disposable Oracle test schema.
-- Does not COMMIT: all test data is rolled back whether tests pass or fail.
-- Requires SET SERVEROUTPUT ON support in SQLcl / SQL Developer Run Script.
SET SERVEROUTPUT ON SIZE UNLIMITED

DECLARE
    v_customer_id NUMBER;
    v_order_id NUMBER;
    v_credit NUMBER;
    v_status VARCHAR2(20);
    v_history_count NUMBER;
BEGIN
    INSERT INTO customers(customer_name, email, city, credit, status)
    VALUES ('Portfolio Smoke Customer', 'smoke-customer@example.invalid',
            'Test City', 500, 'ACTIVE')
    RETURNING customer_id INTO v_customer_id;

    order_pkg.create_order(
        p_customer_id => v_customer_id,
        p_amount => 125,
        p_order_id => v_order_id
    );

    SELECT status INTO v_status FROM orders WHERE order_id = v_order_id;
    IF v_status <> 'NEW' THEN
        raise_application_error(-20901, 'New order status is not NEW');
    END IF;

    order_pkg.pay_order(p_order_id => v_order_id);

    SELECT status INTO v_status FROM orders WHERE order_id = v_order_id;
    SELECT credit INTO v_credit FROM customers WHERE customer_id = v_customer_id;

    IF v_status <> 'COMPLETED' OR v_credit <> 375 THEN
        raise_application_error(-20902, 'Payment status or credit is incorrect');
    END IF;

    SELECT COUNT(*) INTO v_history_count
    FROM order_status_history
    WHERE order_id = v_order_id
      AND old_status = 'NEW'
      AND new_status = 'COMPLETED';

    IF v_history_count <> 1 THEN
        raise_application_error(-20903, 'Audit trigger did not record status change');
    END IF;

    BEGIN
        order_pkg.update_status(v_order_id, 'CANCELLED');
        raise_application_error(-20904, 'Cancelling a completed order should fail');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE <> -20002 THEN RAISE; END IF;
    END;

    SELECT status INTO v_status FROM orders WHERE order_id = v_order_id;
    IF v_status <> 'COMPLETED' THEN
        raise_application_error(-20905, 'Rejected cancellation changed order');
    END IF;

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('PASS - create_order, pay_order, credit, trigger, cancellation guard');
    DBMS_OUTPUT.PUT_LINE('PASS - all synthetic test records rolled back');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('FAIL - ' || SQLERRM);
        RAISE;
END;
/
