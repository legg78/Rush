create or replace package rul_ui_name_pkg as
/*********************************************************
*  Naming service <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 01.04.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: RUL_UI_NAME_PKG <br />
*  @headcom
**********************************************************/

procedure sync_range(
    io_id                in out com_api_type_pkg.t_short_id
  , i_inst_id            in     com_api_type_pkg.t_inst_id
  , i_entity_type        in     com_api_type_pkg.t_dict_value
  , i_algorithm          in     com_api_type_pkg.t_dict_value
  , i_low_value          in     com_api_type_pkg.t_large_id
  , i_high_value         in     com_api_type_pkg.t_large_id
  , i_current_value      in     com_api_type_pkg.t_large_id
  , i_lang               in     com_api_type_pkg.t_dict_value
  , i_name               in     com_api_type_pkg.t_name
);

procedure remove_range (
    i_id                 in com_api_type_pkg.t_short_id
);

procedure sync_part (
    io_id                  in out com_api_type_pkg.t_short_id
  , i_format_id            in     com_api_type_pkg.t_tiny_id
  , i_part_order           in     com_api_type_pkg.t_tiny_id
  , i_base_value_type      in     com_api_type_pkg.t_dict_value
  , i_base_value           in     com_api_type_pkg.t_name
  , i_transformation_type  in     com_api_type_pkg.t_dict_value
  , i_transformation_mask  in     com_api_type_pkg.t_name
  , i_part_length          in     com_api_type_pkg.t_tiny_id
  , i_pad_type             in     com_api_type_pkg.t_dict_value
  , i_pad_string           in     com_api_type_pkg.t_name
  , i_check_part           in     com_api_type_pkg.t_boolean
);

procedure remove_part (
    i_id in com_api_type_pkg.t_short_id
);

procedure sync_name_format (
    io_id                 in out com_api_type_pkg.t_tiny_id
  , i_inst                in     com_api_type_pkg.t_inst_id
  , io_seqnum             in out com_api_type_pkg.t_tiny_id
  , i_entity_type         in     com_api_type_pkg.t_dict_value
  , i_name_length         in     com_api_type_pkg.t_tiny_id
  , i_pad_type            in     com_api_type_pkg.t_dict_value
  , i_pad_string          in     com_api_type_pkg.t_name
  , i_check_algorithm     in     com_api_type_pkg.t_dict_value
  , i_check_base_position in     com_api_type_pkg.t_tiny_id
  , i_check_base_length   in     com_api_type_pkg.t_tiny_id
  , i_check_position      in     com_api_type_pkg.t_tiny_id
  , i_index_range_id      in     com_api_type_pkg.t_short_id
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_label               in     com_api_type_pkg.t_text
  , i_check_name          in     com_api_type_pkg.t_boolean
);

procedure remove_name_format (
    i_id             in     com_api_type_pkg.t_tiny_id
  , i_seqnum         in     com_api_type_pkg.t_tiny_id
);

procedure sync_property_value (
    io_id                  in out com_api_type_pkg.t_short_id
  , i_part_id              in     com_api_type_pkg.t_short_id
  , i_property_id          in     com_api_type_pkg.t_short_id
  , i_property_value       in     com_api_type_pkg.t_name
);

procedure remove_property_value (
    i_id                  in com_api_type_pkg.t_short_id
);

end rul_ui_name_pkg;
/
