create or replace function get_def_inst return com_api_type_pkg.t_inst_id is
begin
  return ost_api_const_pkg.DEFAULT_INST;
end get_def_inst;
/
