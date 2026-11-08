-- Staging allows bad customer data; import_id is the only primary key.
CREATE TABLE customers_stage (
    import_id NUMBER PRIMARY KEY,
    customer_name VARCHAR2(200 BYTE),
    email VARCHAR2(255 BYTE),
    city VARCHAR2(100 BYTE),
    credit NUMBER(12,2),
    status VARCHAR2(20 BYTE)
);
