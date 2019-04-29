create or replace package cst_ap_env_unload_pkg is

procedure unload(
    i_inst_id                in      com_api_type_pkg.t_inst_id
  , i_eff_date               in      date                              default null
  , i_cst_env_operation_type in      com_api_type_pkg.t_dict_value     default null
);

procedure upload_rec_file;

end cst_ap_env_unload_pkg;
/
