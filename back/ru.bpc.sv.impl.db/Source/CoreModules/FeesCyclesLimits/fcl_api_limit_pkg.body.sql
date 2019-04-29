create or replace package body fcl_api_limit_pkg as
/*****************************************************************
* API for limits
* Created by Filimonov A.(filimonov@bpc.ru)  at 07.08.2009
* Last changed by $Author$
* $LastChangedDate::                           $
* Revision: $LastChangedRevision$
* Module: FCL_API_LIMIT_PKG
* @headcom
*****************************************************************/
g_limit_buffer_tab      fcl_api_type_pkg.t_limit_buffer_tab;
g_limit_bulk_tab        fcl_api_type_pkg.t_limit_buffer_tab;
--g_limit_history_tab     fcl_api_type_pkg.t_limit_history_tab;

function get_limit_count_withdraw(
    i_object_id            in   com_api_type_pkg.t_long_id
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_split_hash           in   com_api_type_pkg.t_tiny_id          
) return com_api_type_pkg.t_long_id 
is
    l_debt_count      com_api_type_pkg.t_tiny_id;
    l_auth_count      com_api_type_pkg.t_tiny_id;
    l_result          com_api_type_pkg.t_long_id;
begin
    select count(*) 
      into l_debt_count
      from crd_debt d
         , crd_debt_balance b 
     where b.debt_id = d.id
       and b.split_hash = d.split_hash
       and b.split_hash = i_split_hash 
       and b.balance_type in (acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT, acc_api_const_pkg.BALANCE_TYPE_OVERDUE, acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT)
       and d.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                         , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                         , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
                         , opr_api_const_pkg.OPERATION_TYPE_CR_ADJUST_ACCNT)
       and decode(d.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, d.account_id, null) = i_object_id;

    select count(*)
      into l_auth_count
      from opr_operation o
         , aut_auth a
         , opr_participant p  
     where decode(o.status, opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD, o.id, null) = a.id
       and o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                         , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                         , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
                         , opr_api_const_pkg.OPERATION_TYPE_CR_ADJUST_ACCNT)
       and p.oper_id = o.id                     
       and p.account_id = i_object_id   
       and p.split_hash = i_split_hash;
       
    l_result := l_debt_count + l_auth_count;   
    return l_result;
    
end;

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
       and b.balance_type in (acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT, acc_api_const_pkg.BALANCE_TYPE_OVERDUE, acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT)
       and d.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                         , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                         , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
                         , opr_api_const_pkg.OPERATION_TYPE_CR_ADJUST_ACCNT)
       and decode(d.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, d.account_id, null) = i_object_id;

    select nvl(sum(oper_sum - balance), 0)
      into l_auth_sum  
      from (      
        select x.id
             , x.host_date
             , x.account_id
             , case
                   when x.oper_currency = b.currency
                   then x.oper_amount
                   when x.sttl_currency = b.currency
                   then x.sttl_amount
                   when x.sttl_currency is null or x.sttl_amount is null
                   then com_api_rate_pkg.convert_amount(x.oper_amount, x.oper_currency, b.currency, t.rate_type, a.inst_id, x.oper_date)
                   else com_api_rate_pkg.convert_amount(x.sttl_amount, x.sttl_currency, b.currency, t.rate_type, a.inst_id, x.oper_date)
               end as oper_sum
             , b.balance - nvl(sum(e.amount * e.balance_impact), 0) as balance
          from acc_entry e
             , acc_balance b
             , acc_account a
             , acc_balance_type t
             , (
                select o.oper_amount
                     , o.oper_currency
                     , o.sttl_amount
                     , o.sttl_currency
                     , o.host_date 
                     , o.oper_date 
                     , p.account_id
                     , p.split_hash 
                     , o.id
                  from opr_operation o
                     , aut_auth a
                     , opr_participant p  
                 where decode(o.status, opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD, o.id, null) = a.id
                   and o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                     , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                                     , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
                                     , opr_api_const_pkg.OPERATION_TYPE_CR_ADJUST_ACCNT)
                   and p.oper_id = o.id                     
                   and p.account_id = i_object_id   
                   and p.split_hash = i_split_hash
             ) x
         where x.account_id    = e.account_id      
           and x.split_hash    = e.split_hash              
           and e.balance_type  = acc_api_const_pkg.BALANCE_TYPE_LEDGER
           and x.account_id    = b.account_id
           and b.balance_type  = e.balance_type
           and x.split_hash    = b.split_hash
           and e.posting_date >= x.host_date     
           and e.id(+)        >= com_api_id_pkg.get_from_id(x.host_date)
           and a.id            = x.account_id
           and t.account_type  = a.account_type
           and t.inst_id       = a.inst_id
           and b.balance_type  = t.balance_type
      group by x.host_date
             , x.account_id
             , x.oper_amount
             , x.oper_currency
             , b.balance
             , x.id
             , x.sttl_amount
             , x.sttl_currency
             , b.currency
             , t.rate_type
             , a.inst_id
             , x.oper_date
      order by x.id                              
        );
       
    l_result := l_debt_sum + l_auth_sum;   
    return l_result;
end;

function get_limit_count_spending_card(
    i_object_id            in   com_api_type_pkg.t_long_id
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_split_hash           in   com_api_type_pkg.t_tiny_id          
) return com_api_type_pkg.t_long_id 
is
    l_debt_count      com_api_type_pkg.t_tiny_id;
    l_auth_count      com_api_type_pkg.t_tiny_id;
    l_result          com_api_type_pkg.t_long_id;
begin
    --get count debt of card
    select count(*)  
      into l_debt_count
      from crd_debt d
         , crd_debt_balance b 
     where b.debt_id = d.id
       and b.split_hash = d.split_hash
       and b.split_hash = i_split_hash 
       and b.balance_type in (acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT, acc_api_const_pkg.BALANCE_TYPE_OVERDUE, acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT)
       and decode(d.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, d.card_id, null) = i_object_id;       
 
    --get count auth of card
    select count(*)
      into l_auth_count
      from opr_operation o
         , aut_auth a
         , opr_participant p  
     where decode(o.status, opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD, o.id, null) = a.id
       and p.oper_id = o.id
       and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER                     
       and p.card_id = i_object_id   
       and p.split_hash = i_split_hash;           
              
    l_result := l_debt_count + l_auth_count;   
    return l_result;
    
end;

