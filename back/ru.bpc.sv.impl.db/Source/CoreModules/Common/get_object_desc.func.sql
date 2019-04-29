create or replace function get_object_desc(

    i_entity_type   in    com_api_type_pkg.t_dict_value
  , i_object_id     in    com_api_type_pkg.t_long_id
  , i_lang          in    com_api_type_pkg.t_dict_value default get_user_lang
  , i_enable_empty  in    com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_text is

begin
    return com_ui_object_pkg.get_object_desc(
        i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
      , i_lang         => i_lang
      , i_enable_empty => i_enable_empty
    );

end get_object_desc;
/
