create or replace package body iss_cst_export_pkg is

/*
 * It returns XML structure with card limits, it is for using in SQL-query.
 */
function generate_add_data(
    i_card_id           in     com_api_type_pkg.t_medium_id
)return xmltype 
is
    l_data    xmltype;
begin
    
    return l_data;

exception 
    when others then
        trc_log_pkg.debug('FAILED on i_card_id [' || i_card_id || ']');
        trc_log_pkg.error(sqlerrm);       
        return null;
end;

/*
 * The tag DF8003 contains prd_customer.customer_number if this method returns FALSE.
 * And tag DF8003 contains prd_customer.customer_id if this method returns TRUE.
 */
function get_customer_value_type
    return com_api_type_pkg.t_boolean
is
begin
    return com_api_type_pkg.FALSE;
end;

end;
/