function get_limit_sum_spending_card(
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
       and b.balance_type in (acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT, acc_api_const_pkg.BALANCE_TYPE_OVERDUE, acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT)
       and decode(d.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, d.card_id, null) = i_object_id;

    select nvl(sum(e.amount * e.balance_impact), 0)
      into l_auth_sum
      from opr_operation o
         , opr_participant p 
         , acc_entry e 
         , acc_macros m
     where o.status in (opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD, opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD)
       and p.oper_id          = o.id                     
       and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER                     
       and p.card_id          = i_object_id   
       and p.split_hash       = i_split_hash
       and m.object_id        = o.id
       and m.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and e.macros_id        = m.id
       and e.status           != acc_api_const_pkg.ENTRY_STATUS_CANCELED
       and e.split_hash       = p.split_hash
       and e.id               >= com_api_id_pkg.get_from_id(o.id);
       
    l_result := l_debt_sum + l_auth_sum;   
    return l_result;
end;

function get_limit_count_spending_cust(
    i_object_id            in   com_api_type_pkg.t_long_id
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_split_hash           in   com_api_type_pkg.t_tiny_id          
) return com_api_type_pkg.t_long_id 
is
    l_debt_count      com_api_type_pkg.t_tiny_id;
    l_auth_count      com_api_type_pkg.t_tiny_id;
    l_result          com_api_type_pkg.t_long_id;
begin
    -- get count debt of card
    select count(*)  
      into l_debt_count
      from acc_account a
         , crd_debt d
         , crd_debt_balance b 
     where d.account_id  = a.id
       and a.split_hash  = d.split_hash
       and b.debt_id     = d.id
       and b.split_hash  = d.split_hash
       and b.balance_type in (acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT, acc_api_const_pkg.BALANCE_TYPE_OVERDUE, acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT)
       and d.status      = crd_api_const_pkg.DEBT_STATUS_ACTIVE
       and a.customer_id = i_object_id
       and a.split_hash  = i_split_hash;

    -- get count auth of card
    select count(*)
      into l_auth_count
      from opr_operation o
         , aut_auth a
         , opr_participant p
     where decode(o.status, opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD, o.id, null) = a.id
       and p.oper_id          = o.id
       and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
       and p.customer_id      = i_object_id
       and p.split_hash       = i_split_hash;

    l_result := l_debt_count + l_auth_count;

    return l_result;
end;

function get_limit_sum_spending_cust(
    i_object_id            in   com_api_type_pkg.t_long_id
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_split_hash           in   com_api_type_pkg.t_tiny_id
  , i_currency             in   com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_money 
is
    l_debt_sum       com_api_type_pkg.t_money;
    l_auth_sum       com_api_type_pkg.t_money;
    l_result         com_api_type_pkg.t_money;
    l_service_id     com_api_type_pkg.t_short_id;
    l_curr_rate_type com_api_type_pkg.t_dict_value;
    l_inst_id        com_api_type_pkg.t_inst_id;
    l_eff_date       date;
    l_params         com_api_type_pkg.t_param_tab;
begin
    l_inst_id := ost_api_institution_pkg.get_object_inst_id(
        i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_mask_errors   => com_api_const_pkg.TRUE
    );
    l_eff_date := com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id);
    
    l_service_id := prd_api_service_pkg.get_active_service_id(
        i_entity_type      => i_entity_type
      , i_object_id        => i_object_id
      , i_attr_name        => null
      , i_service_type_id  => prd_api_const_pkg.CUSTOMER_MAINTENANCE_SERVICE
      , i_eff_date         => l_eff_date
      , i_mask_error       => com_api_const_pkg.TRUE
      , i_inst_id          => l_inst_id
    );
    
    if l_service_id is not null then
        l_curr_rate_type := prd_api_product_pkg.get_attr_value_char(
            i_product_id   => prd_api_product_pkg.get_product_id(
                                  i_entity_type => i_entity_type
                                , i_object_id   => i_object_id
                                , i_eff_date    => l_eff_date
                                , i_inst_id     => l_inst_id
                              )
          , i_entity_type  => i_entity_type
          , i_object_id    => i_object_id
          , i_attr_name    => prd_api_const_pkg.CUST_CRED_LIMIT_EXCH_RATE_TYPE
          , i_params       => l_params
          , i_service_id   => l_service_id
          , i_eff_date     => l_eff_date
          , i_inst_id      => l_inst_id
        );
        
        select sum(case
                       when a.currency = i_currency 
                           then 
                               nvl(b.amount, 0)
                           else
                               round(
                                   com_api_rate_pkg.convert_amount(
                                       i_src_amount          => nvl(b.amount, 0)
                                     , i_src_currency        => a.currency
                                     , i_dst_currency        => i_currency
                                     , i_rate_type           => l_curr_rate_type
                                     , i_inst_id             => l_inst_id
                                     , i_eff_date            => l_eff_date
                                     , i_mask_exception      => com_api_type_pkg.FALSE
                                     , i_exception_value     => null
                                     , i_conversion_type     => null
                                   )
                               )
                   end
               )
          into l_debt_sum
          from acc_account a
             , crd_debt d
             , crd_debt_balance b 
         where b.debt_id     = d.id
           and a.split_hash  = d.split_hash
           and a.id          = d.account_id
           and b.split_hash  = d.split_hash
           and b.split_hash  = i_split_hash
           and b.balance_type in (acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT, acc_api_const_pkg.BALANCE_TYPE_OVERDUE, acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT)
           and d.status      = crd_api_const_pkg.DEBT_STATUS_ACTIVE
           and a.customer_id = i_object_id
           and a.split_hash  = i_split_hash;

        select nvl(sum(
                       case
                           when e.currency = i_currency 
                               then 
                                   nvl(e.amount, 0)
                               else
                                   round(
                                       com_api_rate_pkg.convert_amount(
                                           i_src_amount          => nvl(e.amount, 0)
                                         , i_src_currency        => e.currency
                                         , i_dst_currency        => i_currency
                                         , i_rate_type           => l_curr_rate_type
                                         , i_inst_id             => l_inst_id
                                         , i_eff_date            => l_eff_date
                                         , i_mask_exception      => com_api_type_pkg.FALSE
                                         , i_exception_value     => null
                                         , i_conversion_type     => null
                                       )
                                   ) * e.balance_impact
                       end
                  ), 0)
          into l_auth_sum
          from opr_operation o
             , opr_participant p
             , acc_entry e
             , acc_macros m
         where o.status in (opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD)
           and p.oper_id          = o.id
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and p.customer_id      = i_object_id
           and p.split_hash       = i_split_hash
           and m.object_id        = o.id
           and m.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and e.macros_id        = m.id
           and e.status           != acc_api_const_pkg.ENTRY_STATUS_CANCELED
           and e.split_hash       = p.split_hash
           and e.id               >= com_api_id_pkg.get_from_id(o.id);
           
        l_result := l_debt_sum + l_auth_sum;
    end if;
    
    return l_result;
end;

function get_limit_count_threshold_mod( 
    i_object_id      in   com_api_type_pkg.t_long_id
  , i_entity_type    in   com_api_type_pkg.t_dict_value
  , i_split_hash     in   com_api_type_pkg.t_tiny_id
  , i_limit_id       in   com_api_type_pkg.t_long_id
  , i_limit_type     in   com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_long_id 
is
    l_result        com_api_type_pkg.t_long_id;
    l_count_curr    com_api_type_pkg.t_long_id;
    l_count_value   com_api_type_pkg.t_long_id;
    l_sum_value     com_api_type_pkg.t_money;
begin
    begin
        select count_value
          into l_count_curr
          from fcl_limit_counter
         where entity_type = i_entity_type
           and object_id   = i_object_id
           and limit_type  = i_limit_type
           and split_hash  = i_split_hash;
    exception when no_data_found then
        l_count_curr := 0;
    end;
    
    get_limit_value(
        i_limit_id     => i_limit_id
      , o_sum_value    => l_sum_value
      , o_count_value  => l_count_value
    );
    
    l_result := mod(l_count_curr, l_count_value);
    
    return l_result;
end;

function get_limit_sum_threshold_mod( 
    i_object_id      in   com_api_type_pkg.t_long_id
  , i_entity_type    in   com_api_type_pkg.t_dict_value
  , i_split_hash     in   com_api_type_pkg.t_tiny_id
  , i_limit_id       in   com_api_type_pkg.t_long_id
  , i_limit_type     in   com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_long_id 
is
    l_result        com_api_type_pkg.t_money;
    l_sum_curr      com_api_type_pkg.t_money;
    l_count_value   com_api_type_pkg.t_long_id;
    l_sum_value     com_api_type_pkg.t_money;
begin
    begin
        select sum_value
          into l_sum_curr
          from fcl_limit_counter
         where entity_type = i_entity_type
           and object_id   = i_object_id
           and limit_type  = i_limit_type
           and split_hash  = i_split_hash;
    exception when no_data_found then
        l_sum_curr := 0;
    end;
    
    get_limit_value(
        i_limit_id     => i_limit_id
      , o_sum_value    => l_sum_value
      , o_count_value  => l_count_value
    );
    
    l_result := mod(l_sum_curr, l_sum_value);
    
    return l_result;
end;

function get_limit_cnt_wthdrw_less_fee(
    i_object_id            in   com_api_type_pkg.t_long_id
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_split_hash           in   com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_long_id
is
    l_debt_count      com_api_type_pkg.t_tiny_id;
    l_auth_count      com_api_type_pkg.t_tiny_id;
    l_result          com_api_type_pkg.t_long_id;
begin
    select count(*)
      into l_debt_count
      from crd_debt d
         , crd_debt_balance b
         , acc_macros m
     where b.debt_id = d.id
       and b.split_hash = d.split_hash
       and b.split_hash = i_split_hash
       and b.balance_type in (acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT, acc_api_const_pkg.BALANCE_TYPE_OVERDUE, acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT)
       and d.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                         , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                         , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
                         , opr_api_const_pkg.OPERATION_TYPE_CR_ADJUST_ACCNT)
       and decode(d.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, d.account_id, null) = i_object_id
       and m.id = d.id
       and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and m.amount_purpose not in (com_api_const_pkg.AMOUNT_PURPOSE_FEE_AMOUNT
                                  , com_api_const_pkg.AMOUNT_ORIGINAL_FEE)
       and m.amount_purpose not like fcl_api_const_pkg.FEE_TYPE_STATUS_KEY || '%';

    select count(*)
      into l_auth_count
      from opr_operation o
         , aut_auth a
         , opr_participant p
     where decode(o.status, opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD, o.id, null) = a.id
       and o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                         , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                         , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
                         , opr_api_const_pkg.OPERATION_TYPE_CR_ADJUST_ACCNT)
       and p.oper_id = o.id
       and p.account_id = i_object_id
       and p.split_hash = i_split_hash;
       
    l_result := l_debt_count + l_auth_count;
    return l_result;
end;

function get_limit_sum_wthdrw_less_fee(
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
         , acc_macros m
     where b.debt_id = d.id
       and b.split_hash = d.split_hash
       and b.split_hash = i_split_hash
       and b.balance_type in (acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT, acc_api_const_pkg.BALANCE_TYPE_OVERDUE, acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT)
       and d.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                         , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                         , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
                         , opr_api_const_pkg.OPERATION_TYPE_CR_ADJUST_ACCNT)
       and decode(d.status, crd_api_const_pkg.DEBT_STATUS_ACTIVE, d.account_id, null) = i_object_id
       and m.id = d.id
       and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and m.amount_purpose not in (com_api_const_pkg.AMOUNT_PURPOSE_FEE_AMOUNT
                                  , com_api_const_pkg.AMOUNT_ORIGINAL_FEE)
       and m.amount_purpose not like fcl_api_const_pkg.FEE_TYPE_STATUS_KEY || '%';

    select nvl(sum(end_sum), 0)
      into l_auth_sum  
      from (
        select x.id
             , x.host_date
             , x.account_id
             , x.oper_amount - (b.balance - nvl(sum(e.amount * e.balance_impact), 0)) end_sum
            from acc_entry e
               , acc_balance b
               , (
                  select o.oper_amount
                       , o.host_date
                       , o.oper_date
                       , p.account_id
                       , p.split_hash
                       , o.id
                    from opr_operation o
                       , aut_auth a
                       , opr_participant p
                   where decode(o.status, opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD, o.id, null) = a.id
                     and o.oper_type in (opr_api_const_pkg.OPERATION_TYPE_ATM_CASH
                                       , opr_api_const_pkg.OPERATION_TYPE_POS_CASH
                                       , opr_api_const_pkg.OPERATION_TYPE_UNIQUE
                                       , opr_api_const_pkg.OPERATION_TYPE_CR_ADJUST_ACCNT)
                     and p.oper_id = o.id
                     and p.account_id = i_object_id
                     and p.split_hash = i_split_hash
               ) x
           where x.account_id   = e.account_id
             and x.split_hash   = e.split_hash
             and e.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
             and x.account_id   = b.account_id
             and b.balance_type = e.balance_type
             and x.split_hash   = b.split_hash
             and e.posting_date >= x.host_date
             and e.id(+) >= com_api_id_pkg.get_from_id(x.host_date)
          group by x.host_date
             , x.account_id
             , x.oper_amount
             , b.balance
             , x.id
         order by x.id
        );

    l_result := l_debt_sum + l_auth_sum;
    return l_result;
end;

function get_limit_cnt_spend_cus_inter(
    i_object_id            in   com_api_type_pkg.t_long_id
  , i_entity_type          in   com_api_type_pkg.t_dict_value

  , i_split_hash           in   com_api_type_pkg.t_tiny_id          
) return com_api_type_pkg.t_long_id 
is
    l_debt_count                com_api_type_pkg.t_tiny_id;
    l_auth_count                com_api_type_pkg.t_tiny_id;
    l_result                    com_api_type_pkg.t_long_id;
begin
    select count(*)  
      into l_debt_count
      from acc_account a
         , crd_debt d
         , crd_debt_balance b 
     where d.account_id  = a.id
       and a.split_hash  = d.split_hash
       and b.debt_id     = d.id
       and b.split_hash  = d.split_hash
       and b.balance_type in (
               acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT
             , acc_api_const_pkg.BALANCE_TYPE_OVERDUE
             , acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT
             , acc_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
             , crd_api_const_pkg.BALANCE_TYPE_INTEREST
           )
       and d.status      = crd_api_const_pkg.DEBT_STATUS_ACTIVE
       and a.customer_id = i_object_id
       and a.split_hash  = i_split_hash;

    select count(*)
      into l_auth_count
      from opr_operation o
         , aut_auth a
         , opr_participant p
     where decode(o.status, opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD, o.id, null) = a.id
       and p.oper_id          = o.id
       and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
       and p.customer_id      = i_object_id
       and p.split_hash       = i_split_hash;

    l_result := l_debt_count + l_auth_count;

    return l_result;
end;

function get_limit_sum_spend_cus_inter(
    i_object_id            in   com_api_type_pkg.t_long_id
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_split_hash           in   com_api_type_pkg.t_tiny_id
  , i_currency             in   com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_money 
is
    l_debt_sum                  com_api_type_pkg.t_money;
    l_auth_sum                  com_api_type_pkg.t_money;
    l_result                    com_api_type_pkg.t_money;
    l_service_id                com_api_type_pkg.t_short_id;
    l_curr_rate_type            com_api_type_pkg.t_dict_value;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_eff_date                  date;
    l_params                    com_api_type_pkg.t_param_tab;
begin
    l_inst_id := ost_api_institution_pkg.get_object_inst_id(
        i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_mask_errors   => com_api_const_pkg.TRUE
    );
    l_eff_date := com_api_sttl_day_pkg.get_calc_date(i_inst_id => l_inst_id);
    
    l_service_id := prd_api_service_pkg.get_active_service_id(
        i_entity_type     => i_entity_type
      , i_object_id       => i_object_id
      , i_attr_name       => null
      , i_service_type_id => prd_api_const_pkg.CUSTOMER_MAINTENANCE_SERVICE
      , i_eff_date        => l_eff_date
      , i_mask_error      => com_api_const_pkg.TRUE
      , i_inst_id         => l_inst_id
    );
    
    if l_service_id is not null then
        l_curr_rate_type := prd_api_product_pkg.get_attr_value_char(
            i_product_id  => prd_api_product_pkg.get_product_id(
                                 i_entity_type => i_entity_type
                               , i_object_id   => i_object_id
                               , i_eff_date    => l_eff_date
                               , i_inst_id     => l_inst_id
                             )
          , i_entity_type => i_entity_type
          , i_object_id   => i_object_id
          , i_attr_name   => prd_api_const_pkg.CUST_CRED_LIMIT_EXCH_RATE_TYPE
          , i_params      => l_params
          , i_service_id  => l_service_id
          , i_eff_date    => l_eff_date
          , i_inst_id     => l_inst_id
        );
        
        select sum(case
                       when a.currency = i_currency 
                           then 
                               nvl(b.amount, 0)
                           else
                               round(
                                   com_api_rate_pkg.convert_amount(
                                       i_src_amount          => nvl(b.amount, 0)
                                     , i_src_currency        => a.currency
                                     , i_dst_currency        => i_currency
                                     , i_rate_type           => l_curr_rate_type
                                     , i_inst_id             => l_inst_id
                                     , i_eff_date            => l_eff_date
                                     , i_mask_exception      => com_api_type_pkg.FALSE
                                     , i_exception_value     => null
                                     , i_conversion_type     => null
                                   )
                               )
                   end
               )
          into l_debt_sum
          from acc_account a
             , crd_debt d
             , crd_debt_balance b 
         where b.debt_id     = d.id
           and a.split_hash  = d.split_hash
           and a.id          = d.account_id
           and b.split_hash  = d.split_hash
           and b.split_hash  = i_split_hash
           and b.balance_type in (
                   acc_api_const_pkg.BALANCE_TYPE_OVERDRAFT
                 , acc_api_const_pkg.BALANCE_TYPE_OVERDUE
                 , acc_api_const_pkg.BALANCE_TYPE_OVERLIMIT
                 , acc_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
                 , crd_api_const_pkg.BALANCE_TYPE_INTEREST
               )
           and d.status      = crd_api_const_pkg.DEBT_STATUS_ACTIVE
           and a.customer_id = i_object_id
           and a.split_hash  = i_split_hash;

        select nvl(sum(
                       case
                           when e.currency = i_currency 
                               then 
                                   nvl(e.amount, 0)
                               else
                                   round(
                                       com_api_rate_pkg.convert_amount(
                                           i_src_amount          => nvl(e.amount, 0)
                                         , i_src_currency        => e.currency
                                         , i_dst_currency        => i_currency
                                         , i_rate_type           => l_curr_rate_type
                                         , i_inst_id             => l_inst_id
                                         , i_eff_date            => l_eff_date
                                         , i_mask_exception      => com_api_type_pkg.FALSE
                                         , i_exception_value     => null
                                         , i_conversion_type     => null
                                       )
                                   ) * e.balance_impact
                       end
                  ), 0)
          into l_auth_sum
          from opr_operation o
             , opr_participant p
             , acc_entry e
             , acc_macros m
         where o.status in (opr_api_const_pkg.OPERATION_STATUS_AWAITS_UNHOLD)
           and p.oper_id          = o.id
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and p.customer_id      = i_object_id
           and p.split_hash       = i_split_hash
           and m.object_id        = o.id
           and m.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and e.macros_id        = m.id
           and e.status           != acc_api_const_pkg.ENTRY_STATUS_CANCELED
           and e.split_hash       = p.split_hash
           and e.id               >= com_api_id_pkg.get_from_id(o.id);
           
        l_result := l_debt_sum + l_auth_sum;
    end if;
    
    return l_result;
end;

procedure calculate_limit_counter_count(
  i_counter_algorithm      in   com_api_type_pkg.t_dict_value
  , i_eff_date             in   date                            default null                             
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_object_id            in   com_api_type_pkg.t_long_id
  , i_split_hash           in   com_api_type_pkg.t_tiny_id          
  , o_count_curr           out  com_api_type_pkg.t_long_id 
  , i_limit_type           in   com_api_type_pkg.t_dict_value   default null
  , i_product_id           in   com_api_type_pkg.t_long_id      default null
  , i_limit_id             in   com_api_type_pkg.t_long_id      default null
) is
begin
    case i_counter_algorithm
        when fcl_api_const_pkg.ALG_CALC_LIMIT_WITHDRAW_CREDIT then
            o_count_curr := get_limit_count_withdraw(
                                i_object_id   => i_object_id
                              , i_entity_type => i_entity_type
                              , i_split_hash  => i_split_hash
                            );
        when fcl_api_const_pkg.ALG_CALC_LIMIT_SPENDING_CARD then
            o_count_curr := get_limit_count_spending_card(
                                i_object_id   => i_object_id
                              , i_entity_type => i_entity_type
                              , i_split_hash  => i_split_hash
                            );
        when fcl_api_const_pkg.ALG_CALC_LIMIT_SPENDING_CUST then
            o_count_curr := get_limit_count_spending_cust(
                                i_object_id   => i_object_id
                              , i_entity_type => i_entity_type
                              , i_split_hash  => i_split_hash
                            );
        when fcl_api_const_pkg.ALG_CALC_LIMIT_THRESHOLD_MOD then
            o_count_curr := get_limit_count_threshold_mod(
                                i_object_id   => i_object_id
                              , i_entity_type => i_entity_type
                              , i_split_hash  => i_split_hash
                              , i_limit_id    => i_limit_id
                              , i_limit_type  => i_limit_type
                            );
        when fcl_api_const_pkg.ALG_CALC_LIMIT_WTHDRW_LESS_FEE then
            o_count_curr := get_limit_cnt_wthdrw_less_fee(
                                i_object_id   => i_object_id 
                              , i_entity_type => i_entity_type 
                              , i_split_hash  => i_split_hash
                            );
        when fcl_api_const_pkg.ALG_CALC_LIMIT_SPEND_CUS_INTER then
            o_count_curr := get_limit_cnt_spend_cus_inter(
                                i_object_id   => i_object_id
                              , i_entity_type => i_entity_type
                              , i_split_hash  => i_split_hash
                            );
        else
            --cst algorithm
            fcl_cst_limit_calc_pkg.calculate_limit_counter_count(
                  i_counter_algorithm    => i_counter_algorithm
                , i_eff_date             => i_eff_date
                , i_entity_type          => i_entity_type
                , i_object_id            => i_object_id 
                , o_count_curr           => o_count_curr
                , i_limit_type           => i_limit_type
                , i_product_id           => i_product_id
                , i_limit_id             => i_limit_id
            );               
    end case;
end;

procedure calculate_limit_counter_sum(
  i_counter_algorithm      in   com_api_type_pkg.t_dict_value
  , i_eff_date             in   date                            default null                             
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_object_id            in   com_api_type_pkg.t_long_id
  , i_split_hash           in   com_api_type_pkg.t_tiny_id          
  , o_sum_curr             out  com_api_type_pkg.t_money 
  , i_limit_type           in   com_api_type_pkg.t_dict_value   default null
  , i_product_id           in   com_api_type_pkg.t_long_id      default null
  , i_limit_id             in   com_api_type_pkg.t_long_id      default null
  , i_currency             in   com_api_type_pkg.t_curr_code    default null
) is
begin
    case i_counter_algorithm
        when fcl_api_const_pkg.ALG_CALC_LIMIT_WITHDRAW_CREDIT then
            o_sum_curr := get_limit_sum_withdraw(
                              i_object_id   => i_object_id
                            , i_entity_type => i_entity_type
                            , i_split_hash  => i_split_hash
                          );
        when fcl_api_const_pkg.ALG_CALC_LIMIT_SPENDING_CARD then
            o_sum_curr := get_limit_sum_spending_card(
                              i_object_id   => i_object_id
                            , i_entity_type => i_entity_type
                            , i_split_hash  => i_split_hash
                          );
        when fcl_api_const_pkg.ALG_CALC_LIMIT_SPENDING_CUST then
            o_sum_curr := get_limit_sum_spending_cust(
                              i_object_id   => i_object_id
                            , i_entity_type => i_entity_type
                            , i_split_hash  => i_split_hash
                            , i_currency    => i_currency
                          );
        when fcl_api_const_pkg.ALG_CALC_LIMIT_THRESHOLD_MOD then
            o_sum_curr := get_limit_sum_threshold_mod(
                              i_object_id   => i_object_id
                            , i_entity_type => i_entity_type
                            , i_split_hash  => i_split_hash
                            , i_limit_id    => i_limit_id
                            , i_limit_type  => i_limit_type
                          );
        when fcl_api_const_pkg.ALG_CALC_LIMIT_WTHDRW_LESS_FEE then
            o_sum_curr := get_limit_sum_wthdrw_less_fee(
                              i_object_id   => i_object_id 
                            , i_entity_type => i_entity_type 
                            , i_split_hash  => i_split_hash
                          );
        when fcl_api_const_pkg.ALG_CALC_LIMIT_SPEND_CUS_INTER then
            o_sum_curr := get_limit_sum_spend_cus_inter(
                              i_object_id   => i_object_id
                            , i_entity_type => i_entity_type
                            , i_split_hash  => i_split_hash
                            , i_currency    => i_currency
                          );
        else
            --cst algorithm
            fcl_cst_limit_calc_pkg.calculate_limit_counter_sum(
                  i_counter_algorithm    => i_counter_algorithm
                , i_eff_date             => i_eff_date
                , i_entity_type          => i_entity_type
                , i_object_id            => i_object_id 
                , o_sum_curr             => o_sum_curr
                , i_limit_type           => i_limit_type
                , i_product_id           => i_product_id
                , i_limit_id             => i_limit_id
            );               
    end case;
end;

procedure get_limit_count_curr(
  i_limit_type             in   com_api_type_pkg.t_dict_value
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_object_id            in   com_api_type_pkg.t_long_id
  , i_eff_date             in   date                            default null                             
  , i_split_hash           in   com_api_type_pkg.t_tiny_id      default null          
  , i_product_id           in   com_api_type_pkg.t_short_id     default null
  , i_limit_id             in   com_api_type_pkg.t_long_id      default null
  , o_last_reset_date      out  date
  , o_count_curr           out  com_api_type_pkg.t_long_id 
)is
    l_eff_date          date;
    l_prev_date         date;
    l_next_date         date;
    l_id                com_api_type_pkg.t_long_id;
    l_limit_id          com_api_type_pkg.t_long_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_counter_algorithm com_api_type_pkg.t_dict_value;
    l_product_id        com_api_type_pkg.t_short_id;
    l_params            com_api_type_pkg.t_param_tab;
    l_cycle_type        com_api_type_pkg.t_dict_value;

begin
    trc_log_pkg.debug('get_limit_count_curr: '
        ||' i_limit_type ='|| i_limit_type
        ||', i_entity_type='||i_entity_type
        ||', i_object_id='||i_object_id
        ||', i_eff_date='||i_eff_date
        ||', i_split_hash='||i_split_hash
    );

    if i_product_id is null then    
        l_product_id := prd_api_product_pkg.get_product_id(
            i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
        );        
    else
        l_product_id := i_product_id;
    end if;    
        
    l_eff_date := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;
    
    if i_limit_id is null then
        l_limit_id :=
            prd_api_product_pkg.get_limit_id(
                i_product_id        => l_product_id
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_limit_type        => i_limit_type
              , i_params            => l_params
              , i_split_hash        => l_split_hash
              , i_eff_date          => l_eff_date
            );
    else
        l_limit_id := i_limit_id;
    end if;        

    begin
        select nvl(b.counter_algorithm, a.counter_algorithm)
             , b.cycle_type
          into l_counter_algorithm
             , l_cycle_type
          from fcl_limit a
             , fcl_limit_type b
         where a.id         = l_limit_id
           and a.limit_type = b.limit_type;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'LIMIT_NOT_FOUND'
              , i_env_param1    => l_limit_id
            );
    end;
    
    if l_counter_algorithm is null then   
     
        if l_cycle_type is not null then
        
            fcl_api_cycle_pkg.get_cycle_date(
                i_cycle_type        => l_cycle_type
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_split_hash        => l_split_hash
              , i_add_counter       => com_api_type_pkg.FALSE
              , o_prev_date         => l_prev_date
              , o_next_date         => l_next_date
            );

        end if;

        if l_next_date is not null and l_next_date <= l_eff_date then

            o_count_curr := 0;
            o_last_reset_date   := null; 
        else
            begin
                select case when trunc(l_eff_date) >= trunc(last_reset_date) or last_reset_date is null then count_value
                            else nvl(prev_count_value, 0)
                       end
                     , last_reset_date
                     , id
                  into o_count_curr
                     , o_last_reset_date
                     , l_id
                  from fcl_limit_counter
                 where entity_type = i_entity_type
                   and object_id   = i_object_id
                   and limit_type  = i_limit_type
                   and split_hash  = l_split_hash;                   
                   
                trc_log_pkg.debug('limit_counter found, '
                    ||', o_count_value ='||  o_count_curr
                    ||', o_last_reset_date='||o_last_reset_date||', id='||l_id);
            
            exception
                when no_data_found then
                    o_count_curr        := 0; 
                    o_last_reset_date   := null; 
            end;
        end if;
        
    else
        calculate_limit_counter_count(
          i_counter_algorithm   => l_counter_algorithm 
          , i_eff_date          => l_eff_date
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_split_hash        => l_split_hash          
          , o_count_curr        => o_count_curr 
          , i_limit_type        => i_limit_type
          , i_product_id        => i_product_id
          , i_limit_id          => i_limit_id
        );
    end if;
end;

procedure get_limit_sum_curr(
  i_limit_type             in   com_api_type_pkg.t_dict_value
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_object_id            in   com_api_type_pkg.t_long_id
  , i_eff_date             in   date                            default null                             
  , i_split_hash           in   com_api_type_pkg.t_tiny_id      default null          
  , i_product_id           in   com_api_type_pkg.t_short_id     default null
  , i_limit_id             in   com_api_type_pkg.t_long_id      default null
  , o_last_reset_date      out  date
  , o_sum_curr             out  com_api_type_pkg.t_money 
)is
    l_eff_date          date;
    l_prev_date         date;
    l_next_date         date;
    l_id                com_api_type_pkg.t_long_id;
    l_limit_id          com_api_type_pkg.t_long_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_counter_algorithm com_api_type_pkg.t_dict_value;
    l_product_id        com_api_type_pkg.t_short_id;
    l_params            com_api_type_pkg.t_param_tab;
    l_cycle_type        com_api_type_pkg.t_dict_value;
    l_currency          com_api_type_pkg.t_curr_code;

begin
    trc_log_pkg.debug('get_limit_sum_curr: '
        ||' i_limit_type ='|| i_limit_type
        ||', i_entity_type='||i_entity_type
        ||', i_object_id='||i_object_id
        ||', i_eff_date='||i_eff_date
        ||', i_split_hash='||i_split_hash
    );

    l_eff_date := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;
    
    if i_limit_id is null then
        if i_product_id is null then    
            l_product_id := prd_api_product_pkg.get_product_id(
                i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
            );        
        else
            l_product_id := i_product_id;
        end if;    

        l_limit_id :=
            prd_api_product_pkg.get_limit_id(
                i_product_id        => l_product_id
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_limit_type        => i_limit_type
              , i_params            => l_params
              , i_split_hash        => l_split_hash
              , i_eff_date          => l_eff_date
            );
    else
        l_limit_id := i_limit_id;
    end if;        

    begin
        select nvl(b.counter_algorithm, a.counter_algorithm)
             , b.cycle_type
             , a.currency
          into l_counter_algorithm
             , l_cycle_type
             , l_currency
          from fcl_limit a
             , fcl_limit_type b
         where a.id         = l_limit_id
           and a.limit_type = b.limit_type;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'LIMIT_NOT_FOUND'
              , i_env_param1    => l_limit_id
            );
    end;
    
    if l_counter_algorithm is null then   
     
        if l_cycle_type is not null then
        
            fcl_api_cycle_pkg.get_cycle_date(
                i_cycle_type        => l_cycle_type
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_split_hash        => l_split_hash
              , i_add_counter       => com_api_type_pkg.FALSE
              , o_prev_date         => l_prev_date
              , o_next_date         => l_next_date
            );

        end if;

        if l_next_date is not null and l_next_date <= l_eff_date then

            o_sum_curr          := 0;
            o_last_reset_date   := null; 
        else
            begin
                select case when l_eff_date >= last_reset_date or last_reset_date is null then sum_value
                            else nvl(prev_sum_value, 0)
                       end
                     , last_reset_date
                     , id
                  into o_sum_curr
                     , o_last_reset_date
                     , l_id
                  from fcl_limit_counter
                 where entity_type = i_entity_type
                   and object_id   = i_object_id
                   and limit_type  = i_limit_type
                   and split_hash  = l_split_hash;                   
                   
                trc_log_pkg.debug('limit_counter found, sum_value ='|| o_sum_curr
                    ||', o_last_reset_date='||o_last_reset_date||', id='||l_id);
            
            exception
                when no_data_found then
                    o_sum_curr          := 0; 
                    o_last_reset_date   := null; 
            end;
        end if;
        
    else
        calculate_limit_counter_sum(
          i_counter_algorithm   => l_counter_algorithm 
          , i_eff_date          => l_eff_date
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_split_hash        => l_split_hash          
          , o_sum_curr          => o_sum_curr 
          , i_limit_type        => i_limit_type
          , i_product_id        => i_product_id
          , i_limit_id          => i_limit_id
          , i_currency          => l_currency
        );
    end if;
end;

procedure get_limit_counter(
    i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_params            in      com_api_type_pkg.t_param_tab
  , io_currency         in out  com_api_type_pkg.t_curr_code
  , i_eff_date          in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , o_last_reset_date      out  date
  , o_count_curr           out  com_api_type_pkg.t_long_id 
  , o_count_limit          out  com_api_type_pkg.t_long_id 
  , o_sum_limit            out  com_api_type_pkg.t_money
  , o_sum_curr             out  com_api_type_pkg.t_money
) is
    l_eff_date          date;
    l_limit_id          com_api_type_pkg.t_long_id;
    l_currency          com_api_type_pkg.t_curr_code;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_rate_type         com_api_type_pkg.t_dict_value;
    l_cycle_type        com_api_type_pkg.t_dict_value;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_counter_algorithm com_api_type_pkg.t_dict_value;
begin

    trc_log_pkg.debug('get_limit_counter: '
        ||' i_limit_type ='|| i_limit_type
        ||', i_entity_type='||i_entity_type
        ||', i_object_id='||i_object_id
        ||', i_eff_date='||i_eff_date
        ||', io_currency='||io_currency
        ||', i_split_hash='||i_split_hash
    );

    l_eff_date := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;
    
    l_limit_id :=
        prd_api_product_pkg.get_limit_id(
            i_product_id        => i_product_id
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_limit_type        => i_limit_type
          , i_params            => i_params
          , i_split_hash        => l_split_hash
          , i_eff_date          => l_eff_date
        );

    begin
        select a.currency
             , a.inst_id
             , a.sum_limit
             , a.count_limit
             , b.cycle_type
             , nvl(b.counter_algorithm, a.counter_algorithm)
          into l_currency
             , l_inst_id
             , o_sum_limit
             , o_count_limit
             , l_cycle_type
             , l_counter_algorithm
          from fcl_limit a
             , fcl_limit_type b
         where a.id         = l_limit_id
           and a.limit_type = b.limit_type;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'LIMIT_NOT_FOUND'
              , i_env_param1    => l_limit_id
            );
    end;
    
    get_limit_count_curr(
      i_limit_type             => i_limit_type
      , i_entity_type          => i_entity_type
      , i_object_id            => i_object_id
      , i_eff_date             => l_eff_date                             
      , i_split_hash           => l_split_hash          
      , i_product_id           => i_product_id
      , i_limit_id             => l_limit_id
      , o_last_reset_date      => o_last_reset_date
      , o_count_curr           => o_count_curr 
    );
            
    get_limit_sum_curr(
      i_limit_type             => i_limit_type
      , i_entity_type          => i_entity_type
      , i_object_id            => i_object_id
      , i_eff_date             => l_eff_date                             
      , i_split_hash           => l_split_hash          
      , i_product_id           => i_product_id
      , i_limit_id             => l_limit_id 
      , o_last_reset_date      => o_last_reset_date
      , o_sum_curr             => o_sum_curr 
    );
        
    /* 
    if l_counter_algorithm is null then   
     
        if l_cycle_type is not null then
        
            fcl_api_cycle_pkg.get_cycle_date(
                i_cycle_type        => l_cycle_type
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_split_hash        => l_split_hash
              , i_add_counter       => com_api_type_pkg.FALSE
              , o_prev_date         => l_prev_date
              , o_next_date         => l_next_date
            );

        end if;

        if l_next_date is not null and l_next_date <= l_eff_date then

            o_sum_curr   := 0;
            o_count_curr := 0;
            o_last_reset_date   := null; 
        else
            begin
                select case when l_eff_date >= last_reset_date or last_reset_date is null then sum_value
                            else nvl(prev_sum_value, 0)
                       end
                     , case when l_eff_date >= last_reset_date or last_reset_date is null then count_value
                            else nvl(prev_count_value, 0)
                       end
                     , last_reset_date
                     , id
                  into o_sum_curr
                     , o_count_curr
                     , o_last_reset_date
                     , l_id
                  from fcl_limit_counter
                 where entity_type = i_entity_type
                   and object_id   = i_object_id
                   and limit_type  = i_limit_type
                   and split_hash  = l_split_hash;
                   
                   
                trc_log_pkg.debug('limit_counter found, sum_value ='|| o_sum_curr
                    ||', o_count_value ='||  o_count_curr
                    ||', o_last_reset_date='||o_last_reset_date||', id='||l_id);
            
            exception
                when no_data_found then
                    o_sum_curr          := 0; 
                    o_count_curr        := 0; 
                    o_last_reset_date   := null; 
        --            com_api_error_pkg.raise_error( 
        --                i_error         => 'LIMIT_COUNTER_NOT_FOUND' 
        --              , i_env_param1    => i_limit_type 
        --              , i_env_param2    => i_entity_type 
        --              , i_env_param3    => i_object_id 
        --              , i_entity_type   => i_entity_type 
        --              , i_object_id     => i_object_id 
        --            );     
            end;
        end if;
        
    else
       -- calculate_limit_counter(
       --   i_counter_algorithm => l_counter_algorithm 
        --  , i_eff_date          => l_eff_date
        --  , i_entity_type       => i_entity_type
       --   , i_object_id         => i_object_id
       --   , i_split_hash        => l_split_hash          
       --   , o_count_curr        => o_count_curr 
       --   , o_sum_curr          => o_sum_curr
      --  );
        null;
    end if;
      */
        
    if io_currency is not null and l_currency != io_currency  then
        begin
            select r.rate_type
              into l_rate_type
              from fcl_limit_rate r
             where r.inst_id = l_inst_id
               and r.limit_type = i_limit_type;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'LIMIT_RATE_TYPE_NOT_FOUND'
                  , i_env_param1    => i_limit_type
                  , i_env_param2    => l_inst_id
                );
        end;

        if o_sum_limit > 0 then
            o_sum_limit := round(
                com_api_rate_pkg.convert_amount(
                    i_src_amount        => o_sum_limit
                  , i_src_currency      => l_currency       -- currency of limit
                  , i_dst_currency      => io_currency      -- incoming currency
                  , i_rate_type         => l_rate_type
                  , i_inst_id           => l_inst_id
                  , i_eff_date          => l_eff_date
                ));
        end if;    

        o_sum_curr := round(
            com_api_rate_pkg.convert_amount(
                i_src_amount        => o_sum_curr
              , i_src_currency      => l_currency       -- currency of limit
              , i_dst_currency      => io_currency      -- incoming currency
              , i_rate_type         => l_rate_type
              , i_inst_id           => l_inst_id
              , i_eff_date          => l_eff_date
            ));
    else
        io_currency := l_currency;
    end if;
