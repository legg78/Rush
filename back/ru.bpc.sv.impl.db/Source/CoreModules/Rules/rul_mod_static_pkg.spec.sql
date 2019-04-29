create or replace package rul_mod_static_pkg as

function check_condition (
    i_mod_id            in com_api_type_pkg.t_tiny_id
  , i_params            in com_api_type_pkg.t_param_tab
) return com_api_type_pkg.t_boolean;

end;
/
