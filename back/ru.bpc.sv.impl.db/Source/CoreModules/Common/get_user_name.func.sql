create or replace function get_user_name return com_api_type_pkg.t_name is
begin
  return com_ui_user_env_pkg.get_user_name;
end;
/
