create or replace function get_release return com_api_type_pkg.t_name is
  begin
    return com_ui_version_pkg.get_release;
  end;
/
