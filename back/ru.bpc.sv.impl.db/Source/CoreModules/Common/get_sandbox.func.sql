create or replace function get_sandbox(
    i_inst_id           in      com_api_type_pkg.t_inst_id := null
) return com_api_type_pkg.t_inst_id is
begin
    return ost_api_institution_pkg.get_sandbox(i_inst_id);
end get_sandbox;
/