end;

procedure flush_limit_buffer is
begin
    trc_log_pkg.debug('flush_limit_buffer');
    forall i in 1..g_limit_buffer_tab.count
        insert into fcl_limit_buffer(
            id
          , entity_type
          , object_id
          , limit_type
          , count_value
          , sum_value
          , split_hash
        ) values (
            fcl_limit_buffer_seq.nextval
          , g_limit_buffer_tab(i).entity_type
          , g_limit_buffer_tab(i).object_id
          , g_limit_buffer_tab(i).limit_type
          , g_limit_buffer_tab(i).count_value
          , g_limit_buffer_tab(i).sum_value
          , g_limit_buffer_tab(i).split_hash
        );

    g_limit_buffer_tab.delete;

    forall i in 1..g_limit_bulk_tab.count
        update fcl_limit_counter
           set sum_value   = greatest(nvl(sum_value, 0) + g_limit_bulk_tab(i).sum_value, 0)
             , count_value = greatest(nvl(count_value, 0) + g_limit_bulk_tab(i).count_value, 0)
         where entity_type = g_limit_bulk_tab(i).entity_type
           and object_id   = g_limit_bulk_tab(i).object_id
           and limit_type  = g_limit_bulk_tab(i).limit_type
           and split_hash  = g_limit_bulk_tab(i).split_hash;

    g_limit_bulk_tab.delete;

