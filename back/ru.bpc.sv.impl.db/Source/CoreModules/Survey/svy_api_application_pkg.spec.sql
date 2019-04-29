create or replace package svy_api_application_pkg is

procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_data_type            in            com_api_type_pkg.t_dict_value
  , i_element_value_c      in            varchar2                            default null
  , i_element_value_n      in            number                              default null
  , i_element_value_d      in            date                                default null
  , i_lang                 in            com_api_type_pkg.t_dict_value       default null
);

procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            com_api_type_pkg.t_full_desc
  , i_lang                 in            com_api_type_pkg.t_dict_value       default null
);

procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            number
);

procedure add_element(
    i_element_name         in            com_api_type_pkg.t_name
  , i_parent_id            in            com_api_type_pkg.t_long_id
  , i_element_value        in            date
);

procedure process_application;

function get_parent_element_id(
    i_element_id           in            com_api_type_pkg.t_short_id
  , i_app_type             in            com_api_type_pkg.t_dict_value    default  app_api_const_pkg.APPL_TYPE_QUESTIONARY
) return com_api_type_pkg.t_short_id;

end svy_api_application_pkg;
/
