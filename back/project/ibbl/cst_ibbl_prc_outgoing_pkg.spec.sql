create or replace package cst_ibbl_prc_outgoing_pkg as

procedure debit_cards_turnovers(
    i_inst_id  in     com_api_type_pkg.t_inst_id
);

procedure create_operations_from_vss_msg(
    i_inst_id                     in     com_api_type_pkg.t_inst_id
  , i_create_operation            in     com_api_type_pkg.t_boolean
  , i_visa_vss_amnt_type_array_id in com_api_type_pkg.t_short_id
);

function get_multiplier(
    i_curr_code                in            com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_money
result_cache;

end cst_ibbl_prc_outgoing_pkg;
/