--    forall i in 1..g_limit_history_tab.count
--        insert into fcl_limit_history(
--            id
--          , entity_type
--          , object_id
--          , limit_type
--          , count_value
--          , sum_value
--          , source_entity_type
--          , source_object_id
--          , split_hash
--        ) values (
--            fcl_limit_history_seq.nextval
--          , g_limit_history_tab(i).entity_type
--          , g_limit_history_tab(i).object_id
--          , g_limit_history_tab(i).limit_type
--          , g_limit_history_tab(i).count_value
--          , g_limit_history_tab(i).sum_value
--          , g_limit_history_tab(i).source_entity_type
--          , g_limit_history_tab(i).source_object_id
--          , g_limit_history_tab(i).split_hash
--        );

--    g_limit_history_tab.delete;

end;

procedure put_limit_history (
    i_limit_type          in    com_api_type_pkg.t_dict_value
  , i_entity_type         in    com_api_type_pkg.t_dict_value
  , i_object_id           in    com_api_type_pkg.t_long_id
  , i_count_value         in    com_api_type_pkg.t_long_id
  , i_sum_value           in    com_api_type_pkg.t_money
  , i_source_entity_type  in    com_api_type_pkg.t_dict_value
  , i_source_object_id    in    com_api_type_pkg.t_long_id
  , i_split_hash          in    com_api_type_pkg.t_tiny_id
) is
begin
    insert into fcl_limit_history(
        id
      , entity_type
      , object_id
      , limit_type
      , count_value
      , sum_value
      , source_entity_type
      , source_object_id
      , split_hash
    ) values (
        com_api_id_pkg.get_id(fcl_limit_history_seq.nextval, to_date(substr(to_char(i_source_object_id),1,6),'yymmdd'))
      , i_entity_type
      , i_object_id
      , i_limit_type
      , i_count_value
      , i_sum_value
      , i_source_entity_type
      , i_source_object_id
      , i_split_hash
    );
end;

procedure get_limit_border(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_limit_base        in      com_api_type_pkg.t_dict_value
  , i_limit_rate        in      com_api_type_pkg.t_money
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_lock_balance      in      com_api_type_pkg.t_boolean          default com_api_const_pkg.TRUE
  , i_mask_error        in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , o_border_sum       out      com_api_type_pkg.t_money
  , o_border_cnt       out      com_api_type_pkg.t_long_id
) is
    l_limit_id        com_api_type_pkg.t_long_id;
    l_params          com_api_type_pkg.t_param_tab;
    l_amount_rec      com_api_type_pkg.t_amount_rec;
    l_sum             com_api_type_pkg.t_money;
    l_rate_type       com_api_type_pkg.t_dict_value;
    l_entity_type     com_api_type_pkg.t_dict_value;
    l_dst_entity_type com_api_type_pkg.t_dict_value;
    l_id_tab          com_api_type_pkg.t_number_tab; 
    l_split_hash      com_api_type_pkg.t_tiny_id;
    l_lock_balance    com_api_type_pkg.t_boolean     := nvl(i_lock_balance, com_api_const_pkg.TRUE);
