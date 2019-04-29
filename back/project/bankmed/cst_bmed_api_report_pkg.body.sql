create or replace package body cst_bmed_api_report_pkg as
/*********************************************************
*  BankMed custom reports <br />
*  Created by Alalykin A. (alalykin@bpcbt.com) at 31.01.2017 <br />
*  Module: cst_bmed_api_report_pkg <br />
*  @headcom
**********************************************************/

DATE_FORMAT_DAY         constant com_api_type_pkg.t_oracle_name := 'dd/mm/yyyy';
DATETIME_FORMAT         constant com_api_type_pkg.t_oracle_name := 'dd.mm.yyyy hh24:mi:ss';

/*
 * Procedure returns an array of dispute application flows that are associated with PRTYISS/APTPISSA
 * or PRTYACQ/APTPACQA in according to the LOV app_api_const_pkg.LOV_ID_DISPUTE_FLOWS.
 */
procedure get_list_of_flow_id(
    i_participant_type  in     com_api_type_pkg.t_dict_value
  , o_flow_id_tab          out num_tab_tpt
) is
    l_flow_id_tab              com_api_type_pkg.t_name_tab;
    l_lov_param_tab            com_param_map_tpt := com_param_map_tpt();
begin
    l_lov_param_tab.extend(1);
    l_lov_param_tab(1) := com_param_map_tpr('APPL_SUBTYPE', i_participant_type, null, null, null);
    com_ui_lov_pkg.get_lov_codes(
        o_code_tab   => l_flow_id_tab
      , i_lov_id     => app_api_const_pkg.LOV_ID_DISPUTE_FLOWS
      , i_param_map  => l_lov_param_tab
    );

    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.get_list_of_flow_id: '
                     || 'l_flow_id_tab.count() = ' || l_flow_id_tab.count()
    );

    o_flow_id_tab := num_tab_tpt();

    for i in 1 .. l_flow_id_tab.count() loop
        o_flow_id_tab.extend(1);
        o_flow_id_tab(o_flow_id_tab.count()) := to_number(l_flow_id_tab(i));
    end loop;
end;

/*
 * The report displays chargeback cases/applications for specified participant type,
 * report period, IPS, and case status (application status).
 * @i_participant_type - PRTYISS/PRTYACQ, this value is used for get a list of application
 *                       application flows that are associated with APTPISSA or APTPACQA
 * @i_ips              - value from dictionary RIPS, null value is considered as any IPS
 * @i_status           - case/application status, null value is considered as any possible status
 */
