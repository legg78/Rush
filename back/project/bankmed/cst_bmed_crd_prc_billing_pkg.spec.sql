create or replace package cst_bmed_crd_prc_billing_pkg as

procedure process_subsidy(
    i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_cycle_date_type  in     com_api_type_pkg.t_dict_value    default fcl_api_const_pkg.DATE_TYPE_SYSTEM_DATE
);

procedure process_sharing(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_mrch_bunch_type_id  in     com_api_type_pkg.t_tiny_id
  , i_bank_bunch_type_id  in     com_api_type_pkg.t_tiny_id
);

end;
/
