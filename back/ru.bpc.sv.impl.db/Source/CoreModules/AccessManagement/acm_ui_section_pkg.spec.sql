create or replace package acm_ui_section_pkg as
/************************************************************
 * Provides an interface for managing menu section. <br />
 * Created by Filimonov A.(filimonov@bpc.ru)  at 12.10.2010 <br />
 * Module: ACM_UI_SECTION_PKG <br />
 * @headcom
 *************************************************************/
procedure add_menu_section(
    o_section_id           out  com_api_type_pkg.t_tiny_id
  , i_parent_id         in      com_api_type_pkg.t_tiny_id
  , i_action            in      com_api_type_pkg.t_name
  , i_section_type      in      com_api_type_pkg.t_dict_value
  , i_is_visible        in      com_api_type_pkg.t_boolean
  , i_display_order     in      com_api_type_pkg.t_tiny_id
  , i_caption           in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_managed_bean_name in      com_api_type_pkg.t_name
);

procedure modify_menu_section(
    i_section_id        in      com_api_type_pkg.t_tiny_id
  , i_parent_id         in      com_api_type_pkg.t_tiny_id
  , i_action            in      com_api_type_pkg.t_name
  , i_section_type      in      com_api_type_pkg.t_dict_value
  , i_is_visible        in      com_api_type_pkg.t_boolean
  , i_display_order     in      com_api_type_pkg.t_tiny_id
  , i_caption           in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_managed_bean_name in      com_api_type_pkg.t_name
) ;

procedure remove_menu_section(
    i_section_id        in      com_api_type_pkg.t_tiny_id
);

end acm_ui_section_pkg;
/
