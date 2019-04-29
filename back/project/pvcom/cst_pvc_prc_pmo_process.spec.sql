create or replace package cst_pvc_prc_pmo_process_pkg as

-- Update payment orders total amount for active orders belonging to the same customers
procedure update_total_by_customer (
    i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_purpose_id              in     com_api_type_pkg.t_short_id
);

end cst_pvc_prc_pmo_process_pkg;
/
