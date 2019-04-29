create or replace package body cst_nbrt_report_pkg as

procedure monthly_report(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_inst_id       default null
  , i_start_date        in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
) is
    l_start_date        date;
    l_end_date          date;
    l_lang              com_api_type_pkg.t_dict_value;
    l_del_value         com_api_type_pkg.t_tiny_id;
    l_from_id           com_api_type_pkg.t_long_id;
    l_till_id           com_api_type_pkg.t_long_id;

    l_header            xmltype;
    l_detail            xmltype;
    l_result            xmltype;

begin
    l_lang       := nvl(i_lang, get_user_lang);
    l_start_date := trunc(coalesce(i_start_date, com_api_sttl_day_pkg.get_sysdate), 'mm');
    l_end_date   := add_months(l_start_date, 1) - com_api_const_pkg.ONE_SECOND;
    l_from_id    := com_api_id_pkg.get_from_id(l_start_date);
    l_till_id    := com_api_id_pkg.get_till_id(l_end_date);

    trc_log_pkg.debug (
        i_text        => 'cst_nbrt_report_pkg.monthly_report [#1][#2][#3][#4]'
      , i_env_param1  => i_lang
      , i_env_param2  => i_inst_id
      , i_env_param3  => to_char(l_start_date, 'dd.mm.yyyy hh24:mi:ss')
      , i_env_param4  => to_char(l_end_date, 'dd.mm.yyyy hh24:mi:ss')
    );
    
    l_del_value := power(10, com_api_currency_pkg.get_currency_exponent(i_curr_code => cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE));

    -- header
    select xmlelement(
               "header"
             , xmlelement("start_date", to_char(l_start_date, 'dd.mm.yyyy'))
             , xmlelement("end_date", to_char(l_end_date, 'dd.mm.yyyy'))
             , xmlelement("inst_name", decode(i_inst_id, null, 'All', get_text('OST_INSTITUTION','NAME', i_inst_id, l_lang)))
           )
      into l_header
      from dual;

     select xmlelement(
               "details"
             , xmlagg(
                   xmlelement(
                       "detail"
                     , xmlelement("network"
                                 , com_api_i18n_pkg.get_text(
                                       i_table_name   => 'net_network'
                                     , i_column_name  => 'name'
                                     , i_object_id    => o.card_network_id
                                     , i_lang         => l_lang
                                   )
                       )
                     , xmlelement("sttl_lvl", sttl_lvl)
                     , xmlelement("cash_count_national", cash_count_national)
                     , xmlelement("cash_amount_national", cash_amount_national)
                     , xmlelement("cash_count_foreign", cash_count_foreign)
                     , xmlelement("cash_amount_foreign", cash_amount_foreign)
                     , xmlelement("purchase_count_national", purchase_count_national)
                     , xmlelement("purchase_amount_national", purchase_amount_national)
                     , xmlelement("purchase_count_foreign", purchase_count_foreign)
                     , xmlelement("purchase_amount_foreign", purchase_amount_foreign)
                   )
               )
            )
       into l_detail
       from (
            select x.card_network_id
                 , x.sttl_lvl
                 , sum(x.cash_count_national * x.oper_sign) as cash_count_national
                 , round(sum(x.cash_amount_national / l_del_value * x.oper_sign)) as cash_amount_national
                 , sum(x.cash_count_foreign * x.oper_sign) as cash_count_foreign
                 , round(sum(x.cash_amount_foreign / l_del_value * x.oper_sign)) as cash_amount_foreign
                 , sum(x.purchase_count_national * x.oper_sign) as purchase_count_national
                 , round(sum(x.purchase_amount_national / l_del_value * x.oper_sign)) as purchase_amount_national
                 , sum(x.purchase_count_foreign * x.oper_sign) as purchase_count_foreign
                 , round(sum(x.purchase_amount_foreign / l_del_value * x.oper_sign)) as purchase_amount_foreign
              from (
                    select o.card_network_id
                         , case
                               when o.sttl_type = 'on-US' and o.card_country = cst_nbrt_api_const_pkg.TAJIKISTAN_COUNTRY_CODE and o.card_id is not null
                               then 1
                               when o.sttl_type = 'on-THEM' and o.merchant_country = cst_nbrt_api_const_pkg.TAJIKISTAN_COUNTRY_CODE and o.card_id is not null
                               then 2
                               when o.sttl_type = 'on-THEM' and o.merchant_country != cst_nbrt_api_const_pkg.TAJIKISTAN_COUNTRY_CODE and o.card_id is not null
                               then 3
                               when o.sttl_type = 'on-US' and o.card_country = cst_nbrt_api_const_pkg.TAJIKISTAN_COUNTRY_CODE
                               then 4
                               when o.sttl_type = 'on-US' and o.card_country != cst_nbrt_api_const_pkg.TAJIKISTAN_COUNTRY_CODE
                               then 5
                               else 99
                           end as sttl_lvl
                         , case
                               when o.oper_currency = cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'CASH'
                               then 1
                               else 0
                           end as cash_count_national
                         , case
                               when o.oper_currency = cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'CASH'
                               then o.oper_amount
                               else 0
                           end as cash_amount_national
                         , case
                               when o.oper_currency != cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'CASH'
                               then 1
                               else 0
                           end as cash_count_foreign
                         , case
                               when o.oper_currency != cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'CASH'
                               then com_api_rate_pkg.convert_amount(
                                        i_src_amount      => o.sttl_amount
                                      , i_src_currency    => o.sttl_currency
                                      , i_dst_currency    => cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE
                                      , i_rate_type       => cst_nbrt_api_const_pkg.NBRT_RATE_TYPE
                                      , i_inst_id         => i_inst_id
                                      , i_eff_date        => l_end_date
                                      , i_mask_exception  => 1
                                      , i_exception_value => null
                                   )
                               else 0
                           end as cash_amount_foreign
                         , case
                               when o.oper_currency = cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'PURCHASE'
                               then 1
                               else 0
                           end as purchase_count_national
                         , case
                               when o.oper_currency = cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'PURCHASE'
                               then o.oper_amount
                               else 0
                           end as purchase_amount_national
                         , case
                               when o.oper_currency != cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'PURCHASE'
                               then 1
                               else 0
                           end as purchase_count_foreign
                         , case
                               when o.oper_currency != cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'PURCHASE'
                               then com_api_rate_pkg.convert_amount(
                                        i_src_amount      => o.sttl_amount
                                      , i_src_currency    => o.sttl_currency
                                      , i_dst_currency    => cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE
                                      , i_rate_type       => cst_nbrt_api_const_pkg.NBRT_RATE_TYPE
                                      , i_inst_id         => i_inst_id
                                      , i_eff_date        => l_end_date
                                      , i_mask_exception  => 1
                                      , i_exception_value => null
                                   )
                               else 0
                           end as purchase_amount_foreign
                         , o.oper_sign
                      from (
                            select pi.card_network_id
                                 , case
                                       when com_api_array_pkg.is_element_in_array(
                                                i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_ON_US
                                              , i_elem_value   => o.sttl_type
                                            ) = 1
                                       then 'on-US'
                                       when com_api_array_pkg.is_element_in_array(
                                                i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_ON_THEM
                                              , i_elem_value   => o.sttl_type
                                            ) = 1
                                       then 'on-THEM'
                                       else 'Unknown'
                                   end as sttl_type
                                 , o.oper_amount
                                 , o.oper_currency
                                 , case 
                                       when coalesce(o.sttl_currency, '0') = '0'
                                       then o.oper_amount
                                       else coalesce(o.sttl_amount, o.oper_amount)
                                   end as sttl_amount
                                 , case
                                       when coalesce(o.sttl_currency, '0') = '0'
                                       then o.oper_currency
                                       else coalesce(o.sttl_currency, o.oper_currency)
                                   end as sttl_currency
                                 , o.merchant_country
                                 , pi.card_country
                                 , case
                                       when (o.oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND and o.is_reversal = 0
                                             or o.oper_type != opr_api_const_pkg.OPERATION_TYPE_REFUND and o.is_reversal = 1)
                                       then -1
                                       else 1
                                   end as oper_sign
                                 , case 
                                       when com_api_array_pkg.is_element_in_array(
                                                i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_PURCHASE
                                              , i_elem_value   => o.oper_type
                                            ) = 1
                                       then 'PURCHASE'
                                       when com_api_array_pkg.is_element_in_array(
                                                i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_CASH
                                              , i_elem_value   => o.oper_type
                                            ) = 1
                                       then 'CASH'
                                       else 'Unknown'
                                   end as oper_type
                                 , o.id
                                 , pi.card_id
                              from opr_operation o
                                 , opr_participant pi
                                 , opr_participant pa
                                 , opr_card c
                             where o.id between l_from_id and l_till_id
                               and trunc(o.oper_date) between l_start_date and l_end_date
                               and o.id = pi.oper_id
                               and o.msg_type in (
                                       opr_api_const_pkg.MESSAGE_TYPE_COMPLETION
                                     , opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                                     , opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                                   )
                               and pi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                               and pi.oper_id = c.oper_id
                               and pi.participant_type = c.participant_type
                               and o.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                               and o.oper_amount > 0
                               and pa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                               and pa.oper_id = o.id
                               and (pi.inst_id = i_inst_id or pa.inst_id = i_inst_id)
                               and com_api_array_pkg.is_element_in_array(
                                       i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_NETWORK
                                     , i_elem_value   => to_char(pi.card_network_id, com_api_const_pkg.NUMBER_FORMAT)
                                   ) = 1
                               and (com_api_array_pkg.is_element_in_array(
                                        i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_PURCHASE
                                      , i_elem_value   => o.oper_type
                                    ) = 1
                                    or
                                    com_api_array_pkg.is_element_in_array(
                                        i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_CASH
                                      , i_elem_value   => o.oper_type
                                    ) = 1
                                   )
                           ) o
                   ) x
             group by x.card_network_id
                    , x.sttl_lvl
             order by 2, 1
            ) o;

    --if no data
    if l_detail.getclobval() = '<details></details>' then
        select xmlelement(
                   "details"
                 , xmlagg(
                       xmlelement(
                           "detail"
                         , xmlelement("network", null)
                         , xmlelement("sttl_lvl", null)
                         , xmlelement("cash_count_national", null)
                         , xmlelement("cash_amount_national", null)
                         , xmlelement("cash_count_foreign", null)
                         , xmlelement("cash_amount_foreign", null)
                         , xmlelement("purchase_count_national", null)
                         , xmlelement("purchase_amount_national", null)
                         , xmlelement("purchase_count_foreign", null)
                         , xmlelement("purchase_amount_foreign", null)
                       )
                   )
               )
        into l_detail
        from dual;
    end if;

    select xmlelement(
               "report"
             , l_header
             , l_detail
           )
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text => 'cst_nbrt_report_pkg.monthly_report - ok'
    );

