create or replace package com_prc_mcc_export_pkg is

function get_session_file_id
  return com_api_type_pkg.t_long_id;

function get_file_type
  return com_api_type_pkg.t_dict_value;

procedure process(
    i_dict_version         in     com_api_type_pkg.t_name
  , i_lang                 in     com_api_type_pkg.t_dict_value default null
);

end com_prc_mcc_export_pkg;
/