procedure chargeback_dispute_cases(
    o_xml                  out clob
  , i_participant_type  in     com_api_type_pkg.t_dict_value
  , i_start_date        in     date
  , i_end_date          in     date
  , i_ips               in     com_api_type_pkg.t_dict_value
  , i_status            in     com_api_type_pkg.t_dict_value
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.chargeback_dispute_cases ';
    DATE_LAG          constant pls_integer := 30; -- for calculation limits for OPR_OPERATION.ID by input dates
    l_start_date               date;
    l_end_date                 date;
    l_from_id                  com_api_type_pkg.t_long_id;
    l_till_id                  com_api_type_pkg.t_long_id;
    l_lang                     com_api_type_pkg.t_dict_value;
    l_flow_id_tab              num_tab_tpt;
    l_table                    xmltype;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_start_date [#1], i_end_date [#2]'
                                   ||  ', i_participant_type [#3], i_ips [#4], i_status [#5]'
      , i_env_param1 => com_api_type_pkg.convert_to_char(i_start_date)
      , i_env_param2 => com_api_type_pkg.convert_to_char(i_end_date)
      , i_env_param3 => i_participant_type
      , i_env_param4 => i_ips
      , i_env_param5 => i_status
    );

    l_lang       := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());
    -- Report generating is only allowed for a past period
    l_start_date := trunc(least(i_start_date, com_api_sttl_day_pkg.get_sysdate() - 1));
    l_end_date   := trunc(least(i_end_date,   com_api_sttl_day_pkg.get_sysdate() - 1))
                  + 1 - com_api_const_pkg.ONE_SECOND;

    l_from_id    := com_api_id_pkg.get_from_id(i_date => l_start_date - DATE_LAG);
    l_till_id    := com_api_id_pkg.get_from_id(i_date => l_end_date   + DATE_LAG);

    -- Get a list of application flows that are associated with specified participant type
    get_list_of_flow_id(
        i_participant_type  => case i_participant_type
                                   when com_api_const_pkg.PARTICIPANT_ISSUER then
                                       app_api_const_pkg.APPL_TYPE_ISSUING
                                   when com_api_const_pkg.PARTICIPANT_ACQUIRER then
                                       app_api_const_pkg.APPL_TYPE_ACQUIRING
                               end
      , o_flow_id_tab       => l_flow_id_tab
    );
    trc_log_pkg.debug(
        i_text       => 'l_flow_id_tab.count() = #1, l_flow_id_tab(1) = #2'
      , i_env_param1 => l_flow_id_tab.count()
      , i_env_param2 => case when l_flow_id_tab.count() > 0 then l_flow_id_tab(1) end
    );

    select xmlagg(xmlelement("record"
             , xmlelement("ips",            opr.ips)
             , xmlelement("status",         lower(
                                                com_api_dictionary_pkg.get_article_text(
                                                    i_article  => app.appl_status
                                                  , i_lang     => l_lang
                                                )
                                            ))
             , xmlelement("dispute_type"
                 , case
                       when opr.sttl_type in (
                                opr_api_const_pkg.SETTLEMENT_INTERNAL
                              , opr_api_const_pkg.SETTLEMENT_INTERNAL_INTERINST
                              , opr_api_const_pkg.SETTLEMENT_INTERNAL_INTRAINST
                              , opr_api_const_pkg.SETTLEMENT_USONUS
                              , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST
                              , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST
                            )                                                              then 'internal'
                       when nvl(opr.merchant_country, '1') = nvl(opr.card_country, '2')    then 'domestic'
                                                                                           else 'international'
                   end
               )
             , xmlelement("case_id",        cc.id)
             , xmlelement("card_number",    iss_api_card_pkg.get_card_mask(i_card_number => opr.card_number))
             , xmlelement("creation_date",  (select to_char(min(change_date), DATE_FORMAT_DAY)
                                               from app_history h
                                              where h.appl_id = app.id
                                            ))
             , xmlelement("oper_amount",    com_api_currency_pkg.get_amount_str(
                                                i_amount         => opr.oper_amount
                                              , i_curr_code      => opr.oper_currency
                                              , i_mask_curr_code => com_api_const_pkg.FALSE
                                              , i_mask_error     => com_api_const_pkg.TRUE
                                            ))
             , xmlelement("sttl_amount",    com_api_currency_pkg.get_amount_str(
                                                i_amount         => opr.sttl_amount
                                              , i_curr_code      => opr.sttl_currency
                                              , i_mask_curr_code => com_api_const_pkg.FALSE
                                              , i_mask_error     => com_api_const_pkg.TRUE
                                            ))
             , xmlelement("merchant_name",  coalesce(
                                                opr.merchant_name
                                              , acq_api_merchant_pkg.get_merchant_name(
                                                    i_merchant_id  => opr.merchant_id
                                                  , i_mask_error   => com_api_const_pkg.TRUE
                                                )
                                            ))
             , xmlelement("mcc",            opr.mcc)
             , xmlelement("reason_code",    opr.reason_code)
           ))
      into l_table
      from (
          select case
                     when vsf.id is not null then 'Visa'
                     when mcf.id is not null then 'MasterCard'
                 end                             as ips
               , opr.id                          as oper_id
               , opr.dispute_id
               , opr.sttl_type                   as sttl_type
               , opr.merchant_country            as merchant_country
               , opr.oper_amount                 as oper_amount
               , opr.oper_currency               as oper_currency
               , opr.sttl_amount                 as sttl_amount
               , opr.sttl_currency               as sttl_currency
               , opr.mcc                         as mcc
               , crd.card_number                 as card_number
               , iss.card_country                as card_country
               , opr.merchant_name               as merchant_name
               , acq.merchant_id                 as merchant_id
               , nvl(mcf.de025, vsf.reason_code) as reason_code
            from      opr_operation   opr
                 join opr_card        crd    on crd.oper_id          = opr.id
            left join opr_participant iss    on iss.oper_id          = opr.id
                                            and iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
            left join opr_participant acq    on acq.oper_id          = opr.id
                                            and acq.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
            left join mcw_fin         mcf    on mcf.id               = opr.id
            left join vis_fin_message vsf    on vsf.id               = opr.id
           where opr.id                 between l_from_id    and l_till_id
             and trunc(opr.oper_date)   between l_start_date and l_end_date
             and opr.dispute_id  is not null
             and (i_ips = cst_bmed_api_const_pkg.REPORT_IPS_VISA       and vsf.id is not null
                  or
                  i_ips = cst_bmed_api_const_pkg.REPORT_IPS_MASTERCARD and mcf.id is not null
                  or
                  i_ips is null and (vsf.id is not null or mcf.id is not null))
             and (    -- Visa chargebacks
                      vsf.trans_code in (
                          vis_api_const_pkg.TC_SALES_CHARGEBACK
                        , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
                        , vis_api_const_pkg.TC_CASH_CHARGEBACK
                      )
                  or
                      -- MasterCard chargebacks/arbitration chargebacks
                      mcf.mti = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
                      and mcf.de024 in (
                              mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
                            , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
                            , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
                            , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART
                          )
                 )
      ) opr
      join csm_case cc           on cc.original_id   = opr.oper_id
      join app_application app   on app.id           = cc.id
     where app.flow_id in (select column_value from table(cast(l_flow_id_tab as num_tab_tpt)))
       and (i_status is null or app.appl_status = i_status)
    ;

    if l_table is null then
        select xmlelement("record"
                 , xmlelement("ips",            null)
                 , xmlelement("reject_code",    null)
                 , xmlelement("dispute_type",   null)
                 , xmlelement("case_id",        null)
                 , xmlelement("card_number",    null)
                 , xmlelement("creation_date",  null)
                 , xmlelement("oper_amount",    null)
                 , xmlelement("sttl_amount",    null)
                 , xmlelement("merchant_name",  null)
                 , xmlelement("mcc",            null)
                 , xmlelement("reason_code",    null)
               )
          into l_table
          from dual;
    end if;

    select xmlelement("report"
             , (select xmlelement("header"
                         , xmlelement("report_datetime"
                             , to_char(sysdate(), DATETIME_FORMAT)
                           )
                         , xmlelement("period"
                             , to_char(l_start_date, DATE_FORMAT_DAY) || ' - ' ||
                               to_char(l_end_date,   DATE_FORMAT_DAY)
                           )
                         , xmlelement("participant_type", i_participant_type)
                       )
                  from dual
               ) -- header
             , (select xmlelement("table"
                         , l_table
                       )
                  from dual
               )
           ).getclobval()
      into o_xml
      from dual;

exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '>> FAILED: ' || sqlerrm
        );
        raise;
end chargeback_dispute_cases;

