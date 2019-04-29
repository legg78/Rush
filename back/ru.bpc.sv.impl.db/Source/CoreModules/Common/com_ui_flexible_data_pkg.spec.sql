create or replace package com_ui_flexible_data_pkg as
/*******************************************************************
*  UI for flexible data <br />
*  Created by Khougaev A.(khougaev@bpc.ru)  at 19.03.2010 <br />
*  Module: COM_UI_FLEXIBLE_DATA_PKG <br />
*  @headcom
******************************************************************/

procedure add_flexible_field(
    o_field_id               out com_api_type_pkg.t_short_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_type         in     com_api_type_pkg.t_dict_value    default null
  , i_name                in     com_api_type_pkg.t_name
  , i_label               in     com_api_type_pkg.t_name
  , i_description         in     com_api_type_pkg.t_full_desc     default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_data_type           in     com_api_type_pkg.t_dict_value
  , i_data_format         in     com_api_type_pkg.t_name          default null
  , i_lov_id              in     com_api_type_pkg.t_tiny_id       default null
  , i_inst_id             in     com_api_type_pkg.t_inst_id       default null
  , i_default_value_char  in     com_api_type_pkg.t_name          default null
  , i_default_value_num   in     com_api_type_pkg.t_rate          default null
  , i_default_value_date  in     date                             default null
);

procedure modify_flexible_field(
    i_field_id            in     com_api_type_pkg.t_short_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value    default null
  , i_object_type         in     com_api_type_pkg.t_dict_value    default null
  , i_name                in     com_api_type_pkg.t_name          default null
  , i_label               in     com_api_type_pkg.t_name          default null
  , i_description         in     com_api_type_pkg.t_full_desc     default null
  , i_lang                in     com_api_type_pkg.t_dict_value    default null
  , i_data_type           in     com_api_type_pkg.t_dict_value    default null
  , i_data_format         in     com_api_type_pkg.t_name          default null
  , i_lov_id              in     com_api_type_pkg.t_tiny_id       default null
  , i_default_value_char  in     com_api_type_pkg.t_name          default null
  , i_default_value_num   in     com_api_type_pkg.t_rate          default null
  , i_default_value_date  in     date                             default null
);

procedure remove_flexible_field(
    i_field_id            in     com_api_type_pkg.t_short_id
);

procedure set_flexible_value_v(
    i_field_name          in     com_api_type_pkg.t_name
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_seq_number          in     com_api_type_pkg.t_tiny_id       default 1
  , i_field_value         in     varchar2
);

procedure set_flexible_value_d(
    i_field_name          in     com_api_type_pkg.t_name
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_seq_number          in     com_api_type_pkg.t_tiny_id       default 1
  , i_field_value         in     date
);

procedure set_flexible_value_n(
    i_field_name          in     com_api_type_pkg.t_name
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_object_id           in     com_api_type_pkg.t_long_id
  , i_seq_number          in     com_api_type_pkg.t_tiny_id       default 1
  , i_field_value         in     number
);

procedure sync_fields_with_app_structure;

procedure add_flexible_field_usage(
    o_id                     out com_api_type_pkg.t_short_id
  , i_field_id            in     com_api_type_pkg.t_short_id
  , i_usage               in     com_api_type_pkg.t_dict_value
);

procedure modify_flexible_field_usage(
    i_id                  in     com_api_type_pkg.t_short_id
  , i_field_id            in     com_api_type_pkg.t_short_id
  , i_usage               in     com_api_type_pkg.t_dict_value
);

procedure remove_flexible_field_usage(
    i_id                  in     com_api_type_pkg.t_short_id
);

end;
/
