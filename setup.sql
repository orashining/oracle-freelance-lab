-- RUN ONLY IN A NEW/EMPTY TEST SCHEMA! Creates tables, package and trigger.
-- SQLcl / SQL*Plus / SQL Developer Run Script. Not safe to rerun as-is.
@@sql/01_customers.sql
@@sql/02_orders.sql
@@sql/03_order_status_history.sql
@@sql/04_customers_stage.sql
@@sql/order_pkg_spec.sql
@@sql/order_pkg_body.sql
@@sql/05_order_status_trigger.sql
