create or replace package app_ui_dependence_pkg as
/*********************************************************
 *  UI for Dependence in application <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 01.02.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: app_ui_dependence_pkg  <br />
 *  @headcom
 **********************************************************/
function get_property_value(
    i_depend_id         in      com_api_type_pkg.t_tiny_id
  , i_element_name      in      com_api_type_pkg.t_name
  , i_char_value        in      com_api_type_pkg.t_name             default null
  , i_number_value      in      number                          default null
  , i_date_value        in      date                            default null
) return com_api_type_pkg.t_name;

function get_property_value_b(
    i_depend_id         in      com_api_type_pkg.t_tiny_id
  , i_element_name      in      com_api_type_pkg.t_name
  , i_char_value        in      com_api_type_pkg.t_name             default null
  , i_number_value      in      number                          default null
  , i_date_value        in      date                            default null
) return com_api_type_pkg.t_boolean;

function get_property_value_n(
    i_depend_id         in      com_api_type_pkg.t_tiny_id
  , i_element_name      in      com_api_type_pkg.t_name
  , i_char_value        in      com_api_type_pkg.t_name             default null
  , i_number_value      in      number                          default null
  , i_date_value        in      date                            default null
) return number;

function get_property_value_d(
    i_depend_id         in      com_api_type_pkg.t_tiny_id
  , i_element_name      in      com_api_type_pkg.t_name
  , i_char_value        in      com_api_type_pkg.t_name             default null
  , i_number_value      in      number                          default null
  , i_date_value        in      date                            default null
) return date;

function get_parent_entity(
    i_parent_struct_id  in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_name;

procedure add(
    o_id                   out  com_api_type_pkg.t_short_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_struct_id         in      com_api_type_pkg.t_short_id
  , i_depend_struct_id  in      com_api_type_pkg.t_short_id
  , i_dependence        in      com_api_type_pkg.t_dict_value
  , i_condition         in      com_api_type_pkg.t_name
  , i_affected_zone     in      com_api_type_pkg.t_dict_value
);

procedure modify(
    i_id                in      com_api_type_pkg.t_short_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_struct_id         in      com_api_type_pkg.t_short_id
  , i_depend_struct_id  in      com_api_type_pkg.t_short_id
  , i_dependence        in      com_api_type_pkg.t_dict_value
  , i_condition         in      com_api_type_pkg.t_name
  , i_affected_zone     in      com_api_type_pkg.t_dict_value
);

procedure remove(
    i_id                in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

end;
/
