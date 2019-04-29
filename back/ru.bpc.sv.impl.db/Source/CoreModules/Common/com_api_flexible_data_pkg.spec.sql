create or replace package com_api_flexible_data_pkg as

procedure set_flexible_value(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default 1
  , i_field_value       in      varchar2
);

procedure set_flexible_value(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default 1
  , i_field_value       in      number
);

procedure set_flexible_value(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_seq_number        in      com_api_type_pkg.t_tiny_id          default 1
  , i_field_value       in      date
);

function get_flexible_value(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_name;

function get_flexible_value_number(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
) return number;

function get_flexible_value_date(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
) return date;

function get_flexible_field_label(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_name;

function get_flexible_field(
    i_field_name        in      com_api_type_pkg.t_name
  , i_entity_type       in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_flexible_field;

procedure set_usage(
    i_usage             in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
);

function get_usage(
    i_usage             in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean;

function generate_xml(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_standard_id       in      com_api_type_pkg.t_tiny_id
  , i_object_id         in      com_api_type_pkg.t_long_id
) return xmltype;

procedure generate_xml(
    i_entity_type       in            com_api_type_pkg.t_dict_value
  , i_standard_id       in            com_api_type_pkg.t_tiny_id
  , i_object_id         in            com_api_type_pkg.t_long_id
  , o_xml_block            out nocopy com_api_type_pkg.t_lob_data
);

procedure save_data(
    io_flex_data_tab    in out nocopy com_api_type_pkg.t_flexible_data_tab
  , i_entity_type       in            com_api_type_pkg.t_dict_value
  , i_object_id         in            com_api_type_pkg.t_long_id
);

end com_api_flexible_data_pkg;
/
