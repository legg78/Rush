create or replace package lty_api_acq_operation_pkg is

procedure get_operations(
    i_inst_id               com_api_type_pkg.t_inst_id
  , i_merchant_id           com_api_type_pkg.t_medium_id
  , i_status                com_api_type_pkg.t_dict_value
  , i_card_number           com_api_type_pkg.t_card_number
  , i_auth_code             com_api_type_pkg.t_auth_code   default null
  , i_start_date            date                           default null
  , i_end_date              date                           default null
  , i_spent_operation       com_api_type_pkg.t_long_id     default null
  , o_ref_cursor       out  sys_refcursor
);

procedure add_spent_operation(
    i_oper_id_tab        num_tab_tpt
  , i_spent_operation    com_api_type_pkg.t_long_id
);

end;
/
