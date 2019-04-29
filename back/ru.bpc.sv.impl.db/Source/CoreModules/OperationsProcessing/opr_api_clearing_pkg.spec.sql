create or replace package opr_api_clearing_pkg is

procedure mark_uploaded (
    i_id_tab           in     com_api_type_pkg.t_number_tab
);

procedure mark_settled (
    i_id_tab           in     com_api_type_pkg.t_number_tab
  , i_sttl_amount      in     com_api_type_pkg.t_number_tab
  , i_sttl_currency    in     com_api_type_pkg.t_curr_code_tab
);

procedure match_reversal(
    i_oper_id           in     com_api_type_pkg.t_long_id
  , i_is_reversal       in     com_api_type_pkg.t_boolean
  , i_network_refnum    in     com_api_type_pkg.t_rrn
  , i_oper_amount       in     com_api_type_pkg.t_money
  , i_oper_currency     in     com_api_type_pkg.t_curr_code
  , i_card_number       in     com_api_type_pkg.t_card_number
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , io_match_status     in out com_api_type_pkg.t_dict_value
  , io_match_id         in out com_api_type_pkg.t_long_id
);
    
end opr_api_clearing_pkg;
/
