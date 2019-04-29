create or replace function get_timestamp_format return com_api_type_pkg.t_name is
begin
    return com_api_const_pkg.TIMESTAMP_FORMAT;
end;
/
