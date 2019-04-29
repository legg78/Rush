create or replace package body acm_ui_section_pkg as
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
) is
begin
    select acm_section_seq.nextval into o_section_id from dual;

    insert into acm_section_vw(
        id
      , parent_id
      , section_type
      , action
      , is_visible
      , display_order
      , managed_bean_name
    ) values (
        o_section_id
      , i_parent_id
      , i_section_type
      , i_action
      , i_is_visible
      , i_display_order
      , i_managed_bean_name
    );

    com_api_i18n_pkg.add_text (
        i_table_name    =>  'acm_section'
      , i_column_name   =>  'caption'
      , i_object_id     =>  o_section_id
      , i_lang          =>  i_lang
      , i_text          =>  i_caption
    );

    com_api_i18n_pkg.add_text (
        i_table_name    =>  'acm_section'
      , i_column_name   =>  'description'
      , i_object_id     =>  o_section_id
      , i_lang          =>  i_lang
      , i_text          =>  i_description
    );

end;

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
) is
begin
    update acm_section_vw
       set parent_id     = i_parent_id
         , section_type  = i_section_type
         , action        = i_action
         , is_visible    = i_is_visible
         , display_order = i_display_order 
         , managed_bean_name = i_managed_bean_name
     where id            = i_section_id;

    com_api_i18n_pkg.add_text (
        i_table_name    =>  'acm_section'
      , i_column_name   =>  'caption'
      , i_object_id     =>  i_section_id
      , i_lang          =>  i_lang
      , i_text          =>  i_caption
    );

    com_api_i18n_pkg.add_text (
        i_table_name    =>  'acm_section'
      , i_column_name   =>  'description'
      , i_object_id     =>  i_section_id
      , i_lang          =>  i_lang
      , i_text          =>  i_description
    );

end;

procedure remove_menu_section(
    i_section_id        in      com_api_type_pkg.t_tiny_id
) is
begin
    delete acm_section_vw
     where id           = i_section_id;

    com_api_i18n_pkg.remove_text(
        i_table_name  =>  'acm_section'
      , i_object_id   =>  i_section_id
    );
end;

end;
/
