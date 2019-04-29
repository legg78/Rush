create or replace package app_ui_element_pkg as
/*********************************************************
*  Application - UI for elements <br />
*  Created by Filimonov A.(filimonov@bpcbt.com)  at 23.10.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_UI_ELEMENT_PKG <br />
*  @headcom
**********************************************************/
procedure add_element(
    o_element_id           out  com_api_type_pkg.t_short_id
  , i_element_name      in      com_api_type_pkg.t_name
  , i_element_type      in      com_api_type_pkg.t_dict_value
  , i_data_type         in      com_api_type_pkg.t_dict_value
  , i_min_length        in      com_api_type_pkg.t_tiny_id
  , i_max_length        in      com_api_type_pkg.t_tiny_id
  , i_min_value         in      com_api_type_pkg.t_name
  , i_max_value         in      com_api_type_pkg.t_name
  , i_lov_id            in      com_api_type_pkg.t_tiny_id
  , i_default_value     in      com_api_type_pkg.t_name
  , i_is_multilang      in      com_api_type_pkg.t_boolean
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_edit_form         in      com_api_type_pkg.t_name
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_full_desc         in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
);

procedure add_desc(
    i_element_name      in      com_api_type_pkg.t_name
  , i_short_desc        in      com_api_type_pkg.t_short_desc
  , i_full_desc         in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
);

end;
/
