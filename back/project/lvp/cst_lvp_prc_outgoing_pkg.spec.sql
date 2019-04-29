create or replace package cst_lvp_prc_outgoing_pkg as

procedure process_export_cbs(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
);

procedure process_export_rtgs(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_purpose_id            in     com_api_type_pkg.t_short_id
);

end;
/
