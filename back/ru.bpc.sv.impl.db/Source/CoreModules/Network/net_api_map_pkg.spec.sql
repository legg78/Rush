create or replace package net_api_map_pkg as

function get_oper_type(
    i_network_oper_type in      com_api_type_pkg.t_dict_value
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_mask_error        in      com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
) return com_api_type_pkg.t_dict_value;

function get_network_type(
    i_oper_type         in      com_api_type_pkg.t_dict_value
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_mask_error        in      com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_dict_value;

function get_msg_type(
    i_network_msg_type  in      com_api_type_pkg.t_dict_value
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_mask_error        in      com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE
) return com_api_type_pkg.t_dict_value;

function get_network_card_type_list(i_card_type_id in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_dict_tab;

function get_card_type_network_id(
    i_card_type_id    in    com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id;

end;
/
