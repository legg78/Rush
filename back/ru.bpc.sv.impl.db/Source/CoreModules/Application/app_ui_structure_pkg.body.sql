create or replace package body app_ui_structure_pkg as
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
) is
begin
    select app_structure_seq.nextval 
      into o_id
      from dual;

    insert into app_structure_vw (
        id
      , appl_type
      , element_id
      , parent_element_id
      , min_count
      , max_count
      , default_value
      , is_visible
      , is_updatable
      , display_order
      , is_info
      , lov_id
      , is_wizard
      , edit_form
      , is_parent_desc
    ) values (
        o_id
      , i_appl_type
      , i_element_id
      , i_parent_element_id
      , i_min_count
      , i_max_count
      , i_default_value
      , i_is_visible
      , i_is_updatable
      , i_display_order
      , i_is_info
      , i_lov_id
      , i_is_wizard
      , i_edit_form
      , i_is_parent_desc
    );
end add;

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
) is
begin
    update app_structure_vw
    set appl_type         = i_appl_type
      , element_id        = i_element_id
      , parent_element_id = i_parent_element_id
      , min_count         = i_min_count
      , max_count         = i_max_count
      , default_value     = i_default_value
      , is_visible        = i_is_visible
      , is_updatable      = i_is_updatable
      , display_order     = i_display_order
      , is_info           = i_is_info
      , lov_id            = i_lov_id
      , is_wizard         = i_is_wizard
      , edit_form         = i_edit_form
      , is_parent_desc    = i_is_parent_desc
    where id = i_id;
end modify;

procedure remove( 
    i_id                in     com_api_type_pkg.t_short_id
) is
begin
    delete from app_structure_vw
    where id = i_id;
end remove;

end app_ui_structure_pkg;
/
