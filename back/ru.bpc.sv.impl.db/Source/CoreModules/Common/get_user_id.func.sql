create or replace function get_user_id return com_api_type_pkg.t_short_id is
begin
  return com_ui_user_env_pkg.get_user_id;
end get_user_id;
/
