create or replace package body mcw_cst_ird_pkg as

function get_default_ird return com_api_type_pkg.t_byte_char is
begin
    return '75';
end;

end;
/