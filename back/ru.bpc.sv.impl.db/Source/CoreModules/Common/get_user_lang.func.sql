create or replace function get_user_lang return com_api_type_pkg.t_dict_value is
begin
  return com_ui_user_env_pkg.get_user_lang;
end get_user_lang;
/
