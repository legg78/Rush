create or replace package body acc_api_customer_pkg is
/********************************************************* 
 *  API for customer's accounts <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 05.12.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: acc_api_customer_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 

procedure get_customer_accounts(
    i_customer_id    in     com_api_type_pkg.t_medium_id
  , i_currency       in     com_api_type_pkg.t_curr_code
  , i_rate_type      in     com_api_type_pkg.t_dict_value
  , o_accounts          out sys_refcursor
) is
begin
    open o_accounts for
    select a.account_number
         , a.account_type
         , a.currency
         , a.status
         , round(nvl(sum(case b.balance_type when acc_api_const_pkg.BALANCE_TYPE_LEDGER 
                   then com_api_rate_pkg.convert_amount(
                            i_src_amount      => b.balance
                          , i_src_currency    => b.currency
                          , i_dst_currency    => a.currency
                          , i_rate_type       => t.rate_type
                          , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_BUYING
                          , i_inst_id         => a.inst_id
                          , i_eff_date        => get_sysdate
                          , i_mask_exception  => com_api_const_pkg.TRUE
                          , i_exception_value => null
                        )
                   else 0 end)
              , 0)) ledger_account_currency
         , round(nvl(sum(case b.balance_type when acc_api_const_pkg.BALANCE_TYPE_HOLD
                   then com_api_rate_pkg.convert_amount(
                            i_src_amount      => b.balance
                          , i_src_currency    => b.currency
                          , i_dst_currency    => a.currency
                          , i_rate_type       => t.rate_type
                          , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_BUYING
                          , i_inst_id         => a.inst_id
                          , i_eff_date        => get_sysdate
                          , i_mask_exception  => com_api_const_pkg.TRUE
                          , i_exception_value => null
                        )
                   else 0 end)
              , 0)) hold_account_currency
         , round(nvl(sum(case b.balance_type when acc_api_const_pkg.BALANCE_TYPE_HOLD
                   then com_api_rate_pkg.convert_amount(
                            i_src_amount      => b.balance
                          , i_src_currency    => b.currency
                          , i_dst_currency    => i_currency
                          , i_rate_type       => t.rate_type
                          , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_BUYING
                          , i_inst_id         => a.inst_id
                          , i_eff_date        => get_sysdate
                          , i_mask_exception  => com_api_const_pkg.TRUE
                          , i_exception_value => null
                        )
                   else 0 end)
              , 0)) hold_request_currency
         , round(nvl(sum(case b.balance_type when crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
                   then 
                       case when a.currency = b.currency then b.balance
                       else com_api_rate_pkg.convert_amount(
                                i_src_amount      => b.balance
                              , i_src_currency    => b.currency
                              , i_dst_currency    => a.currency
                              , i_rate_type       => t.rate_type
                              , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_BUYING
                              , i_inst_id         => a.inst_id
                              , i_eff_date        => get_sysdate
                              , i_mask_exception  => com_api_const_pkg.TRUE
                              , i_exception_value => null
                            )
                        end
                   else 0 end)
              , 0)) exceed_account_currency
         , round(nvl(sum(t.aval_impact * 
                       com_api_rate_pkg.convert_amount(
                            i_src_amount      => b.balance
                          , i_src_currency    => b.currency
                          , i_dst_currency    => i_currency
                          , i_rate_type       => i_rate_type
                          , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_BUYING
                          , i_inst_id         => a.inst_id
                          , i_eff_date        => get_sysdate
                          , i_mask_exception  => com_api_const_pkg.TRUE
                          , i_exception_value => null
                       )),0)) available_request_currency
         , round(nvl(sum(t.aval_impact * 
                       com_api_rate_pkg.convert_amount(
                            i_src_amount      => b.balance
                          , i_src_currency    => b.currency
                          , i_dst_currency    => a.currency
                          , i_rate_type       => i_rate_type
                          , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_BUYING
                          , i_inst_id         => a.inst_id
                          , i_eff_date        => get_sysdate
                          , i_mask_exception  => com_api_const_pkg.TRUE
                          , i_exception_value => null
                       )),0)) available_account_currency
      from acc_account a
         , acc_balance b
         , acc_balance_type t
     where a.customer_id  = i_customer_id 
       and b.account_id   = a.id
       and t.inst_id      = a.inst_id
       and t.account_type = a.account_type
       and t.balance_type = b.balance_type
  group by a.account_number
         , a.account_type
         , a.currency
         , a.status;
end;

end;
/