exception when others then
    trc_log_pkg.debug(i_text => sqlerrm);
    raise ;
end monthly_report;

procedure detailed_report(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_inst_id       default null
  , i_start_date        in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
) is
    l_start_date        date;
    l_end_date          date;
    l_lang              com_api_type_pkg.t_dict_value;
    l_del_value         com_api_type_pkg.t_tiny_id;
    l_from_id           com_api_type_pkg.t_long_id;
    l_till_id           com_api_type_pkg.t_long_id;

    l_header            xmltype;
    l_detail_us_on_them xmltype;
    l_detail_them_on_us xmltype;
    l_result            xmltype;

begin
    l_lang       := nvl(i_lang, get_user_lang);
    l_start_date := trunc(coalesce(i_start_date, com_api_sttl_day_pkg.get_sysdate), 'mm');
    l_end_date   := add_months(l_start_date, 1) - com_api_const_pkg.ONE_SECOND;
    l_from_id    := com_api_id_pkg.get_from_id(l_start_date);
    l_till_id    := com_api_id_pkg.get_till_id(l_end_date);

    trc_log_pkg.debug (
        i_text        => 'cst_nbrt_report_pkg.detailed_report [#1][#2][#3][#4]'
      , i_env_param1  => i_lang
      , i_env_param2  => i_inst_id
      , i_env_param3  => to_char(l_start_date, 'dd.mm.yyyy hh24:mi:ss')
      , i_env_param4  => to_char(l_end_date, 'dd.mm.yyyy hh24:mi:ss')
    );
    
    l_del_value := power(10, com_api_currency_pkg.get_currency_exponent(i_curr_code => cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE));

    -- header
    select xmlelement(
               "header"
             , xmlelement("start_date", to_char(l_start_date, 'dd.mm.yyyy'))
             , xmlelement("end_date", to_char(l_end_date, 'dd.mm.yyyy'))
             , xmlelement("main_inst_name", decode(i_inst_id, null, 'All', get_text('OST_INSTITUTION','NAME', i_inst_id, l_lang)))
           )
      into l_header
      from dual;

    select xmlagg(xmlelement(
                     "detail"
                     , xmlelement("network"
                                 , com_api_i18n_pkg.get_text(
                                       i_table_name   => 'net_network'
                                     , i_column_name  => 'name'
                                     , i_object_id    => card_network_id
                                     , i_lang         => l_lang
                                   )
                       )
                     , xmlelement("inst_name", inst_name)
                     , xmlelement("sttl_lvl", sttl_lvl)
                     , xmlelement("cash_count_national", cash_count_national)
                     , xmlelement("cash_amount_national", cash_amount_national)
                     , xmlelement("cash_count_foreign", cash_count_foreign)
                     , xmlelement("cash_amount_foreign", cash_amount_foreign)
                     , xmlelement("purchase_count_national", purchase_count_national)
                     , xmlelement("purchase_amount_national", purchase_amount_national)
                     , xmlelement("purchase_count_foreign", purchase_count_foreign)
                     , xmlelement("purchase_amount_foreign", purchase_amount_foreign)
                   )
           )
      into l_detail_us_on_them
      from (
             with insts as (
                            select distinct
                                   com_api_i18n_pkg.get_text(
                                        i_table_name   => 'cst_nbrt_bin_range'
                                      , i_column_name  => 'label'
                                      , i_object_id    => r.id
                                      , i_lang         => l_lang
                                   ) as inst_name
                                 , n.id as network_id
                              from cst_nbrt_bin_range r
                                 , net_network n
                             where com_api_array_pkg.is_element_in_array(
                                       i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_NETWORK
                                     , i_elem_value   => to_char(n.id, com_api_const_pkg.NUMBER_FORMAT)
                                   ) = 1
                           )
             select insts.inst_name
                  , insts.network_id as card_network_id
                  , 2 as sttl_lvl
                  , nvl(sum(x.cash_count_national * x.oper_sign), 0) as cash_count_national
                  , nvl(round(sum(x.cash_amount_national / l_del_value * x.oper_sign)), 0) as cash_amount_national
                  , nvl(sum(x.cash_count_foreign * x.oper_sign), 0) as cash_count_foreign
                  , nvl(round(sum(x.cash_amount_foreign / l_del_value * x.oper_sign)), 0) as cash_amount_foreign
                  , nvl(sum(x.purchase_count_national * x.oper_sign), 0) as purchase_count_national
                  , nvl(round(sum(x.purchase_amount_national / l_del_value * x.oper_sign)), 0) as purchase_amount_national
                  , nvl(sum(x.purchase_count_foreign * x.oper_sign), 0) as purchase_count_foreign
                  , nvl(round(sum(x.purchase_amount_foreign / l_del_value * x.oper_sign)), 0) as purchase_amount_foreign
               from (
                     select o.card_network_id
                          , case
                                when o.oper_currency = cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'CASH'
                                then 1
                                else 0
                            end as cash_count_national
                          , case
                                when o.oper_currency = cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'CASH'
                                then o.oper_amount
                                else 0
                            end as cash_amount_national
                          , case
                                when o.oper_currency != cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'CASH'
                                then 1
                                else 0
                            end as cash_count_foreign
                          , case
                                when o.oper_currency != cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'CASH'
                                then com_api_rate_pkg.convert_amount(
                                         i_src_amount      => o.sttl_amount
                                       , i_src_currency    => o.sttl_currency
                                       , i_dst_currency    => cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE
                                       , i_rate_type       => cst_nbrt_api_const_pkg.NBRT_RATE_TYPE
                                       , i_inst_id         => i_inst_id
                                       , i_eff_date        => l_end_date
                                       , i_mask_exception  => 1
                                       , i_exception_value => null
                                    )
                                else 0
                            end as cash_amount_foreign
                          , case
                                when o.oper_currency = cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'PURCHASE'
                                then 1
                                else 0
                            end as purchase_count_national
                          , case
                                when o.oper_currency = cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'PURCHASE'
                                then o.oper_amount
                                else 0
                            end as purchase_amount_national
                          , case
                                when o.oper_currency != cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'PURCHASE'
                                then 1
                                else 0
                            end as purchase_count_foreign
                          , case
                                when o.oper_currency != cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'PURCHASE'
                                then com_api_rate_pkg.convert_amount(
                                         i_src_amount      => o.sttl_amount
                                       , i_src_currency    => o.sttl_currency
                                       , i_dst_currency    => cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE
                                       , i_rate_type       => cst_nbrt_api_const_pkg.NBRT_RATE_TYPE
                                       , i_inst_id         => i_inst_id
                                       , i_eff_date        => l_end_date
                                       , i_mask_exception  => 1
                                       , i_exception_value => null
                                    )
                                else 0
                            end as purchase_amount_foreign
                          , o.oper_sign
                          , o.inst_name
                       from (
                             select pi.card_network_id
                                  , r.inst_name
                                  , o.oper_amount
                                  , o.oper_currency
                                  , case 
                                        when coalesce(o.sttl_currency, '0') = '0'
                                        then o.oper_amount
                                        else coalesce(o.sttl_amount, o.oper_amount)
                                    end as sttl_amount
                                  , case
                                        when coalesce(o.sttl_currency, '0') = '0'
                                        then o.oper_currency
                                        else coalesce(o.sttl_currency, o.oper_currency)
                                    end as sttl_currency
                                  , o.merchant_country
                                  , pi.card_country
                                  , case
                                        when (o.oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND and o.is_reversal = 0
                                              or o.oper_type != opr_api_const_pkg.OPERATION_TYPE_REFUND and o.is_reversal = 1)
                                        then -1
                                        else 1
                                    end as oper_sign
                                  , case 
                                        when com_api_array_pkg.is_element_in_array(
                                                 i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_PURCHASE
                                               , i_elem_value   => o.oper_type
                                             ) = 1
                                        then 'PURCHASE'
                                        when com_api_array_pkg.is_element_in_array(
                                                 i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_CASH
                                               , i_elem_value   => o.oper_type
                                             ) = 1
                                        then 'CASH'
                                        else 'Unknown'
                                    end as oper_type
                                  , o.id
                                  , pi.card_id
                                  , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
                                  , o.acq_inst_bin
                               from opr_operation o
                                  , opr_participant pi
                                  , opr_participant pa
                                  , opr_card c
                                  , (select pan_low
                                          , pan_high
                                          , pan_length
                                          , com_api_i18n_pkg.get_text(
                                                i_table_name   => 'cst_nbrt_bin_range'
                                              , i_column_name  => 'label'
                                              , i_object_id    => r.id
                                              , i_lang         => l_lang
                                            ) as inst_name
                                       from cst_nbrt_bin_range r) r
                              where o.id between l_from_id and l_till_id
                                and trunc(o.oper_date) between l_start_date and l_end_date
                                and o.id = pi.oper_id
                                and o.msg_type in (
                                        opr_api_const_pkg.MESSAGE_TYPE_COMPLETION
                                      , opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                                      , opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                                    )
                                and pi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                                and pi.oper_id = c.oper_id
                                and pi.participant_type = c.participant_type
                                and o.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                and o.oper_amount > 0
                                and pa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                                and pa.oper_id = o.id
                                and (pi.inst_id = i_inst_id or pa.inst_id = i_inst_id)
                                and com_api_array_pkg.is_element_in_array(
                                        i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_ON_THEM
                                      , i_elem_value   => o.sttl_type
                                    ) = 1
                                and pi.card_country = cst_nbrt_api_const_pkg.TAJIKISTAN_COUNTRY_CODE
                                and pi.card_id is not null
                                and rpad(o.acq_inst_bin, r.pan_length, '0') between r.pan_low and r.pan_high
                                and com_api_array_pkg.is_element_in_array(
                                        i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_NETWORK
                                      , i_elem_value   => to_char(pi.card_network_id, com_api_const_pkg.NUMBER_FORMAT)
                                    ) = 1
                                and (com_api_array_pkg.is_element_in_array(
                                         i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_PURCHASE
                                       , i_elem_value   => o.oper_type
                                     ) = 1
                                     or
                                     com_api_array_pkg.is_element_in_array(
                                         i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_CASH
                                       , i_elem_value   => o.oper_type
                                     ) = 1
                                    )
                            ) o
                    ) x
                  , insts
              where insts.inst_name = x.inst_name(+)
                and insts.network_id = x.card_network_id(+)
           group by insts.inst_name
                  , insts.network_id
           order by network_id, inst_name
           );

    select xmlagg(xmlelement(
                     "detail"
                     , xmlelement("network"
                                 , com_api_i18n_pkg.get_text(
                                       i_table_name   => 'net_network'
                                     , i_column_name  => 'name'
                                     , i_object_id    => card_network_id
                                     , i_lang         => l_lang
                                   )
                       )
                     , xmlelement("inst_name", inst_name)
                     , xmlelement("sttl_lvl", sttl_lvl)
                     , xmlelement("cash_count_national", cash_count_national)
                     , xmlelement("cash_amount_national", cash_amount_national)
                     , xmlelement("cash_count_foreign", cash_count_foreign)
                     , xmlelement("cash_amount_foreign", cash_amount_foreign)
                     , xmlelement("purchase_count_national", purchase_count_national)
                     , xmlelement("purchase_amount_national", purchase_amount_national)
                     , xmlelement("purchase_count_foreign", purchase_count_foreign)
                     , xmlelement("purchase_amount_foreign", purchase_amount_foreign)
                   )
           )
      into l_detail_them_on_us
      from (
             with insts as (
                            select distinct
                                   com_api_i18n_pkg.get_text(
                                        i_table_name   => 'cst_nbrt_bin_range'
                                      , i_column_name  => 'label'
                                      , i_object_id    => r.id
                                      , i_lang         => l_lang
                                   ) as inst_name
                                 , n.id as network_id
                              from cst_nbrt_bin_range r
                                 , net_network n
                             where com_api_array_pkg.is_element_in_array(
                                       i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_NETWORK
                                     , i_elem_value   => to_char(n.id, com_api_const_pkg.NUMBER_FORMAT)
                                   ) = 1
                           )
             select insts.inst_name
                  , insts.network_id as card_network_id
                  , 4 as sttl_lvl
                  , nvl(sum(x.cash_count_national * x.oper_sign), 0) as cash_count_national
                  , nvl(round(sum(x.cash_amount_national / l_del_value * x.oper_sign)), 0) as cash_amount_national
                  , nvl(sum(x.cash_count_foreign * x.oper_sign), 0) as cash_count_foreign
                  , nvl(round(sum(x.cash_amount_foreign / l_del_value * x.oper_sign)), 0) as cash_amount_foreign
                  , nvl(sum(x.purchase_count_national * x.oper_sign), 0) as purchase_count_national
                  , nvl(round(sum(x.purchase_amount_national / l_del_value * x.oper_sign)), 0) as purchase_amount_national
                  , nvl(sum(x.purchase_count_foreign * x.oper_sign), 0) as purchase_count_foreign
                  , nvl(round(sum(x.purchase_amount_foreign / l_del_value * x.oper_sign)), 0) as purchase_amount_foreign
               from (
                     select o.card_network_id
                          , case
                                when o.oper_currency = cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'CASH'
                                then 1
                                else 0
                            end as cash_count_national
                          , case
                                when o.oper_currency = cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'CASH'
                                then o.oper_amount
                                else 0
                            end as cash_amount_national
                          , case
                                when o.oper_currency != cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'CASH'
                                then 1
                                else 0
                            end as cash_count_foreign
                          , case
                                when o.oper_currency != cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'CASH'
                                then com_api_rate_pkg.convert_amount(
                                         i_src_amount      => o.sttl_amount
                                       , i_src_currency    => o.sttl_currency
                                       , i_dst_currency    => cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE
                                       , i_rate_type       => cst_nbrt_api_const_pkg.NBRT_RATE_TYPE
                                       , i_inst_id         => i_inst_id
                                       , i_eff_date        => l_end_date
                                       , i_mask_exception  => 1
                                       , i_exception_value => null
                                    )
                                else 0
                            end as cash_amount_foreign
                          , case
                                when o.oper_currency = cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'PURCHASE'
                                then 1
                                else 0
                            end as purchase_count_national
                          , case
                                when o.oper_currency = cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'PURCHASE'
                                then o.oper_amount
                                else 0
                            end as purchase_amount_national
                          , case
                                when o.oper_currency != cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'PURCHASE'
                                then 1
                                else 0
                            end as purchase_count_foreign
                          , case
                                when o.oper_currency != cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE and o.oper_type = 'PURCHASE'
                                then com_api_rate_pkg.convert_amount(
                                         i_src_amount      => o.sttl_amount
                                       , i_src_currency    => o.sttl_currency
                                       , i_dst_currency    => cst_nbrt_api_const_pkg.TAJIKISTAN_CURRENCY_CODE
                                       , i_rate_type       => cst_nbrt_api_const_pkg.NBRT_RATE_TYPE
                                       , i_inst_id         => i_inst_id
                                       , i_eff_date        => l_end_date
                                       , i_mask_exception  => 1
                                       , i_exception_value => null
                                    )
                                else 0
                            end as purchase_amount_foreign
                          , o.oper_sign
                          , o.inst_name
                       from (
                             select pi.card_network_id
                                  , r.inst_name
                                  , o.oper_amount
                                  , o.oper_currency
                                  , case 
                                        when coalesce(o.sttl_currency, '0') = '0'
                                        then o.oper_amount
                                        else coalesce(o.sttl_amount, o.oper_amount)
                                    end as sttl_amount
                                  , case
                                        when coalesce(o.sttl_currency, '0') = '0'
                                        then o.oper_currency
                                        else coalesce(o.sttl_currency, o.oper_currency)
                                    end as sttl_currency
                                  , o.merchant_country
                                  , pi.card_country
                                  , case
                                        when (o.oper_type = opr_api_const_pkg.OPERATION_TYPE_REFUND and o.is_reversal = 0
                                              or o.oper_type != opr_api_const_pkg.OPERATION_TYPE_REFUND and o.is_reversal = 1)
                                        then -1
                                        else 1
                                    end as oper_sign
                                  , case 
                                        when com_api_array_pkg.is_element_in_array(
                                                 i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_PURCHASE
                                               , i_elem_value   => o.oper_type
                                             ) = 1
                                        then 'PURCHASE'
                                        when com_api_array_pkg.is_element_in_array(
                                                 i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_CASH
                                               , i_elem_value   => o.oper_type
                                             ) = 1
                                        then 'CASH'
                                        else 'Unknown'
                                    end as oper_type
                                  , o.id
                                  , pi.card_id
                                  , iss_api_token_pkg.decode_card_number(i_card_number => c.card_number) as card_number
                                  , o.acq_inst_bin
                               from opr_operation o
                                  , opr_participant pi
                                  , opr_participant pa
                                  , opr_card c
                                  , (select pan_low
                                          , pan_high
                                          , pan_length
                                          , com_api_i18n_pkg.get_text(
                                                i_table_name   => 'cst_nbrt_bin_range'
                                              , i_column_name  => 'label'
                                              , i_object_id    => r.id
                                              , i_lang         => l_lang
                                            ) as inst_name
                                       from cst_nbrt_bin_range r) r
                              where o.id between l_from_id and l_till_id
                                and trunc(o.oper_date) between l_start_date and l_end_date
                                and o.id = pi.oper_id
                                and o.msg_type in (
                                        opr_api_const_pkg.MESSAGE_TYPE_COMPLETION
                                      , opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                                      , opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
                                    )
                                and pi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                                and pi.oper_id = c.oper_id
                                and pi.participant_type = c.participant_type
                                and o.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED
                                and o.oper_amount > 0
                                and pa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                                and pa.oper_id = o.id
                                and (pi.inst_id = i_inst_id or pa.inst_id = i_inst_id)
                                and com_api_array_pkg.is_element_in_array(
                                        i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_ON_US
                                      , i_elem_value   => o.sttl_type
                                    ) = 1
                                and pi.card_country = cst_nbrt_api_const_pkg.TAJIKISTAN_COUNTRY_CODE
                                and pi.card_id is not null
                                and rpad(substr(iss_api_token_pkg.decode_card_number(i_card_number => c.card_number), 1 , r.pan_length)
                                       , r.pan_length, '0') between r.pan_low and r.pan_high
                                and com_api_array_pkg.is_element_in_array(
                                        i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_NETWORK
                                      , i_elem_value   => to_char(pi.card_network_id, com_api_const_pkg.NUMBER_FORMAT)
                                    ) = 1
                                and (com_api_array_pkg.is_element_in_array(
                                         i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_PURCHASE
                                       , i_elem_value   => o.oper_type
                                     ) = 1
                                     or
                                     com_api_array_pkg.is_element_in_array(
                                         i_array_id     => cst_nbrt_api_const_pkg.ARRAY_ID_CASH
                                       , i_elem_value   => o.oper_type
                                     ) = 1
                                    )
                            ) o
                    ) x
                  , insts
              where insts.inst_name = x.inst_name(+)
                and insts.network_id = x.card_network_id(+)
           group by insts.inst_name
                  , insts.network_id
           order by network_id, inst_name
           );

    select xmlelement(
               "report"
             , l_header
             , l_detail_us_on_them
             , l_detail_them_on_us
           )
    into l_result
    from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(
        i_text => 'cst_nbrt_report_pkg.detailed_report - ok'
    );

exception when others then
    trc_log_pkg.debug(i_text => sqlerrm);
    raise ;
end detailed_report;

end;
/