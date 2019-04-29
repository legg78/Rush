create or replace package body rus_prc_form_259_pkg is

function get_reversal_amount(
    i_oper_id        in com_api_type_pkg.t_long_id
  , i_amount_rev     in com_api_type_pkg.t_money
  , i_inst_id        in com_api_type_pkg.t_tiny_id
  , i_date_start     in date
  , i_date_end       in date
) return com_api_type_pkg.t_money
is
    l_amount_origin     com_api_type_pkg.t_money;
    l_oper_date_origin  date;
begin
    select oper_date
      into l_oper_date_origin
      from opr_operation
     where id = i_oper_id;

    if l_oper_date_origin between i_date_start and i_date_end then
        return i_amount_rev * -1;
    else
        return i_amount_rev;
    end if;

exception
    when others
    then return i_amount_rev;
end get_reversal_amount;

function get_reversal_count(
    i_oper_id        in com_api_type_pkg.t_long_id
  , i_inst_id        in com_api_type_pkg.t_tiny_id
  , i_date_start     in date
  , i_date_end       in date
) return com_api_type_pkg.t_tiny_id
is
    l_oper_date_origin  date;
begin
    select oper_date
      into l_oper_date_origin
      from opr_operation
     where id = i_oper_id;

    if l_oper_date_origin between i_date_start and i_date_end then
        return -1;
    else
        return 1;
    end if;

exception
    when others
    then return 1;
end get_reversal_count;

procedure process_form_259_1(
    i_inst_id        in com_api_type_pkg.t_tiny_id
  , i_agent_id       in com_api_type_pkg.t_short_id  default null
  , i_start_date     in date
  , i_end_date       in date
)
is
    l_date_start   date;
    l_date_end     date;
    l_date         date;
    l_sysdate      date;
    l_pmode        com_api_type_pkg.t_tiny_id;
