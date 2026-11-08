CREATE OR REPLACE EDITIONABLE PACKAGE order_pkg AS

    PROCEDURE update_status (
        p_order_id IN NUMBER,
        p_status IN VARCHAR2
    );

    PROCEDURE create_order (
        p_customer_id IN NUMBER,
        p_amount IN NUMBER,
        p_order_id OUT NUMBER
    );

    PROCEDURE pay_order (
        p_order_id IN NUMBER
    );

END order_pkg;
/
