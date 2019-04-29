create or replace package iss_cst_export_pkg as

/*
 * It returns XML structure with card limits, it is for using in SQL-query.
 */
function generate_add_data(
    i_card_id         in      com_api_type_pkg.t_medium_id
) return xmltype;

/*
 * The tag DF8003 contains prd_customer.customer_number if this method returns FALSE.
 * And tag DF8003 contains prd_customer.customer_id if this method returns TRUE.
 */
function get_customer_value_type
    return com_api_type_pkg.t_boolean;

end iss_cst_export_pkg;
/
