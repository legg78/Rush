create or replace function get_session_id return com_api_type_pkg.t_long_id is
begin
 return prc_api_session_pkg.get_session_id;
end get_session_id;
/
