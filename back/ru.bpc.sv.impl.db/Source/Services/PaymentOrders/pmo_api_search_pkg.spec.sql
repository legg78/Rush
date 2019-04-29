create or replace package pmo_api_search_pkg as
/************************************************************
 * API for search of payment orders and authorizations <br />
 * Created by Fomichev A.(fomichev@bpcbt.com)  at 15.02.2012  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: pmo_api_search_pkg <br />
 * @headcom
 ************************************************************/

function get_payment_params(
    i_payment_order_id      in      com_api_type_pkg.t_long_id
  , o_merchant_number          out  com_api_type_pkg.t_merchant_number
  , o_terminal_number          out  com_api_type_pkg.t_merchant_number
  , o_acq_inst_id              out  com_api_type_pkg.t_inst_id
  , o_mcc                      out  com_api_type_pkg.t_mcc
  , o_customer_id              out  com_api_type_pkg.t_medium_id
  , o_card_number              out  com_api_type_pkg.t_card_number
  , o_account_number           out  com_api_type_pkg.t_account_number
  , o_client_id_type           out  com_api_type_pkg.t_dict_value
  , o_client_id_value          out  com_api_type_pkg.t_name
  , o_purpose_id               out  com_api_type_pkg.t_short_id
  , o_payment_param_id_tab     out  com_api_type_pkg.t_number_tab
  , o_payment_param_val_tab    out  com_api_type_pkg.t_varchar2_tab
  , o_oper_type                out  com_api_type_pkg.t_dict_value
  , o_dst_customer_id          out  com_api_type_pkg.t_medium_id
  , o_dst_card_number          out  com_api_type_pkg.t_card_number
  , o_dst_account_number       out  com_api_type_pkg.t_account_number
  , o_dst_client_id_type       out  com_api_type_pkg.t_dict_value
  , o_dst_client_id_value      out  com_api_type_pkg.t_name
  , o_oper_amount              out  com_api_type_pkg.t_money
  , o_oper_request_amount      out  com_api_type_pkg.t_money
  , o_oper_currency            out  com_api_type_pkg.t_curr_code
  , o_oper_surcharge_amount    out  com_api_type_pkg.t_money
  , o_oper_amount_algorithm    out  com_api_type_pkg.t_dict_value
  , o_oper_id                  out  com_api_type_pkg.t_long_id
  , o_oper_date                out  date
  , o_cardseqnumber            out  com_api_type_pkg.t_tiny_id
  , o_cardexpirdate            out  date
  , o_dstaccounttype           out  com_api_type_pkg.t_dict_value
  , o_oper_reason              out  com_api_type_pkg.t_dict_value
  , o_split_hash               out  com_api_type_pkg.t_tiny_id
  , i_need_payment_params   in      com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_dict_value;

end pmo_api_search_pkg;
/
