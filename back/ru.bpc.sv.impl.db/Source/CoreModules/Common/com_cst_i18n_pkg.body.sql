create or replace package body com_cst_i18n_pkg is

function check_text_for_latin
return com_api_type_pkg.t_boolean is
begin
    return com_api_const_pkg.TRUE;
end check_text_for_latin;

end com_cst_i18n_pkg;
/
