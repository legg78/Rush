create or replace package net_api_standard_pkg is

function get_inst_id (
    i_value             in com_api_type_pkg.t_name
  , i_name            in com_api_type_pkg.t_name
  , i_network_id      in com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_inst_id;
    
function get_basic_standard return com_api_type_pkg.t_tiny_id;

end;
/