create or replace package cst_bmed_prc_incoming_pkg as

procedure process_import_rgts;

procedure process_import_account_status(
    i_fe_acc_status_array_type_id   in com_api_type_pkg.t_tiny_id   default cst_bmed_api_const_pkg.FE_ACC_STATUS_ARRAY_TYPE_ID
  , i_fe_acc_status_array_id        in com_api_type_pkg.t_short_id  default cst_bmed_api_const_pkg.FE_ACC_STATUS_ARRAY_ID
);

end;
/
