create or replace function get_def_agent 
return com_api_type_pkg.t_agent_id is
begin
  return ost_api_const_pkg.DEFAULT_AGENT;
end get_def_agent;
/
