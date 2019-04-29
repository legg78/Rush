create or replace package acq_ui_account_pattern_pkg as

procedure add_account_pattern(
    o_id                  out  com_api_type_pkg.t_medium_id
  , o_seqnum              out  com_api_type_pkg.t_seqnum
  , i_scheme_id        in      com_api_type_pkg.t_tiny_id
  , i_oper_type        in      com_api_type_pkg.t_dict_value
  , i_oper_reason      in      com_api_type_pkg.t_dict_value
  , i_sttl_type        in      com_api_type_pkg.t_dict_value
  , i_terminal_type    in      com_api_type_pkg.t_dict_value
  , i_currency         in      com_api_type_pkg.t_curr_code
  , i_oper_sign        in      com_api_type_pkg.t_boolean
  , i_merchant_type    in      com_api_type_pkg.t_dict_value
  , i_account_type     in      com_api_type_pkg.t_dict_value
  , i_account_currency in      com_api_type_pkg.t_curr_code
  , i_priority         in      com_api_type_pkg.t_tiny_id
);

procedure modify_account_pattern(
    i_id               in      com_api_type_pkg.t_medium_id
  , io_seqnum          in out  com_api_type_pkg.t_seqnum
  , i_scheme_id        in      com_api_type_pkg.t_tiny_id
  , i_oper_type        in      com_api_type_pkg.t_dict_value
  , i_oper_reason      in      com_api_type_pkg.t_dict_value
  , i_sttl_type        in      com_api_type_pkg.t_dict_value
  , i_terminal_type    in      com_api_type_pkg.t_dict_value
  , i_currency         in      com_api_type_pkg.t_curr_code
  , i_oper_sign        in      com_api_type_pkg.t_boolean
  , i_merchant_type    in      com_api_type_pkg.t_dict_value
  , i_account_type     in      com_api_type_pkg.t_dict_value
  , i_account_currency in      com_api_type_pkg.t_curr_code
  , i_priority         in      com_api_type_pkg.t_tiny_id
);

procedure remove_account_pattern (
    i_id               in      com_api_type_pkg.t_medium_id
  , i_seqnum           in      com_api_type_pkg.t_seqnum
);

end;
/
