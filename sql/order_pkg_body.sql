CREATE OR REPLACE EDITIONABLE PACKAGE BODY order_pkg AS

    PROCEDURE update_status (
        p_order_id IN NUMBER,
        p_status   IN VARCHAR2
    ) AS
        v_current_status orders.status%TYPE;
    BEGIN
        SELECT status
          INTO v_current_status
          FROM orders
         WHERE order_id = p_order_id
        FOR UPDATE;

        IF v_current_status = 'COMPLETED'
           AND p_status = 'CANCELLED'
        THEN
            raise_application_error(
                -20002,
                'Completed orders cannot be cancelled'
            );
        END IF;

        UPDATE orders
           SET status = p_status
         WHERE order_id = p_order_id;

    EXCEPTION
        WHEN no_data_found THEN
            raise_application_error(
                -20001,
                'Order not found'
            );
    END update_status;

    PROCEDURE create_order (
        p_customer_id IN NUMBER,
        p_amount      IN NUMBER,
        p_order_id    OUT NUMBER
    ) AS
        v_status customers.status%TYPE;
    BEGIN
        IF p_amount IS NULL OR p_amount <= 0 THEN
            raise_application_error(
                -20005,
                'Invalid order amount'
            );
        END IF;

        SELECT status
          INTO v_status
          FROM customers
         WHERE customer_id = p_customer_id;

        IF v_status <> 'ACTIVE' THEN
            raise_application_error(
                -20004,
                'Customer is not active'
            );
        END IF;

        INSERT INTO orders (
            customer_id,
            amount,
            status
        ) VALUES (
            p_customer_id,
            p_amount,
            'NEW'
        ) RETURNING order_id INTO p_order_id;

    EXCEPTION
        WHEN no_data_found THEN
            raise_application_error(
                -20003,
                'Customer not found'
            );
    END create_order;

    PROCEDURE pay_order (
        p_order_id IN NUMBER
    ) AS
        v_customer_id     orders.customer_id%TYPE;
        v_amount          orders.amount%TYPE;
        v_order_status    orders.status%TYPE;
        v_customer_status customers.status%TYPE;
    BEGIN
        SAVEPOINT before_payment;

        SELECT customer_id,
               amount,
               status
          INTO v_customer_id,
               v_amount,
               v_order_status
          FROM orders
         WHERE order_id = p_order_id
        FOR UPDATE;

        IF v_order_status NOT IN ('NEW', 'UNPAID') THEN
            raise_application_error(
                -20010,
                'Order cannot be paid'
            );
        END IF;

        SELECT status
          INTO v_customer_status
          FROM customers
         WHERE customer_id = v_customer_id
        FOR UPDATE;

        IF v_customer_status <> 'ACTIVE' THEN
            raise_application_error(
                -20011,
                'Customer is not active'
            );
        END IF;

        UPDATE customers
           SET credit = credit - v_amount
         WHERE customer_id = v_customer_id
           AND credit >= v_amount;

        IF SQL%ROWCOUNT = 0 THEN
            raise_application_error(
                -20012,
                'Insufficient credit'
            );
        END IF;

        UPDATE orders
           SET status = 'COMPLETED'
         WHERE order_id = p_order_id;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO before_payment;
            RAISE;
    END pay_order;
END order_pkg;
/