begin

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    o_border_sum   := null;
    o_border_cnt   := null;
    l_entity_type  := i_entity_type;

    if i_limit_base like 'BLTP%' then
        l_dst_entity_type := acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;
    else
        select a.entity_type
          into l_dst_entity_type
          from prd_attribute a
         where a.object_type     = i_limit_base;
    end if;

    if  l_entity_type      = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
    and l_dst_entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD then
        select object_id
          bulk collect into l_id_tab
          from acc_account_object
         where entity_type = l_dst_entity_type
           and account_id  = i_object_id
           and split_hash  = l_split_hash;
    elsif l_entity_type      = iss_api_const_pkg.ENTITY_TYPE_CARD
      and l_dst_entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then

        select account_id
          bulk collect into l_id_tab
          from acc_account_object
         where entity_type   = l_entity_type
           and object_id     = i_object_id
           and split_hash    = l_split_hash;  

    elsif l_entity_type = l_dst_entity_type
      and (l_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD 
           or
           l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          )
      then
          l_id_tab(l_id_tab.count+1) :=  i_object_id;
    end if;
    
    for i in nvl(l_id_tab.first, 1) .. nvl(l_id_tab.last,0) loop
    
        if i_limit_base like 'LMTP%' then
            l_limit_id := prd_api_product_pkg.get_limit_id(
                              i_product_id      => i_product_id
                            , i_entity_type     => l_dst_entity_type
                            , i_object_id       => l_id_tab(i)
                            , i_limit_type      => i_limit_base
                            , i_params          => l_params
                            , i_split_hash      => l_split_hash
                            , i_eff_date        => get_sysdate
                            , i_inst_id         => i_inst_id 
                            , i_mask_error      => i_mask_error
                          );

              select sum_limit
                   , count_limit
                into l_sum
                   , o_border_cnt
                from fcl_limit
               where id = l_limit_id;
               
        elsif i_limit_base like 'BLTP%' then
            l_amount_rec :=
                acc_api_balance_pkg.get_balance_amount(
                    i_account_id    => l_id_tab(i)
                  , i_balance_type  => i_limit_base
                  , i_mask_error    => i_mask_error
                  , i_lock_balance  => l_lock_balance
                );
            if l_amount_rec.currency != i_currency then
                begin
                    select r.rate_type
                      into l_rate_type
                      from fcl_limit_rate r
                     where r.inst_id    = i_inst_id
                       and r.limit_type = i_limit_type;
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error(
                            i_error        => 'LIMIT_RATE_TYPE_NOT_FOUND'
                          , i_env_param1   => i_limit_type
                          , i_env_param2   => i_inst_id
                        );
                end;

                l_sum := 
                    com_api_rate_pkg.convert_amount(
                        i_src_amount      => l_amount_rec.amount
                      , i_src_currency    => l_amount_rec.currency
                      , i_dst_currency    => i_currency
                      , i_rate_type       => l_rate_type
                      , i_inst_id         => i_inst_id
                      , i_eff_date        => get_sysdate
                    );
            else
               l_sum := l_amount_rec.amount;
            end if;
            
            o_border_cnt := -1;
    
        end if;

    end loop;
    o_border_sum  := round(l_sum * i_limit_rate / 100);
    
end;

function get_limit_border_sum(
    i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_limit_base           in      com_api_type_pkg.t_dict_value
  , i_limit_rate           in      com_api_type_pkg.t_money
  , i_currency             in      com_api_type_pkg.t_curr_code
  , i_inst_id              in      com_api_type_pkg.t_inst_id
  , i_product_id           in      com_api_type_pkg.t_short_id
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_mask_error           in      com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_money
is
    l_border_sum        com_api_type_pkg.t_money;
    l_border_count      com_api_type_pkg.t_long_id;
begin

    get_limit_border(
        i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_limit_type    => i_limit_type
      , i_limit_base    => i_limit_base
      , i_limit_rate    => i_limit_rate
      , i_currency      => i_currency
      , i_inst_id       => i_inst_id
      , i_product_id    => i_product_id
      , i_split_hash    => i_split_hash
      , i_lock_balance  => com_api_type_pkg.FALSE
      , i_mask_error    => i_mask_error
      , o_border_sum    => l_border_sum
      , o_border_cnt    => l_border_count
    );

    return l_border_sum;

end;

function get_limit_border_count(
    i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_limit_base           in      com_api_type_pkg.t_dict_value
  , i_limit_rate           in      com_api_type_pkg.t_money
  , i_currency             in      com_api_type_pkg.t_curr_code
  , i_inst_id              in      com_api_type_pkg.t_inst_id
  , i_product_id           in      com_api_type_pkg.t_short_id
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_mask_error           in      com_api_type_pkg.t_boolean         default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id
is
    l_border_sum        com_api_type_pkg.t_money;
    l_border_count      com_api_type_pkg.t_long_id;
begin

    get_limit_border(
        i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_limit_type    => i_limit_type
      , i_limit_base    => i_limit_base
      , i_limit_rate    => i_limit_rate
      , i_currency      => i_currency
      , i_inst_id       => i_inst_id
      , i_product_id    => i_product_id
      , i_split_hash    => i_split_hash
      , i_lock_balance  => com_api_type_pkg.FALSE
      , i_mask_error    => i_mask_error
      , o_border_sum    => l_border_sum
      , o_border_cnt    => l_border_count
    );

    return l_border_count;

end;

procedure switch_limit_counter(
    i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_count_value       in      com_api_type_pkg.t_long_id          default null
  , i_sum_value         in      com_api_type_pkg.t_money
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_eff_date          in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_check_overlimit   in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , i_switch_limit      in      com_api_type_pkg.t_boolean          default com_api_const_pkg.TRUE
  , i_source_entity_type in     com_api_type_pkg.t_dict_value       default null
  , i_source_object_id   in     com_api_type_pkg.t_long_id          default null
  , o_count_curr           out  com_api_type_pkg.t_long_id 
  , o_count_limit          out  com_api_type_pkg.t_long_id 
  , o_currency             out  com_api_type_pkg.t_curr_code
  , o_sum_value            out  com_api_type_pkg.t_money
  , o_sum_limit            out  com_api_type_pkg.t_money
  , o_sum_curr             out  com_api_type_pkg.t_money
  , i_service_id        in      com_api_type_pkg.t_short_id         default null
  , i_test_mode         in      com_api_type_pkg.t_dict_value       default fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
  , i_use_base_currency in      com_api_type_pkg.t_boolean          default com_api_const_pkg.TRUE
) is
    l_sum_value         com_api_type_pkg.t_money        := 0;
    l_count_value       com_api_type_pkg.t_long_id      := 0;
    l_posting_method    com_api_type_pkg.t_dict_value;
    l_cycle_type        com_api_type_pkg.t_dict_value;
    l_limit_id          com_api_type_pkg.t_long_id;
    l_eff_date          date;
    l_next_date         date;
    l_prev_date         date;
    l_last_reset_date   date;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_count             pls_integer;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_rate_type         com_api_type_pkg.t_dict_value;
    l_limit_base        com_api_type_pkg.t_dict_value;
    l_limit_rate        com_api_type_pkg.t_money;
    l_check_type        com_api_type_pkg.t_dict_value;
    l_counter_algorithm com_api_type_pkg.t_dict_value;
    l_params            com_api_type_pkg.t_param_tab := i_params;
begin
    trc_log_pkg.debug('switch_limit_counter, limit_type ='||i_limit_type 
     ||', i_entity_type ='||i_entity_type
     ||', i_object_id='||i_object_id
     ||', i_test_mode='||i_test_mode);
     
    if i_test_mode not in (
        fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
      , fcl_api_const_pkg.ATTR_MISS_UNBOUNDED_VALUE
      , fcl_api_const_pkg.ATTR_MISS_PROHIBITIVE_VALUE
    ) then
        com_api_error_pkg.raise_error(
            i_error     =>  'WRONG_TEST_MODE'
        );
    end if; 
  
    l_eff_date   := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);

    if i_inst_id is null then
        l_inst_id := ost_api_institution_pkg.get_object_inst_id(i_entity_type, i_object_id);
    else
        l_inst_id := i_inst_id;
    end if;

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    rul_api_param_pkg.set_param(
        io_params  => l_params
      , i_name     => 'SUM_VALUE'
      , i_value    => i_sum_value
    );

    begin
        l_limit_id :=
            prd_api_product_pkg.get_limit_id(
                i_product_id      => i_product_id
              , i_entity_type     => i_entity_type
              , i_object_id       => i_object_id
              , i_limit_type      => i_limit_type
              , i_params          => l_params
              , i_split_hash      => l_split_hash
              , i_service_id      => i_service_id
              , i_eff_date        => l_eff_date
              , i_inst_id         => l_inst_id
            );
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error in ('PRD_NO_ACTIVE_SERVICE', 'LIMIT_NOT_DEFINED', 'FEE_NOT_DEFINED') then
                if i_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
                    raise;
                elsif i_test_mode = fcl_api_const_pkg.ATTR_MISS_UNBOUNDED_VALUE then -- -1
                    o_count_curr    := fcl_api_const_pkg.LIMIT_COUNT_UNBOUNDED_VALUE;
                    o_count_limit   := fcl_api_const_pkg.LIMIT_COUNT_UNBOUNDED_VALUE;
                    o_sum_value     := fcl_api_const_pkg.LIMIT_SUM_UNBOUNDED_VALUE;
                    o_sum_limit     := fcl_api_const_pkg.LIMIT_SUM_UNBOUNDED_VALUE;
                    o_sum_curr      := fcl_api_const_pkg.LIMIT_SUM_UNBOUNDED_VALUE;
                    o_currency      := com_api_const_pkg.UNDEFINED_CURRENCY;
                    return;
                elsif i_test_mode = fcl_api_const_pkg.ATTR_MISS_PROHIBITIVE_VALUE then -- 0
                    o_count_curr    := fcl_api_const_pkg.LIMIT_COUNT_PROHIBITIVE_VALUE;
                    o_count_limit   := fcl_api_const_pkg.LIMIT_COUNT_PROHIBITIVE_VALUE;
                    o_sum_value     := fcl_api_const_pkg.LIMIT_SUM_PROHIBITIVE_VALUE;
                    o_sum_limit     := fcl_api_const_pkg.LIMIT_SUM_PROHIBITIVE_VALUE;
                    o_sum_curr      := fcl_api_const_pkg.LIMIT_SUM_PROHIBITIVE_VALUE;
                    o_currency      := com_api_const_pkg.UNDEFINED_CURRENCY;
                    return;
                end if;
            else
                raise;
            end if;
    end;

    begin
        select nvl(b.posting_method, a.posting_method)
             , a.limit_base
             , a.limit_rate
             , b.cycle_type
             , a.currency
             , a.sum_limit
             , a.count_limit
             , nvl(a.check_type, fcl_api_const_pkg.CHECK_TYPE_OR)
             , nvl(b.counter_algorithm, a.counter_algorithm)
          into l_posting_method
             , l_limit_base
             , l_limit_rate
             , l_cycle_type
             , o_currency
             , o_sum_limit
             , o_count_limit
             , l_check_type
             , l_counter_algorithm
          from fcl_limit a
             , fcl_limit_type b
         where a.id         = l_limit_id
           and a.limit_type = b.limit_type;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'LIMIT_NOT_FOUND'
              , i_env_param1    => l_limit_id
            );
    end;

    if l_counter_algorithm is null then
        begin
            select last_reset_date
                 , sum_value
                 , count_value
              into l_last_reset_date
                 , o_sum_curr
                 , o_count_curr
              from fcl_limit_counter
             where entity_type      = i_entity_type
               and object_id        = i_object_id
               and limit_type       = i_limit_type
               and split_hash       = l_split_hash;
        exception
            when no_data_found then
                add_limit_counter(
                    i_limit_type   => i_limit_type
                  , i_entity_type  => i_entity_type
                  , i_object_id    => i_object_id
                  , i_eff_date     => i_eff_date
                  , i_split_hash   => l_split_hash
                  , i_inst_id      => l_inst_id
                );
                o_sum_curr   := 0;
                o_count_curr := 0;
        end;
    else
        calculate_limit_counter_sum(
          i_counter_algorithm      => l_counter_algorithm
          , i_eff_date             => l_eff_date
          , i_entity_type          => i_entity_type
          , i_object_id            => i_object_id
          , i_split_hash           => l_split_hash
          , o_sum_curr             => o_sum_curr
          , i_limit_type           => i_limit_type
          , i_product_id           => i_product_id
          , i_limit_id             => l_limit_id
          , i_currency             => o_currency
        );

        calculate_limit_counter_count(
          i_counter_algorithm      => l_counter_algorithm
          , i_eff_date             => l_eff_date
          , i_entity_type          => i_entity_type
          , i_object_id            => i_object_id
          , i_split_hash           => l_split_hash
          , o_count_curr           => o_count_curr
          , i_limit_type           => i_limit_type
          , i_product_id           => i_product_id
          , i_limit_id             => l_limit_id
        );
    end if;
    
    if l_cycle_type is not null and i_switch_limit != com_api_const_pkg.NONE and l_counter_algorithm is null then
    
        fcl_api_cycle_pkg.get_cycle_date(
            i_cycle_type        => l_cycle_type
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_split_hash        => l_split_hash
          , o_prev_date         => l_prev_date
          , o_next_date         => l_next_date
        );
        trc_log_pkg.debug('l_next_date='||l_next_date || ', l_prev_date=' || l_prev_date || ', l_last_reset_date=' || l_last_reset_date || ', l_eff_date=' || l_eff_date); 
        
        if l_next_date is null or l_next_date <= l_eff_date then

            zero_limit_counter(
                i_limit_type        => i_limit_type
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_eff_date          => coalesce(l_next_date, l_eff_date)
              , i_split_hash        => l_split_hash
            );

            o_sum_curr   := 0;
            o_count_curr := 0;

            fcl_api_cycle_pkg.switch_cycle(
                i_cycle_type        => l_cycle_type
              , i_product_id        => i_product_id
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_params            => l_params
              , i_start_date        => l_eff_date
              , i_eff_date          => l_eff_date
              , i_split_hash        => l_split_hash
              , o_new_finish_date   => l_next_date
            );
        elsif l_prev_date <= l_eff_date and l_last_reset_date < l_prev_date then

            zero_limit_counter(
                i_limit_type        => i_limit_type
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_eff_date          => l_prev_date
              , i_split_hash        => l_split_hash
            );

            o_sum_curr   := 0;
            o_count_curr := 0;

        elsif l_last_reset_date > l_eff_date then
            return;
        end if;
    end if;

    if l_limit_base is not null then
        get_limit_border(
            i_entity_type => i_entity_type
          , i_object_id   => i_object_id
          , i_limit_type  => i_limit_type
          , i_limit_base  => l_limit_base
          , i_limit_rate  => l_limit_rate
          , i_currency    => i_currency
          , i_inst_id     => i_inst_id
          , i_product_id  => i_product_id
          , i_split_hash  => l_split_hash
          , o_border_sum  => l_sum_value
          , o_border_cnt  => l_count_value
        );
        
        l_sum_value   := round(least(nvl(l_sum_value,   nvl(i_sum_value, 0)), nvl(i_sum_value, 0)));
        l_count_value := least(nvl(l_count_value, nvl(i_count_value, 0)), nvl(i_count_value, 0)); 
    else
        l_sum_value   := round(nvl(i_sum_value, 0));
        l_count_value := nvl(i_count_value, 0);
    end if;

    if i_currency is not null and i_currency != o_currency then
        begin
            select r.rate_type
              into l_rate_type
              from fcl_limit_rate r
             where r.inst_id = l_inst_id
               and r.limit_type = i_limit_type;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'LIMIT_RATE_TYPE_NOT_FOUND'
                  , i_env_param1    => i_limit_type
                  , i_env_param2    => l_inst_id
                );
        end;

        l_sum_value := round(
            com_api_rate_pkg.convert_amount(
                i_src_amount        => l_sum_value
              , i_src_currency      => i_currency       -- incoming currency
              , i_dst_currency      => o_currency       -- currency of limit
              , i_rate_type         => l_rate_type
              , i_inst_id           => l_inst_id
              , i_eff_date          => l_eff_date
            ));

    end if;
    
    if l_posting_method = acc_api_const_pkg.POSTING_METHOD_BUFFERED and l_counter_algorithm is null 
    then

        l_count                                  := g_limit_buffer_tab.count + 1;
        g_limit_buffer_tab(l_count).entity_type  := i_entity_type;
        g_limit_buffer_tab(l_count).object_id    := i_object_id;
        g_limit_buffer_tab(l_count).limit_type   := i_limit_type;
        g_limit_buffer_tab(l_count).count_value  := (l_count_value * i_switch_limit);
        g_limit_buffer_tab(l_count).sum_value    := (l_sum_value * i_switch_limit);
        g_limit_buffer_tab(l_count).split_hash   := l_split_hash;

    elsif l_posting_method = acc_api_const_pkg.POSTING_METHOD_BULK and l_counter_algorithm is null 
    then

        l_count                                  := g_limit_bulk_tab.count + 1;
        g_limit_bulk_tab(l_count).entity_type    := i_entity_type;
        g_limit_bulk_tab(l_count).object_id      := i_object_id;
        g_limit_bulk_tab(l_count).limit_type     := i_limit_type;
        g_limit_bulk_tab(l_count).count_value    := (l_count_value * i_switch_limit);
        g_limit_bulk_tab(l_count).sum_value      := (l_sum_value * i_switch_limit);
        g_limit_bulk_tab(l_count).split_hash     := l_split_hash;

    else
        if i_check_overlimit = com_api_const_pkg.TRUE then
            if (l_check_type = fcl_api_const_pkg.CHECK_TYPE_OR and --default check 'or'
                (
                    (o_sum_curr   + l_sum_value   > o_sum_limit and o_sum_limit >= 0) 
                    or
                    (o_count_curr + l_count_value > o_count_limit and o_count_limit >= 0)
                ))
                or
                (l_check_type = fcl_api_const_pkg.CHECK_TYPE_AND and
                (
                    (o_sum_curr   + l_sum_value   > o_sum_limit or o_sum_limit < 0) 
                    and
                    (o_count_curr + l_count_value > o_count_limit or o_count_limit < 0)
                    and
                    not (o_sum_limit < 0 and o_count_limit < 0)
                )) then
                com_api_error_pkg.raise_error(
                    i_error         => 'OVERLIMIT'
                  , i_env_param1    => i_limit_type
                  , i_env_param2    => i_entity_type
                  , i_env_param3    => o_sum_limit
                  , i_env_param4    => o_count_limit
                );
            end if;    
        end if; 
        
        if i_switch_limit != com_api_const_pkg.NONE then

            update fcl_limit_counter
               set sum_value   = greatest(nvl(sum_value, 0) + (l_sum_value * i_switch_limit), 0)
                 , count_value = greatest(nvl(count_value, 0) + (l_count_value * i_switch_limit), 0)
             where entity_type = i_entity_type
               and object_id   = i_object_id
               and limit_type  = i_limit_type
               and split_hash  = l_split_hash;
        end if;
    end if;

    if i_switch_limit != com_api_const_pkg.NONE and 
       i_source_entity_type is not null and 
       i_source_object_id is not null 
    then
        fcl_api_limit_pkg.put_limit_history (
            i_limit_type          => i_limit_type
          , i_entity_type         => i_entity_type
          , i_object_id           => i_object_id
          , i_count_value         => (l_count_value * i_switch_limit)
          , i_sum_value           => (l_sum_value * i_switch_limit)
          , i_source_entity_type  => i_source_entity_type
          , i_source_object_id    => i_source_object_id
          , i_split_hash          => l_split_hash
        );
    end if;

    if g_limit_buffer_tab.count >= 1000 then
        forall i in 1..g_limit_buffer_tab.count
            insert into fcl_limit_buffer(
                id
              , entity_type
              , object_id
              , limit_type
              , count_value
              , sum_value
              , split_hash
            ) values (
                fcl_limit_buffer_seq.nextval
              , g_limit_buffer_tab(i).entity_type
              , g_limit_buffer_tab(i).object_id
              , g_limit_buffer_tab(i).limit_type
              , g_limit_buffer_tab(i).count_value
              , g_limit_buffer_tab(i).sum_value
              , g_limit_buffer_tab(i).split_hash
            );

        g_limit_buffer_tab.delete;
    end if;

    if g_limit_bulk_tab.count >= 1000 then
        forall i in 1..g_limit_bulk_tab.count
            update fcl_limit_counter
               set sum_value   = greatest(nvl(sum_value, 0) + g_limit_bulk_tab(i).sum_value, 0)
                 , count_value = greatest(nvl(count_value, 0) + g_limit_bulk_tab(i).count_value, 0)
             where entity_type = g_limit_bulk_tab(i).entity_type
               and object_id   = g_limit_bulk_tab(i).object_id
               and limit_type  = g_limit_bulk_tab(i).limit_type
               and split_hash  = g_limit_bulk_tab(i).split_hash;

        g_limit_bulk_tab.delete;
    end if;
    
    o_sum_value := l_sum_value;
    if i_switch_limit != com_api_const_pkg.NONE then
        o_sum_curr  := o_sum_curr + (l_sum_value  * i_switch_limit);
    end if;

    if i_currency is not null and i_currency != o_currency and i_use_base_currency = com_api_const_pkg.TRUE then
        if o_sum_limit > 0 then
            o_sum_limit := round(
                com_api_rate_pkg.convert_amount(
                    i_src_amount        => o_sum_limit
                  , i_src_currency      => o_currency       -- currency of limit
                  , i_dst_currency      => i_currency       -- incoming currency
                  , i_rate_type         => l_rate_type
                  , i_inst_id           => l_inst_id
                  , i_eff_date          => l_eff_date
                ));
        end if; 
                   
        o_sum_curr := round(
            com_api_rate_pkg.convert_amount(
                i_src_amount        => o_sum_curr
              , i_src_currency      => o_currency       -- currency of limit
              , i_dst_currency      => i_currency       -- incoming currency
              , i_rate_type         => l_rate_type
              , i_inst_id           => l_inst_id
              , i_eff_date          => l_eff_date
            ));
            
        o_currency  := i_currency;    
        o_sum_value := i_sum_value;
    end if;

    if o_sum_limit < 0 then  
        o_sum_limit := 999999999999999999;
    end if;

    if o_count_limit < 0 then  
        o_count_limit := 9999999999999999;
    end if;

