create or replace package body fcl_cst_limit_pkg as

function get_limit_sum_withdraw(
    i_object_id            in   com_api_type_pkg.t_long_id
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_split_hash           in   com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_money
is
    l_debt_sum      com_api_type_pkg.t_money;
    l_auth_sum      com_api_type_pkg.t_money;
    l_result        com_api_type_pkg.t_money;
begin
    select nvl(sum(b.amount), 0)
      into l_debt_sum
      from crd_debt d
         , crd_debt_balance b
     where b.debt_id = d.id
       and b.split_hash = d.split_hash
       and b.split_hash = i_split_hash
       and b.balance_type in (
                               acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT
                             , acc_api_const_pkg.BALANCE_TYPE_OVERDUE
                             , acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT
                             )
       and d.oper_type in (
                            opr_api_const_pkg.OPERATION_TYPE_ATM_CASH  -- 'OPTP0001'
                          , opr_api_const_pkg.OPERATION_TYPE_POS_CASH  -- 'OPTP0012'
                          , opr_api_const_pkg.OPERATION_TYPE_UNIQUE    -- 'OPTP0018'
                          , opr_api_const_pkg.OPERATION_TYPE_CR_ADJUST_ACCNT  -- 'OPTP0412'
                          )
       and decode(d.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, d.account_id, null) = i_object_id;

    select nvl(sum(ae.amount * ae.balance_impact), 0)
      into l_auth_sum
      from acc_entry ae
         , acc_macros am
         , acc_account aa
         , acc_balance ab
         , acc_balance_type abt
         , (
            select oo.id
                 , oo.host_date
                 , oo.oper_date
                 , op.account_id
                 , op.split_hash
              from opr_operation oo
                 , opr_participant op
             where decode(oo.status, opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD, oo.id, null) = oo.id
               and oo.oper_type in (
                                     opr_api_const_pkg.OPERATION_TYPE_ATM_CASH  -- 'OPTP0001'
                                   , opr_api_const_pkg.OPERATION_TYPE_POS_CASH  -- 'OPTP0012'
                                   , opr_api_const_pkg.OPERATION_TYPE_UNIQUE    -- 'OPTP0018'
                                   , opr_api_const_pkg.OPERATION_TYPE_CR_ADJUST_ACCNT  -- 'OPTP0412'
                                   )
               and op.oper_id = oo.id
               and op.account_id = i_object_id
               and op.split_hash = i_split_hash
           ) o
     where aa.id               = o.account_id
       and ab.account_id       = aa.id
       and abt.inst_id         = aa.inst_id
       and abt.account_type    = aa.account_type
       and abt.balance_type    = ab.balance_type
       and am.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION -- 'ENTTOPER'
       and am.object_id        = o.id
       and ab.split_hash       = aa.split_hash
       and am.cancel_indicator = com_api_const_pkg.INDICATOR_NOT_CANCELED -- 'CNLINTCN'
       and ae.account_id       = aa.id
       and ae.split_hash       = aa.split_hash
       and ae.balance_type     = ab.balance_type
       and ae.macros_id        = am.id
       and ae.balance_type     = acc_api_const_pkg.BALANCE_TYPE_HOLD  -- 'BLTP0002'
       and ae.id              >= com_api_id_pkg.get_from_id(o.host_date);

    l_result := abs(l_debt_sum) + l_auth_sum;
    return l_result;
end get_limit_sum_withdraw;


procedure calculate_limit_counter_count(
    i_counter_algorithm    in   com_api_type_pkg.t_dict_value
  , i_eff_date             in   date                                default null
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_object_id            in   com_api_type_pkg.t_long_id
  , o_count_curr           out  com_api_type_pkg.t_long_id 
) is
begin
    o_count_curr := 0; 
end calculate_limit_counter_count;


procedure calculate_limit_counter_sum(
    i_counter_algorithm    in   com_api_type_pkg.t_dict_value
  , i_eff_date             in   date                                default null
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_object_id            in   com_api_type_pkg.t_long_id
  , o_sum_curr             out  com_api_type_pkg.t_money
) is
    l_split_hash         com_api_type_pkg.t_tiny_id;
begin
    l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);

    case i_counter_algorithm
    when cst_apc_const_pkg.ALG_CALC_LIMIT_WITHDRAW_CREDIT then
        o_sum_curr :=
            get_limit_sum_withdraw(
                i_object_id   => i_object_id
              , i_entity_type => i_entity_type
              , i_split_hash  => l_split_hash
            );
    else
        o_sum_curr := 0;
    end case;
end calculate_limit_counter_sum;

end fcl_cst_limit_pkg;
/
