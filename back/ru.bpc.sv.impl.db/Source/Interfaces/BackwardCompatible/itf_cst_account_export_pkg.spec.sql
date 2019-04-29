create or replace package itf_cst_account_export_pkg is

function generate_add_data(
    i_account_id         in      com_api_type_pkg.t_account_id
)return xmltype;

function get_date_out_value(
    i_oper_id         in      com_api_type_pkg.t_long_id
)return date;

function get_date_out_name(
    i_oper_id         in      com_api_type_pkg.t_long_id
)return com_api_type_pkg.t_name;

end;
/