procedure issuing_chargeback_disputes(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_ips               in     com_api_type_pkg.t_dict_value
  , i_status            in     com_api_type_pkg.t_dict_value
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
begin
    chargeback_dispute_cases(
        o_xml               => o_xml
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_ips               => i_ips
      , i_status            => i_status
      , i_lang              => i_lang
    );
end;

procedure acquring_chargeback_disputes(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_ips               in     com_api_type_pkg.t_dict_value
  , i_status            in     com_api_type_pkg.t_dict_value
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
begin
    chargeback_dispute_cases(
        o_xml               => o_xml
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_ips               => i_ips
      , i_status            => i_status
      , i_lang              => i_lang
    );
end;

/*
 * The report displays merchant's transactions and terminal/installation fees).
 */
procedure merchant_statement(
    o_xml                  out clob
  , i_merchant_id       in     com_api_type_pkg.t_short_id
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.merchant_statement ';
    DATE_LAG          constant pls_integer := 30; -- for calculation limits for OPR_OPERATION.ID by input dates
    l_merchant_name            com_api_type_pkg.t_name;
    l_start_date               date;
    l_end_date                 date;
    l_lang                     com_api_type_pkg.t_dict_value;
    l_table                    xmltype;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_start_date [#1], i_end_date [#2], i_merchant_id [#3]'
      , i_env_param1 => com_api_type_pkg.convert_to_char(i_start_date)
      , i_env_param2 => com_api_type_pkg.convert_to_char(i_end_date)
      , i_env_param3 => i_merchant_id
    );

    -- Check if the merchant exists
    l_merchant_name :=
        acq_api_merchant_pkg.get_merchant_name(
            i_merchant_id  => i_merchant_id
          , i_mask_error   => com_api_const_pkg.FALSE
        );

    l_lang       := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());
    -- Report generating is only allowed for a past period
    l_start_date := trunc(least(i_start_date, com_api_sttl_day_pkg.get_sysdate() - 1));
    l_end_date   := trunc(least(i_end_date,   com_api_sttl_day_pkg.get_sysdate() - 1))
                  + 1 - com_api_const_pkg.ONE_SECOND;

    select xmlagg(xmlelement("record"
             , xmlelement("ips",              opr.ips)
             , xmlelement("fee_type",         case
                                                  when opr.fee_oper_type is not null
                                                   and opr.oper_reason like fcl_api_const_pkg.FEE_TYPE_STATUS_KEY || '%'
                                                  then com_api_dictionary_pkg.get_article_text(
                                                           i_article => opr.oper_reason
                                                         , i_lang    => l_lang
                                                       )
                                              end)
             , xmlelement("merchant_id",      opr.merchant_id)
             , xmlelement("terminal_id",      opr.terminal_id)
             , xmlelement("oper_date",        to_char(opr.oper_date, DATE_FORMAT_DAY))
             , xmlelement("invoice",          opr.system_trace_audit_number)
             , xmlelement("card_number",      iss_api_card_pkg.get_card_mask(i_card_number => opr.card_number)
                                           || case opr.sttl_type
                                                  when opr_api_const_pkg.SETTLEMENT_USONUS then ' (*)'
                                              end)
             , xmlelement("us_on_us",         case opr.sttl_type
                                                  when opr_api_const_pkg.SETTLEMENT_USONUS then 1 else 0
                                              end)
             , xmlelement("usd_amount"
                 , nvl(
                       com_api_currency_pkg.get_amount_str(
                           i_amount         => opr.usd_amount * case when opr.fee_oper_type is not null then -1 else 1 end
                         , i_curr_code      => cst_bmed_csc_const_pkg.CURRENCY_CODE_US_DOLLAR
                         , i_mask_curr_code => com_api_const_pkg.TRUE
                         , i_mask_error     => com_api_const_pkg.FALSE
                       )
                     , '0'
                   )
               )
             , xmlelement("usd_tip",          '0')
             , xmlelement("lbp_amount"
                 , nvl(
                       com_api_currency_pkg.get_amount_str(
                           i_amount         => opr.lbp_amount * case when opr.fee_oper_type is not null then -1 else 1 end
                         , i_curr_code      => cst_bmed_csc_const_pkg.CURRENCY_CODE_LEBANESE_POUND
                         , i_mask_curr_code => com_api_const_pkg.TRUE
                         , i_mask_error     => com_api_const_pkg.FALSE
                       )
                     , '0'
                   )
               )
             , xmlelement("lbp_tip",          '0')
           ))
      into l_table
      from (
          select case
                     when fee.fee_oper_type is not null    then null
                     when vsf.id is not null               then 'Visa'
                     when mcf.id is not null               then 'MasterCard'
                                                           else 'Other'
                 end as ips
               , opr.sttl_type
               , opr.oper_date
               , case
                     when opr.oper_currency = cst_bmed_csc_const_pkg.CURRENCY_CODE_US_DOLLAR
                     then opr.oper_amount
                     else com_api_rate_pkg.convert_amount(
                              i_src_amount      => opr.oper_amount
                            , i_src_currency    => opr.oper_currency
                            , i_dst_currency    => cst_bmed_csc_const_pkg.CURRENCY_CODE_US_DOLLAR
                            , i_rate_type       => cst_bmed_csc_const_pkg.REPORT_MERCHANT_RATE_TYPE
                            , i_conversion_type => com_api_const_pkg.CONVERSION_TYPE_SELLING
                            , i_inst_id         => acq.inst_id
                            , i_eff_date        => opr.oper_date
                            , i_mask_exception  => com_api_const_pkg.TRUE
                            , i_exception_value => null
                          )
                 end as usd_amount
               , case
                     when opr.oper_currency = cst_bmed_csc_const_pkg.CURRENCY_CODE_LEBANESE_POUND
                     then opr.oper_amount
                 end as lbp_amount
               , crd.card_number
               , acq.merchant_id
               , opr.merchant_country
               , opr.merchant_city
               , opr.merchant_name
               , acq.terminal_id
               , opr.terminal_type
               , opr.oper_reason
               , fee.fee_oper_type
               , aut.system_trace_audit_number
            from      opr_operation   opr
                 join opr_card        crd    on crd.oper_id          = opr.id
                 join opr_participant acq    on acq.oper_id          = opr.id
                                            and acq.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
            left join aut_auth        aut    on aut.id               = opr.id
            left join mcw_fin         mcf    on mcf.id               = opr.id
            left join vis_fin_message vsf    on vsf.id               = opr.id
            left join (
                     select element_value as fee_oper_type
                       from com_array_element e
                      where e.array_id = cst_bmed_csc_const_pkg.ARRAY_ID_ACQ_FEE_OPER_TYPES
                 ) fee
                                             on fee.fee_oper_type    = opr.oper_type
           where opr.id               >= com_api_id_pkg.get_from_id(i_date => l_start_date - DATE_LAG)
             and opr.id               <= com_api_id_pkg.get_from_id(i_date => l_end_date   + DATE_LAG)
             and trunc(opr.oper_date) >= l_start_date
             and trunc(opr.oper_date) <= l_end_date
             and opr.status in (
                     select element_value
                       from com_array_element e
                      where e.array_id = opr_api_const_pkg.OPER_STATUS_ARRAY_ID
                 )
             and acq.merchant_id in ( -- Current merchant with all its child merchants
                     select id
                       from acq_merchant
                    connect by
                            prior id = parent_id
                      start with
                            id = i_merchant_id
                 )
             -- POS transaction of operation with some merchant fee
             and (opr.terminal_type in (acq_api_const_pkg.TERMINAL_TYPE_POS
                                      , acq_api_const_pkg.TERMINAL_TYPE_EPOS
                                      , acq_api_const_pkg.TERMINAL_TYPE_MOBILE_POS)
                  or
                  opr.oper_reason like fcl_api_const_pkg.FEE_TYPE_STATUS_KEY || '%')
             and nvl(trim(opr.oper_currency), com_api_const_pkg.ZERO_CURRENCY) != com_api_const_pkg.ZERO_CURRENCY
      ) opr
     order by
           case ips
               when 'MasterCard' then 0
               when 'Visa'       then 1
               when 'Other'      then 2 -- other IPS
                                 else 3 -- Fees
           end
    ;

    if l_table is null then
        select xmlelement("record"
                 , xmlelement("ips",                 null)
                 , xmlelement("fee_type",            null)
                 , xmlelement("merchant_id",         null)
                 , xmlelement("merchant_name",       null)
                 , xmlelement("merchant_country",    null)
                 , xmlelement("merchant_city",       null)
                 , xmlelement("terminal_id",         null)
                 , xmlelement("oper_date",           null)
                 , xmlelement("invoice",             null)
                 , xmlelement("card_number",         null)
                 , xmlelement("us_on_us",            null)
                 , xmlelement("usd_amount",          null)
                 , xmlelement("usd_tip",             null)
                 , xmlelement("lbp_amount",          null)
                 , xmlelement("lbp_amount",          null)
               )
          into l_table
          from dual;
    end if;

    select xmlelement("report"
             , (select xmlelement("header"
                         , xmlelement("report_datetime"
                             , to_char(sysdate(), DATE_FORMAT_DAY)
                           )
                         , xmlelement("period"
                             , to_char(l_start_date, DATE_FORMAT_DAY) || ' - ' ||
                               to_char(l_end_date,   DATE_FORMAT_DAY)
                           )
                         , xmlelement("parent_merchant_id", i_merchant_id)
                         , xmlelement("merchant_name",      l_merchant_name)
                         , xmlelement("merchant_country",   com_api_country_pkg.get_country_full_name(
                                                                i_code         => address.country
                                                              , i_lang         => l_lang
                                                              , i_raise_error  => com_api_const_pkg.TRUE
                                                            ))
                         , xmlelement("merchant_city",      address.city)
                       )
                  from (
                      select a.*
                           , row_number() over (
                                 order by
                                     case
                                         when ao.address_type = com_api_const_pkg.ADDRESS_TYPE_BUSINESS
                                         then 0
                                         else 1
                                     end
                             ) as rn
                        from com_address_object ao
                        join com_address        a     on a.id = ao.address_id
                       where ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                         and ao.object_id   = i_merchant_id
                  ) address
                 where address.rn = 1
               ) -- header
             , (select xmlelement("table"
                         , l_table
                       )
                  from dual
               )
           ).getclobval()
      into o_xml
      from dual;

exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '>> FAILED: ' || sqlerrm
        );
        raise;
end merchant_statement;

procedure credit_statement_with_loyalty(
    o_xml                  out clob
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_invoice_id        in     com_api_type_pkg.t_medium_id
) is
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.credit_statement_with_loyalty ';
    BAR_CODE_TEMPLATE       constant com_api_type_pkg.t_name := '*C0990S%CARD_UID%*';
    BAR_CODE_VAR_PART       constant com_api_type_pkg.t_name := '%CARD_UID%';
    
    l_header                xmltype;
    l_detail                xmltype;
    l_result                xmltype;

    l_account_id            com_api_type_pkg.t_account_id;
    l_invoice_date          date;
    l_start_date            date;
    l_eff_date              date := get_sysdate;
    l_lag_invoice           crd_api_type_pkg.t_invoice_rec;
    l_currency_id           com_api_type_pkg.t_tiny_id;
    l_currency              com_api_type_pkg.t_dict_value;
    l_currency_name         com_api_type_pkg.t_dict_value;
    l_lty_account_id_tab    num_tab_tpt := num_tab_tpt();
    l_lty_account           acc_api_type_pkg.t_account_rec;
    l_loyalty_currency      com_api_type_pkg.t_curr_code;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_loyalty_incoming      com_api_type_pkg.t_money;
    l_loyalty_earned        com_api_type_pkg.t_money;
    l_loyalty_spent         com_api_type_pkg.t_money;
    l_loyalty_expired       com_api_type_pkg.t_money;
    l_loyalty_outgoing      com_api_type_pkg.t_money;
    
    l_percent_cash_interest        com_api_type_pkg.t_full_desc;
    l_percent_non_cash_interest    com_api_type_pkg.t_full_desc;
    l_amount_cash_interest         com_api_type_pkg.t_money;
    l_amount_non_cash_interest     com_api_type_pkg.t_money;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'Run statement report [#1] [#2]'
      , i_env_param1  => i_lang
      , i_env_param2  => i_invoice_id
    );
    
    begin
        select account_id
             , invoice_date
             , inst_id
          into l_account_id
             , l_invoice_date
             , l_inst_id
          from crd_invoice_vw
         where id = i_invoice_id;
    exception when no_data_found then
        com_api_error_pkg.raise_error(
            i_error         => 'INVOICE_NOT_FOUND'
          , i_env_param1  => i_invoice_id
        );
    end;

    select currency
         , split_hash
      into l_currency
         , l_split_hash
      from acc_account
     where id = l_account_id;

    -- get previous invoice
    begin
        select i1.id
             , i1.account_id
             , i1.serial_number
             , i1.invoice_type
             , i1.exceed_limit
             , i1.total_amount_due
             , i1.own_funds
             , i1.min_amount_due
             , i1.invoice_date
             , i1.grace_date
             , i1.due_date
             , i1.penalty_date
             , i1.aging_period
             , i1.is_tad_paid
             , i1.is_mad_paid
             , i1.inst_id
             , i1.agent_id
             , i1.split_hash
             , i1.overdue_date
             , i1.start_date
          into l_lag_invoice
          from crd_invoice_vw i1
             , ( select
                     a.id
                     , lag(a.id) over (order by a.invoice_date) lag_id
                   from crd_invoice_vw a
                  where a.account_id = l_account_id
               ) i2
         where i1.id = i2.lag_id
           and i2.id = i_invoice_id;
    exception when no_data_found then
        trc_log_pkg.debug(
            i_text  => 'Previous invoice not found'
        );
    end;
    
    -- get interest part
    select fcl_ui_fee_pkg.get_fee_desc(i_fee_id => cash_fee_id_interest) as cash_fee_interest
         , fcl_ui_fee_pkg.get_fee_desc(i_fee_id => non_cash_fee_id_interest) as non_cash_fee_interest
         , cash_amount_interest
         , non_cash_amount_interest
      into l_percent_cash_interest
         , l_percent_non_cash_interest
         , l_amount_cash_interest
         , l_amount_non_cash_interest
      from (
          select max(decode(cd.oper_type, opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, cdi.fee_id, null)) cash_fee_id_interest
               , max(decode(cd.oper_type, opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, null, cdi.fee_id)) non_cash_fee_id_interest
               , sum(decode(cd.oper_type, opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, cdi.interest_amount, 0)) cash_amount_interest
               , sum(decode(cd.oper_type, opr_api_const_pkg.OPERATION_TYPE_ATM_CASH, 0, cdi.interest_amount)) non_cash_amount_interest
            from crd_debt_interest cdi
               , crd_debt cd
           where cdi.invoice_id = i_invoice_id
             and cd.id          = cdi.debt_id
             and cdi.is_charged = com_api_const_pkg.TRUE
      );
      
    -- calc start date
    if l_lag_invoice.id is null then
        begin
            select o.start_date
              into l_start_date
              from prd_service_object o
                 , prd_service s
             where o.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
               and object_id         = l_account_id
               and s.id              = o.service_id
               and s.service_type_id = crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID;
        exception when no_data_found then
            com_api_error_pkg.raise_error(
                i_error       => 'ACCOUNT_SERVICE_NOT_FOUND'
              , i_env_param1  => l_account_id
              , i_env_param2  => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
            );
        end;
    else
        l_start_date := l_lag_invoice.invoice_date;
    end if;

    select id
         , name
      into l_currency_id
         , l_currency_name
      from com_currency
     where code = l_currency;
     
    for r in (
        select ao.object_id
             , ao.entity_type
          from acc_account_object ao
         where ao.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
           and ao.account_id     = l_account_id
            union all
        select l_account_id as object_id
             , acc_api_const_pkg.ENTITY_TYPE_ACCOUNT as entity_type 
          from dual
    )
    loop
        lty_api_bonus_pkg.get_lty_account(
            i_entity_type => r.entity_type
          , i_object_id   => r.object_id
          , i_inst_id     => l_inst_id
          , i_eff_date    => l_invoice_date
          , i_mask_error  => com_api_const_pkg.TRUE
          , o_account     => l_lty_account
        );
        if l_lty_account.account_id is not null then
            l_lty_account_id_tab.extend;
            l_lty_account_id_tab(l_lty_account_id_tab.count) := l_lty_account.account_id;
            l_loyalty_currency := l_lty_account.currency;
        end if;
    end loop;
    trc_log_pkg.debug(
        i_text  => 'count of lty accounts ' || l_lty_account_id_tab.count
    );
    
    select sum(l.amount - l.spent_amount)
      into l_loyalty_expired
      from table(cast(l_lty_account_id_tab as num_tab_tpt)) b
         , lty_bonus l
     where l.account_id = b.column_value
       and l.expire_date between l_start_date and l_invoice_date
       and l.status     = lty_api_const_pkg.BONUS_TRANSACTION_OUTDATED
       and l.split_hash = l_split_hash;

    select min(loyalty_incoming) as loyalty_incoming
         , min(loyalty_earned) as loyalty_earned
         , min(loyalty_spent) - l_loyalty_expired as loyalty_spent
         , min(loyalty_outgoing) as loyalty_outgoing
      into l_loyalty_incoming
         , l_loyalty_earned
         , l_loyalty_spent
         , l_loyalty_outgoing
      from (
               select max(balance - amount) keep (dense_rank first order by posting_order) over () as loyalty_incoming
                    , sum(decode(a.balance_impact, 1, a.amount, null)) over () as loyalty_earned
                    , sum(decode(a.balance_impact, -1, a.amount, null)) over () as loyalty_spent
                    , min(balance) keep (dense_rank last order by posting_order) over () as loyalty_outgoing
                 from table(cast(l_lty_account_id_tab as num_tab_tpt)) b
                    , acc_entry a
                where a.account_id = b.column_value
                  and a.split_hash = l_split_hash
                  and a.posting_date between l_start_date and l_invoice_date
           );

    -- header
    select xmlconcat(
               xmlelement("customer_number", t.customer_number)
             , xmlelement("account_number", t.account_number)
             , xmlelement("account_currency", l_currency_name)
             , xmlelement(
                   "card_uid_barcode"
                 , (select replace(BAR_CODE_TEMPLATE, BAR_CODE_VAR_PART, s.card_uid)
                      from (
                        select ao.account_id
                             , ici.card_uid
                             , row_number() over(partition by ao.account_id order by decode(ic.category, iss_api_const_pkg.CARD_CATEGORY_PRIMARY, 0, 1), ici.seq_number desc) rnk
                          from acc_account_object ao
                             , iss_card ic
                             , iss_card_instance ici
                         where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                           and ao.object_id   = ic.id
                           and ici.card_id    = ic.id
                      ) s
                    where s.account_id = t.account_id
                      and s.rnk = 1
                   )
               )
             , (
                   select xmlagg(
                              xmlelement("customer_name"
                                , xmlelement("surname", p.surname)
                                , xmlelement("first_name", p.first_name)
                                , xmlelement("second_name", p.second_name)
                                , xmlelement("person_title", p.title)
                              )
                          )
                     from (select id, min(lang) keep(dense_rank first order by decode(lang, i_lang, 1, 'LANGENG', 2, 3)) lang 
                             from com_person 
                            group by id
                          ) p2
                         , com_person p
                    where p2.id  = t.object_id
                      and p.id   = p2.id
                      and p.lang = p2.lang
               )
             , (
                   select xmlelement("delivery_address"
                            , xmlelement("region", a.region)
                            , xmlelement("city", a.city)
                            , xmlelement("street", a.street)
                            , xmlelement("house", a.house)
                            , xmlelement("apartment", a.apartment)
                            , xmlelement("postal_code", a.postal_code)
                          )
                         from com_address_object o
                            , com_address a
                        where o.entity_type = 'ENTTCUST'
                          and o.object_id   = t.customer_id 
                          and a.id          = o.address_id
                          and a.lang        = i_lang
                          and rownum        = 1
               )
             , xmlelement("start_date", to_char(start_date, 'dd/mm/yyyy'))
             , xmlelement("invoice_date", to_char(invoice_date, 'dd/mm/yyyy'))
             , xmlelement("min_amount_due"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(min_amount_due, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("due_date", to_char(due_date, 'dd/mm/yyyy'))
             , xmlelement("eff_date", to_char(l_eff_date, 'dd/mm/yyyy'))
             , xmlelement("credit_limit"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(credit_limit, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("incoming_balance"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(incoming_balance, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("payment_amount"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(payment_amount, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("expense_amount"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(expense_amount, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("interest_amount"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(interest_amount, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("interest_cash_percent", l_percent_cash_interest)
             , xmlelement(
                   "interest_cash_amount"
                 , com_api_currency_pkg.get_amount_str(
                       i_amount         => l_amount_cash_interest
                     , i_curr_code      => l_currency
                     , i_mask_curr_code => com_api_type_pkg.TRUE
                   )
               )
             , xmlelement("interest_non_cash_percent", l_percent_non_cash_interest)
             , xmlelement(
                   "interest_non_cash_amount"
                 , com_api_currency_pkg.get_amount_str(
                       i_amount         => l_amount_non_cash_interest
                     , i_curr_code      => l_currency
                     , i_mask_curr_code => com_api_type_pkg.TRUE
                   )
               )
             , xmlelement(
                   "apr"
                 , to_char(
                       round(nvl(apr, 0)/com_api_const_pkg.ONE_PERCENT, 2)
                     , com_api_const_pkg.XML_FLOAT_FORMAT
                   )
                   || '%'
               )
             , xmlelement(
                   "irr"
                 , to_char(
                       round(nvl(irr, 0)/com_api_const_pkg.ONE_PERCENT, 2)
                     , com_api_const_pkg.XML_FLOAT_FORMAT
                   )
                   || '%'
               )
             , xmlelement("fee_amount"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(fee_amount, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("total_amount_due"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(total_amount_due, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("own_funds"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(own_funds, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("hold_balance"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(hold_balance, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("available_balance"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(available_balance, 0)
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("outgoing_balance"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => (nvl(total_amount_due, 0)- nvl(own_funds, 0))
                            , i_curr_code      => l_currency
                            , i_mask_curr_code => com_api_type_pkg.TRUE
                          )
               )
             , xmlelement("loyalty_incoming"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(l_loyalty_incoming, 0)
                            , i_curr_code      => l_loyalty_currency
                            , i_mask_curr_code => com_api_const_pkg.TRUE
                            , i_mask_error     => com_api_const_pkg.TRUE
                          )
               )
             , xmlelement("loyalty_earned"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(l_loyalty_earned, 0)
                            , i_curr_code      => l_loyalty_currency
                            , i_mask_curr_code => com_api_const_pkg.TRUE
                            , i_mask_error     => com_api_const_pkg.TRUE
                          )
               )
             , xmlelement("loyalty_spent"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(l_loyalty_spent, 0)
                            , i_curr_code      => l_loyalty_currency
                            , i_mask_curr_code => com_api_const_pkg.TRUE
                            , i_mask_error     => com_api_const_pkg.TRUE
                          )
               )
             , xmlelement("loyalty_expired"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(l_loyalty_expired, 0)
                            , i_curr_code      => l_loyalty_currency
                            , i_mask_curr_code => com_api_const_pkg.TRUE
                            , i_mask_error     => com_api_const_pkg.TRUE
                          )
               )
             , xmlelement("loyalty_outgoing"
                        , com_api_currency_pkg.get_amount_str(
                              i_amount         => nvl(l_loyalty_outgoing, 0)
                            , i_curr_code      => l_loyalty_currency
                            , i_mask_curr_code => com_api_const_pkg.TRUE
                            , i_mask_error     => com_api_const_pkg.TRUE
                          )
               )
             , xmlelement("invoice_id", t.invoice_id)
           )
    into l_header
    from (
             select c.customer_number
                  , i.id invoice_id
                  , i.account_id
                  , a.account_number 
                  , c.object_id
                  , c.id customer_id
                  , i.start_date
                  , i.invoice_date
                  , i.min_amount_due
                  , i.due_date
                  , i.exceed_limit credit_limit
                  , nvl(l_lag_invoice.total_amount_due, 0) incoming_balance
                  , i.payment_amount
                  , (i.expense_amount - i.fee_amount) expense_amount
                  , i.interest_amount
                  , i.fee_amount
                  , i.total_amount_due
                  , i.own_funds
                  , i.hold_balance
                  , i.available_balance
                  , i.apr
                  , i.irr
               from crd_invoice_vw i
                  , acc_account_vw a
                  , prd_customer_vw c
              where i.id             = i_invoice_id
                and a.id             = i.account_id
                and c.id(+)          = a.customer_id
                and c.entity_type(+) = com_api_const_pkg.ENTITY_TYPE_PERSON
    ) t;
    
    begin
        -- details
        select xmlelement("operations",
                   xmlagg(
                       xmlelement("operation"
                         , xmlelement("card_mask", card_mask)
                         , xmlelement("oper_category", oper_category)
                         , xmlelement("oper_date", to_char(oper_date, 'dd.mm.yyyy hh24:mi:ss'))
                         , xmlelement("posting_date", to_char(posting_date, 'dd.mm.yyyy'))
                         , xmlelement("oper_amount"
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => oper_amount
                                        , i_curr_code      => l_currency
                                        , i_mask_curr_code => com_api_type_pkg.TRUE
                                      )
                           )
                         , xmlelement("oper_currency", oper_currency)
                         , xmlelement("posting_amount" 
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => account_amount
                                        , i_curr_code      => l_currency
                                        , i_mask_curr_code => com_api_type_pkg.TRUE
                                      )
                           )
                         , xmlelement("posting_currency", account_currency)
                         , xmlelement("oper_type", oper_type)
                         , xmlelement("oper_type_name", oper_type_name)
                         , xmlelement("merchant_name", merchant_name)
                         , xmlelement("merchant_street", merchant_street)
                         , xmlelement("merchant_city", merchant_city)
                         , xmlelement("merchant_country", merchant_country)
                         , xmlelement("oper_id", oper_id)
                         , xmlelement("fee_type", fee_type)
                         , xmlelement("fee_type_name"
                                    , com_api_dictionary_pkg.get_article_text(
                                          i_article => fee_type
                                        , i_lang    => i_lang
                                      )
                           )
                         , xmlelement("loyalty_points"
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => nvl(lty_points, 0)
                                        , i_curr_code      => l_loyalty_currency
                                        , i_mask_curr_code => com_api_const_pkg.TRUE
                                        , i_mask_error     => com_api_const_pkg.TRUE
                                      )
                           )
                         , xmlelement("loyalty_points_pending"
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => nvl(lty_points_pending, 0)
                                        , i_curr_code      => l_loyalty_currency
                                        , i_mask_curr_code => com_api_const_pkg.TRUE
                                        , i_mask_error     => com_api_const_pkg.TRUE
                                      )
                           )
                         , xmlelement("interest_amount"
                                    , com_api_currency_pkg.get_amount_str(
                                          i_amount         => nvl(interest_amount, 0)
                                        , i_curr_code      => l_currency
                                        , i_mask_curr_code => com_api_const_pkg.TRUE
                                        , i_mask_error     => com_api_const_pkg.TRUE
                                      )
                           )
                      )
                      order by 
                            case when t.card_category = iss_api_const_pkg.CARD_CATEGORY_PRIMARY
                                     then 0 
                                 when t.card_category is not null 
                                   then 1
                                 else 3
                            end
                          , oper_category
                          , oper_date
                   )
               )
          into l_detail   
          from (     
              select coalesce(
                         v.card_mask
                       , iss_api_card_pkg.get_card_mask(
                             i_card_number => v.card_number
                         )
                     ) card_mask
                   , v.category as card_category
                   , 'EXPENSE' oper_category
                   , o.oper_date
                   , d.posting_date
                   , o.oper_amount
                   , ocr.name oper_currency  
                   , p.account_amount
                   , cr.name account_currency 
                   , o.oper_type
                   , com_api_dictionary_pkg.get_article_text(o.oper_type, i_lang) oper_type_name
                   , o.merchant_name
                   , o.merchant_street
                   , o.merchant_city
                   , r.name merchant_country
                   , d.fee_type  
                   , d.card_id
                   , o.id oper_id 
                   , d.id debt_id
                   , b.lty_points
                   , b.lty_points_pending
                   , i.interest_amount
                from (
                      select distinct debt_id
                        from crd_invoice_debt_vw
                       where invoice_id = i_invoice_id
                         and is_new     = com_api_type_pkg.TRUE
                     ) e
                   , crd_debt d
                   , iss_card_vw v
                   , opr_operation o
                   , opr_participant p
                   , com_country r
                   , com_currency cr
                   , com_currency ocr
                   , (
                      select sum(case when m.posting_date between l_start_date and l_invoice_date then m.amount end) as lty_points
                           , sum(case when m.posting_date not between l_start_date and l_invoice_date then m.amount end) as lty_points_pending
                           , m.object_id as oper_id
                        from table(cast(l_lty_account_id_tab as num_tab_tpt)) b
                           , acc_macros m
                           , acc_entry e
                       where m.account_id     = b.column_value
                         and m.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                         and m.id             = e.macros_id
                         and e.balance_impact = 1
                       group by m.object_id
                     ) b
                   , (
                      select debt_id
                           , sum(nvl(interest_amount, 0)) as interest_amount
                        from crd_debt_interest
                       where invoice_id = i_invoice_id
                         and split_hash = l_split_hash
                         and is_charged = 1
                       group by debt_id
                     ) i
               where d.id                  = e.debt_id
                 and d.oper_id             = o.id(+)
                 and d.card_id             = v.id(+)
                 and p.oper_id(+)          = o.id
                 and p.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
                 and d.oper_type           != opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
                 and o.merchant_country    = r.code(+)
                 and p.account_currency    = cr.code(+)
                 and o.oper_currency       = ocr.code(+)
                 and d.oper_id             = b.oper_id(+)
                 and e.debt_id             = i.debt_id(+)
               union all
              select coalesce(
                         v.card_mask
                       , iss_api_card_pkg.get_card_mask(
                             i_card_number => v.card_number
                         )
                     ) card_mask
                   , v.category as card_category
                   , 'FEE' oper_category
                   , o.oper_date
                   , d.posting_date
                   , o.oper_amount
                   , ocr.name oper_currency  
                   , p.account_amount
                   , cr.name account_currency 
                   , o.oper_type
                   , com_api_dictionary_pkg.get_article_text(o.oper_type, i_lang) oper_type_name
                   , o.merchant_name
                   , o.merchant_street
                   , o.merchant_city
                   , r.name merchant_country
                   , d.fee_type  
                   , d.card_id
                   , o.id oper_id 
                   , d.id  
                   , null as lty_points
                   , null as lty_points_pending
                   , null as interest_amount
                from (
                      select distinct debt_id
                        from crd_invoice_debt_vw
                       where invoice_id = i_invoice_id
                         and is_new = com_api_type_pkg.TRUE
                     ) e
                   , crd_debt d
                   , iss_card_vw v
                   , opr_operation o
                   , opr_participant p
                   , com_country r
                   , com_currency cr
                   , com_currency ocr
               where d.id                  = e.debt_id
                 and d.oper_id             = o.id(+)
                 and d.card_id             = v.id(+)
                 and p.oper_id(+)          = o.id
                 and p.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
                 and d.oper_type           = opr_api_const_pkg.OPERATION_TYPE_ISSUER_FEE
                 and o.merchant_country    = r.code(+)
                 and p.account_currency    = cr.code(+)
                 and o.oper_currency       = ocr.code(+)
               union all        
              select coalesce(
                         v.card_mask
                       , iss_api_card_pkg.get_card_mask(
                             i_card_number => v.card_number
                         )
                     ) card_mask
                   , v.category as card_category
                   , 'PAYMENT' oper_category
                   , o.oper_date
                   , m.posting_date
                   , o.oper_amount
                   , ocr.name oper_currency  
                   , iss.account_amount
                   , cr.name account_currency 
                   , o.oper_type
                   , com_api_dictionary_pkg.get_article_text(o.oper_type, i_lang) oper_type_name
                   , o.merchant_name
                   , o.merchant_street
                   , o.merchant_city
                   , r.name merchant_country
                   , null as fee_type
                   , m.card_id
                   , o.id oper_id    
                   , null as debt_id
                   , null as lty_points
                   , null as lty_points_pending
                   , null as interest_amount
                from crd_invoice_payment p
                   , crd_payment m
                   , iss_card_vw v
                   , opr_operation o
                   , opr_participant iss
                   , com_country r
                   , com_currency cr
                   , com_currency ocr
               where p.invoice_id            = i_invoice_id
                 and p.is_new                = com_api_type_pkg.TRUE
                 and m.id                    = p.pay_id
                 and m.oper_id               = o.id(+)
                 and m.card_id               = v.id
                 and iss.oper_id(+)          = o.id
                 and iss.participant_type(+) = com_api_const_pkg.PARTICIPANT_ISSUER
                 and o.merchant_country      = r.code(+)
                 and iss.account_currency    = cr.code(+)
                 and o.oper_currency         = ocr.code(+)
          ) t;
    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text  => 'Operations not found'
            );
    end;

    select xmlelement(
               "report"
             , l_header
             , l_detail
           ) r
      into l_result
      from dual;

    o_xml := l_result.getclobval();

end;

end;
/