begin
    l_sysdate    := get_sysdate;
    l_date_start := nvl(trunc(i_start_date), trunc(add_months(l_sysdate, -3), 'Q'));
    l_date_end   := nvl(trunc(i_end_date), trunc(l_sysdate, 'Q') - 1) + 1 - com_api_const_pkg.ONE_SECOND;
    l_date       := trunc(l_date_start, 'yyyy');

    if trunc(l_date_start, 'Q') != trunc(l_date_end, 'Q') then
        -- Raise exception when Start date and End date not in same quartal
        trc_log_pkg.debug(i_text => 'Start date and End date not in same quartal');
        com_api_error_pkg.raise_error(
            i_error       => 'RUS_WRONG_DATE_RANGE'
          , i_env_param1  => l_date_start
          , i_env_param2  => l_date_end
        );
    end if;

    select max(pmode)
      into l_pmode
      from rus_form_259_1_report
     where inst_id     = i_inst_id
       and report_date = trunc(l_date_start, 'Q');

    if l_pmode is null then
        select nvl(max(pmode), 0) + 1
          into l_pmode
          from rus_form_259_1_report
         where inst_id    != i_inst_id
           and report_date = trunc(l_date_start, 'Q');
    end if;

    -- Delete data for selected institute and period
    delete from rus_form_259_1_report
     where inst_id     = i_inst_id
       and report_date = trunc(l_date_start, 'Q');

    -- Initialize table with empty values
    insert into rus_form_259_1_report(
        inst_id
      , report_date
      , pmode
      , customer_type
      , contract_type
      , network_id
      , card_count
      , active_card_count
      , balance_amount
      , credit_count
      , credit_amount
      , credit_mobile_count
      , credit_mobile_amount
      , debit_count
      , debit_amount
      , debit_bank_count
      , debit_bank_amount
      , debit_bank_other_count
      , debit_bank_other_amount
      , debit_cash_count
      , debit_cash_amount
    )
    with dict as
        ( --DICT
         select customer_type
              , contract_type
              , network_id
           from
                ( --customer types
                  select com_api_const_pkg.ENTITY_TYPE_PERSON as customer_type from dual
                   union
                  select com_api_const_pkg.ENTITY_TYPE_COMPANY as customer_type from dual
                   union
                  select com_api_const_pkg.ENTITY_TYPE_UNDEFINED as customer_type from dual
                )
              , ( --contract types
                  select prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD as contract_type from dual
                )
              , ( --card_types
                  select distinct
                         com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 130
                           , i_array_type_id     => 4
                           , i_array_id          => 10000103
                           , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => id
                         ) as network_id
                    from net_card_type
                   where com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 130
                           , i_array_type_id     => 4
                           , i_array_id          => 10000103
                           , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => id
                         )  is not null
                )
        ) --DICT
    select i_inst_id as inst_id
         , trunc(l_date_start, 'Q') as report_date
         , l_pmode
         , customer_type
         , contract_type
         , network_id
         , 0 as card_count
         , 0 as active_card_count
         , 0 as balance_amount
         , 0 as credit_count
         , 0 as credit_amount
         , 0 as credit_mobile_count
         , 0 as credit_mobile_amount
         , 0 as debit_count
         , 0 as debit_amount
         , 0 as debit_bank_count
         , 0 as debit_bank_amount
         , 0 as debit_bank_other_count
         , 0 as debit_bank_other_amount
         , 0 as debit_cash_count
         , 0 as debit_cash_amount
      from dict
    group by grouping sets
                    ( (customer_type, contract_type, network_id)
                     ,(customer_type, network_id)
                     ,(network_id)
                     --,()                 --it must be separately (after union)
                    )                      --to there were null rows "itogo" when data are absent
     union all
    select i_inst_id as inst_id
         , trunc(l_date_start, 'Q') as report_date
         , l_pmode
         , null as customer_type
         , null as contract_type
         , null as network_id
         , 0 as card_count
         , 0 as active_card_count
         , 0 as balance_amount
         , 0 as credit_count
         , 0 as credit_amount
         , 0 as credit_mobile_count
         , 0 as credit_mobile_amount
         , 0 as debit_count
         , 0 as debit_amount
         , 0 as debit_bank_count
         , 0 as debit_bank_amount
         , 0 as debit_bank_other_count
         , 0 as debit_bank_other_amount
         , 0 as debit_cash_count
         , 0 as debit_cash_amount
      from dual;

    trc_log_pkg.debug(i_text => 'Initialize table with empty values');

    -- filling of cards count (column 3)
    for rc in (
        with cards as (
            select ao.account_id
                 , c.id as card_id
                 , ci.state
                 , ci.expir_date
                 , a.inst_id
                 , a.account_number
                 , case cont.contract_type
                       when prd_api_const_pkg.CONTRACT_TYPE_INSTANT_CARD then com_api_const_pkg.ENTITY_TYPE_UNDEFINED
                       else cust.entity_type
                   end as customer_type
                 , case cont.contract_type
                       when prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD then cont.contract_type
                       else null
                   end as contract_type
                 , com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 130
                     , i_array_type_id     => 4
                     , i_array_id          => 10000103
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => c.card_type_id
                   ) as network_id
              from acc_account a
                 , acc_account_object ao
                 , iss_card c
                 , iss_card_instance ci
                 , prd_customer cust
                 , prd_contract cont
             where substr(a.account_number, 1, length(rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND)) = rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND
               and a.inst_id      = i_inst_id
               and a.id           = ao.account_id
               and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and ao.object_id   = c.id
               and ci.card_id     = c.id
               and ci.expir_date  > l_date_end
               and nvl(ci.iss_date, trunc(l_date_end,'Q')) <= l_date_end
               and ci.status      = iss_api_const_pkg.CARD_STATUS_VALID_CARD
               and a.customer_id  = cust.id
               and a.contract_id  = cont.id
        )
        select customer_type
             , contract_type
             , network_id
             , count(distinct card_id) as card_count
          from cards
         group by grouping sets
               ((customer_type, contract_type, network_id)
               ,(customer_type, network_id)
               ,(network_id)
               )
          union all
         select null as customer_type
              , null as contract_type
              , null as network_id
              , count(distinct card_id) as card_count
           from cards
    )
    loop
        update rus_form_259_1_report
           set card_count              = rc.card_count
         where inst_id                 = i_inst_id
           and report_date             = trunc(l_date_start, 'Q')
           and nvl(customer_type, '&') = nvl(rc.customer_type, '&')
           and nvl(contract_type, '&') = nvl(rc.contract_type, '&')
           and nvl(network_id, -1)     = nvl(rc.network_id, -1);
    end loop;

    trc_log_pkg.debug(i_text => 'rus_prc_form_259_pkg.process_form_259_1 (3)');

    -- filling of balance (column 5)
    for rc in (
        select ac.customer_type
             , ac.contract_type
             , ac.network_id
             , sum(round(ac.balance_amount/power(10, 5), 2)) as balance_amount
          from (
                with accounts as (
                    select a.id
                         , a.inst_id
                         , a.account_number
                         , case cont.contract_type
                               when prd_api_const_pkg.CONTRACT_TYPE_INSTANT_CARD then com_api_const_pkg.ENTITY_TYPE_UNDEFINED
                               else cust.entity_type
                           end as customer_type
                         , case cont.contract_type
                               when prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD then cont.contract_type
                               else null
                           end as contract_type
                         , acc_api_balance_pkg.get_aval_balance_amount_only(i_account_id => a.id) as balance_amount
                         , a.currency
                         , b.network_id
                      from acc_account a
                         , prd_customer cust
                         , prd_contract cont
                         , ( --card_types
                            select distinct
                                   com_api_array_pkg.conv_array_elem_v(
                                       i_lov_id            => 130
                                     , i_array_type_id     => 4
                                     , i_array_id          => 10000103
                                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                     , i_elem_value        => id
                                   ) as network_id
                              from net_card_type
                             where com_api_array_pkg.conv_array_elem_v(
                                       i_lov_id            => 130
                                     , i_array_type_id     => 4
                                     , i_array_id          => 10000103
                                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                     , i_elem_value        => id
                                   )  is not null
                           ) b
                     where substr(a.account_number, 1, length(rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND)) = rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND
                       and a.inst_id      = i_inst_id
                       and a.customer_id  = cust.id
                       and a.contract_id  = cont.id
                       and b.network_id in (select com_api_array_pkg.conv_array_elem_v(
                                                       i_lov_id            => 130
                                                     , i_array_type_id     => 4
                                                     , i_array_id          => 10000103
                                                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                                     , i_elem_value        => c.card_type_id
                                                   )
                                              from iss_card c
                                                 , iss_card_instance ci
                                                 , acc_account_object ao
                                             where a.id           = ao.account_id
                                               and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                                               and ao.object_id   = c.id
                                               and ci.id          = iss_api_card_instance_pkg.get_card_instance_id(i_card_id => c.id)
                                               and ci.state       = iss_api_const_pkg.CARD_STATE_ACTIVE)
                )
                select customer_type
                     , contract_type
                     , network_id
                     , sum(
                           case when accounts.currency = '643'
                                then accounts.balance_amount
                                when accounts.currency in ('840', '978')
                                then com_api_rate_pkg.convert_amount(
                                         i_src_amount      => accounts.balance_amount
                                       , i_src_currency    => accounts.currency
                                       , i_dst_currency    => '643'
                                       , i_rate_type       => 'RTTPCBRF'
                                       , i_inst_id         => i_inst_id
                                       , i_eff_date        => l_sysdate
                                       , i_mask_exception  => 0
                                       , i_exception_value => 0
                                     )
                           end
                       ) as balance_amount
                  from accounts
                 group by customer_type, contract_type, network_id
               ) ac
         group by grouping sets
               ((customer_type, contract_type, network_id)
               ,(customer_type, network_id)
               ,(network_id)
               ,()
               )
    )
    loop
        update rus_form_259_1_report
           set balance_amount          = rc.balance_amount
         where inst_id                 = i_inst_id
           and report_date             = trunc(l_date_start, 'Q')
           and nvl(customer_type, '&') = nvl(rc.customer_type, '&')
           and nvl(contract_type, '&') = nvl(rc.contract_type, '&')
           and nvl(network_id, -1)     = nvl(rc.network_id, -1);
    end loop;

    trc_log_pkg.debug(i_text => 'rus_prc_form_259_pkg.process_form_259_1 (5)');

    -- Delete data
    execute immediate 'truncate table rus_form_259_1_opers';
    -- filling of operations temporary table
    -- filling MasterCard transaction
    insert into rus_form_259_1_opers
    select a.id as account_id
         , a.inst_id
         , o.id as oper_id
         , nvl(f.p0159_8, oper_date) as oper_date
         , o.original_id
         , o.is_reversal
         , case cont.contract_type
               when prd_api_const_pkg.CONTRACT_TYPE_INSTANT_CARD then com_api_const_pkg.ENTITY_TYPE_UNDEFINED
               else cust.entity_type
           end as customer_type
         , case cont.contract_type
               when prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD then cont.contract_type
               else null
           end as contract_type
         , case when ae.currency = '643'
                then ae.amount
                when ae.currency in ('840', '978')
                then com_api_rate_pkg.convert_amount(
                         i_src_amount      => ae.amount
                       , i_src_currency    => ae.currency
                       , i_dst_currency    => '643'
                       , i_rate_type       => 'RTTPCBRF'
                       , i_inst_id         => i_inst_id
                       , i_eff_date        => l_sysdate
                       , i_mask_exception  => 0
                       , i_exception_value => 0
                     )
           end as amount
         , '643' as currency
         , case
               when ae.balance_impact = 1 and
                    com_api_array_pkg.is_element_in_array(
                        i_array_id          => rus_api_const_pkg.OPER_INCREASE_AMOUNT_ARRAY
                      , i_elem_value        => o.oper_type
                    ) = com_api_const_pkg.TRUE
               then 'increase_amount'
               when ae.balance_impact = -1 and
                    com_api_array_pkg.is_element_in_array(
                        i_array_id          => rus_api_const_pkg.OPER_DECREASE_AMOUNT_ARRAY
                      , i_elem_value        => o.oper_type
                    ) = com_api_const_pkg.TRUE
               then 'decrease_amount'
               when ae.balance_impact = -1 and
                    com_api_array_pkg.is_element_in_array(
                        i_array_id          => rus_api_const_pkg.OPER_CASH_OUT_ARRAY
                      , i_elem_value        => o.oper_type
                    ) = com_api_const_pkg.TRUE
               then 'cash_out'
               else 'undefined'
           end as oper_type
         , case
               when pd.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT
                and (substr(pd.client_id_value, 1, length(rus_api_const_pkg.ACCOUNT_PREFIX_CREDIT_ORGANIZ)) = rus_api_const_pkg.ACCOUNT_PREFIX_CREDIT_ORGANIZ
                     or com_api_array_pkg.is_element_in_array(
                            i_array_id          => rus_api_const_pkg.ACCOUNT_PREFIX_PERSONAL_ARRAY
                          , i_elem_value        => substr(pd.client_id_value, 1, 5)
                        ) = com_api_const_pkg.TRUE
                    )
               then 'total'
               else 'commerce'
           end as account_dst
         , b.network_id as card_network_id
      from acc_account a
         , prd_customer cust
         , prd_contract cont
         , acc_entry ae
         , acc_macros am
         , opr_operation o
         , opr_participant pd
         , opr_participant pa
         , mcw_fin f
         , ( --card_types
            select distinct
                   com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 130
                     , i_array_type_id     => 4
                     , i_array_id          => 10000103
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => id
                   ) as network_id
              from net_card_type
             where com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 130
                     , i_array_type_id     => 4
                     , i_array_id          => 10000103
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => id
                   )  is not null
           ) b
     where substr(a.account_number, 1, length(rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND)) = rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND
       and a.inst_id               = i_inst_id
       and a.customer_id           = cust.id
       and a.contract_id           = cont.id
       and a.id                    = ae.account_id
       and ae.amount              != 0
       and ae.currency            in ('643', '840', '978')
       and ae.macros_id            = am.id
       and am.entity_type          = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and am.object_id            in (o.id, o.match_id)
       and o.id                    = f.id
       and nvl(f.p0159_8, o.oper_date) between l_date_start and l_date_end
       and o.id                    = pd.oper_id(+)
       and pd.participant_type(+)  = com_api_const_pkg.PARTICIPANT_DEST
       and o.id                    = pa.oper_id(+)
       and pa.participant_type(+)  = com_api_const_pkg.PARTICIPANT_ACQUIRER
       and substr(am.amount_purpose, 1, 4) != fcl_api_const_pkg.FEE_TYPE_STATUS_KEY
       and am.status              != acc_api_const_pkg.ENTRY_STATUS_CANCELED
       and com_api_array_pkg.is_element_in_array(
               i_array_id          => rus_api_const_pkg.MACROS_TYPE_ARRAY
             , i_elem_value        => com_api_type_pkg.convert_to_char(am.macros_type_id)
           ) = com_api_const_pkg.TRUE
       and com_api_array_pkg.is_element_in_array(
               i_array_id          => rus_api_const_pkg.BALANCE_TYPE_ARRAY
             , i_elem_value        => ae.balance_type
           ) = com_api_const_pkg.TRUE
       and b.network_id in (select com_api_array_pkg.conv_array_elem_v(
                                       i_lov_id            => 130
                                     , i_array_type_id     => 4
                                     , i_array_id          => 10000103
                                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                     , i_elem_value        => c.card_type_id
                                   )
                              from iss_card c
                                 , iss_card_instance ci
                                 , acc_account_object ao
                             where a.id           = ao.account_id
                               and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                               and ao.object_id   = c.id
                               and ci.id          = iss_api_card_instance_pkg.get_card_instance_id(i_card_id => c.id)
                               and ci.state       = iss_api_const_pkg.CARD_STATE_ACTIVE)
    ;

    -- filling VISA transaction
    insert into rus_form_259_1_opers
    select a.id as account_id
         , a.inst_id
         , o.id as oper_id
         , vf.sttl_date as oper_date
         , o.original_id
         , o.is_reversal
         , case cont.contract_type
               when prd_api_const_pkg.CONTRACT_TYPE_INSTANT_CARD then com_api_const_pkg.ENTITY_TYPE_UNDEFINED
               else cust.entity_type
           end as customer_type
         , case cont.contract_type
               when prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD then cont.contract_type
               else null
           end as contract_type
         , case when ae.currency = '643'
                then ae.amount
                when ae.currency in ('840', '978')
                then com_api_rate_pkg.convert_amount(
                         i_src_amount      => ae.amount
                       , i_src_currency    => ae.currency
                       , i_dst_currency    => '643'
                       , i_rate_type       => 'RTTPCBRF'
                       , i_inst_id         => i_inst_id
                       , i_eff_date        => l_sysdate
                       , i_mask_exception  => 0
                       , i_exception_value => 0
                     )
           end as amount
         , '643' as currency
         , case
               when ae.balance_impact = 1 and
                    com_api_array_pkg.is_element_in_array(
                        i_array_id          => rus_api_const_pkg.OPER_INCREASE_AMOUNT_ARRAY
                      , i_elem_value        => o.oper_type
                    ) = com_api_const_pkg.TRUE
               then 'increase_amount'
               when ae.balance_impact = -1 and
                    com_api_array_pkg.is_element_in_array(
                        i_array_id          => rus_api_const_pkg.OPER_DECREASE_AMOUNT_ARRAY
                      , i_elem_value        => o.oper_type
                    ) = com_api_const_pkg.TRUE
               then 'decrease_amount'
               when ae.balance_impact = -1 and
                    com_api_array_pkg.is_element_in_array(
                        i_array_id          => rus_api_const_pkg.OPER_CASH_OUT_ARRAY
                      , i_elem_value        => o.oper_type
                    ) = com_api_const_pkg.TRUE
               then 'cash_out'
               else 'undefined'
           end as oper_type
         , case
               when pd.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT
                and (substr(pd.client_id_value, 1, length(rus_api_const_pkg.ACCOUNT_PREFIX_CREDIT_ORGANIZ)) = rus_api_const_pkg.ACCOUNT_PREFIX_CREDIT_ORGANIZ
                     or com_api_array_pkg.is_element_in_array(
                            i_array_id          => rus_api_const_pkg.ACCOUNT_PREFIX_PERSONAL_ARRAY
                          , i_elem_value        => substr(pd.client_id_value, 1, 5)
                        ) = com_api_const_pkg.TRUE
                    )
               then 'total'
               else 'commerce'
           end as account_dst
         , b.network_id as card_network_id
      from acc_account a
         , prd_customer cust
         , prd_contract cont
         , acc_entry ae
         , acc_macros am
         , opr_operation o
         , opr_participant pd
         , opr_participant pa
         , vis_file vf
         , vis_fin_message f
         , ( --card_types
            select distinct
                   com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 130
                     , i_array_type_id     => 4
                     , i_array_id          => 10000103
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => id
                   ) as network_id
              from net_card_type
             where com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 130
                     , i_array_type_id     => 4
                     , i_array_id          => 10000103
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => id
                   )  is not null
           ) b
     where substr(a.account_number, 1, length(rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND)) = rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND
       and a.inst_id               = i_inst_id
       and a.customer_id           = cust.id
       and a.contract_id           = cont.id
       and a.id                    = ae.account_id
       and ae.amount              != 0
       and ae.currency            in ('643', '840', '978')
       and ae.macros_id            = am.id
       and am.entity_type          = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and am.object_id            in (o.id, o.match_id)
       and o.id                    = f.id
       and vf.sttl_date      between l_date_start and l_date_end
       and vf.is_incoming          = com_api_type_pkg.TRUE
       and o.incom_sess_file_id    = vf.id
       and o.id                    = pd.oper_id(+)
       and pd.participant_type(+)  = com_api_const_pkg.PARTICIPANT_DEST
       and o.id                    = pa.oper_id(+)
       and pa.participant_type(+)  = com_api_const_pkg.PARTICIPANT_ACQUIRER
       and substr(am.amount_purpose, 1, 4) != fcl_api_const_pkg.FEE_TYPE_STATUS_KEY
       and am.status              != acc_api_const_pkg.ENTRY_STATUS_CANCELED
       and com_api_array_pkg.is_element_in_array(
               i_array_id          => rus_api_const_pkg.MACROS_TYPE_ARRAY
             , i_elem_value        => com_api_type_pkg.convert_to_char(am.macros_type_id)
           ) = com_api_const_pkg.TRUE
       and com_api_array_pkg.is_element_in_array(
               i_array_id          => rus_api_const_pkg.BALANCE_TYPE_ARRAY
             , i_elem_value        => ae.balance_type
           ) = com_api_const_pkg.TRUE
       and b.network_id in (select com_api_array_pkg.conv_array_elem_v(
                                       i_lov_id            => 130
                                     , i_array_type_id     => 4
                                     , i_array_id          => 10000103
                                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                     , i_elem_value        => c.card_type_id
                                   )
                              from iss_card c
                                 , iss_card_instance ci
                                 , acc_account_object ao
                             where a.id           = ao.account_id
                               and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                               and ao.object_id   = c.id
                               and ci.id          = iss_api_card_instance_pkg.get_card_instance_id(i_card_id => c.id)
                               and ci.state       = iss_api_const_pkg.CARD_STATE_ACTIVE)
    ;

    -- filling of rows: amount\count of transactions (columns 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)
    for rc in (
        select opr.customer_type
             , opr.contract_type
             , opr.card_network_id
             , sum(round(opr.increase_amount/power(10, 5), 2)) as increase_amount
             , sum(round(opr.increase_mobile_amount/power(10, 5), 2)) as increase_mobile_amount
             , sum(round(opr.decrease_commerce_amount/power(10, 5), 2)) as decrease_commerce_amount
             , sum(round(opr.decrease_amount/power(10, 5), 2)) as decrease_amount
             , sum(round(opr.cash_out/power(10, 5), 2)) as cash_out
             , sum(opr.increase_count) as increase_count
             , sum(opr.increase_mobile_count) as increase_mobile_count
             , sum(opr.decrease_commerce_count) as decrease_commerce_count
             , sum(opr.decrease_count) as decrease_count
             , sum(opr.cash_count) as cash_count
          from (select customer_type
                     , contract_type
                     , card_network_id
                     , sum(case when oper_type = 'increase_amount' then amount else 0 end) increase_amount
                     , sum(case when oper_type = 'increase_amount' then 1 else 0 end) increase_count
                     , sum(case when oper_type = 'increase_mobile_amount' and customer_type != com_api_const_pkg.ENTITY_TYPE_COMPANY then amount else 0 end) increase_mobile_amount
                     , sum(case when oper_type = 'increase_mobile_amount' and customer_type != com_api_const_pkg.ENTITY_TYPE_COMPANY then 1 else 0 end) increase_mobile_count
                     , sum(case when oper_type = 'decrease_amount' and account_dst = 'commerce' then amount else 0 end) decrease_commerce_amount
                     , sum(case when oper_type = 'decrease_amount' and account_dst = 'commerce' then 1 else 0 end) decrease_commerce_count
                     , sum(case when oper_type = 'decrease_amount' then amount else 0 end) decrease_amount
                     , sum(case when oper_type = 'decrease_amount' then 1 else 0 end) decrease_count
                     , sum(case when oper_type = 'cash_out' and customer_type != com_api_const_pkg.ENTITY_TYPE_COMPANY then amount else 0 end) cash_out
                     , sum(case when oper_type = 'cash_out' and customer_type != com_api_const_pkg.ENTITY_TYPE_COMPANY then 1 else 0 end) cash_count
                  from rus_form_259_1_opers
                 where oper_type != 'undefined'
                 group by customer_type, contract_type, card_network_id
               ) opr
         group by grouping sets
               ((customer_type, contract_type, card_network_id)
               ,(customer_type, card_network_id)
               ,(card_network_id)
               ,()
               )
    )
    loop
        update rus_form_259_1_report
           set credit_count             = rc.increase_count + rc.increase_mobile_count
             , credit_amount            = rc.increase_amount + rc.increase_mobile_amount
             , credit_mobile_count      = rc.increase_mobile_count
             , credit_mobile_amount     = rc.increase_mobile_amount
             , debit_count              = rc.decrease_count + rc.cash_count
             , debit_amount             = rc.decrease_amount + rc.cash_out
             , debit_bank_count         = rc.decrease_count
             , debit_bank_amount        = rc.decrease_amount
             , debit_bank_other_count   = rc.decrease_commerce_count
             , debit_bank_other_amount  = rc.decrease_commerce_amount
             , debit_cash_count         = rc.cash_count
             , debit_cash_amount        = rc.cash_out
         where inst_id                  = i_inst_id
           and report_date              = trunc(l_date_start, 'Q')
           and nvl(customer_type, '&')  = nvl(rc.customer_type, '&')
           and nvl(contract_type, '&')  = nvl(rc.contract_type, '&')
           and nvl(network_id, -1)      = nvl(rc.card_network_id, -1) ;
    end loop;

    trc_log_pkg.debug ( i_text => 'rus_prc_form_259_pkg.process_form_259_1 (6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)' );

    -- filling of active cards table
    insert into rus_form_259_1_cards
    select c.id as card_id
         , c.customer_id
         , c.contract_id
         , c.inst_id
         , l_date as period
         , com_api_array_pkg.conv_array_elem_v(
               i_lov_id            => 130
             , i_array_type_id     => 4
             , i_array_id          => 10000103
             , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
             , i_elem_value        => c.card_type_id
           ) as network_id
      from acc_account a
         , acc_account_object ao
         , iss_card c
         , iss_card_instance ci
     where substr(a.account_number, 1, length(rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND)) = rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND
       and a.inst_id      = i_inst_id
       and a.id           = ao.account_id
       and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
       and ao.object_id   = c.id
       and ci.card_id     = c.id
       and ci.expir_date  > l_date_end
       and nvl(ci.iss_date, trunc(l_date_end,'Q')) <= l_date_end
       and ci.status      = iss_api_const_pkg.CARD_STATUS_VALID_CARD
       and exists (select 1
                     from opr_participant op
                        , rus_form_259_1_opers opr
                    where op.card_id           = c.id
                      and op.participant_type in (com_api_const_pkg.PARTICIPANT_ISSUER, com_api_const_pkg.PARTICIPANT_DEST)
                      and op.oper_id           = opr.oper_id)
       and not exists (select 1
                         from rus_form_259_1_cards card
                        where c.id   = card.card_id
                          and l_date = card.period)
       and com_api_array_pkg.conv_array_elem_v(
               i_lov_id            => 130
             , i_array_type_id     => 4
             , i_array_id          => 10000103
             , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
             , i_elem_value        => c.card_type_id
           )  is not null
  group by c.id
         , c.customer_id
         , c.contract_id
         , com_api_array_pkg.conv_array_elem_v(
               i_lov_id            => 130
             , i_array_type_id     => 4
             , i_array_id          => 10000103
             , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
             , i_elem_value        => c.card_type_id
           )
         , c.inst_id;

    -- filling of active cards count (column 4)
    for rc in (
        with cards as (
            select card.card_id
                 , case cont.contract_type
                       when prd_api_const_pkg.CONTRACT_TYPE_INSTANT_CARD then com_api_const_pkg.ENTITY_TYPE_UNDEFINED
                       else cust.entity_type
                   end as customer_type
                 , case cont.contract_type
                       when prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD then cont.contract_type
                       else null
                   end as contract_type
                 , card.network_id
              from rus_form_259_1_cards card
                 , prd_customer cust
                 , prd_contract cont
             where card.inst_id      = i_inst_id
               and card.customer_id  = cust.id
               and card.contract_id  = cont.id
               and card.period       = l_date
        )
        select customer_type
             , contract_type
             , network_id
             , count(distinct card_id) as card_count
          from cards
         group by grouping sets
               ((customer_type, contract_type, network_id)
               ,(customer_type, network_id)
               ,(network_id)
               )
          union all
         select null as customer_type
              , null as contract_type
              , null as network_id
              , count(distinct card_id) as card_count
           from cards
    )
    loop
        update rus_form_259_1_report
           set active_card_count       = rc.card_count
         where inst_id                 = i_inst_id
           and report_date             = trunc(l_date_start, 'Q')
           and nvl(customer_type, '&') = nvl(rc.customer_type, '&')
           and nvl(contract_type, '&') = nvl(rc.contract_type, '&')
           and nvl(network_id, -1)     = nvl(rc.network_id, -1);
    end loop;

    trc_log_pkg.debug(i_text => 'rus_prc_form_259_pkg.process_form_259_1 (4)');

    trc_log_pkg.debug(i_text => 'rus_prc_form_259_pkg.process_form_259_1 - ok');

