create or replace package jcb_cst_merchant_pkg as
/**********************************************************
 * Custom processing of merchant.
 **********************************************************/
function get_merchant_commission_rate(
    i_merchant_rec           in jcb_api_type_pkg.t_merchant_rec
    , i_inst_id              in com_api_type_pkg.t_inst_id
)return com_api_type_pkg.t_tag;

end;
/