end;

procedure switch_limit_counter(
    i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_count_value       in      com_api_type_pkg.t_long_id          default null
  , i_sum_value         in      com_api_type_pkg.t_money
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_eff_date          in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_check_overlimit   in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , i_switch_limit      in      com_api_type_pkg.t_boolean          default com_api_const_pkg.TRUE
  , i_source_entity_type in     com_api_type_pkg.t_dict_value       default null
  , i_source_object_id   in     com_api_type_pkg.t_long_id          default null
  , o_sum_value            out  com_api_type_pkg.t_money
  , o_currency             out  com_api_type_pkg.t_curr_code
  , i_service_id        in      com_api_type_pkg.t_short_id         default null
  , i_test_mode         in      com_api_type_pkg.t_dict_value       default fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
  , i_use_base_currency in      com_api_type_pkg.t_boolean          default com_api_const_pkg.TRUE
) is
    l_sum_limit         com_api_type_pkg.t_money;
    l_sum_curr          com_api_type_pkg.t_money;
    l_count_curr        com_api_type_pkg.t_long_id; 
    l_count_limit       com_api_type_pkg.t_long_id;
begin
    switch_limit_counter(
        i_limit_type        => i_limit_type
      , i_product_id        => i_product_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_params            => i_params
      , i_count_value       => i_count_value
      , i_sum_value         => i_sum_value
      , i_currency          => i_currency
      , i_eff_date          => i_eff_date
      , i_split_hash        => i_split_hash
      , i_check_overlimit   => i_check_overlimit
      , i_switch_limit      => i_switch_limit
      , i_source_entity_type => i_source_entity_type
      , i_source_object_id   => i_source_object_id
      , o_count_curr        => l_count_curr
      , o_count_limit       => l_count_limit
      , o_currency          => o_currency
      , o_sum_value         => o_sum_value
      , o_sum_limit         => l_sum_limit
      , o_sum_curr          => l_sum_curr
      , i_service_id        => i_service_id
      , i_test_mode         => i_test_mode
      , i_use_base_currency => i_use_base_currency
    );
end;

procedure switch_limit_counter(
    i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_count_value       in      com_api_type_pkg.t_long_id          default null
  , i_sum_value         in      com_api_type_pkg.t_money
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_eff_date          in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_check_overlimit   in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE
  , i_switch_limit      in      com_api_type_pkg.t_boolean          default com_api_const_pkg.TRUE
  , i_source_entity_type in     com_api_type_pkg.t_dict_value       default null
  , i_source_object_id   in     com_api_type_pkg.t_long_id          default null
  , i_service_id        in      com_api_type_pkg.t_short_id         default null
  , i_test_mode         in      com_api_type_pkg.t_dict_value       default fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
) is
    l_sum_value         com_api_type_pkg.t_money;
    l_currency          com_api_type_pkg.t_curr_code;
begin
    switch_limit_counter(
        i_limit_type        => i_limit_type
      , i_product_id        => i_product_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_params            => i_params
      , i_count_value       => i_count_value
      , i_sum_value         => i_sum_value
      , i_currency          => i_currency
      , i_eff_date          => i_eff_date
      , i_split_hash        => i_split_hash
      , i_check_overlimit   => i_check_overlimit
      , i_switch_limit      => i_switch_limit
      , i_source_entity_type => i_source_entity_type
      , i_source_object_id   => i_source_object_id
      , o_sum_value         => l_sum_value
      , o_currency          => l_currency
      , i_service_id        => i_service_id
      , i_test_mode         => i_test_mode
    );
end;

procedure zero_limit_counter(
    i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
) is
    l_eff_date          date;
    l_split_hash        com_api_type_pkg.t_tiny_id;
