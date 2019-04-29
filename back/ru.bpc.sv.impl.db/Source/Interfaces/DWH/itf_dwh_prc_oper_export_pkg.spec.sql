create or replace package itf_dwh_prc_oper_export_pkg is

procedure process(
    i_dwh_version         in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
  , i_start_date          in     date                             default null
  , i_end_date            in     date                             default null
  , i_masking_card        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.TRUE
);

end;
/
