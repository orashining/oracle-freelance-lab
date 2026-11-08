-- Depends on 02_orders.sql. Identity definition retained as ALWAYS.
CREATE TABLE order_status_history (
    history_id NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL,
    order_id NUMBER NOT NULL,
    old_status VARCHAR2(20 BYTE),
    new_status VARCHAR2(20 BYTE) NOT NULL,
    changed_date DATE DEFAULT SYSDATE NOT NULL,
    PRIMARY KEY (history_id),
    CONSTRAINT fk_history_order FOREIGN KEY (order_id) REFERENCES orders (order_id)
);
