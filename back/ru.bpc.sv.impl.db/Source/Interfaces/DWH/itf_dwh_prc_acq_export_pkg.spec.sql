create or replace package itf_dwh_prc_acq_export_pkg is

procedure process_merchant(
    i_dwh_version         in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
);

procedure process_terminal(
    i_dwh_version         in     com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_full_export         in     com_api_type_pkg.t_boolean       default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_count               in     com_api_type_pkg.t_medium_id     default null
);

end;
/
