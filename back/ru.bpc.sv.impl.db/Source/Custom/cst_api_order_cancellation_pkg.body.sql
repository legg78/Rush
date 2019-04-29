CREATE OR REPLACE PACKAGE body cst_api_order_cancellation_pkg AS

procedure cancel_order (
    i_payment_order_id  in  com_api_type_pkg.t_long_id
) is
    l_oper_id               com_api_type_pkg.t_long_id;
    l_oper_status           com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text          => 'cst_api_order_cancellation_pkg.cancel_order [#1]'
      , i_env_param1    => i_payment_order_id
    );
    
end cancel_order;    

END cst_api_order_cancellation_pkg;

/