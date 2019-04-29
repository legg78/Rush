create or replace package com_api_array_pkg as

function conv_array_elem_v(
    i_array_type_id       in      com_api_type_pkg.t_tiny_id
  , i_array_id            in      com_api_type_pkg.t_short_id     default null
  , i_inst_id             in      com_api_type_pkg.t_inst_id      default null
  , i_elem_value          in      com_api_type_pkg.t_name
  , i_mask_error          in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , i_error_value         in      com_api_type_pkg.t_name         default null
) return com_api_type_pkg.t_name;

function conv_array_elem_v (
    i_lov_id              in      com_api_type_pkg.t_tiny_id
  , i_array_type_id       in      com_api_type_pkg.t_tiny_id
  , i_array_id            in      com_api_type_pkg.t_short_id     default null
  , i_inst_id             in      com_api_type_pkg.t_inst_id      default null
  , i_elem_value          in      com_api_type_pkg.t_name
  , i_mask_error          in      com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
  , i_error_value         in      com_api_type_pkg.t_name         default null
) return com_api_type_pkg.t_name;

function get_elements(
    i_array_id  in  com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_array_element_tab;

function get_elements(
    i_array_id            in      com_api_type_pkg.t_short_id
  , i_pattern             in      com_api_type_pkg.t_name
  , i_replacement_string  in      com_api_type_pkg.t_name
  , i_start_position      in      com_api_type_pkg.t_tiny_id
  , i_occurrence          in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_array_element_cache_tab;

procedure sync_dynamic_array_element(
    i_object_id           in      com_api_type_pkg.t_long_id
  , i_entity_type         in      com_api_type_pkg.t_dict_value
  , i_inst_id             in      com_api_type_pkg.t_inst_id
  , i_agent_id            in      com_api_type_pkg.t_agent_id     default null
);

function is_element_in_array(
    i_array_id            in      com_api_type_pkg.t_short_id
  , i_elem_value          in      com_api_type_pkg.t_name  
) return com_api_type_pkg.t_boolean;

function get_element_list(
    i_array_id          in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_full_desc;

end com_api_array_pkg;
/