exception
    when others
    then raise_application_error (-20001, sqlerrm);
end process_form_259_1;

procedure process_form_259_2(
    i_inst_id        in com_api_type_pkg.t_tiny_id
  , i_agent_id       in com_api_type_pkg.t_short_id  default null
  , i_start_date     in date
  , i_end_date       in date
)
is
    l_date_start   date;
    l_date_end     date;
    l_sysdate      date;
    l_pmode        com_api_type_pkg.t_tiny_id;
begin
    l_sysdate    := get_sysdate;
    l_date_start := nvl(trunc(i_start_date), trunc(add_months(l_sysdate, -3), 'Q'));
    l_date_end   := nvl(trunc(i_end_date), trunc(l_sysdate, 'Q') - 1) + 1 - com_api_const_pkg.ONE_SECOND;

    if trunc(l_date_start, 'Q') != trunc(l_date_end, 'Q') then
        -- Raise exception when Start date and End date not in same quartal
        trc_log_pkg.debug(i_text => 'Start date and End date not in same quartal');
        com_api_error_pkg.raise_error(
            i_error       => 'RUS_WRONG_DATE_RANGE'
          , i_env_param1  => l_date_start
          , i_env_param2  => l_date_end
        );
    end if;

    select max(pmode)
      into l_pmode
      from rus_form_259_2_report
     where inst_id     = i_inst_id
       and report_date = trunc(l_date_start, 'Q');

    if l_pmode is null then
        select nvl(max(pmode), 0) + 1
          into l_pmode
          from rus_form_259_2_report
         where inst_id    != i_inst_id
           and report_date = trunc(l_date_start, 'Q');
    end if;

    -- Delete data for selected institute and period
    delete from rus_form_259_2_report
     where inst_id     = i_inst_id
       and report_date = trunc(l_date_start, 'Q');

    -- Initialize table with empty values
    insert into rus_form_259_2_report(
        inst_id
      , report_date
      , pmode
      , customer_type
      , contract_type
      , network_id
      , legal_foreign_count
      , legal_foreign_amount
      , person_foreign_count
      , person_foreign_amount
      , legal_domestic_count
      , legal_domestic_amount
      , person_domestic_count
      , person_domestic_amount
    )
    with dict as
        ( --DICT
         select customer_type
              , contract_type
              , network_id
           from
                ( --customer types
                  select com_api_const_pkg.ENTITY_TYPE_PERSON as customer_type from dual
                   union
                  select com_api_const_pkg.ENTITY_TYPE_COMPANY as customer_type from dual
                   union
                  select com_api_const_pkg.ENTITY_TYPE_UNDEFINED as customer_type from dual
                )
              , ( --contract types
                  select prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD as contract_type from dual
                )
              , ( --card_types
                  select distinct
                         com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 130
                           , i_array_type_id     => 4
                           , i_array_id          => 10000103
                           , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => id
                         ) as network_id
                    from net_card_type
                   where com_api_array_pkg.conv_array_elem_v(
                             i_lov_id            => 130
                           , i_array_type_id     => 4
                           , i_array_id          => 10000103
                           , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                           , i_elem_value        => id
                         )  is not null
                )
        ) --DICT
    select i_inst_id as inst_id
         , trunc(l_date_start, 'Q') as report_date
         , l_pmode
         , customer_type
         , contract_type
         , network_id
         , 0 as legal_foreign_count
         , 0 as legal_foreign_amount
         , 0 as person_foreign_count
         , 0 as person_foreign_amount
         , 0 as legal_domestic_count
         , 0 as legal_domestic_amount
         , 0 as person_domestic_count
         , 0 as person_domestic_amount
      from dict
    group by grouping sets
                    ( (customer_type, contract_type, network_id)
                     ,(customer_type, network_id)
                     ,(network_id)
                     --,()                 --it must be separately (after union)
                    )                      --to there were null rows "itogo" when data are absent
     union all
    select i_inst_id as inst_id
         , trunc(l_date_start, 'Q') as report_date
         , l_pmode
         , null as customer_type
         , null as contract_type
         , null as network_id
         , 0 as legal_foreign_count
         , 0 as legal_foreign_amount
         , 0 as person_foreign_count
         , 0 as person_foreign_amount
         , 0 as legal_domestic_count
         , 0 as legal_domestic_amount
         , 0 as person_domestic_count
         , 0 as person_domestic_amount
      from dual;

    trc_log_pkg.debug(i_text => 'Initialize table with empty values');

    -- Delete data
    execute immediate 'truncate table rus_form_259_2_opers';
    -- filling of operations temporary table
    -- filling MasterCard transaction
    insert into rus_form_259_2_opers
    select a.id as account_id
         , a.inst_id
         , o.id as oper_id
         , nvl(f.p0159_8, o.oper_date) as oper_date
         , o.original_id
         , o.is_reversal
         , case cont.contract_type
               when prd_api_const_pkg.CONTRACT_TYPE_INSTANT_CARD then com_api_const_pkg.ENTITY_TYPE_UNDEFINED
               else cust.entity_type
           end as customer_type
         , case cont.contract_type
               when prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD then cont.contract_type
               else null
           end as contract_type
         , case when ae.currency = '643'
                then ae.amount
                when ae.currency in ('840', '978')
                then com_api_rate_pkg.convert_amount(
                         i_src_amount      => ae.amount
                       , i_src_currency    => ae.currency
                       , i_dst_currency    => '643'
                       , i_rate_type       => 'RTTPCBRF'
                       , i_inst_id         => i_inst_id
                       , i_eff_date        => l_sysdate
                       , i_mask_exception  => 0
                       , i_exception_value => 0
                     )
           end as amount
         , o.oper_currency as currency
         , case
               when pd.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT
                and com_api_array_pkg.is_element_in_array(
                        i_array_id          => rus_api_const_pkg.ACCOUNT_PREFIX_PERSONAL_ARRAY
                      , i_elem_value        => substr(pd.client_id_value, 1, 5)
                    ) = com_api_const_pkg.TRUE
               then 'person'
               else 'commerce'
           end as account_dst
         , b.network_id as card_network_id
      from acc_account a
         , prd_customer cust
         , prd_contract cont
         , acc_entry ae
         , acc_macros am
         , opr_operation o
         , opr_participant pd
         , opr_participant pa
         , mcw_fin f
         , ( --card_types
            select distinct
                   com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 130
                     , i_array_type_id     => 4
                     , i_array_id          => 10000103
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => id
                   ) as network_id
              from net_card_type
             where com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 130
                     , i_array_type_id     => 4
                     , i_array_id          => 10000103
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => id
                   )  is not null
           ) b
     where substr(a.account_number, 1, length(rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND)) = rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND
       and a.inst_id               = i_inst_id
       and a.customer_id           = cust.id
       and a.contract_id           = cont.id
       and a.id                    = ae.account_id
       and ae.amount              != 0
       and ae.currency            in ('643', '840', '978')
       and ae.balance_impact       = -1
       and ae.macros_id            = am.id
       and am.entity_type          = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and am.object_id            in (o.id, o.match_id)
       and o.id                    = f.id
       and nvl(f.p0159_8, oper_date) between l_date_start and l_date_end
       and o.id                    = pd.oper_id(+)
       and pd.participant_type(+)  = com_api_const_pkg.PARTICIPANT_DEST
       and o.id                    = pa.oper_id(+)
       and pa.participant_type(+)  = com_api_const_pkg.PARTICIPANT_ACQUIRER
       and substr(am.amount_purpose, 1, 4) != fcl_api_const_pkg.FEE_TYPE_STATUS_KEY
       and am.status              != acc_api_const_pkg.ENTRY_STATUS_CANCELED
       and com_api_array_pkg.is_element_in_array(
               i_array_id          => rus_api_const_pkg.OPER_MONEY_TRUNSFER_ARRAY
             , i_elem_value        => o.oper_type
           ) = com_api_const_pkg.TRUE
       and com_api_array_pkg.is_element_in_array(
               i_array_id          => rus_api_const_pkg.MACROS_TYPE_ARRAY
             , i_elem_value        => com_api_type_pkg.convert_to_char(am.macros_type_id)
           ) = com_api_const_pkg.TRUE
       and com_api_array_pkg.is_element_in_array(
               i_array_id          => rus_api_const_pkg.BALANCE_TYPE_ARRAY
             , i_elem_value        => ae.balance_type
           ) = com_api_const_pkg.TRUE
       and b.network_id in (select com_api_array_pkg.conv_array_elem_v(
                                       i_lov_id            => 130
                                     , i_array_type_id     => 4
                                     , i_array_id          => 10000103
                                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                     , i_elem_value        => c.card_type_id
                                   )
                              from iss_card c
                                 , iss_card_instance ci
                                 , acc_account_object ao
                             where a.id           = ao.account_id
                               and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                               and ao.object_id   = c.id
                               and ci.id          = iss_api_card_instance_pkg.get_card_instance_id(i_card_id => c.id)
                               and ci.state       = iss_api_const_pkg.CARD_STATE_ACTIVE)
    ;

    -- filling VISA transaction
    insert into rus_form_259_2_opers
    select a.id as account_id
         , a.inst_id
         , o.id as oper_id
         , vf.sttl_date as oper_date
         , o.original_id
         , o.is_reversal
         , case cont.contract_type
               when prd_api_const_pkg.CONTRACT_TYPE_INSTANT_CARD then com_api_const_pkg.ENTITY_TYPE_UNDEFINED
               else cust.entity_type
           end as customer_type
         , case cont.contract_type
               when prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD then cont.contract_type
               else null
           end as contract_type
         , case when ae.currency = '643'
                then ae.amount
                when ae.currency in ('840', '978')
                then com_api_rate_pkg.convert_amount(
                         i_src_amount      => ae.amount
                       , i_src_currency    => ae.currency
                       , i_dst_currency    => '643'
                       , i_rate_type       => 'RTTPCBRF'
                       , i_inst_id         => i_inst_id
                       , i_eff_date        => l_sysdate
                       , i_mask_exception  => 0
                       , i_exception_value => 0
                     )
           end as amount
         , o.oper_currency as currency
         , case
               when pd.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT
                and com_api_array_pkg.is_element_in_array(
                        i_array_id          => rus_api_const_pkg.ACCOUNT_PREFIX_PERSONAL_ARRAY
                      , i_elem_value        => substr(pd.client_id_value, 1, 5)
                    ) = com_api_const_pkg.TRUE
               then 'person'
               else 'commerce'
           end as account_dst
         , b.network_id as card_network_id
      from acc_account a
         , prd_customer cust
         , prd_contract cont
         , acc_entry ae
         , acc_macros am
         , opr_operation o
         , opr_participant pd
         , opr_participant pa
         , vis_file vf
         , vis_fin_message f
         , ( --card_types
            select distinct
                   com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 130
                     , i_array_type_id     => 4
                     , i_array_id          => 10000103
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => id
                   ) as network_id
              from net_card_type
             where com_api_array_pkg.conv_array_elem_v(
                       i_lov_id            => 130
                     , i_array_type_id     => 4
                     , i_array_id          => 10000103
                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                     , i_elem_value        => id
                   )  is not null
           ) b
     where substr(a.account_number, 1, length(rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND)) = rus_api_const_pkg.ACCOUNT_PREFIX_ELECTRONIC_FUND
       and a.inst_id               = i_inst_id
       and a.customer_id           = cust.id
       and a.contract_id           = cont.id
       and a.id                    = ae.account_id
       and ae.amount              != 0
       and ae.currency            in ('643', '840', '978')
       and ae.balance_impact       = -1
       and ae.macros_id            = am.id
       and am.entity_type          = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and am.object_id            in (o.id, o.match_id)
       and o.id                    = f.id
       and vf.sttl_date      between l_date_start and l_date_end
       and vf.is_incoming          = com_api_type_pkg.TRUE
       and o.incom_sess_file_id    = vf.id
       and o.id                    = pd.oper_id(+)
       and pd.participant_type(+)  = com_api_const_pkg.PARTICIPANT_DEST
       and o.id                    = pa.oper_id(+)
       and pa.participant_type(+)  = com_api_const_pkg.PARTICIPANT_ACQUIRER
       and substr(am.amount_purpose, 1, 4) != fcl_api_const_pkg.FEE_TYPE_STATUS_KEY
       and am.status              != acc_api_const_pkg.ENTRY_STATUS_CANCELED
       and com_api_array_pkg.is_element_in_array(
               i_array_id          => rus_api_const_pkg.OPER_MONEY_TRUNSFER_ARRAY
             , i_elem_value        => o.oper_type
           ) = com_api_const_pkg.TRUE
       and com_api_array_pkg.is_element_in_array(
               i_array_id          => rus_api_const_pkg.MACROS_TYPE_ARRAY
             , i_elem_value        => com_api_type_pkg.convert_to_char(am.macros_type_id)
           ) = com_api_const_pkg.TRUE
       and com_api_array_pkg.is_element_in_array(
               i_array_id          => rus_api_const_pkg.BALANCE_TYPE_ARRAY
             , i_elem_value        => ae.balance_type
           ) = com_api_const_pkg.TRUE
       and b.network_id in (select com_api_array_pkg.conv_array_elem_v(
                                       i_lov_id            => 130
                                     , i_array_type_id     => 4
                                     , i_array_id          => 10000103
                                     , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                     , i_elem_value        => c.card_type_id
                                   )
                              from iss_card c
                                 , iss_card_instance ci
                                 , acc_account_object ao
                             where a.id           = ao.account_id
                               and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                               and ao.object_id   = c.id
                               and ci.id          = iss_api_card_instance_pkg.get_card_instance_id(i_card_id => c.id)
                               and ci.state       = iss_api_const_pkg.CARD_STATE_ACTIVE)
    ;

    -- filling of rows: amount\count of transactions (columns 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17)
    for rc in (
        select opr.customer_type
             , opr.contract_type
             , opr.card_network_id
             , sum(round(opr.legal_foreign_amount/power(10, 5), 2)) as legal_foreign_amount
             , sum(round(opr.person_foreign_amount/power(10, 5), 2)) as person_foreign_amount
             , sum(round(opr.legal_domestic_amount/power(10, 5), 2)) as legal_domestic_amount
             , sum(round(opr.person_domestic_amount/power(10, 5), 2)) as person_domestic_amount
             , sum(opr.legal_foreign_count) as legal_foreign_count
             , sum(opr.person_foreign_count) as person_foreign_count
             , sum(opr.legal_domestic_count) as legal_domestic_count
             , sum(opr.person_domestic_count) as person_domestic_count
          from (
                with oper as (
                    select customer_type
                         , contract_type
                         , card_network_id
                         , sum(
                               decode(is_reversal
                                    , com_api_const_pkg.FALSE
                                    , amount
                                    , get_reversal_amount(
                                          i_oper_id    => original_id
                                        , i_amount_rev => amount
                                        , i_inst_id    => i_inst_id
                                        , i_date_start => l_date_start
                                        , i_date_end   => l_date_end + 1
                                      )
                               )
                           ) as amount
                         , decode(is_reversal
                                , com_api_const_pkg.FALSE
                                , 1
                                , get_reversal_count(
                                      i_oper_id    => original_id
                                    , i_inst_id    => i_inst_id
                                    , i_date_start => l_date_start
                                    , i_date_end   => l_date_end + 1
                                  )
                           ) as oper_count
                         , oper_id
                         , account_dst
                         , currency
                      from rus_form_259_2_opers opr
                  group by customer_type
                         , contract_type
                         , card_network_id
                         , decode(is_reversal
                                , com_api_const_pkg.FALSE
                                , 1
                                , get_reversal_count(
                                      i_oper_id    => original_id
                                    , i_inst_id    => i_inst_id
                                    , i_date_start => l_date_start
                                    , i_date_end   => l_date_end + 1
                                  )
                           )
                         , oper_id
                         , account_dst
                         , currency
                )
                select customer_type
                     , contract_type
                     , card_network_id
                     , sum(case when account_dst = 'commerce' and currency != '643' then amount else 0 end) legal_foreign_amount
                     , sum(case when account_dst = 'commerce' and currency != '643' then oper_count else 0 end) legal_foreign_count
                     , sum(case when account_dst = 'person' and currency != '643' then amount else 0 end) person_foreign_amount
                     , sum(case when account_dst = 'person' and currency != '643' then oper_count else 0 end) person_foreign_count
                     , sum(case when account_dst = 'commerce' and currency = '643' then amount else 0 end) legal_domestic_amount
                     , sum(case when account_dst = 'commerce' and currency = '643' then oper_count else 0 end) legal_domestic_count
                     , sum(case when account_dst = 'person' and currency = '643' then amount else 0 end) person_domestic_amount
                     , sum(case when account_dst = 'person' and currency = '643' then oper_count else 0 end) person_domestic_count
                  from oper
                 group by customer_type, contract_type, card_network_id
               ) opr
         group by grouping sets
               ((customer_type, contract_type, card_network_id)
               ,(customer_type, card_network_id)
               ,(card_network_id)
               ,()
               )
    )
    loop
        update rus_form_259_2_report
           set legal_foreign_count      = rc.legal_foreign_count
             , legal_foreign_amount     = rc.legal_foreign_amount
             , person_foreign_count     = rc.person_foreign_count
             , person_foreign_amount    = rc.person_foreign_amount
             , legal_domestic_count     = rc.legal_domestic_count
             , legal_domestic_amount    = rc.legal_domestic_amount
             , person_domestic_count    = rc.person_domestic_count
             , person_domestic_amount   = rc.person_domestic_amount
         where inst_id                 = i_inst_id
           and report_date             = trunc(l_date_start, 'Q')
           and nvl(customer_type, '&') = nvl(rc.customer_type, '&')
           and nvl(contract_type, '&') = nvl(rc.contract_type, '&')
           and nvl(network_id, -1)     = nvl(rc.card_network_id, -1);
    end loop;

    trc_log_pkg.debug(i_text => 'rus_prc_form_259_pkg.process_form_259_2 (3, 4, 5, 6, 7, 8, 9, 10)');

    trc_log_pkg.debug(i_text => 'rus_prc_form_259_pkg.process_form_259_2 - ok');

exception
    when others
    then raise_application_error (-20001, sqlerrm);
end process_form_259_2;

end;
/
