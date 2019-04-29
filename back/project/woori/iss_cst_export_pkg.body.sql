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
select 
    xmlelement("add_data"
      , xmlelement("usage_hybrid_threshold", nvl(prd_api_product_pkg.get_attr_value_number (
                                                    i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
                                                  , i_object_id         => i_card_id
                                                  , i_attr_name         => 'ISS_USAGE_HYBRID_THRESHOLD'
                                                  , i_mask_error        => com_api_type_pkg.TRUE
                                                )
                                              , 0))
    )
    into l_data 
    from dual;
    
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
