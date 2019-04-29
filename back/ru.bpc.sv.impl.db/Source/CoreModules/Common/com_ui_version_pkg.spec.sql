create or replace package com_ui_version_pkg as

function get_last_version(
    i_part          in      com_api_type_pkg.t_dict_value := 'PARTBACK'
) return com_api_type_pkg.t_name
    result_cache;

function get_release(
    i_part          in      com_api_type_pkg.t_dict_value := 'PARTPDSS'
) return com_api_type_pkg.t_name
    result_cache;

function get_description(
    i_major         in      com_api_type_pkg.t_tiny_id
  , i_minor         in      com_api_type_pkg.t_tiny_id
  , i_maintenance   in      com_api_type_pkg.t_tiny_id
  , i_build         in      com_api_type_pkg.t_tiny_id
  , i_extension     in      com_api_type_pkg.t_dict_value
  , i_revision      in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_name;

procedure register_version(
    i_version       in      com_api_type_pkg.t_name
  , i_build_date    in      date
  , i_part_name     in      com_api_type_pkg.t_dict_value
  , i_git_revision  in      com_api_type_pkg.t_name
);

end com_ui_version_pkg;
/

