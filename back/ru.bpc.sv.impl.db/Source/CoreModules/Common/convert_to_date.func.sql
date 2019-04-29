create or replace function convert_to_date(
    i_string        in   varchar2
) return date is
begin
    return com_api_type_pkg.convert_to_date(i_string);
end;
/
