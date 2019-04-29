create or replace function get_thread_number return com_api_type_pkg.t_tiny_id is
begin
  return prc_api_session_pkg.get_thread_number;
end get_thread_number;
/
