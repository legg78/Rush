create or replace package body itf_cst_account_export_pkg is


function generate_add_data(
    i_account_id         in      com_api_type_pkg.t_account_id
)return xmltype 
is
    l_data    xmltype;
begin
    
    return l_data;

exception 
    when others then
        trc_log_pkg.error('Error when generate limits on account = ' || i_account_id);       
        trc_log_pkg.error(sqlerrm);       
        return null;
end;

function get_date_out_value(
    i_oper_id         in      com_api_type_pkg.t_long_id
)return date 
is
begin
    return null;
end;

function get_date_out_name(
    i_oper_id         in      com_api_type_pkg.t_long_id
)return com_api_type_pkg.t_name
is 
begin
    return null;
end;

end;
/
