CREATE OR REPLACE PACKAGE cst_api_order_cancellation_pkg AS

procedure cancel_order (
    i_payment_order_id  in  com_api_type_pkg.t_long_id
);

END cst_api_order_cancellation_pkg;

/
