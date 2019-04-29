create or replace function get_text 
( 
    i_table_name  in com_api_type_pkg.t_oracle_name
  , i_column_name in com_api_type_pkg.t_oracle_name
  , i_object_id   in com_api_type_pkg.t_long_id
  , i_lang        in com_api_type_pkg.t_dict_value default null  
)
 return com_api_type_pkg.t_text is
begin
  return com_api_i18n_pkg.get_text
  (
      i_table_name  => i_table_name
    , i_column_name => i_column_name
    , i_object_id   => i_object_id
    , i_lang        => i_lang 
  );

end get_text;
/
