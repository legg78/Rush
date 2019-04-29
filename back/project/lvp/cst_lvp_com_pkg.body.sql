create or replace package body cst_lvp_com_pkg as

function get_debt_level(
    i_account_id  in     com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_tiny_id
is
    l_debt_level        com_api_type_pkg.t_tiny_id default 0;
begin

    l_debt_level :=
        to_number(
            substr(
                com_api_flexible_data_pkg.get_flexible_value(
                    i_field_name  => cst_lvp_const_pkg.DEBT_LEVEL_FLEXIBLE_FIELD
                  , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id   => i_account_id
                )
              , -4
            )
        );

    return l_debt_level;

exception
    when no_data_found then
        return null;

end get_debt_level;


function get_main_card_id (
    i_account_id  in     com_api_type_pkg.t_account_id
  , i_split_hash  in     com_api_type_pkg.t_tiny_id     default null
) return com_api_type_pkg.t_medium_id
is
    l_split_hash         com_api_type_pkg.t_tiny_id;
begin

    l_split_hash := i_split_hash;
    if l_split_hash is null then
        l_split_hash := com_api_hash_pkg.get_split_hash(
                            i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id     => i_account_id
                        );
    end if;

    for rec in (
        select t.id as card_id
          from (
                select c.id
                     , row_number() over (order by
                                          case
                                              when c.category = 'CRCG0800' then 1
                                              when c.category = 'CRCG0600' then 2
                                              when c.category = 'CRCG0200' then 3
                                              when c.category = 'CRCG0900' then 4
                                          end) as seqnum
                  from iss_card_vw c
                     , acc_account_object ao
                 where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and ao.object_id = c.id
                   and ao.account_id = i_account_id
                   and ao.split_hash = l_split_hash
               ) t
         order by t.seqnum
    ) loop
        return rec.card_id;
    end loop;

    return com_api_const_pkg.FALSE;

end get_main_card_id;


function current_fee_debt (
    i_account_id  in     com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_amount_rec
is
    l_split_hash         com_api_type_pkg.t_tiny_id;
    l_amount             com_api_type_pkg.t_money;
    l_result             com_api_type_pkg.t_amount_rec;
    l_account            acc_api_type_pkg.t_account_rec;
begin

    l_account :=
        acc_api_account_pkg.get_account(
            i_account_id => i_account_id
          , i_mask_error => com_api_const_pkg.FALSE
        );

    l_split_hash := l_account.split_hash;

    select nvl(sum(cdb.amount), 0)
      into l_amount
      from crd_debt cd
         , crd_debt_balance cdb
     where cd.id = cdb.debt_id
       and cd.account_id = i_account_id
       and cd.split_hash = l_split_hash
       and cdb.split_hash = l_split_hash
       and cdb.balance_type in (
                                 crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT -- 'BLTP1002'
                               , crd_api_const_pkg.BALANCE_TYPE_OVERDUE   -- 'BLTP1004'
                               , crd_api_const_pkg.BALANCE_TYPE_OVERLIMIT -- 'BLTP1007'
                               )
       and cd.macros_type_id in (
                                 select numeric_value
                                   from com_ui_array_element_vw
                                  where array_id = cst_lvp_const_pkg.ARRAY_FEE_MACROS_TYPE -- -50000025
                                    and lang = com_api_const_pkg.LANGUAGE_ENGLISH
                                );

    l_result.amount := l_amount;
    l_result.currency := l_account.currency;

    return l_result;

end current_fee_debt;


function current_interest_debt (
    i_account_id  in     com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_amount_rec
is
    l_split_hash         com_api_type_pkg.t_tiny_id;
    l_amount             com_api_type_pkg.t_money;
    l_result             com_api_type_pkg.t_amount_rec;
    l_account            acc_api_type_pkg.t_account_rec;
begin

    l_account :=
        acc_api_account_pkg.get_account(
            i_account_id => i_account_id
          , i_mask_error => com_api_const_pkg.FALSE
        );

    l_split_hash := l_account.split_hash;

    select nvl(sum(cdb.amount), 0)
      into l_amount
      from crd_debt cd
         , crd_debt_balance cdb
     where cd.id = cdb.debt_id
       and cd.account_id = i_account_id
       and cd.split_hash = l_split_hash
       and cdb.split_hash = l_split_hash
       and cdb.balance_type in (
                                 crd_api_const_pkg.BALANCE_TYPE_INTEREST           -- 'BLTP1003'
                               , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST   -- 'BLTP1005'
                               );

    l_result.amount := l_amount;
    l_result.currency := l_account.currency;

    return l_result;

end current_interest_debt;


function current_main_debt (
    i_account_id  in     com_api_type_pkg.t_account_id
) return com_api_type_pkg.t_amount_rec
is
    l_split_hash         com_api_type_pkg.t_tiny_id;
    l_amount             com_api_type_pkg.t_money;
    l_result             com_api_type_pkg.t_amount_rec;
    l_account            acc_api_type_pkg.t_account_rec;
begin

    l_account :=
        acc_api_account_pkg.get_account(
            i_account_id => i_account_id
          , i_mask_error => com_api_const_pkg.FALSE
        );

    l_split_hash := l_account.split_hash;

    select nvl(sum(cdb.amount), 0)
      into l_amount
      from crd_debt cd
         , crd_debt_balance cdb
     where cd.id = cdb.debt_id
       and cd.account_id = i_account_id
       and cd.split_hash = l_split_hash
       and cdb.split_hash = l_split_hash
       and cdb.balance_type in (
                                 crd_api_const_pkg.BALANCE_TYPE_OVERDRAFT -- 'BLTP1002'
                               , crd_api_const_pkg.BALANCE_TYPE_OVERDUE   -- 'BLTP1004'
                               , crd_api_const_pkg.BALANCE_TYPE_OVERLIMIT -- 'BLTP1007'
                               )
       and cd.macros_type_id not in (
                                     select numeric_value
                                       from com_ui_array_element_vw
                                      where array_id = cst_lvp_const_pkg.ARRAY_FEE_MACROS_TYPE -- -50000025
                                        and lang = com_api_const_pkg.LANGUAGE_ENGLISH
                                    );

    l_result.amount := l_amount;
    l_result.currency := l_account.currency;

    return l_result;

end current_main_debt;


procedure get_cash_limit_value(
    i_account_id  in     com_api_type_pkg.t_account_id
  , i_split_hash  in     com_api_type_pkg.t_tiny_id
  , i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_date        in     date default get_sysdate
  , o_value          out com_api_type_pkg.t_money
  , o_current_sum    out com_api_type_pkg.t_money
)
is
begin
    select case when l.limit_base is not null and l.limit_rate is not null
                then
                    nvl(fcl_api_limit_pkg.get_limit_border_sum(
                            i_entity_type          => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                          , i_object_id            => i_account_id
                          , i_limit_type           => crd_api_const_pkg.ACCOUNT_CASH_VALUE_LIMIT_TYPE
                          , i_limit_base           => l.limit_base
                          , i_limit_rate           => l.limit_rate
                          , i_currency             => l.currency
                          , i_inst_id              => i_inst_id
                          , i_product_id           => prd_api_product_pkg.get_product_id(
                                                          i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                        , i_object_id         => i_account_id
                                                        , i_inst_id           => i_inst_id
                                                      )
                          , i_split_hash           => i_split_hash
                          , i_mask_error           => com_api_const_pkg.TRUE
                        ), 0
                    )
                else
                    nvl(l.sum_limit, 0)
           end
         , nvl(fcl_api_limit_pkg.get_limit_sum_curr(
                   i_limit_type  => l.limit_type
                 , i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 , i_object_id   => i_account_id
                 , i_limit_id    => l.id
                 , i_split_hash  => i_split_hash
                 , i_mask_error  => com_api_const_pkg.TRUE
              )
              , 0
           )
      into o_value
         , o_current_sum
      from fcl_limit l
         , (select to_number(limit_id, 'FM000000000000000000.0000') limit_id
                 , row_number() over (partition by account_id, limit_type order by decode(level_priority, 0, 0, 1)
                                                                                 , level_priority
                                                                                 , start_date desc
                                                                                 , register_timestamp desc) rn
                 , account_id
                 , split_hash
                 , start_date
                 , end_date
              from (
                    select v.attr_value limit_id
                         , 0 level_priority
                         , a.object_type limit_type
                         , v.register_timestamp
                         , v.start_date
                         , v.end_date
                         , v.object_id  account_id
                         , v.split_hash
                      from prd_attribute_value v
                         , prd_attribute a
                     where v.entity_type  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                       and a.entity_type  = fcl_api_const_pkg.ENTITY_TYPE_LIMIT  --'ENTTLIMT'
                       and a.object_type  = crd_api_const_pkg.ACCOUNT_CASH_VALUE_LIMIT_TYPE
                       and a.id           = v.attr_id
                       and i_date between nvl(v.start_date, i_date) and nvl(v.end_date, trunc(i_date)+1)
                    union all
                    select v.attr_value
                         , p.level_priority
                         , a.object_type limit_type
                         , v.register_timestamp
                         , v.start_date
                         , v.end_date
                         , ac.id  account_id
                         , ac.split_hash
                      from (
                            select connect_by_root id product_id
                                 , level level_priority
                                 , id parent_id
                                 , product_type
                                 , case when parent_id is null then 1 else 0 end top_flag
                              from prd_product
                           connect by prior parent_id = id
                           ) p
                         , prd_attribute_value v
                         , prd_attribute a
                         , prd_service_type st
                         , prd_service s
                         , prd_product_service ps
                         , prd_contract c
                         , acc_account ac
                     where v.service_id      = s.id
                       and v.object_id       = decode(a.definition_level, 'SADLSRVC', s.id, p.parent_id)
                       and v.entity_type     = decode(a.definition_level, 'SADLSRVC', decode(top_flag, 1, 'ENTTSRVC', '-'), 'ENTTPROD')
                       and v.attr_id         = a.id
                       and i_date between nvl(v.start_date, i_date) and nvl(v.end_date, trunc(i_date)+1)
                       and a.service_type_id = s.service_type_id
                       and a.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT  --'ENTTLIMT'
                       and st.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                       and st.id             = s.service_type_id
                       and p.product_id      = ps.product_id
                       and s.id              = ps.service_id
                       and ps.product_id     = c.product_id
                       and c.id              = ac.contract_id
                       and c.split_hash      = ac.split_hash
                       and a.object_type     = crd_api_const_pkg.ACCOUNT_CASH_VALUE_LIMIT_TYPE
                       -- Get active service id with subquery instead of the "prd_api_service_pkg.get_active_service_id" function
                       and s.id = coalesce (
                                            (
                                             select min(service_id)
                                               from prd_service_object o
                                                  , prd_service s
                                              where o.service_id      = s.id
                                                and s.service_type_id = a.service_type_id
                                                and o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                                and o.object_id       = ac.id
                                                and o.split_hash      = ac.split_hash
                                                and i_date between nvl(trunc(o.start_date), i_date) and nvl(o.end_date, trunc(i_date)+1)
                                            )
                                            -- Save debug message when active service is not exist
                                          , prd_api_service_pkg.message_no_active_service(
                                                i_entity_type          => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                              , i_object_id            => ac.id
                                              , i_limit_type           => a.object_type
                                              , i_eff_date             => i_date
                                            )
                                           )
                    ) tt
           ) limits
         , fcl_cycle c
         , fcl_cycle_counter b
     where limits.account_id = i_account_id
       and limits.split_hash = i_split_hash
       and limits.rn         = 1
       and l.id              = limits.limit_id
       and c.id(+)           = l.cycle_id
       and b.cycle_type(+)   = c.cycle_type
       and b.entity_type(+)  = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
       and b.object_id(+)    = i_account_id
       and b.split_hash(+)   = i_split_hash;

exception
    when no_data_found then
        o_value := -1;
        o_current_sum := 0;
end get_cash_limit_value;


procedure get_card_credit_limits_current(
    i_card_id          in     com_api_type_pkg.t_account_id
  , i_split_hash       in     com_api_type_pkg.t_tiny_id    default null
  , i_mask_error       in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , o_value               out com_api_type_pkg.t_money
  , o_current_sum         out com_api_type_pkg.t_money
  , o_value_cash          out com_api_type_pkg.t_money
  , o_current_sum_cash    out com_api_type_pkg.t_money
)
is
begin
    o_value :=
        fcl_api_limit_pkg.get_sum_limit (
            i_limit_type   => cst_lvp_const_pkg.LIMIT_TYPE_CARD_CREDIT -- 'LMTP0131'
          , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD -- 'ENTTCARD'
          , i_object_id    => i_card_id
          , i_split_hash   => i_split_hash
          , i_mask_error   => i_mask_error
        );
    o_current_sum :=
        fcl_api_limit_pkg.get_limit_sum_curr (
            i_limit_type   => cst_lvp_const_pkg.LIMIT_TYPE_CARD_CREDIT -- 'LMTP0131'
          , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD -- 'ENTTCARD'
          , i_object_id    => i_card_id
          , i_split_hash   => i_split_hash
          , i_mask_error   => i_mask_error
        );
    o_value_cash :=
        fcl_api_limit_pkg.get_sum_limit (
            i_limit_type   => cst_lvp_const_pkg.LIMIT_TYPE_CARD_CASH -- 'LMTP0143'
          , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD -- 'ENTTCARD'
          , i_object_id    => i_card_id
          , i_split_hash   => i_split_hash
          , i_mask_error   => i_mask_error
        );
    o_current_sum_cash :=
        fcl_api_limit_pkg.get_limit_sum_curr (
            i_limit_type   => cst_lvp_const_pkg.LIMIT_TYPE_CARD_CASH -- 'LMTP0143'
          , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD -- 'ENTTCARD'
          , i_object_id    => i_card_id
          , i_split_hash   => i_split_hash
          , i_mask_error   => i_mask_error
        );
end get_card_credit_limits_current;

function check_set_product_attr(
    i_product_id        in     com_api_type_pkg.t_short_id
  , i_attr_name         in     com_api_type_pkg.t_name
) return com_api_type_pkg.t_boolean
is
    l_attr_exist        com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE;
begin
    select com_api_const_pkg.TRUE
      into l_attr_exist
      from prd_attribute        pa
         , prd_attribute_value  pav
     where pa.attr_name         = i_attr_name
       and pa.id                = pav.attr_id
       and pav.entity_type      = prd_api_const_pkg.ENTITY_TYPE_PRODUCT --'ENTTPROD'
       and pav.object_id        in (select id
                                      from prd_product
                                     start with id = i_product_id
                                   connect by id   = prior parent_id)
       and rownum               = 1;
    return l_attr_exist;
exception
        when no_data_found then
             return com_api_const_pkg.FALSE;
end;

function check_reversal_oper
return com_api_type_pkg.t_boolean
is
    l_is_reversal   com_api_type_pkg.t_boolean;
    l_selector      com_api_type_pkg.t_name;
    l_oper_id       com_api_type_pkg.t_long_id;
begin
    l_selector := opr_api_shared_data_pkg.get_param_char (
        i_name         => 'OPERATION_SELECTOR'
      , i_mask_error   => com_api_type_pkg.TRUE
      , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
    );
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_oper_id := opr_api_shared_data_pkg.get_operation_id (
        i_selector => l_selector
    );  
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.check_oper_reversal, l_oper_id='||l_oper_id);
    select is_reversal
      into l_is_reversal
      from opr_operation
     where id = l_oper_id;
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.check_oper_reversal, return value='||l_is_reversal);
return l_is_reversal;
exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text          => lower($$PLSQL_UNIT) || '.check_oper_reversal, no_data_found for l_oper_id[#1], return default value = 0'
          , i_env_param1    => l_oper_id
        ); 
        return com_api_type_pkg.FALSE;
end check_reversal_oper;

function check_reversal_orn_oper
return com_api_type_pkg.t_boolean
is
    l_is_reversal   com_api_type_pkg.t_boolean;
    l_selector      com_api_type_pkg.t_name;
    l_oper_id       com_api_type_pkg.t_long_id;
begin
    l_selector := opr_api_shared_data_pkg.get_param_char (
        i_name         => 'OPERATION_SELECTOR'
      , i_mask_error   => com_api_type_pkg.TRUE
      , i_error_value  => opr_api_const_pkg.OPER_SELECTOR_CURRENT
    );
    l_selector := nvl(l_selector, opr_api_const_pkg.OPER_SELECTOR_CURRENT);

    l_oper_id := opr_api_shared_data_pkg.get_operation_id (
        i_selector => l_selector
    );  
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.check_reversal_orn_oper, l_oper_id='||l_oper_id);
    select o.is_reversal
      into l_is_reversal
      from opr_operation o
         , opr_operation n
     where n.id = o.match_id
       and n.id = l_oper_id;
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.check_reversal_orn_oper, return value='||l_is_reversal);
    return l_is_reversal;
exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text          => lower($$PLSQL_UNIT) || '.check_reversal_orn_oper, no_data_found for l_oper_id[#1], return default value = 0'
          , i_env_param1    => l_oper_id
        ); 
        return com_api_type_pkg.FALSE;
end check_reversal_orn_oper;

function format_amount (
    i_amount              in     com_api_type_pkg.t_money
  , i_curr_code           in     com_api_type_pkg.t_curr_code
  , i_add_curr_name       in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_use_separator       in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
  , i_mask_error          in     com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_name
is
    l_format_base com_api_type_pkg.t_name;
    l_result      com_api_type_pkg.t_name;
begin
    if i_use_separator = com_api_type_pkg.TRUE then
        l_format_base := 'FM999,999,999,999,990';
    else
        l_format_base := 'FM999999999999990';
    end if;

    if i_amount is not null then -- return null if i_amount is null
        select to_char(
                        round(i_amount) / power(10, exponent)
                      , l_format_base || case
                                             when exponent > 0
                                             then '.' || rpad('0', exponent, '0')
                                             else null
                                         end
                      )
               || case
                      when i_add_curr_name = com_api_type_pkg.FALSE
                      then ' ' || name
                      else ''
                  end
          into l_result
          from com_currency
         where code = i_curr_code;
    end if;

    return l_result;

exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            return to_char(i_amount);
        else
            com_api_error_pkg.raise_error(
                i_error      => 'CURRENCY_NOT_FOUND'
              , i_env_param1 => i_curr_code
            );
        end if;

end format_amount;

end cst_lvp_com_pkg;
/
