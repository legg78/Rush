create or replace package cst_bmed_lty_prc_bonus_pkg as

procedure export_new_members(
    i_inst_id            in        com_api_type_pkg.t_inst_id
  , i_service_id         in        com_api_type_pkg.t_short_id
);

procedure export_bonus_spending_file(
    i_inst_id            in        com_api_type_pkg.t_inst_id
  , i_service_id         in        com_api_type_pkg.t_short_id
  , i_dest_curr          in        com_api_type_pkg.t_curr_code
  , i_rate_type          in        com_api_type_pkg.t_dict_value
  , i_transaction_type   in        com_api_type_pkg.t_dict_value
) ;

end cst_bmed_lty_prc_bonus_pkg;
/
