create or replace package cst_gpb_pmo_prc_make_pkg is

procedure process(
    i_inst_id           in  com_api_type_pkg.t_inst_id
  , i_purpose_id        in  com_api_type_pkg.t_short_id
  , i_is_eod            in  com_api_type_pkg.t_boolean
);

end cst_gpb_pmo_prc_make_pkg;
/
