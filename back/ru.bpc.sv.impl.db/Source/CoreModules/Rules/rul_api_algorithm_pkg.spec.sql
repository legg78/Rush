create or replace package rul_api_algorithm_pkg is

function get_algorithm_procedure(
    i_algorithm             in     com_api_type_pkg.t_dict_value
  , i_entry_point           in     com_api_type_pkg.t_dict_value     default null
) return com_api_type_pkg.t_name result_cache;

procedure execute_algorithm(
    i_algorithm             in     com_api_type_pkg.t_dict_value
  , i_entry_point           in     com_api_type_pkg.t_dict_value     default null
);

function check_algorithm_exists(
    i_algorithm             in     com_api_type_pkg.t_dict_value
  , i_entry_point           in     com_api_type_pkg.t_dict_value     default null
) return com_api_type_pkg.t_boolean;

end;
/
