create or replace function get_user_sandbox return com_api_type_pkg.t_inst_id is
begin
  return com_ui_user_env_pkg.get_user_sandbox;
end get_user_sandbox;
/
