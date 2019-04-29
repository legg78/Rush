create or replace function convert_to_number(
    i_string        in   varchar2
) return number is
begin
    return com_api_type_pkg.convert_to_number(i_string);
end;
/
