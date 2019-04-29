create or replace function get_def_lang return com_api_type_pkg.t_dict_value is
begin
  return com_api_const_pkg.DEFAULT_LANGUAGE;
end get_def_lang;
/
