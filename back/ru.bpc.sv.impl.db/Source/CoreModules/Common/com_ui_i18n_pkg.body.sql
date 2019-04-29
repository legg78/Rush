create or replace package body com_ui_i18n_pkg as

procedure add_text(
    i_table_name    in      com_api_type_pkg.t_oracle_name
  , i_column_name   in      com_api_type_pkg.t_oracle_name
  , i_object_id     in      com_api_type_pkg.t_long_id
  , i_text          in      com_api_type_pkg.t_text
  , i_lang          in      com_api_type_pkg.t_dict_value   default null
  , i_check_unique  in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
) is
begin
    com_api_i18n_pkg.add_text(
        i_table_name    => i_table_name
      , i_column_name   => i_column_name
      , i_object_id     => i_object_id
      , i_text          => i_text
      , i_lang          => i_lang
      , i_check_unique  => i_check_unique
    );
end;

end;
/