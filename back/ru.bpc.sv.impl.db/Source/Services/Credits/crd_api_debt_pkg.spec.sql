create or replace package crd_api_debt_pkg as

procedure create_debt(
    i_macros_id         in      com_api_type_pkg.t_long_id
  , i_card_id           in      com_api_type_pkg.t_long_id
  , i_oper_id           in      com_api_type_pkg.t_long_id
  , i_oper_type         in      com_api_type_pkg.t_dict_value
  , i_sttl_type         in      com_api_type_pkg.t_dict_value
  , i_fee_type          in      com_api_type_pkg.t_dict_value
  , i_macros_type_id    in      com_api_type_pkg.t_tiny_id
  , i_terminal_type     in      com_api_type_pkg.t_dict_value
  , i_oper_date         in      date
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_amount            in      com_api_type_pkg.t_money
  , i_mcc               in      com_api_type_pkg.t_mcc
  , i_account_id        in      com_api_type_pkg.t_medium_id
  , i_posting_date      in      date
  , i_sttl_day          in      com_api_type_pkg.t_tiny_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_agent_id          in      com_api_type_pkg.t_agent_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id
  , i_is_reversal       in      com_api_type_pkg.t_boolean
  , i_original_id       in      com_api_type_pkg.t_long_id
);

function check_operation_billing(
    i_oper_id   in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_boolean;

end;
/

