create or replace function get_label_text(
    i_name                in     com_api_type_pkg.t_short_desc
  , i_lang                in     com_api_type_pkg.t_dict_value default null
) return com_api_type_pkg.t_short_desc is
begin
    return 
        com_api_label_pkg.get_label_text(
           i_name => i_name
         , i_lang => i_lang
        );
end;
/
