create or replace package body rus_prc_form_250_pkg is

function get_reversal_amount (
    i_oper_id      in com_api_type_pkg.t_long_id
    , i_amount_rev in com_api_type_pkg.t_money
    , i_inst_id    in com_api_type_pkg.t_tiny_id
    , i_date_start in date
    , i_date_end   in date
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
end;

procedure process_form_250_1(
    i_inst_id      in com_api_type_pkg.t_tiny_id
  , i_agent_id     in com_api_type_pkg.t_short_id  default null
  , i_start_date   in date
  , i_end_date     in date
) 
is
    pragma         autonomous_transaction;     
    l_date_start   date;
    l_date_end     date;
begin
    l_date_start := nvl(i_start_date, trunc(add_months(get_sysdate, -3), 'Q'));
    l_date_end := nvl(i_end_date, trunc(get_sysdate, 'Q') - 1) + 1 - com_api_const_pkg.ONE_SECOND;
    
    if trunc(l_date_start, 'Q') != trunc(l_date_end, 'Q') then
        -- Raise exception when Start date and End date not in same quartal 
        trc_log_pkg.debug ( i_text => 'Start date and End date not in same quartal' );
        com_api_error_pkg.raise_error (
            i_error       => 'RUS_WRONG_DATE_RANGE'
          , i_env_param1  => l_date_start
          , i_env_param2  => l_date_end
        );
    end if;
    
    -- Delete data for selected institute and period 
    delete from rus_form_250_1_report
     where inst_id = i_inst_id
       and report_date = trunc(l_date_start, 'Q');

    -- Initialize table with empty values
    insert into rus_form_250_1_report(
        inst_id
        , report_date
        , region_code
        , customer_type
        , network_id
        , card_type
        , customer_count
        , card_type_count
        , card_count
        , active_card_count
        , oper_amount_debit
        , oper_amount_credit
        , domestic_cash_count
        , domestic_cash_amount
        , foreign_cash_count
        , foreign_cash_amout
        , domestic_purch_count
        , domestic_purch_amount
        , foreign_purch_count
        , foreign_purch_amount
        , customs_count
        , customs_amount
        , other_count
        , other_amount
        , internet_count
        , internet_amount
        , internet_shop_count
        , internet_shop_amount
        , mobile_count
        , mobile_amount
    )
    with dict as
        ( --DICT
         select customer_type
              , network_id
              , card_feature
           from
                ( --customer types
                  select com_api_const_pkg.ENTITY_TYPE_PERSON as customer_type from dual 
                   union
                  select com_api_const_pkg.ENTITY_TYPE_COMPANY as customer_type from dual
                )
              , ( --card features
                  select net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT as card_feature from dual 
                   union
                  select net_api_const_pkg.CARD_FEATURE_STATUS_CREDIT as card_feature from dual 
                )
              , ( --networks
                  select com_api_type_pkg.convert_to_number (element_value) as network_id
                    from com_array_element
                   where array_id in (select id from com_array where array_type_id = 4)
                )
        ) --DICT
    select i_inst_id as inst_id 
         , trunc(l_date_start, 'Q') as report_date
         , null as region_code
         , customer_type
         , network_id
         , card_feature
         , 0 as customer_count
         , 0 as card_type_count
         , 0 as card_count
         , 0 as active_card_count
         , 0 as oper_amount_debit
         , 0 as oper_amount_credit
         , 0 as domestic_cash_count
         , 0 as domestic_cash_amount
         , 0 as foreign_cash_count
         , 0 as foreign_cash_amout
         , 0 as domestic_purch_count
         , 0 as domestic_purch_amount
         , 0 as foreign_purch_count
         , 0 as foreign_purch_amount
         , 0 as customs_count
         , 0 as customs_amount
         , 0 as other_count
         , 0 as other_amount
         , 0 as internet_count
         , 0 as internet_amount
         , 0 as internet_shop_count
         , 0 as internet_shop_amount
         , 0 as mobile_count
         , 0 as mobile_amount
      from dict
    group by grouping sets
                    ( (customer_type, network_id, card_feature)
                     ,(customer_type, network_id)
                     ,(customer_type )
                     ,(card_feature)
                     --,()                 --it must be separately (after union)
                    )                      --to there were null rows "itogo" when data are absent
     union all
    select i_inst_id as inst_id 
         , trunc(l_date_start, 'Q') as report_date
         , null as region_code
         , null as customer_type
         , null as network_id
         , net_api_const_pkg.CARD_FEATURE_STATUS_CNCTLESS as card_feature
         , 0 as customer_count
         , 0 as card_type_count
         , 0 as card_count
         , 0 as active_card_count
         , 0 as oper_amount_debit
         , 0 as oper_amount_credit
         , 0 as domestic_cash_count
         , 0 as domestic_cash_amount
         , 0 as foreign_cash_count
         , 0 as foreign_cash_amout
         , 0 as domestic_purch_count
         , 0 as domestic_purch_amount
         , 0 as foreign_purch_count
         , 0 as foreign_purch_amount
         , 0 as customs_count
         , 0 as customs_amount
         , 0 as other_count
         , 0 as other_amount
         , 0 as internet_count
         , 0 as internet_amount
         , 0 as internet_shop_count
         , 0 as internet_shop_amount
         , 0 as mobile_count
         , 0 as mobile_amount
      from dual
     union all
    select i_inst_id as inst_id 
         , trunc(l_date_start, 'Q') as report_date
         , null as region_code
         , null as customer_type
         , null as network_id
         , 'OPERCNTL' as card_feature
         , 0 as customer_count
         , 0 as card_type_count
         , 0 as card_count
         , 0 as active_card_count
         , 0 as oper_amount_debit
         , 0 as oper_amount_credit
         , 0 as domestic_cash_count
         , 0 as domestic_cash_amount
         , 0 as foreign_cash_count
         , 0 as foreign_cash_amout
         , 0 as domestic_purch_count
         , 0 as domestic_purch_amount
         , 0 as foreign_purch_count
         , 0 as foreign_purch_amount
         , 0 as customs_count
         , 0 as customs_amount
         , 0 as other_count
         , 0 as other_amount
         , 0 as internet_count
         , 0 as internet_amount
         , 0 as internet_shop_count
         , 0 as internet_shop_amount
         , 0 as mobile_count
         , 0 as mobile_amount
      from dual
     union all
    select i_inst_id as inst_id 
         , trunc(l_date_start, 'Q') as report_date
         , null as region_code
         , null as customer_type
         , null as network_id
         , null as card_feature
         , 0 as customer_count
         , 0 as card_type_count
         , 0 as card_count
         , 0 as active_card_count
         , 0 as oper_amount_debit
         , 0 as oper_amount_credit
         , 0 as domestic_cash_count
         , 0 as domestic_cash_amount
         , 0 as foreign_cash_count
         , 0 as foreign_cash_amout
         , 0 as domestic_purch_count
         , 0 as domestic_purch_amount
         , 0 as foreign_purch_count
         , 0 as foreign_purch_amount
         , 0 as customs_count
         , 0 as customs_amount
         , 0 as other_count
         , 0 as other_amount
         , 0 as internet_count
         , 0 as internet_amount
         , 0 as internet_shop_count
         , 0 as internet_shop_amount
         , 0 as mobile_count
         , 0 as mobile_amount
      from dual;

    trc_log_pkg.debug ( i_text => 'Initialize table with empty values' );
    
    -- Delete data
    execute immediate 'truncate table rus_form_250_cards';
    -- filling of card temporary table
    insert into rus_form_250_cards
        select c.id as card_id
             , fe.card_feature
             , cust.entity_type as customer_type
             , null as region_code
             , c.customer_id
             , b.network_id
             , ci.start_date
             , ci.expir_date
             , nvl(bt.is_contactless, 0) as is_contactless
          from iss_card              c
             , prd_customer          cust
             , prd_contract          cont
             , (select id, network_id
                  from iss_bin b
                 where exists (select 1
                                 from com_array_element
                                where array_id in (select id from com_array where array_type_id = 4)
                                  and com_api_type_pkg.get_number_value (i_data_type => com_api_const_pkg.DATA_TYPE_NUMBER
                                                                       , i_value     => element_value) = b.network_id )
               )                     b
             , iss_card_instance     ci
             , prs_blank_type        bt
             , ( select 10000045 as array_id, net_api_const_pkg.CARD_FEATURE_STATUS_DEBIT as card_feature from dual
                  union
                 select 10000047 as array_id, net_api_const_pkg.CARD_FEATURE_STATUS_CREDIT as card_feature from dual
               )                     fe
             , com_array_element     cae
         where c.inst_id in ( select id from ost_institution
                               where ( i_inst_id <> ost_api_const_pkg.DEFAULT_INST and id = i_inst_id ) 
                                     or 
                                     ( i_inst_id = ost_api_const_pkg.DEFAULT_INST and network_id = 1001 )
                            )
           and c.contract_id = cont.id
           and c.customer_id = cust.id
           and cont.product_id = com_api_type_pkg.get_number_value (i_data_type => com_api_const_pkg.DATA_TYPE_NUMBER
                                                                  , i_value     => cae.element_value)
           and cae.array_id = fe.array_id
           and (i_agent_id is null or cont.agent_id = i_agent_id)
           and ci.card_id = c.id
           and b.id = ci.bin_id
           and ci.id = iss_api_card_instance_pkg.get_card_instance_id(i_card_id => c.id)
           and ci.blank_type_id = bt.id(+);
    
    -- Delete data
    execute immediate 'truncate table rus_form_250_opers';
    -- filling of operations temporary table
    insert into rus_form_250_opers
        select o.id as oper_id
             , a_opr.column_type as oper_type
             , o.mcc
             , card.card_id
             , case when o.merchant_country = '643'
                     and o.sttl_type not in (select element_value from com_array_element where array_id = 10000028)
                     and pa.inst_id not in (select element_value from com_array_element where array_id = 10000055)
                    then nvl(
                             com_api_array_pkg.conv_array_elem_v(
                                 i_lov_id            => 1019
                               , i_array_type_id     => 4
                               , i_array_id          => 3
                               , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                               , i_elem_value        => card.network_id
                             )
                           , to_char(card.network_id)
                         )
                    else to_char(card.network_id)
               end as card_network_id
             , o.merchant_country
             , o.is_reversal
             , o.original_id
             , a_bltp.column_type as balance_type
             , ae.currency
             , ae.id
             , case when ae.currency = '643' 
                    then ae.amount
                    when ae.currency in ('840', '978') 
                    then com_api_rate_pkg.convert_amount(
                             i_src_amount      => ae.amount
                           , i_src_currency    => ae.currency
                           , i_dst_currency    => '643'
                           , i_rate_type       => 'RTTPCBRF'
                           , i_inst_id         => i_inst_id
                           , i_eff_date        => ae.posting_date
                           , i_mask_exception  => 0
                           , i_exception_value => 0
                         )
               end  as entry_amount
             , 1 as count_multiplier
             , greatest(nvl( (select case when nvl(vfm.electr_comm_ind, '0') in ('5', '6', '7') 
                                          then 1 
                                          else 0 
                                     end 
                                from vis_fin_message vfm
                               where vfm.id = o.id)
                        , 0)
                      , nvl( (select case when nvl(mf.de022_7, '0') in ('S') 
                                          then 1 
                                          else 0 
                                     end 
                                from mcw_fin mf
                               where mf.id = o.id)
                        , 0)
               ) as is_internet
             , decode(o.terminal_type, acq_api_const_pkg.TERMINAL_TYPE_MOBILE, 1, 0) as is_mobile
             , greatest(nvl( (select case when nvl(vfm.pos_entry_mode, '00') in ('07') 
                                          then 1 
                                          else 0 
                                     end 
                                from vis_fin_message vfm
                               where vfm.id = o.id)
                          , 0)
                      , nvl( (select case when nvl(mf.de022_7, '0') in ('A') 
                                          then 1 
                                          else 0 
                                          end 
                                from mcw_fin mf
                               where mf.id = o.id)
                          , 0)
                      , nvl( (select case when nvl(substr(aa.card_data_input_mode, -1), '0') in ('M', 'N', 'P') 
                                          then 1 
                                          else 0 
                                     end 
                                from aut_auth aa 
                               where aa.id = o.id)
                          , 0)
                      , nvl( (select case when nvl(substr(cf.pos_entry_mode, 1, 2), '00') in ('07', '91') 
                                          then 1 
                                          else 0 
                                          end 
                                from cmp_fin_message cf
                               where cf.id = o.id)
                          , 0)
               ) as is_contactless
          from opr_operation   o
             , opr_participant op
             , opr_participant pa
             , acc_entry ae
             , acc_macros am
             , rus_form_250_cards card
             , (--form 250 oper_types
                select decode (array_id, 4, 'cashout', 5, 'purchases', 6, 'customs', 7, 'others') as column_type
                     , element_value as oper_type
                  from com_array_element
                 where array_id in (select id from com_array where array_type_id = 5)
               ) a_opr
             , (--form 250 balance_types
                select decode (array_id, 10000042, 'ledger', 10000043, 'overdraft') as column_type
                      , element_value as balance_type
                   from com_array_element
                  where array_id in (select id from com_array where array_type_id = 2)
               ) a_bltp
         where o.id                  = op.oper_id
           and o.is_reversal         = com_api_const_pkg.FALSE
           and card.card_id          = op.card_id
           and op.participant_type  in (com_api_const_pkg.PARTICIPANT_ISSUER, com_api_const_pkg.PARTICIPANT_DEST)
           and o.id                  = pa.oper_id
           and pa.participant_type  in (com_api_const_pkg.PARTICIPANT_ACQUIRER)
           and o.oper_date          >= l_date_start
           and o.oper_date          <= l_date_end
           and (o.match_status       = opr_api_const_pkg.OPERATION_MATCH_DONT_REQ_MATCH
                or o.msg_type        = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT)
           and o.status             in (opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
                                      , opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                      , opr_api_const_pkg.OPERATION_STATUS_AUTHORIZED)
           and o.oper_amount         > 0
           and (o.oper_currency     in ('643', '840', '978')
                or o.sttl_currency  is not null)
           and o.oper_type           = a_opr.oper_type
           and a_opr.column_type    is not null
           and not (o.oper_type     in ('OPTP0041', 'OPTP0042') and nvl(o.mcc, -1)  = 9311 and a_opr.column_type = 'others' )
           and not (o.oper_type     in ('OPTP0041', 'OPTP0042') and nvl(o.mcc, -1) != 9311 and a_opr.column_type = 'customs' )  
           and ae.macros_id          = am.id
           and ae.account_id         = op.account_id
           and am.object_id          = o.id
           and am.entity_type        = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and ae.balance_type       = a_bltp.balance_type
           and a_bltp.column_type   is not null
           and substr(am.amount_purpose, 1, 4) != fcl_api_const_pkg.FEE_TYPE_STATUS_KEY
           and am.status            != acc_api_const_pkg.ENTRY_STATUS_CANCELED
           and (ae.transaction_type != 'TRNT0003' and am.amount_purpose != 'AMPR0001');

    -- filling of rows: customers count (columns 4)
    for rc in
        ( with cards as  ( select c.region_code
                                , c.customer_type
                                , c.network_id
                                , c.card_feature
                                , c.customer_id
                                , c.is_contactless
                             from rus_form_250_cards  c
                            where c.start_date <= l_date_end
                              and nvl(c.expir_date, l_date_end + 1) > l_date_end
                         ) --CARDS
          select null as region_code
               , customer_type
               , network_id
               , card_feature
               , count(distinct customer_id) as customer_count
            from cards
           group by grouping sets
                 ((customer_type, network_id, card_feature)
                 ,(customer_type, network_id)
                 ,(customer_type)
                 ,(card_feature)
                 )
            union all
           select null as region_code
                , null as customer_type
                , null as network_id
                , net_api_const_pkg.CARD_FEATURE_STATUS_CNCTLESS as card_feature
                , count(distinct customer_id) as customer_count
             from cards
            where is_contactless = 1
            union all
           select null as region_code
                , null as customer_type
                , null as network_id
                , null as card_feature
                , count(distinct customer_id) as customer_count
             from cards
        )
    loop
        update rus_form_250_1_report
           set customer_count = rc.customer_count
         where inst_id = i_inst_id
           and report_date = trunc(l_date_start, 'Q')
           and nvl(region_code, '&') = nvl(rc.region_code, '&')
           and nvl(customer_type, '&') = nvl(rc.customer_type, '&')
           and nvl(network_id, -99) = nvl(rc.network_id, -99)
           and nvl(card_type, '&') = nvl(rc.card_feature, '&') ;

        update rus_form_250_1_report
           set customer_count = rc.customer_count
         where inst_id = i_inst_id
           and report_date = trunc(l_date_start, 'Q')
           and nvl(region_code, '&') = nvl(rc.region_code, '&')
           and nvl(customer_type, '&') = nvl(rc.customer_type, '&')
           and nvl(network_id, -99) = nvl(nvl(com_api_array_pkg.conv_array_elem_v(
                                                  i_lov_id            => 1019
                                                , i_array_type_id     => 4
                                                , i_array_id          => 3
                                                , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                                , i_elem_value        => rc.network_id
                                              )
                                            , to_char(rc.network_id)
                                          ), -99)
           and nvl(card_type, '&') = nvl(rc.card_feature, '&') ;
    end loop;

    trc_log_pkg.debug ( i_text => 'rus_prc_form_250_pkg.process_form_250_1 (4)' );

    -- filling of rows: cards count (column 5)
    for rc in
        ( with cards as  ( select c.region_code
                                , c.customer_type
                                , c.network_id
                                , c.card_feature
                                , c.customer_id
                                , c.card_id
                                , c.is_contactless
                             from rus_form_250_cards  c
                            where c.start_date <= l_date_end
                              and nvl(c.expir_date, l_date_end + 1) > l_date_end
                         ) --CARDS
          select null as region_code
               , customer_type
               , network_id
               , card_feature
               , count(distinct card_id) as card_count
            from cards
           group by grouping sets
                 ((customer_type, network_id, card_feature)
                 ,(customer_type, network_id)
                 ,(customer_type)
                 ,(card_feature)
                 )
           union all
          select null as region_code
               , null as customer_type
               , null as network_id
               , net_api_const_pkg.CARD_FEATURE_STATUS_CNCTLESS as card_feature
               , count(distinct card_id) as card_count
            from cards
            where is_contactless = com_api_const_pkg.TRUE
           union all
          select null as region_code
               , null as customer_type
               , null as network_id
               , null as card_feature
               , count(distinct card_id) as card_count
            from cards
        )
    loop
        update rus_form_250_1_report
           set card_count = rc.card_count
         where inst_id = i_inst_id
           and report_date = trunc(l_date_start, 'Q')
           and nvl(region_code, '&') = nvl(rc.region_code, '&')
           and nvl(customer_type, '&') = nvl(rc.customer_type, '&')
           and nvl(network_id, -99) = nvl(rc.network_id, -99)
           and nvl(card_type, '&') = nvl(rc.card_feature, '&') ;

        update rus_form_250_1_report
           set card_count = rc.card_count
         where inst_id = i_inst_id
           and report_date = trunc(l_date_start, 'Q')
           and nvl(region_code, '&') = nvl(rc.region_code, '&')
           and nvl(customer_type, '&') = nvl(rc.customer_type, '&')
           and nvl(network_id, -99) = nvl(nvl(com_api_array_pkg.conv_array_elem_v(
                                                  i_lov_id            => 1019
                                                , i_array_type_id     => 4
                                                , i_array_id          => 3
                                                , i_inst_id           => ost_api_const_pkg.DEFAULT_INST
                                                , i_elem_value        => rc.network_id
                                             )
                                           , to_char(rc.network_id)
                                          ), -99)
           and nvl(card_type, '&') = nvl(rc.card_feature, '&') ;
    end loop;

    trc_log_pkg.debug ( i_text => 'rus_prc_form_250_pkg.process_form_250_1 (5)' );
    
    -- filling of rows: amount\count of transactions and count of active cards (columns 6, 7, 8)
    for rc in (
        select null as region_code
             , opr.customer_type
             , opr.network_id
             , opr.card_feature
             , count(distinct opr.card_id) as card_count
             , sum(round(opr.ledger_amount/ power(10, 5), 2)) as ledger_amount
             , sum(round(opr.overdraft_amount/ power(10, 5), 2)) as overdraft_amount
          from (
                with opers as (select card.region_code
                                    , card.customer_type
                                    , oper.card_network_id as network_id
                                    , card.card_feature
                                    , card.card_id
                                    , oper.balance_type
                                    , decode(is_reversal
                                           , com_api_const_pkg.FALSE
                                           , entry_amount
                                           , get_reversal_amount(
                                                 i_oper_id    => original_id
                                               , i_amount_rev => entry_amount
                                               , i_inst_id    => i_inst_id
                                               , i_date_start => l_date_start
                                               , i_date_end   => l_date_end + 1
                                             )
                                      ) as actual_amount
                                    , card.is_contactless as card_contactless
                                 from rus_form_250_cards card
                                    , rus_form_250_opers oper
                                where card.card_id = oper.card_id)
                select null as region_code
                     , customer_type
                     , network_id
                     , card_feature
                     , card_id
                     , sum(decode(balance_type, 'ledger', actual_amount, 0)) as ledger_amount
                     , sum(decode(balance_type, 'overdraft', actual_amount, 0)) as overdraft_amount
                  from opers
                 group by customer_type, network_id, card_feature, card_id
               ) opr
      group by grouping sets
               ((customer_type, network_id, card_feature)
               ,(customer_type, network_id)
               ,(customer_type)
               ,(card_feature)
               ,()
               )
    )
    loop
        update rus_form_250_1_report
           set active_card_count     = rc.card_count
             , oper_amount_debit     = rc.ledger_amount
             , oper_amount_credit    = rc.overdraft_amount
         where inst_id = i_inst_id
           and report_date = trunc(l_date_start, 'Q')
           and nvl(region_code, '&') = nvl(rc.region_code, '&')
           and nvl(customer_type, '&') = nvl(rc.customer_type, '&')
           and nvl(network_id, -99) = nvl(rc.network_id, -99)
           and nvl(card_type, '&') = nvl(rc.card_feature, '&') ;
    end loop;

    for rc in
        ( with opers as (select card.region_code
                              , card.customer_type
                              , oper.card_network_id as network_id
                              , card.card_feature
                              , card.card_id
                              , oper.balance_type
                              , decode ( is_reversal, 0, entry_amount
                                                       , get_reversal_amount
                                                                   ( i_oper_id    => original_id
                                                                   , i_amount_rev => entry_amount
                                                                   , i_inst_id    => i_inst_id
                                                                   , i_date_start => l_date_start
                                                                   , i_date_end   => l_date_end + 1
                                                                   )
                                ) as actual_amount
                              , card.is_contactless as card_contactless
                           from rus_form_250_cards card
                              , rus_form_250_opers oper
                          where card.card_id = oper.card_id)
          select null as region_code
               , null as customer_type
               , null as network_id
               , net_api_const_pkg.CARD_FEATURE_STATUS_CNCTLESS as card_feature
               , count(distinct card_id) as card_count
               , 0 as ledger_amount
               , 0 as overdraft_amount
          from opers
         where card_contactless = 1
        )
    loop
        update rus_form_250_1_report
           set active_card_count     = rc.card_count
             , oper_amount_debit     = round(rc.ledger_amount/ power(10,5), 2)
             , oper_amount_credit    = round(rc.overdraft_amount/ power(10,5), 2)
         where inst_id = i_inst_id
           and report_date = trunc(l_date_start, 'Q')
           and nvl(region_code, '&') = nvl(rc.region_code, '&')
           and nvl(customer_type, '&') = nvl(rc.customer_type, '&')
           and nvl(network_id, -99) = nvl(rc.network_id, -99)
           and nvl(card_type, '&') = nvl(rc.card_feature, '&') ;
    end loop;

    trc_log_pkg.debug ( i_text => 'rus_prc_form_250_pkg.process_form_250_1 (6, 7, 8)' );

    -- filling of rows: amount\count of transactions (columns 9, 10, 11, 12, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28)
    for rc in ( 
        select null as region_code
             , opr.customer_type
             , opr.network_id
             , opr.card_feature
             , sum(opr.domestic_cash_count) as domestic_cash_count
             , sum(round(opr.domestic_cash_amount/ power(10, 5), 2)) as domestic_cash_amount
             , sum(opr.foreign_cash_count) as foreign_cash_count
             , sum(round(opr.foreign_cash_amount/ power(10, 5), 2)) as foreign_cash_amount
             , sum(opr.domestic_purchases_count) as domestic_purchases_count
             , sum(round(opr.domestic_purchases_amount/ power(10, 5), 2)) as domestic_purchases_amount
             , sum(opr.foreign_purchases_count) as foreign_purchases_count
             , sum(round(opr.foreign_purchases_amount/ power(10, 5), 2)) as foreign_purchases_amount
             , sum(opr.customs_count) as customs_count
             , sum(round(opr.customs_amount/ power(10, 5), 2)) as customs_amount
             , sum(opr.others_count) as others_count
             , sum(round(opr.others_amount/ power(10, 5), 2)) as others_amount
             , sum(opr.internet_count) as internet_count
             , sum(round(opr.internet_amount/ power(10, 5), 2)) as internet_amount
             , sum(opr.internet_shop_count) as internet_shop_count
             , sum(round(opr.internet_shop_amount/ power(10, 5), 2)) as internet_shop_amount
             , sum(opr.mobile_count) as mobile_count
             , sum(round(opr.mobile_amount/ power(10, 5), 2)) as mobile_amount
          from (
                with opers as (select card.region_code
                                    , card.customer_type
                                    , oper.card_network_id as network_id
                                    , card.card_feature
                                    , oper.oper_id
                                    , oper.oper_type
                                    , sum(decode(
                                              is_reversal
                                            , com_api_const_pkg.FALSE
                                            , entry_amount
                                            , get_reversal_amount(
                                                   i_oper_id    => original_id
                                                 , i_amount_rev => entry_amount
                                                 , i_inst_id    => i_inst_id
                                                 , i_date_start => l_date_start
                                                 , i_date_end   => l_date_end + 1
                                              )
                                          )
                                      ) as actual_amount
                                    , decode(oper.merchant_country, '643', 1, 0) as is_domestic
                                    , oper.count_multiplier
                                    , oper.is_internet
                                    , oper.is_mobile
                                    , card.is_contactless as card_contactless
                                    , oper.is_contactless as oper_contactless
                                 from rus_form_250_cards card
                                    , rus_form_250_opers oper
                                where card.card_id = oper.card_id
                             group by card.region_code
                                    , card.customer_type
                                    , oper.card_network_id
                                    , card.card_feature
                                    , oper.oper_id
                                    , oper.oper_type
                                    , decode(oper.merchant_country, '643', 1, 0)
                                    , oper.count_multiplier
                                    , oper.is_internet
                                    , oper.is_mobile
                                    , card.is_contactless
                                    , oper.is_contactless
                     )
                select null as region_code
                     , customer_type
                     , network_id
                     , card_feature
                     , sum(case when is_domestic = 1 and oper_type = 'cashout' then sign(actual_amount) * count_multiplier else 0 end) as domestic_cash_count
                     , sum(case when is_domestic = 1 and oper_type = 'cashout' then actual_amount else 0 end) as domestic_cash_amount
                     , sum(case when is_domestic = 0 and oper_type = 'cashout' then sign(actual_amount) * count_multiplier else 0 end) as foreign_cash_count
                     , sum(case when is_domestic = 0 and oper_type = 'cashout' then actual_amount else 0 end) as foreign_cash_amount
                     , sum(case when is_domestic = 1 and oper_type = 'purchases' then sign(actual_amount) * count_multiplier else 0 end) as domestic_purchases_count
                     , sum(case when is_domestic = 1 and oper_type = 'purchases' then actual_amount else 0 end) as domestic_purchases_amount
                     , sum(case when is_domestic = 0 and oper_type = 'purchases' then sign(actual_amount) * count_multiplier else 0 end) as foreign_purchases_count
                     , sum(case when is_domestic = 0 and oper_type = 'purchases' then actual_amount else 0 end) as foreign_purchases_amount
                     , sum(case when oper_type = 'customs' then sign(actual_amount) * count_multiplier else 0 end) as customs_count
                     , sum(case when oper_type = 'customs' then actual_amount else 0 end) as customs_amount
                     , sum(case when oper_type = 'others' then sign(actual_amount) * count_multiplier else 0 end) as others_count
                     , sum(case when oper_type = 'others' then actual_amount else 0 end) as others_amount
                     , sum(case when is_internet = 1 then sign(actual_amount) * count_multiplier else 0 end) as internet_count
                     , sum(case when is_internet = 1 then actual_amount else 0 end) as internet_amount
                     , sum(case when is_internet = 1 and is_domestic = 0 and oper_type = 'purchases' then sign(actual_amount) * count_multiplier else 0 end) as internet_shop_count
                     , sum(case when is_internet = 1 and is_domestic = 0 and oper_type = 'purchases' then actual_amount else 0 end) as internet_shop_amount
                     , sum(case when is_mobile = 1 then sign(actual_amount) * count_multiplier else 0 end) as mobile_count
                     , sum(case when is_mobile = 1 then actual_amount else 0 end) as mobile_amount
                  from opers
                 group by customer_type, network_id, card_feature
               ) opr
      group by grouping sets
               ((customer_type, network_id, card_feature)
               ,(customer_type, network_id)
               ,(customer_type)
               ,(card_feature)
               ,()
               )
        )
    loop
        update rus_form_250_1_report
           set domestic_cash_count     = rc.domestic_cash_count
             , domestic_cash_amount    = rc.domestic_cash_amount
             , foreign_cash_count      = rc.foreign_cash_count
             , foreign_cash_amout      = rc.foreign_cash_amount
             , domestic_purch_count    = rc.domestic_purchases_count
             , domestic_purch_amount   = rc.domestic_purchases_amount
             , foreign_purch_count     = rc.foreign_purchases_count
             , foreign_purch_amount    = rc.foreign_purchases_amount
             , customs_count           = rc.customs_count
             , customs_amount          = rc.customs_amount
             , other_count             = rc.others_count
             , other_amount            = rc.others_amount
             , internet_count          = rc.internet_count
             , internet_amount         = rc.internet_amount
             , internet_shop_count     = rc.internet_shop_count
             , internet_shop_amount    = rc.internet_shop_amount
             , mobile_count            = rc.mobile_count
             , mobile_amount           = rc.mobile_amount
         where inst_id = i_inst_id
           and report_date = trunc(l_date_start, 'Q')
           and nvl(region_code, '&') = nvl(rc.region_code, '&')
           and nvl(customer_type, '&') = nvl(rc.customer_type, '&')
           and nvl(network_id, -99) = nvl(rc.network_id, -99)
           and nvl(card_type, '&') = nvl(rc.card_feature, '&') ;
    end loop;

    -- filling of rows: amount\count of contactless cards and transactions 
    for rc in
        ( with opers as (select card.region_code
                              , card.customer_type
                              , oper.card_network_id as network_id
                              , card.card_feature
                              , oper.oper_id
                              , oper.oper_type
                              , sum (decode ( is_reversal, 0, entry_amount
                                                            , get_reversal_amount
                                                                   ( i_oper_id    => original_id
                                                                   , i_amount_rev => entry_amount
                                                                   , i_inst_id    => i_inst_id
                                                                   , i_date_start => l_date_start
                                                                   , i_date_end   => l_date_end + 1
                                                                   )
                                            )
                                ) as actual_amount
                              , decode (oper.merchant_country, '643', 1, 0) as is_domestic
                              , oper.count_multiplier
                              , oper.is_internet
                              , oper.is_mobile
                              , card.is_contactless as card_contactless
                              , oper.is_contactless as oper_contactless
                           from rus_form_250_cards card
                              , rus_form_250_opers oper
                          where card.card_id = oper.card_id
                       group by card.region_code
                              , card.customer_type
                              , oper.card_network_id
                              , card.card_feature
                              , oper.oper_id
                              , oper.oper_type
                              , decode (oper.merchant_country, '643', 1, 0)
                              , oper.count_multiplier
                              , oper.is_internet
                              , oper.is_mobile
                              , card.is_contactless
                              , oper.is_contactless
                          )
          select null as region_code
               , null as customer_type
               , null as network_id
               , net_api_const_pkg.CARD_FEATURE_STATUS_CNCTLESS as card_feature
               , sum(case when is_domestic = 1 and oper_type = 'cashout' then sign(actual_amount) * count_multiplier else 0 end) as domestic_cash_count
               , sum(case when is_domestic = 1 and oper_type = 'cashout' then actual_amount else 0 end) as domestic_cash_amount
               , sum(case when is_domestic = 0 and oper_type = 'cashout' then sign(actual_amount) * count_multiplier else 0 end) as foreign_cash_count
               , sum(case when is_domestic = 0 and oper_type = 'cashout' then actual_amount else 0 end) as foreign_cash_amount
               , sum(case when is_domestic = 1 and oper_type = 'purchases' then sign(actual_amount) * count_multiplier else 0 end) as domestic_purchases_count
               , sum(case when is_domestic = 1 and oper_type = 'purchases' then actual_amount else 0 end) as domestic_purchases_amount
               , sum(case when is_domestic = 0 and oper_type = 'purchases' then sign(actual_amount) * count_multiplier else 0 end) as foreign_purchases_count
               , sum(case when is_domestic = 0 and oper_type = 'purchases' then actual_amount else 0 end) as foreign_purchases_amount
               , sum(case when oper_type = 'customs' then sign(actual_amount) * count_multiplier else 0 end) as customs_count
               , sum(case when oper_type = 'customs' then actual_amount else 0 end) as customs_amount
               , sum(case when oper_type = 'others' then sign(actual_amount) * count_multiplier else 0 end) as others_count
               , sum(case when oper_type = 'others' then actual_amount else 0 end) as others_amount
               , 0 as internet_count
               , 0 as internet_amount
               , 0 as internet_shop_count
               , 0 as internet_shop_amount
               , 0 as mobile_count
               , 0 as mobile_amount
            from opers
           where card_contactless = 1
           union all
          select null as region_code
               , null as customer_type
               , null as network_id
               , 'OPERCNTL' as card_feature
               , sum(case when is_domestic = 1 and oper_type = 'cashout' then sign(actual_amount) * count_multiplier else 0 end) as domestic_cash_count
               , sum(case when is_domestic = 1 and oper_type = 'cashout' then actual_amount else 0 end) as domestic_cash_amount
               , sum(case when is_domestic = 0 and oper_type = 'cashout' then sign(actual_amount)  *count_multiplier else 0 end) as foreign_cash_count
               , sum(case when is_domestic = 0 and oper_type = 'cashout' then actual_amount else 0 end) as foreign_cash_amount
               , sum(case when is_domestic = 1 and oper_type = 'purchases' then sign(actual_amount) * count_multiplier else 0 end) as domestic_purchases_count
               , sum(case when is_domestic = 1 and oper_type = 'purchases' then actual_amount else 0 end) as domestic_purchases_amount
               , sum(case when is_domestic = 0 and oper_type = 'purchases' then sign(actual_amount) * count_multiplier else 0 end) as foreign_purchases_count
               , sum(case when is_domestic = 0 and oper_type = 'purchases' then actual_amount else 0 end) as foreign_purchases_amount
               , sum(case when oper_type = 'customs' then sign(actual_amount) * count_multiplier else 0 end) as customs_count
               , sum(case when oper_type = 'customs' then actual_amount else 0 end) as customs_amount
               , sum(case when oper_type = 'others' then sign(actual_amount) * count_multiplier else 0 end) as others_count
               , sum(case when oper_type = 'others' then actual_amount else 0 end) as others_amount
               , 0 as internet_count
               , 0 as internet_amount
               , 0 as internet_shop_count
               , 0 as internet_shop_amount
               , 0 as mobile_count
               , 0 as mobile_amount
          from opers
         where oper_contactless = 1
        )
    loop
        update rus_form_250_1_report
           set domestic_cash_count     = rc.domestic_cash_count
             , domestic_cash_amount    = round(rc.domestic_cash_amount/ power(10, 5), 2)
             , foreign_cash_count      = rc.foreign_cash_count
             , foreign_cash_amout      = round(rc.foreign_cash_amount/ power(10, 5), 2)
             , domestic_purch_count    = rc.domestic_purchases_count
             , domestic_purch_amount   = round(rc.domestic_purchases_amount/ power(10, 5), 2)
             , foreign_purch_count     = rc.foreign_purchases_count
             , foreign_purch_amount    = round(rc.foreign_purchases_amount/ power(10, 5), 2)
             , customs_count           = rc.customs_count
             , customs_amount          = round(rc.customs_amount/ power(10, 5), 2)
             , other_count             = rc.others_count
             , other_amount            = round(rc.others_amount/ power(10, 5), 2)
             , internet_count          = rc.internet_count
             , internet_amount         = round(rc.internet_amount/ power(10, 5), 2)
             , internet_shop_count     = rc.internet_shop_count
             , internet_shop_amount    = round(rc.internet_shop_amount/ power(10, 5), 2)
             , mobile_count            = rc.mobile_count
             , mobile_amount           = round(rc.mobile_amount/ power(10, 5), 2)
         where inst_id = i_inst_id
           and report_date = trunc(l_date_start, 'Q')
           and nvl(region_code, '&') = nvl(rc.region_code, '&')
           and nvl(customer_type, '&') = nvl(rc.customer_type, '&')
           and nvl(network_id, -99) = nvl(rc.network_id, -99)
           and nvl(card_type, '&') = nvl(rc.card_feature, '&') ;
    end loop;

    trc_log_pkg.debug ( i_text => 'rus_prc_form_250_pkg.process_form_250_1 (9, 10, 11, 12, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28)' );

    update rus_form_250_1_report r
       set oper_amount_debit = 
               case when oper_amount_debit > 0
                    then (domestic_cash_amount + foreign_cash_amout + domestic_purch_amount + foreign_purch_amount + customs_amount + other_amount) - oper_amount_credit
                    else oper_amount_debit
               end
         , oper_amount_credit =
               case when oper_amount_credit > 0 and oper_amount_debit = 0
                    then (domestic_cash_amount + foreign_cash_amout + domestic_purch_amount + foreign_purch_amount + customs_amount + other_amount) - oper_amount_debit
                    else oper_amount_credit
               end
     where oper_amount_debit + oper_amount_credit > 0
       and (oper_amount_debit + oper_amount_credit) != (domestic_cash_amount + foreign_cash_amout + domestic_purch_amount + foreign_purch_amount + customs_amount + other_amount);

    trc_log_pkg.debug ( i_text => 'rus_prc_form_250_pkg.process_form_250_1 - ok' );

exception 
    when others 
    then raise_application_error (-20001, sqlerrm);
end;

end;
/
