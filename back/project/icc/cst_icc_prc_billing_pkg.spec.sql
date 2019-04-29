create or replace package cst_icc_prc_billing_pkg as

procedure process(
    i_inst_id           in      com_api_type_pkg.t_inst_id
    , i_cycle_date_type in      com_api_type_pkg.t_dict_value  default fcl_api_const_pkg.DATE_TYPE_SYSTEM_DATE  
);

end;
/
