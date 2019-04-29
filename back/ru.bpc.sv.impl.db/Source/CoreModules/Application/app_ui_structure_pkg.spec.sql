create or replace package app_ui_structure_pkg as
/*******************************************************************
*  API for application's structure <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 04.08.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate:: $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_UI_STRUCTURE_PKG <br />
*  @headcom
******************************************************************/

procedure add(
    o_id                   out com_api_type_pkg.t_short_id
  , i_appl_type         in     com_api_type_pkg.t_dict_value
  , i_element_id        in     com_api_type_pkg.t_short_id
  , i_parent_element_id in     com_api_type_pkg.t_short_id
  , i_min_count         in     com_api_type_pkg.t_tiny_id
  , i_max_count         in     com_api_type_pkg.t_tiny_id
  , i_default_value     in     com_api_type_pkg.t_name
  , i_is_visible        in     com_api_type_pkg.t_boolean
  , i_is_updatable      in     com_api_type_pkg.t_boolean
  , i_display_order     in     com_api_type_pkg.t_tiny_id
  , i_is_info           in     com_api_type_pkg.t_boolean
  , i_lov_id            in     com_api_type_pkg.t_tiny_id
  , i_is_wizard         in     com_api_type_pkg.t_boolean
  , i_edit_form         in     com_api_type_pkg.t_name
  , i_is_parent_desc    in     com_api_type_pkg.t_boolean
);

procedure modify(
    i_id                in     com_api_type_pkg.t_short_id
  , i_appl_type         in     com_api_type_pkg.t_dict_value
  , i_element_id        in     com_api_type_pkg.t_short_id
  , i_parent_element_id in     com_api_type_pkg.t_short_id
  , i_min_count         in     com_api_type_pkg.t_tiny_id
  , i_max_count         in     com_api_type_pkg.t_tiny_id
  , i_default_value     in     com_api_type_pkg.t_name
  , i_is_visible        in     com_api_type_pkg.t_boolean
  , i_is_updatable      in     com_api_type_pkg.t_boolean
  , i_display_order     in     com_api_type_pkg.t_tiny_id
  , i_is_info           in     com_api_type_pkg.t_boolean
  , i_lov_id            in     com_api_type_pkg.t_tiny_id
  , i_is_wizard         in     com_api_type_pkg.t_boolean
  , i_edit_form         in     com_api_type_pkg.t_name
  , i_is_parent_desc    in     com_api_type_pkg.t_boolean
);

procedure remove( 
    i_id                in     com_api_type_pkg.t_short_id
);

end app_ui_structure_pkg;
/