begin

    trc_log_pkg.debug('zero_limit_counter, limit_type='||i_limit_type ||', entity_type='||i_entity_type 
      ||', object_id='||i_object_id ||', i_eff_date='||i_eff_date ||', i_split_hash='||i_split_hash);

    l_eff_date          := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    update fcl_limit_counter
       set prev_sum_value   = sum_value
         , prev_count_value = count_value
         , sum_value        = 0
         , count_value      = 0
         , last_reset_date  = l_eff_date
     where entity_type      = i_entity_type
       and object_id        = i_object_id
       and limit_type       = i_limit_type
       and split_hash       = l_split_hash;

    delete fcl_limit_history
     where entity_type      = i_entity_type
       and object_id        = i_object_id
       and limit_type       = i_limit_type
       and split_hash       = l_split_hash;
end;

procedure add_limit_counter(
    i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
) is
    l_eff_date          date;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_count             com_api_type_pkg.t_count    := 0;
begin
    trc_log_pkg.debug('fcl_api_limit_pkg.add_limit_counter: limit_type='||i_limit_type
                     ||', entity_type='||i_entity_type||', object_id='||i_object_id);
  
    l_eff_date   := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;
    
    select count(1)
      into l_count
      from fcl_limit_counter
     where entity_type = i_entity_type
       and object_id   = i_object_id
       and limit_type  = i_limit_type
       and split_hash  = l_split_hash;

    if l_count = 0 then
        insert into fcl_limit_counter(
            id
          , entity_type
          , object_id
          , limit_type
          , count_value
          , sum_value
          , last_reset_date
          , split_hash
          , inst_id
        ) values (
            fcl_limit_counter_seq.nextval
          , i_entity_type
          , i_object_id
          , i_limit_type
          , 0
          , 0
          , l_eff_date
          , l_split_hash
          , i_inst_id
        );
    end if;
end;

procedure remove_limit_counter(
    i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
) is
    l_split_hash        com_api_type_pkg.t_tiny_id;
begin
    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    delete from fcl_limit_counter
     where entity_type = i_entity_type
       and object_id   = i_object_id
       and limit_type  = i_limit_type
       and split_hash  = l_split_hash;
end;

procedure get_limit_value(
    i_limit_id          in      com_api_type_pkg.t_long_id
  , o_sum_value            out  com_api_type_pkg.t_money
  , o_count_value          out  com_api_type_pkg.t_long_id
) is
begin
    select sum_limit
         , count_limit
      into o_sum_value
         , o_count_value
      from fcl_limit
     where id = i_limit_id;
     
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'LIMIT_NOT_FOUND'
          , i_env_param1    => i_limit_id
        );
end;

function get_limit(
    i_limit_id          in      com_api_type_pkg.t_long_id
) return fcl_api_type_pkg.t_limit is
    l_limit fcl_api_type_pkg.t_limit;
begin
    select id
         , limit_type
         , cycle_id
         , count_limit
         , sum_limit
         , currency
         , posting_method
         , is_custom
         , inst_id
         , limit_base
         , limit_rate
         , count_max_bound
         , sum_max_bound
      into l_limit.id
         , l_limit.limit_type
         , l_limit.cycle_id
         , l_limit.count_limit
         , l_limit.sum_limit
         , l_limit.currency
         , l_limit.posting_method
         , l_limit.is_custom
         , l_limit.inst_id
         , l_limit.limit_base
         , l_limit.limit_rate
         , l_limit.count_max_bound
         , l_limit.sum_max_bound
      from fcl_limit l
     where id = i_limit_id;
     
     return l_limit;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'LIMIT_NOT_FOUND'
          , i_env_param1    => i_limit_id
        );
end; 

function get_sum_limit(
    i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id  default null
  , i_mask_error        in      com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_money is
    l_result            com_api_type_pkg.t_money;
    l_param_tab         com_api_type_pkg.t_param_tab;
    l_limit_id          com_api_type_pkg.t_long_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
begin
    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    rul_api_shared_data_pkg.load_params(
        i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
      , io_params      => l_param_tab
      , i_full_set     => com_api_const_pkg.TRUE
    );

    l_limit_id :=
        prd_api_product_pkg.get_limit_id (
            i_product_id    => prd_api_product_pkg.get_product_id(
                                   i_entity_type   => i_entity_type
                                 , i_object_id     => i_object_id
                               )
          , i_entity_type   => i_entity_type
          , i_object_id     => i_object_id
          , i_limit_type    => i_limit_type
          , i_params        => l_param_tab
          , i_split_hash    => l_split_hash
          , i_service_id    => null
          , i_eff_date      => null
          , i_mask_error    => i_mask_error
        );

    select sum_limit
      into l_result
      from fcl_limit
     where id = l_limit_id;
            
    return l_result;
exception
    when no_data_found then
        return null;
    when others then
        if i_mask_error = com_api_type_pkg.TRUE then
            return null;
        else
            raise;
        end if;            
end; 

function get_limit_currency(
    i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id  default null
  , i_mask_error        in      com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_curr_code is
    l_result            com_api_type_pkg.t_curr_code;
    l_param_tab         com_api_type_pkg.t_param_tab;
    l_limit_id          com_api_type_pkg.t_long_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
begin
    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    rul_api_shared_data_pkg.load_params(
        i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
      , io_params      => l_param_tab
      , i_full_set     => com_api_const_pkg.TRUE
    );

    l_limit_id :=
        prd_api_product_pkg.get_limit_id (
            i_product_id    => prd_api_product_pkg.get_product_id(
                                   i_entity_type   => i_entity_type
                                 , i_object_id     => i_object_id
                               )
          , i_entity_type   => i_entity_type
          , i_object_id     => i_object_id
          , i_limit_type    => i_limit_type
          , i_params        => l_param_tab
          , i_split_hash    => l_split_hash
          , i_service_id    => null
          , i_eff_date      => null
          , i_mask_error    => i_mask_error
        );

    select currency
      into l_result
      from fcl_limit
     where id = l_limit_id;
            
    return l_result;
exception
    when no_data_found then
        return null;
    when others then
        if i_mask_error = com_api_type_pkg.TRUE then
            return null;
        else
            raise;
        end if;            
end; 

function get_sum_remainder(
    i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id  default null
  , i_mask_error        in      com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_money is
    l_result            com_api_type_pkg.t_money;
    l_split_hash        com_api_type_pkg.t_tiny_id;
begin
    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    select case when sum_limit >= 0 then (sum_limit - sum_value) else 999999999999999999 end
      into l_result
      from fcl_ui_limit_counter_vw
     where entity_type = i_entity_type
       and object_id   = i_object_id
       and limit_type  = i_limit_type
       and split_hash  = l_split_hash;
            
    return l_result;
exception
    when no_data_found then
        return null;
    when others then
        if i_mask_error = com_api_type_pkg.TRUE then
            return null;
        else
            raise;
        end if;            
end; 

procedure rollback_limit_counters(
    i_source_entity_type  in    com_api_type_pkg.t_dict_value
  , i_source_object_id    in    com_api_type_pkg.t_long_id
) is
begin
--    if i_source_entity_type = aut_api_const_pkg.ENTITY_TYPE_AUTHORIZATION then
--        for r in (
--            select a.host_date
--                 , h.entity_type
--                 , h.object_id
--                 , h.count_value
--                 , h.limit_type
--                 , h.sum_value
--                 , h.split_hash
--              from fcl_limit_history h
--                 , opr_operation a
--             where h.source_entity_type = i_source_entity_type
--               and h.source_object_id   = i_source_object_id
--               and h.source_object_id   = a.id 
--        ) loop 
--            update fcl_limit_counter c
--               set sum_value         = greatest(0, nvl(sum_value, 0) - r.sum_value)
--                 , count_value       = greatest(0, nvl(count_value, 0) - r.count_value)
--             where c.entity_type     = r.entity_type
--               and c.object_id       = r.object_id
--               and c.limit_type      = r.limit_type
--               and c.split_hash      = r.split_hash
--               and c.last_reset_date < r.host_date;
--        end loop;
--    els
    if i_source_entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION then
        for r in (
            select o.host_date
                 , h.entity_type
                 , h.object_id
                 , h.count_value
                 , h.limit_type
                 , h.sum_value
                 , h.split_hash
              from fcl_limit_history h
                 , opr_operation o
             where h.source_entity_type = i_source_entity_type
               and h.source_object_id   = i_source_object_id
               and h.source_object_id   = o.id 
        ) loop 
            update fcl_limit_counter c
               set sum_value         = greatest(0, nvl(sum_value, 0) - r.sum_value)
                 , count_value       = greatest(0, nvl(count_value, 0) - r.count_value)
             where c.entity_type     = r.entity_type
               and c.object_id       = r.object_id
               and c.limit_type      = r.limit_type
               and c.split_hash      = r.split_hash
               and c.last_reset_date < r.host_date;
        end loop;
    end if;
end;


procedure rollback_limit_counter(
    i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_product_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_params            in      com_api_type_pkg.t_param_tab
  , i_sum_value         in      com_api_type_pkg.t_money
  , i_currency          in      com_api_type_pkg.t_curr_code        default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_source_object_id   in     com_api_type_pkg.t_long_id          default null
) is
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_split_hash        com_api_type_pkg.t_tiny_id;
    l_limit_id          com_api_type_pkg.t_long_id;
    o_currency          com_api_type_pkg.t_curr_code;
    l_rate_type         com_api_type_pkg.t_dict_value;
    l_sum_value         com_api_type_pkg.t_money        := 0;
    l_last_reset_date   date;
    l_cycle_id          com_api_type_pkg.t_long_id;
    o_prev_date         date;
    l_host_date         date;
    
begin
    if i_inst_id is null then
        l_inst_id := ost_api_institution_pkg.get_object_inst_id(i_entity_type, i_object_id);
    else
        l_inst_id := i_inst_id;
    end if;

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    -- get operation date
    begin
        select o.host_date
            into l_host_date
         from opr_operation o    
        where o.id = i_source_object_id;     
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'OPERATION_NOT_FOUND'
              , i_env_param1    => i_source_object_id
            );
    end;

    -- get limit id
    begin
        l_limit_id :=
            prd_api_product_pkg.get_limit_id (
                i_product_id      => i_product_id
              , i_entity_type     => i_entity_type
              , i_object_id       => i_object_id
              , i_limit_type      => i_limit_type
              , i_split_hash      => l_split_hash
              , i_params          => i_params
              , i_eff_date        => l_host_date
              , i_inst_id         => l_inst_id
            );
    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error in ('PRD_NO_ACTIVE_SERVICE', 'LIMIT_NOT_DEFINED') then
                return;
            end if;
            com_api_error_pkg.raise_error(
                i_error         => 'LIMIT_NOT_FOUND'
              , i_env_param1    => l_limit_id
            );
    end;
       
    --get limit currency and cycle data
    begin 
        select a.currency
             , a.cycle_id
          into o_currency
             , l_cycle_id
          from fcl_limit a
             , fcl_limit_type b
         where a.id         = l_limit_id
           and a.limit_type = b.limit_type;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'LIMIT_NOT_FOUND'
              , i_env_param1    => l_limit_id
            );
    end;

    if i_currency is not null and i_currency != o_currency then
        begin
            select r.rate_type
              into l_rate_type
              from fcl_limit_rate r
             where r.inst_id = l_inst_id
               and r.limit_type = i_limit_type;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'LIMIT_RATE_TYPE_NOT_FOUND'
                  , i_env_param1    => i_limit_type
                  , i_env_param2    => l_inst_id
                );
        end;

        l_sum_value := round(
            com_api_rate_pkg.convert_amount(
                i_src_amount        => i_sum_value
              , i_src_currency      => i_currency       -- incoming currency
              , i_dst_currency      => o_currency       -- currency of limit
              , i_rate_type         => l_rate_type
              , i_inst_id           => l_inst_id
              , i_eff_date          => l_host_date
            ));
    else 
        l_sum_value := i_sum_value;       
    end if;

    -- get last_reset_date
    begin
        select last_reset_date
          into l_last_reset_date
          from fcl_limit_counter
         where entity_type      = i_entity_type
           and object_id        = i_object_id
           and limit_type       = i_limit_type
           and split_hash       = l_split_hash;
        
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'LIMIT_COUNTER_NOT_FOUND'
              , i_env_param1    => l_limit_id
            );
    end;
    
    if l_cycle_id is not null then    
        if l_host_date > l_last_reset_date then    -- current cycle
            update fcl_limit_counter c
               set sum_value         = greatest(0, nvl(sum_value, 0) - l_sum_value)
                 , count_value       = greatest(0, nvl(count_value, 0) - 1)
             where c.entity_type     = i_entity_type
               and c.object_id       = i_object_id
               and c.limit_type      = i_limit_type
               and c.split_hash      = l_split_hash
               and c.last_reset_date between l_last_reset_date and l_host_date;   
        else
            begin
                fcl_api_cycle_pkg.calc_next_date(           -- get prev cycle date
                    i_cycle_id          => l_cycle_id
                    , i_start_date      => l_last_reset_date
                    , i_forward         => com_api_type_pkg.FALSE
                    , o_next_date       => o_prev_date
                );
                if l_host_date > o_prev_date then 
                    update fcl_limit_counter c
                       set sum_value         = greatest(0, nvl(sum_value, 0) - l_sum_value)
                         , count_value       = greatest(0, nvl(count_value, 0) - 1)
                     where c.entity_type     = i_entity_type
                       and c.object_id       = i_object_id
                       and c.limit_type      = i_limit_type
                       and c.split_hash      = l_split_hash
                       and c.last_reset_date between o_prev_date and l_last_reset_date;
                end if;
            end;
        end if;
    else -- no cycle
        update fcl_limit_counter c
           set sum_value         = greatest(0, nvl(sum_value, 0) - l_sum_value)
             , count_value       = greatest(0, nvl(count_value, 0) - 1)
         where c.entity_type     = i_entity_type
           and c.object_id       = i_object_id
           and c.limit_type      = i_limit_type
           and c.split_hash      = l_split_hash;
    end if;

