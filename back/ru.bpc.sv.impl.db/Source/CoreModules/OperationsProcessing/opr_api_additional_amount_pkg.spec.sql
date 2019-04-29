create or replace package opr_api_additional_amount_pkg is

procedure save_amount(
    i_oper_id              in     com_api_type_pkg.t_long_id
  , i_amount_type          in     com_api_type_pkg.t_dict_value
  , i_amount_value         in     com_api_type_pkg.t_money
  , i_currency             in     com_api_type_pkg.t_curr_code
);

procedure get_amount(
    i_oper_id              in     com_api_type_pkg.t_long_id
  , i_amount_type          in     com_api_type_pkg.t_dict_value
  , o_amount                  out com_api_type_pkg.t_money
  , o_currency                out com_api_type_pkg.t_curr_code
  , i_mask_error           in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_error_amount         in     com_api_type_pkg.t_money      default null
  , i_error_currency       in     com_api_type_pkg.t_curr_code  default null
);

/*
 * Procedure reads all additional amounts for an operation from the table.
 */
procedure get_amounts(
    i_oper_id              in     com_api_type_pkg.t_long_id
  , o_amount_tab              out com_api_type_pkg.t_amount_tab
);

procedure insert_amount(
    i_oper_id              in     com_api_type_pkg.t_long_id
  , i_amount_type_tab      in     com_api_type_pkg.t_dict_tab
  , i_amount_value_tab     in     com_api_type_pkg.t_money_tab
  , i_currency_tab         in     com_api_type_pkg.t_curr_code_tab
);

end opr_api_additional_amount_pkg;
/