end;

function get_count_limit(
    i_limit_type        in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_split_hash        in      com_api_type_pkg.t_tiny_id  default null
  , i_mask_error        in      com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id
is
    l_limit_id          com_api_type_pkg.t_long_id;
    l_product_id        com_api_type_pkg.t_short_id;
    l_param_tab         com_api_type_pkg.t_param_tab;
    l_count_limit       com_api_type_pkg.t_long_id; 
    l_split_hash        com_api_type_pkg.t_tiny_id;
  
begin

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    rul_api_shared_data_pkg.load_params(
        i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
      , io_params      => l_param_tab
      , i_full_set     => com_api_const_pkg.TRUE
    );
    
    l_product_id := prd_api_product_pkg.get_product_id(
        i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
    );      

    l_limit_id :=
        prd_api_product_pkg.get_limit_id (
            i_product_id    => l_product_id
          , i_entity_type   => i_entity_type
          , i_object_id     => i_object_id
          , i_limit_type    => i_limit_type
          , i_params        => l_param_tab
          , i_split_hash    => l_split_hash
          , i_service_id    => null
          , i_eff_date      => null
        );

    select count_limit
      into l_count_limit
      from fcl_limit
     where id = l_limit_id;
            
    return l_count_limit;
exception
    when no_data_found then
        return null;
    when others then
        if i_mask_error = com_api_type_pkg.TRUE then
            return null;
        else
            raise;
        end if;     

end get_count_limit; 
 
function get_limit_count_curr(
  i_limit_type             in   com_api_type_pkg.t_dict_value
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_object_id            in   com_api_type_pkg.t_long_id
  , i_limit_id             in   com_api_type_pkg.t_long_id  default null   
  , i_mask_error           in   com_api_type_pkg.t_boolean  default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id
is    
    l_last_reset_date    date;
    l_count_curr         com_api_type_pkg.t_long_id;     
begin
    
    get_limit_count_curr(
      i_limit_type             => i_limit_type
      , i_entity_type          => i_entity_type
      , i_object_id            => i_object_id
      , i_limit_id             => i_limit_id   
      , o_last_reset_date      => l_last_reset_date
      , o_count_curr           => l_count_curr 
    );    
    return l_count_curr;

exception
    when no_data_found then
        return null;
    when others then
        if i_mask_error = com_api_type_pkg.TRUE then
            return null;
        else
            raise;
        end if;         
    
end;

function get_limit_sum_curr(
  i_limit_type             in   com_api_type_pkg.t_dict_value
  , i_entity_type          in   com_api_type_pkg.t_dict_value
  , i_object_id            in   com_api_type_pkg.t_long_id
  , i_limit_id             in   com_api_type_pkg.t_long_id    default null   
  , i_mask_error           in   com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_split_hash           in   com_api_type_pkg.t_tiny_id    default null          
  , i_product_id           in   com_api_type_pkg.t_short_id   default null
) return com_api_type_pkg.t_money
is
    l_last_reset_date      date;
    l_sum_curr             com_api_type_pkg.t_money;
begin

    get_limit_sum_curr(
        i_limit_type           => i_limit_type
      , i_entity_type          => i_entity_type
      , i_object_id            => i_object_id
      , i_split_hash           => i_split_hash
      , i_product_id           => i_product_id
      , i_limit_id             => i_limit_id   
      , o_last_reset_date      => l_last_reset_date
      , o_sum_curr             => l_sum_curr 
    );    
    
    return l_sum_curr;

exception
    when no_data_found then
        return null;
    when others then
        if i_mask_error = com_api_type_pkg.TRUE then
            return null;
        else
            raise;
        end if;         
        
end;

procedure set_limit_counter(
    i_limit_type           in      com_api_type_pkg.t_dict_value
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_count_value          in      com_api_type_pkg.t_long_id
  , i_sum_value            in      com_api_type_pkg.t_money
  , i_eff_date             in      date                               default null
  , i_split_hash           in      com_api_type_pkg.t_tiny_id         default null
  , i_inst_id              in      com_api_type_pkg.t_inst_id         default null
  , i_allow_insert         in      com_api_type_pkg.t_inst_id         default com_api_const_pkg.FALSE
) is
    l_eff_date             date;
    l_split_hash           com_api_type_pkg.t_tiny_id;
begin

    trc_log_pkg.debug('set_limit_counter, limit_type=' || i_limit_type || ', entity_type=' || i_entity_type 
                   || ', object_id=' || i_object_id || ', i_count_value='|| i_count_value ||', i_sum_value=' || i_sum_value
                   || ', i_eff_date=' ||i_eff_date || ', i_split_hash=' || i_split_hash || ', i_inst_id=' || i_inst_id
                   || ', i_allow_insert=' || i_allow_insert);

    l_eff_date       := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);

    if i_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(i_entity_type, i_object_id);
    else
        l_split_hash := i_split_hash;
    end if;

    update fcl_limit_counter
       set prev_sum_value   = sum_value
         , prev_count_value = count_value
         , sum_value        = nvl(i_sum_value, 0)
         , count_value      = nvl(i_count_value, 0)
         , last_reset_date  = l_eff_date
     where entity_type      = i_entity_type
       and object_id        = i_object_id
       and limit_type       = i_limit_type
       and split_hash       = l_split_hash;
    
    if sql%rowcount = 0 and i_allow_insert = com_api_const_pkg.TRUE then
        insert into fcl_limit_counter(
            id
          , entity_type
          , object_id
          , limit_type
          , count_value
          , sum_value
          , last_reset_date
          , split_hash
          , inst_id
        ) values (
            fcl_limit_counter_seq.nextval
          , i_entity_type
          , i_object_id
          , i_limit_type
          , nvl(i_count_value, 0)
          , nvl(i_sum_value, 0)
          , l_eff_date
          , l_split_hash
          , i_inst_id
        );
    end if;
end set_limit_counter;

function check_overlimit(
    i_entity_type        in      com_api_type_pkg.t_dict_value
  , i_object_id          in      com_api_type_pkg.t_long_id
  , i_limit_type         in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_boolean is
    l_overlimit                  com_api_type_pkg.t_boolean;
    l_entity_type                com_api_type_pkg.t_dict_value;
    l_object_id                  com_api_type_pkg.t_long_id;
    l_limit_type                 com_api_type_pkg.t_dict_value;
    l_limit_id                   com_api_type_pkg.t_long_id;
    l_check_type                 com_api_type_pkg.t_dict_value;
    l_test_mode                  com_api_type_pkg.t_dict_value;
    l_split_hash                 com_api_type_pkg.t_tiny_id;
    l_limit_base                 com_api_type_pkg.t_dict_value;
    l_inst_id                    com_api_type_pkg.t_inst_id;
    l_limit_rate                 com_api_type_pkg.t_money;
    l_currency                   com_api_type_pkg.t_curr_code;
    l_product_id                 com_api_type_pkg.t_short_id;

    l_sum_value                  com_api_type_pkg.t_money        := 0;
    l_count_value                com_api_type_pkg.t_long_id      := 0;
    l_sum_limit                  com_api_type_pkg.t_money        := 0;
    l_count_limit                com_api_type_pkg.t_long_id      := 0;
    l_sum_curr                   com_api_type_pkg.t_money        := 0;
    l_count_curr                 com_api_type_pkg.t_long_id      := 0;

begin
    l_entity_type     := opr_api_shared_data_pkg.get_param_char(i_name => 'ENTITY_TYPE');
    l_limit_type      := opr_api_shared_data_pkg.get_param_char(i_name => 'LIMIT_TYPE');
    l_object_id       := opr_api_shared_data_pkg.get_param_num(i_name  => 'OBJECT_ID');

    trc_log_pkg.debug(
        i_text          => 'Checking overlimit for limit[#1] object[#2] id[#3]'
      , i_env_param1    => l_limit_type
      , i_env_param2    => l_entity_type
      , i_env_param3    => l_object_id
    );

    l_split_hash := com_api_hash_pkg.get_split_hash(
                        i_entity_type => l_entity_type
                      , i_object_id   => l_object_id
                    );

    l_inst_id    := ost_api_institution_pkg.get_object_inst_id(
                        i_entity_type => l_entity_type
                      , i_object_id   => l_object_id
                    );

    l_product_id := prd_api_product_pkg.get_product_id(
                        i_entity_type => l_entity_type
                      , i_object_id   => l_object_id
                    );

    l_test_mode  := opr_api_shared_data_pkg.get_param_char(
                        i_name         => 'ATTR_MISS_TESTMODE'
                      , i_mask_error   => com_api_const_pkg.TRUE
                      , i_error_value  => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
                    );

    begin
        l_limit_id := prd_api_product_pkg.get_limit_id(
                          i_entity_type => l_entity_type
                        , i_object_id   => l_object_id
                        , i_limit_type  => l_limit_type
                      );

    exception
        when com_api_error_pkg.e_application_error then
            if com_api_error_pkg.get_last_error in ('PRD_NO_ACTIVE_SERVICE', 'LIMIT_NOT_DEFINED') then

                if l_test_mode = fcl_api_const_pkg.ATTR_MISS_RISE_ERROR then
                    raise;
                else
                    trc_log_pkg.debug(
                        i_text => com_api_error_pkg.get_last_error
                    );
                    return com_api_const_pkg.FALSE;
                end if;
            else 
                raise;
            end if;
    end;

    select nvl(a.check_type, fcl_api_const_pkg.CHECK_TYPE_OR)
         , a.limit_base
         , a.limit_rate
         , a.currency
         , a.sum_limit
         , a.count_limit
      into l_check_type
         , l_limit_base
         , l_limit_rate
         , l_currency
         , l_sum_limit
         , l_count_limit
      from fcl_limit      a
         , fcl_limit_type b
     where a.id         = l_limit_id
       and a.limit_type = b.limit_type;

    if l_limit_base is not null then
        fcl_api_limit_pkg.get_limit_border(
            i_entity_type => l_entity_type
          , i_object_id   => l_object_id
          , i_limit_type  => l_limit_type
          , i_limit_base  => l_limit_base
          , i_limit_rate  => l_limit_rate
          , i_currency    => l_currency
          , i_inst_id     => l_inst_id
          , i_product_id  => l_product_id
          , o_border_sum  => l_sum_value
          , o_border_cnt  => l_count_value
        );
    end if;

    l_sum_value   := round(nvl(l_sum_value,   0));
    l_count_value :=       nvl(l_count_value, 0);

    l_count_curr  := fcl_api_limit_pkg.get_limit_count_curr(
                         i_limit_type     => l_limit_type
                       , i_entity_type    => l_entity_type
                       , i_object_id      => l_object_id
                     );

    l_sum_curr    := fcl_api_limit_pkg.get_limit_sum_curr(
                         i_limit_type     => l_limit_type
                       , i_entity_type    => l_entity_type
                       , i_object_id      => l_object_id
                     );

    select case when ((l_check_type = fcl_api_const_pkg.CHECK_TYPE_OR and
                       (
                          (l_sum_curr   + l_sum_value   > l_sum_limit and l_sum_limit >= 0)
                          or
                          (l_count_curr + l_count_value > l_count_limit and l_count_limit >= 0)
                      ))
                      or
                      (l_check_type = fcl_api_const_pkg.CHECK_TYPE_AND and
                      (
                          (l_sum_curr   + l_sum_value   > l_sum_limit or l_sum_limit < 0)
                          and
                          (l_count_curr + l_count_value > l_count_limit or l_count_limit < 0)
                          and
                          not (l_sum_limit < 0 and l_count_limit < 0)
                      ))
                      ) then com_api_const_pkg.TRUE
                else com_api_const_pkg.FALSE
           end
      into l_overlimit
      from fcl_limit_counter c
     where c.object_id   = l_object_id
       and c.entity_type = l_entity_type
       and c.limit_type  = l_limit_type;

    return l_overlimit;

end check_overlimit;

end fcl_api_limit_pkg;
/
