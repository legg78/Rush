create or replace package body csm_api_report_pkg is
/**********************************************************
 * Create reports for disputes <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 06.12.2016 <br />
 * Module: CSM_API_REPORT_PKG
 * @headcom
 **********************************************************/

DATE_FORMAT_DAY         constant com_api_type_pkg.t_oracle_name := 'dd/mm/yyyy';
DATE_FORMAT_MONTH       constant com_api_type_pkg.t_oracle_name := 'mm/yyyy';
DATETIME_FORMAT         constant com_api_type_pkg.t_oracle_name := 'dd.mm.yyyy hh24:mi:ss';

procedure create_notification_report(
    o_xml               out     clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value  default null
) is

    l_dispute_id             com_api_type_pkg.t_long_id;
    l_message_type           com_api_type_pkg.t_dict_value;
    l_card_number            com_api_type_pkg.t_card_number;
    l_due_date               date;
    l_dispute_reason         com_api_type_pkg.t_dict_value;
    l_reason_code            com_api_type_pkg.t_tag;
    l_created_date           date;

begin
    trc_log_pkg.debug (
        i_text       => 'Create notification report [#1] [#2] [#3] [#4] [#5]: Data generation is started'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );
    
    begin
        select c.dispute_id
             , iss_api_token_pkg.decode_card_number(i_card_number => cc.card_number)
             , c.due_date
             , c.dispute_reason
             , nvl(mf.de025, vf.reason_code) as reason_code
             , nvl(mf.mti, vf.trans_code) 
          into l_dispute_id
             , l_card_number
             , l_due_date
             , l_dispute_reason
             , l_reason_code
             , l_message_type
          from csm_case c
             , csm_card cc
             , opr_operation op
             , mcw_fin mf
             , vis_fin_message vf
         where c.id     = i_object_id
           and cc.id    = c.id
           and op.id(+) = c.original_id
           and mf.id(+) = op.id
           and vf.id(+) = op.id;
    exception 
        when no_data_found then
            l_reason_code := null;
    end;
    
    begin
        select min(change_date) as created_date
          into l_created_date
          from app_history
         where appl_id = i_object_id;
    exception 
        when no_data_found then
           l_created_date := null;
    end;

    select xmlconcat(
               xmlelement("application_id", s.appl_id)
             , xmlelement("appl_status", s.appl_status)
             , xmlelement("appl_status_name", com_api_dictionary_pkg.get_article_text(
                                                  i_article => s.appl_status
                                                , i_lang    => i_lang
                                              )
               )
             , xmlelement("reject_code", s.reject_code)
             , xmlelement("reject_code_name", com_api_dictionary_pkg.get_article_text(
                                                  i_article => s.reject_code
                                                , i_lang    => i_lang
                                              )
               )
             , xmlelement("comments", s.comments)
             , xmlelement("user_id", s.user_id)
             , xmlelement("user_name", s.user_name)
             , xmlelement("person_name", com_ui_person_pkg.get_person_name(
                                             i_person_id => s.person_id
                                           , i_lang      => i_lang
                                         )
               )
             , xmlelement("dispute_id", l_dispute_id)
             , xmlelement("dispute_reason", l_dispute_reason)
             , xmlelement("dispute_reason_name", com_api_dictionary_pkg.get_article_text(
                                                     i_article => l_dispute_reason
                                                   , i_lang    => i_lang
                                                 )
               )
             , xmlelement("system_reason_code", l_reason_code)
             , xmlelement("message_type", l_message_type)
             , xmlelement("message_type_name", com_api_dictionary_pkg.get_article_text(
                                                   i_article => l_message_type
                                                 , i_lang    => i_lang
                                               )
               )
             , xmlelement("card_number", iss_api_card_pkg.get_short_card_mask(
                                             i_card_number => l_card_number
                                         )
               )
             , xmlelement("eff_date", to_char(s.eff_date, com_api_const_pkg.XML_DATE_FORMAT))
             , xmlelement("due_date", to_char(l_due_date, com_api_const_pkg.XML_DATE_FORMAT))
             , xmlelement("created_date", to_char(l_created_date, com_api_const_pkg.XML_DATE_FORMAT))
             , xmlelement("role_id", s.role_id)
             , xmlelement("role_name", s.role_name)
           ).getclobval()
      into o_xml
      from
      (    select ah.appl_id
                , ah.change_date as eff_date
                , ah.appl_status
                , ah.comments
                , ah.reject_code
                , au.id as user_id
                , au.name as user_name
                , au.person_id
                , afs.role_id
                , ar.name as role_name
             from app_history ah
                , app_application ap
                , acm_user au
                , app_flow_stage afs
                , acm_role ar
            where ah.appl_id                   = i_object_id
              and ap.id                        = ah.appl_id
              and au.id                        = ap.user_id
              and afs.flow_id                  = ap.flow_id
              and afs.appl_status              = ah.appl_status
              and nvl(afs.reject_code, '9999') = nvl(ah.reject_code, '9999')
              and ar.id                        = afs.role_id
            order by ah.id desc
     ) s
     where rownum = 1;

    trc_log_pkg.debug (
        i_text       => 'Create notification report [#1] [#2] [#3] [#4] [#5]: Data generation is finished success'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );

exception
    when others then
        trc_log_pkg.debug (
            i_text       => 'Create notification report [#1] [#2] [#3] [#4] [#5]: Data generation is finished failed, error: [#6]'
          , i_env_param1 => i_event_type
          , i_env_param2 => i_lang
          , i_env_param3 => i_inst_id
          , i_env_param4 => i_entity_type
          , i_env_param5 => i_object_id
          , i_env_param6 => sqlerrm
        );

        raise;

end create_notification_report;

/*
 * Procedure gather dispute application data for generating a report.
 */
procedure dispute_appl_data_engine(
    o_xml                  out clob
  , i_appl_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_actual_date       in     date                            default null
  , i_amount            in     com_api_type_pkg.t_money        default null
  , i_denom1            in     com_api_type_pkg.t_long_id      default null
  , i_denom2            in     com_api_type_pkg.t_long_id      default null
  , i_text              in     com_api_type_pkg.t_full_desc    default null
  , i_title             in     com_api_type_pkg.t_dict_value   default null
  , i_name              in     com_api_type_pkg.t_name         default null
  , i_docs              in     com_api_type_pkg.t_boolean      default null
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.dispute_application_data ';
    l_lang                     com_api_type_pkg.t_dict_value;
    l_docs                     com_api_type_pkg.t_full_desc;
begin
    trc_log_pkg.debug(
        i_text => 'dispute_appl_data_engine: start ' || i_appl_id
    );
    l_lang := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());

    if i_docs = com_api_const_pkg.TRUE then
        begin
            select substr(listagg(get_article_desc(document_type) || ' - ' || nvl(document_number, id), ',' || chr(10))
            within group (order by id), 1, 2000)
              into l_docs
              from rpt_document
             where entity_type = app_api_const_pkg.ENTITY_TYPE_APPLICATION
               and objecT_id = i_appl_id
             group by entity_type, object_id;
        exception
            when others then
                l_docs := '';
        end;
    end if;

    with appl_data as (
        select appl.appl_id
             , appl.appl_status
             , appl.reject_code
             , appl.card_number
             , appl.dispute_id
             , appl.claim_id
             , min(pers.id)                                                                   as person_id
             , min(pers.lang)          keep (dense_rank first order by
                                           case pers.lang
                                               when l_lang                             then 0
                                               when com_api_const_pkg.DEFAULT_LANGUAGE then 1
                                                                                       else 2
                                           end)                                               as person_lang
             , min(pers.title)         keep (dense_rank first order by
                                           case pers.lang
                                               when l_lang                             then 0
                                               when com_api_const_pkg.DEFAULT_LANGUAGE then 1
                                                                                       else 2
                                           end)                                               as person_title
             , min(opr.oper_date)      keep (dense_rank first order by opr.oper_date, opr.id) as oper_date
             , min(opr.oper_amount)    keep (dense_rank first order by opr.oper_date, opr.id) as oper_amount
             , min(opr.oper_currency)  keep (dense_rank first order by opr.oper_date, opr.id) as oper_currency
             , min(opr.network_refnum) keep (dense_rank first order by opr.oper_date, opr.id) as rrn
             , min(iss.auth_code)      keep (dense_rank first order by opr.oper_date, opr.id) as auth_code
             , min(acq.merchant_id)    keep (dense_rank first order by opr.oper_date, opr.id) as merchant_id
             , min(acq.terminal_id)    keep (dense_rank first order by opr.oper_date, opr.id) as terminal_id
             , min(mcf.de025)          keep (dense_rank first order by opr.oper_date, opr.id) as mcf_reason_code
             , min(vsf.reason_code)    keep (dense_rank first order by opr.oper_date, opr.id) as vsf_reason_code
             , coalesce(
                   (select address_id
                      from com_address_object
                     where entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                       and object_id   = crhd.id
                   )
                 , (select address_id
                      from com_address_object
                     where entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                       and object_id   = crd.customer_id
                   )
               )                                                                              as address_id
          from ( --case
              select a.id as appl_id
                   , a.appl_status
                   , a.reject_code
                   , iss_api_token_pkg.decode_card_number(i_card_number => card.card_number) as card_number
                   , c.dispute_id
                   , c.original_id
                   , cn.card_id
                   , case when c.claim_id is null 
                              then null
                          else
                              ' ' || c.claim_id
                     end as claim_id
                from app_application a
                   , csm_case c
                   , csm_card card
                   , iss_card_number cn
               where a.id           = i_appl_id
                 and c.id           = a.id
                 and card.id        = c.id
                 and cn.card_number = card.card_number
          ) appl
          join      iss_card        crd   on crd.id               = appl.card_id
          join      iss_cardholder  crhd  on crhd.id              = crd.cardholder_id
          join      com_person      pers  on pers.id              = crhd.person_id
          join      opr_operation   opr   on opr.id               = appl.original_id
          left join opr_participant iss   on iss.oper_id          = opr.id
                                         and iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
          left join opr_participant acq   on acq.oper_id          = opr.id
                                         and acq.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
          left join mcw_fin         mcf   on mcf.id               = opr.id
          left join vis_fin_message vsf   on vsf.id               = opr.id
         group by
               appl.appl_id
             , appl.appl_status
             , appl.reject_code
             , appl.card_number
             , appl.dispute_id
             , appl.claim_id
             , crhd.id
             , crd.customer_id
    ) --with
    select xmlelement("dispute_appl_data"
             , xmlelement("system_date",      to_char(com_api_sttl_day_pkg.get_sysdate(), DATETIME_FORMAT))
             , xmlelement("appl_id",          appl_id)
             , xmlelement("appl_status",      com_api_dictionary_pkg.get_article_text(
                                                  i_article       => appl_status
                                                , i_lang          => l_lang
                                              ))
             , xmlelement("reject_code",      com_api_dictionary_pkg.get_article_text(
                                                  i_article       => reject_code
                                                , i_lang          => l_lang
                                              ))
             , xmlelement("card_number",      iss_api_card_pkg.get_card_mask(i_card_number => card_number))
             , xmlelement("dispute_id",       dispute_id)
             , xmlelement("claim_id",         claim_id)
             , xmlelement("oper_date",        to_char(oper_date, DATETIME_FORMAT))
             , xmlelement("oper_amount",      oper_amount)
             , xmlelement("oper_currency",    com_api_currency_pkg.get_currency_name(
                                                  i_curr_code      => oper_currency
                                              ))
             , xmlelement("oper_amount_curr", com_api_currency_pkg.get_amount_str(
                                                  i_amount         => oper_amount
                                                , i_curr_code      => oper_currency
                                                , i_mask_curr_code => com_api_const_pkg.FALSE
                                                , i_mask_error     => com_api_const_pkg.FALSE
                                              ))
             , xmlelement("rrn",              rrn)
             , xmlelement("auth_code",        auth_code)
             , xmlelement("merchant_name",    (select merchant_name   from acq_merchant where id = merchant_id))
             , xmlelement("terminal_number",  (select terminal_number from acq_terminal where id = terminal_id))
             , xmlelement("address",          com_api_address_pkg.get_address_string(
                                                  i_address_id    => address_id
                                                , i_lang          => l_lang
                                                , i_enable_empty  => com_api_const_pkg.TRUE
                                              ))
             , xmlelement("cardholder_name",  com_ui_person_pkg.get_person_name(
                                                  i_person_id     => person_id
                                                , i_lang          => person_lang
                                              ))
             , xmlelement("cardholder_title", com_api_dictionary_pkg.get_article_text(
                                                  i_article       => person_title
                                                , i_lang          => person_lang
                                              ))
             , xmlelement("rc",               nvl(mcf_reason_code, vsf_reason_code))
             , xmlelement("actual_date",     to_char(i_actual_date, DATE_FORMAT_DAY))            -- for several reports
             , xmlelement("amount",          com_api_currency_pkg.get_amount_str(
                                                 i_amount         => i_amount * power(10, com_api_currency_pkg.get_currency_exponent(oper_currency))
                                               , i_curr_code      => oper_currency
                                               , i_mask_curr_code => com_api_const_pkg.FALSE
                                               , i_mask_error     => com_api_const_pkg.FALSE
                                             ))
             , xmlelement("denom1",          com_api_currency_pkg.get_amount_str(
                                                 i_amount         => i_denom1 * power(10, com_api_currency_pkg.get_currency_exponent(oper_currency))
                                               , i_curr_code      => oper_currency
                                               , i_mask_curr_code => com_api_const_pkg.FALSE
                                               , i_mask_error     => com_api_const_pkg.FALSE
                                             ))
             , xmlelement("denom2",          com_api_currency_pkg.get_amount_str(
                                                 i_amount         => i_denom2 * power(10, com_api_currency_pkg.get_currency_exponent(oper_currency))
                                               , i_curr_code      => oper_currency
                                               , i_mask_curr_code => com_api_const_pkg.FALSE
                                               , i_mask_error     => com_api_const_pkg.FALSE
                                             ))
             , xmlelement("text",            i_text)
             , xmlelement("title",           com_api_dictionary_pkg.get_article_text(
                                                 i_article => i_title
                                               , i_lang    => l_lang
                                             )
                         )
             , xmlelement("name",            i_name)
             , xmlelement("docs",            l_docs)
           ).getclobval()
      into o_xml
      from appl_data;

      trc_log_pkg.debug(
          i_text => 'dispute_appl_data_engine: END'
      );

exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'APPLICATION_NOT_FOUND'
          , i_env_param1 => i_appl_id
        );
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '>> FAILED; i_appl_id [' || i_appl_id || '], sqlerrm: ' || sqlerrm
        );
        raise;
end dispute_appl_data_engine;

procedure dispute_application_data(
    o_xml                  out clob
  , i_appl_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
begin
    dispute_appl_data_engine(
        o_xml         => o_xml
      , i_appl_id     => i_appl_id
      , i_lang        => i_lang
    );
end dispute_application_data;

procedure dispute_application_data_date(
    o_xml                  out clob
  , i_appl_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_actual_date       in     date
) is
begin
    dispute_appl_data_engine(
        o_xml         => o_xml
      , i_appl_id     => i_appl_id
      , i_lang        => i_lang
      , i_actual_date => i_actual_date
    );
end dispute_application_data_date;

procedure dispute_application_data_amnt(
    o_xml                  out clob
  , i_appl_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_amount            in     com_api_type_pkg.t_money
) is
begin
    dispute_appl_data_engine(
        o_xml         => o_xml
      , i_appl_id     => i_appl_id
      , i_lang        => i_lang
      , i_amount      => i_amount
    );
end dispute_application_data_amnt;

/*
 * Procedure gather dispute application data for generating a repor with denominations.
 */
procedure dispute_application_data_denom(
    o_xml                  out clob
  , i_appl_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_denom1            in     com_api_type_pkg.t_long_id
  , i_denom2            in     com_api_type_pkg.t_long_id
)  is
begin
    dispute_appl_data_engine(
        o_xml         => o_xml
      , i_appl_id     => i_appl_id
      , i_lang        => i_lang
      , i_denom1      => i_denom1
      , i_denom2      => i_denom2
    );
end dispute_application_data_denom;

procedure dispute_application_data_text(
    o_xml                  out clob
  , i_appl_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_text              in     com_api_type_pkg.t_full_desc
) is
begin
    dispute_appl_data_engine(
        o_xml         => o_xml
      , i_appl_id     => i_appl_id
      , i_lang        => i_lang
      , i_text        => i_text
    );
end dispute_application_data_text;

procedure dispute_application_data_mgr(
    o_xml                  out clob
  , i_appl_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_title             in     com_api_type_pkg.t_dict_value
  , i_name              in     com_api_type_pkg.t_name
) is
begin
    dispute_appl_data_engine(
        o_xml         => o_xml
      , i_appl_id     => i_appl_id
      , i_lang        => i_lang
      , i_title       => i_title
      , i_name        => i_name
    );
end dispute_application_data_mgr;

procedure dispute_application_data_docs(
    o_xml                  out clob
  , i_appl_id           in     com_api_type_pkg.t_long_id
  , i_lang              in     com_api_type_pkg.t_dict_value  
) is
begin
    dispute_appl_data_engine(
        o_xml         => o_xml
      , i_appl_id     => i_appl_id
      , i_lang        => i_lang
      , i_docs        => com_api_const_pkg.TRUE
    );
end dispute_application_data_docs;

/*
 * The report displays a number of new created issuing cases grouped by specified period, IPS, and case category.
 */
procedure new_issuing_cases(
    o_xml                  out clob
  , i_grouping_period   in     com_api_type_pkg.t_dict_value
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.new_issuing_cases ';
    DATE_LAG          constant pls_integer := 30; -- for calculation limits for OPR_OPERATION.ID by input dates
    l_start_date               date;
    l_end_date                 date;
    l_lang                     com_api_type_pkg.t_dict_value;
    l_grouping_date_format     com_api_type_pkg.t_oracle_name;
    l_table                    xmltype;
begin
    --trc_log_pkg.debug(
    --    i_text       => LOG_PREFIX || '<< i_start_date [#1], i_end_date [#2], i_lang [#3]'
    --  , i_env_param1 => com_api_type_pkg.convert_to_char(i_start_date)
    --  , i_env_param2 => com_api_type_pkg.convert_to_char(i_end_date)
    --  , i_env_param3 => i_lang
    --);

    l_lang       := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());
    -- Report generating is only allowed for a past period
    l_start_date := trunc(least(i_start_date, com_api_sttl_day_pkg.get_sysdate() - 1));
    l_end_date   := trunc(least(i_end_date,   com_api_sttl_day_pkg.get_sysdate() - 1))
                  + 1 - com_api_const_pkg.ONE_SECOND;

    l_grouping_date_format := case i_grouping_period
                                  when csm_api_const_pkg.GROUPING_PERIOD_MONTH then DATE_FORMAT_MONTH
                                  when csm_api_const_pkg.GROUPING_PERIOD_DAY   then DATE_FORMAT_DAY
                                                                               else DATE_FORMAT_DAY
                              end;

    select xmlagg(xmlelement("record"
             , xmlelement("period",         period)
             , xmlelement("ips",            ips)
             , xmlelement("dispute_source", dispute_source)
             , xmlelement("internal",       sum(case when dispute_type = 'internal'      then 1 else 0 end))
             , xmlelement("domestic",       sum(case when dispute_type = 'domestic'      then 1 else 0 end))
             , xmlelement("international",  sum(case when dispute_type = 'international' then 1 else 0 end))
             , xmlelement("atm_cases",      sum(is_atm_case))
           ))
      into l_table
      from (
          select case
                     when vsf.id is not null then 'Visa'
                     when mcf.id is not null then 'MasterCard'
                 end
                     as ips
                 -- Grouping by a month or a day
               , to_char(o.oper_date, l_grouping_date_format)
                     as period
               , com_api_dictionary_pkg.get_article_text(
                     i_article => case
                                      when mcf.is_incoming = com_api_const_pkg.TRUE
                                        or vsf.is_incoming = com_api_const_pkg.TRUE
                                      then csm_api_const_pkg.CASE_SOURCE_INCOMING_CLEARING
                                      else csm_api_const_pkg.CASE_SOURCE_MANUALLY_CREATED
                                  end
                   , i_lang    => l_lang
                 )
                     as dispute_source
               , case
                     when o.sttl_type in (
                              opr_api_const_pkg.SETTLEMENT_INTERNAL
                            , opr_api_const_pkg.SETTLEMENT_INTERNAL_INTERINST
                            , opr_api_const_pkg.SETTLEMENT_INTERNAL_INTRAINST
                            , opr_api_const_pkg.SETTLEMENT_USONUS
                            , opr_api_const_pkg.SETTLEMENT_USONUS_INTERINST
                            , opr_api_const_pkg.SETTLEMENT_USONUS_INTRAINST
                          )                                                         then 'internal'
                     when nvl(o.merchant_country, '1') = nvl(iss.card_country, '2') then 'domestic'
                                                                                    else 'international'
                 end
                     as dispute_type
               , case
                     when vsf.mcc   = vis_api_const_pkg.MCC_ATM
                       or mcf.de026 = mcw_api_const_pkg.MCC_ATM
                     then 1
                     else 0
                 end
                     as is_atm_case
            from      opr_operation   o
            left join opr_participant iss    on iss.oper_id          = o.id
                                            and iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
            left join mcw_fin         mcf    on mcf.id = o.id
            left join vis_fin_message vsf    on vsf.id = o.id
           where o.id               >= com_api_id_pkg.get_from_id(i_date => l_start_date - DATE_LAG)
             and o.id               <= com_api_id_pkg.get_from_id(i_date => l_end_date   + DATE_LAG)
             and trunc(o.oper_date) >= l_start_date
             and trunc(o.oper_date) <= l_end_date
             and o.dispute_id is not null
             and o.msg_type          = opr_api_const_pkg.MESSAGE_TYPE_CHARGEBACK
             and (mcf.id is not null or vsf.id is not null)
      )
     group by
           period
         , ips
         , dispute_source;

    if l_table is null then
        select xmlelement("record"
                 , xmlelement("period",         to_char(l_start_date, l_grouping_date_format))
                 , xmlelement("ips",            null)
                 , xmlelement("dispute_source", null)
                 , xmlelement("internal",       null)
                 , xmlelement("domestic",       null)
                 , xmlelement("international",  null)
                 , xmlelement("atm_cases",      null)
               )
          into l_table
          from dual;
    end if;

    select xmlelement("report"
             , (select xmlelement("header"
                         , xmlelement("report_datetime"
                             , to_char(sysdate(), DATETIME_FORMAT)
                           )
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
end new_issuing_cases;

/*
 * The report displays a number and total amount of the incoming/outgoing representments
 * and outgoing/incoming (arbitration )chargebacks processed by the issuer/acquirer
 * and grouped by message types and IPS.
 * Note. It is considered that settlement currency is the same for all dispute messages (items) for
 * some certain IPS and message type, so that if there are several values of currency in tables
 * of financial messages (vis_fin_message/mcw_fin), there will be several group results in the report.
 */
procedure items_grouped(
    o_xml                  out clob
  , i_participant_type  in     com_api_type_pkg.t_dict_value
  , i_grouping_period   in     com_api_type_pkg.t_dict_value
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.items_grouped ';
    DATE_LAG          constant pls_integer := 30; -- for calculation limits for OPR_OPERATION.ID by input dates
    l_start_date               date;
    l_end_date                 date;
    l_lang                     com_api_type_pkg.t_dict_value;
    l_grouping_date_format     com_api_type_pkg.t_oracle_name;
    l_table                    xmltype;
    -- Incoming/outgoing flags for messages of some types, they are inverted for an issuer and an acquirer
    l_incoming_represenment    com_api_type_pkg.t_boolean;
    l_incoming_chargeback      com_api_type_pkg.t_boolean;
begin
    l_lang       := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());
    -- Report generating is only allowed for a past period
    l_start_date := trunc(least(i_start_date, com_api_sttl_day_pkg.get_sysdate() - 1));
    l_end_date   := trunc(least(i_end_date,   com_api_sttl_day_pkg.get_sysdate() - 1))
                  + 1 - com_api_const_pkg.ONE_SECOND;

    l_grouping_date_format := case i_grouping_period
                                  when csm_api_const_pkg.GROUPING_PERIOD_MONTH then DATE_FORMAT_MONTH
                                  when csm_api_const_pkg.GROUPING_PERIOD_DAY   then DATE_FORMAT_DAY
                                                                               else DATE_FORMAT_DAY
                              end;

    if i_participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then
        l_incoming_represenment := com_api_const_pkg.TRUE;
        l_incoming_chargeback   := com_api_const_pkg.FALSE;
    else -- acquirer
        l_incoming_represenment := com_api_const_pkg.FALSE;
        l_incoming_chargeback   := com_api_const_pkg.TRUE;
    end if;

    select xmlagg(xmlelement("record"
             , xmlelement("period",          period)
             , xmlelement("ips",             ips)
             , xmlelement("dispute_message", dispute_message)
             , xmlelement("currency_code",   oper_currency)
             , xmlelement("oper_count",      count(*))
             , xmlelement("oper_amount",     com_api_currency_pkg.get_amount_str(
                                                 i_amount         => sum(oper_amount)
                                               , i_curr_code      => oper_currency
                                               , i_mask_curr_code => com_api_const_pkg.FALSE
                                               , i_format_mask    => null
                                               , i_mask_error     => com_api_const_pkg.FALSE
                                             ))
           ))
      into l_table
      from (
          select case
                     when vsf.id is not null then 'Visa'
                     when mcf.id is not null then 'MasterCard'
                 end
                     as ips
                 -- Grouping by a month or a day
               , to_char(o.oper_date, l_grouping_date_format)
                     as period
               , case
                     -- Visa
                     when vsf.usage_code  = '9'
                      and vsf.is_incoming = l_incoming_chargeback
                      and vsf.trans_code  in (
                              vis_api_const_pkg.TC_SALES_CHARGEBACK
                            , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
                            , vis_api_const_pkg.TC_CASH_CHARGEBACK
                            )                                                       then 'Dispute Financial'
                     when vsf.usage_code  = '9'
                      and vsf.is_incoming = l_incoming_chargeback
                      and vsf.trans_code  in (
                              vis_api_const_pkg.TC_SALES_CHARGEBACK_REV
                            , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV
                            , vis_api_const_pkg.TC_CASH_CHARGEBACK_REV
                            )                                                       then 'Dispute Financial Reversal'
                     when vsf.is_incoming = l_incoming_chargeback
                      and vsf.trans_code  = vis_api_const_pkg.TC_SALES_CHARGEBACK   then 'Sales Draft Chargeback'
                     when vsf.is_incoming = l_incoming_chargeback
                      and vsf.trans_code  = vis_api_const_pkg.TC_VOUCHER_CHARGEBACK then 'Credit Voucher Chargeback'
                     when vsf.is_incoming = l_incoming_chargeback
                      and vsf.trans_code  = vis_api_const_pkg.TC_CASH_CHARGEBACK    then 'Cash Disbursement Chargeback'
                     when vsf.is_incoming = l_incoming_chargeback
                      and vsf.trans_code  = vis_api_const_pkg.TC_SALES_CHARGEBACK_REV   then 'Sales Draft Chargeback Reversal'
                     when vsf.is_incoming = l_incoming_chargeback
                      and vsf.trans_code  = vis_api_const_pkg.TC_VOUCHER_CHARGEBACK_REV then 'Credit Voucher Chargeback Reversal'
                     when vsf.is_incoming = l_incoming_chargeback
                      and vsf.trans_code  = vis_api_const_pkg.TC_CASH_CHARGEBACK_REV    then 'Cash Disbursement Chargeback Reversal'
                     when vsf.is_incoming = l_incoming_represenment
                      and vsf.trans_code  in (
                              vis_api_const_pkg.TC_SALES
                            , vis_api_const_pkg.TC_VOUCHER
                            , vis_api_const_pkg.TC_CASH
                          )
                      and vsf.usage_code  = '9'                                     then 'Dispute Response Financial'
                     when vsf.is_incoming = l_incoming_represenment
                      and vsf.trans_code  in (
                              vis_api_const_pkg.TC_SALES_REVERSAL
                            , vis_api_const_pkg.TC_VOUCHER_REVERSAL
                            , vis_api_const_pkg.TC_CASH_REVERSAL
                          )
                      and vsf.usage_code  = '9'                                     then 'Dispute Response Financial Reversal'
                     when vsf.is_incoming = l_incoming_represenment
                      and vsf.trans_code  = vis_api_const_pkg.TC_SALES
                      and vsf.usage_code  = '2'                                     then 'Sales Draft Representment'
                     when vsf.is_incoming = l_incoming_represenment
                      and vsf.trans_code  = vis_api_const_pkg.TC_VOUCHER
                      and vsf.usage_code  = '2'                                     then 'Credit Voucher Representment'
                     when vsf.is_incoming = l_incoming_represenment
                      and vsf.trans_code  = vis_api_const_pkg.TC_CASH
                      and vsf.usage_code  = '2'                                     then 'Cash Disbursement Representment'
                     when vsf.is_incoming = l_incoming_represenment
                      and vsf.trans_code  = vis_api_const_pkg.TC_SALES_REVERSAL
                      and vsf.usage_code  = '2'                                     then 'Sales Draft Representment Reversal'
                     when vsf.is_incoming = l_incoming_represenment
                      and vsf.trans_code  = vis_api_const_pkg.TC_VOUCHER_REVERSAL
                      and vsf.usage_code  = '2'                                     then 'Credit Voucher Representment Reversal'
                     when vsf.is_incoming = l_incoming_represenment
                      and vsf.trans_code  = vis_api_const_pkg.TC_CASH_REVERSAL
                      and vsf.usage_code  = '2'                                     then 'Cash Disbursement Representment Reversal'

                     -- MasterCard
                     when mcf.is_incoming = l_incoming_chargeback
                      and mcf.mti         = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
                      and mcf.de024 in (
                              mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
                            , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
                          )                                                         then 'First Chargeback'
                     when mcf.is_incoming = l_incoming_represenment
                      and mcf.mti         = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
                      and mcf.de024 in (
                              mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
                            , mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_PART
                          )                                                         then 'Second Presentment'
                     when mcf.is_incoming = l_incoming_chargeback
                      and mcf.mti         = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
                      and mcf.de024 in (
                              mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
                            , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART
                          )                                                         then 'Arbitration Chargeback'
                 end
                     as dispute_message
               , case
                     when vsf.id is not null then nvl(vsf.sttl_currency, vsf.oper_currency)
                     when mcf.id is not null then nvl(mcf.de050,         mcf.de049)
                 end
                     as oper_currency
               , case
                     when vsf.id is not null then nvl(vsf.sttl_amount,   vsf.oper_amount)
                     when mcf.id is not null then nvl(mcf.de005,         mcf.de004)
                 end
                     as oper_amount
            from      opr_operation   o
            left join opr_participant iss    on iss.oper_id          = o.id
                                            and iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
            left join mcw_fin         mcf    on mcf.id = o.id
            left join vis_fin_message vsf    on vsf.id = o.id
           where o.id               >= com_api_id_pkg.get_from_id(i_date => l_start_date - DATE_LAG)
             and o.id               <= com_api_id_pkg.get_from_id(i_date => l_end_date   + DATE_LAG)
             and trunc(o.oper_date) >= l_start_date
             and trunc(o.oper_date) <= l_end_date
             and o.dispute_id is not null
             and (mcf.id is not null or vsf.id is not null)
      )
     where dispute_message is not null
     group by
           period
         , ips
         , dispute_message
         , oper_currency;

    if l_table is null then
        select xmlelement("record"
                 , xmlelement("period",          to_char(l_start_date, l_grouping_date_format))
                 , xmlelement("ips",             null)
                 , xmlelement("dispute_message", null)
                 , xmlelement("currency_code",   null)
                 , xmlelement("currency_name",   null)
                 , xmlelement("oper_amount",     null)
               )
          into l_table
          from dual;
    end if;

    select xmlelement("report"
             , (select xmlelement("header"
                         , xmlelement("report_datetime"
                             , to_char(sysdate(), DATETIME_FORMAT)
                           )
                         , xmlelement("participant_type"
                             , upper(
                                   com_api_dictionary_pkg.get_article_text(
                                       i_article => i_participant_type
                                     , i_lang    => l_lang
                                   )
                               )
                           )
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
            i_text       => LOG_PREFIX || '>> FAILED; i_grouping_period [#1], sqlerrm: ' || sqlerrm
          , i_env_param1 => i_grouping_period
        );
        raise;
end items_grouped;

procedure issuing_items_grouped(
    o_xml                  out clob
  , i_grouping_period   in     com_api_type_pkg.t_dict_value
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
begin
    items_grouped(
        o_xml               => o_xml
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_grouping_period   => i_grouping_period
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_lang              => i_lang
    );
end issuing_items_grouped;

procedure acquiring_items_grouped(
    o_xml                  out clob
  , i_grouping_period   in     com_api_type_pkg.t_dict_value
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
begin
    items_grouped(
        o_xml               => o_xml
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
      , i_grouping_period   => i_grouping_period
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_lang              => i_lang
    );
end acquiring_items_grouped;

/*
 * The report displays datailed information about incoming/outgoing dispute messages;
 * direction I/O depends on participant type (issuer/acquier).
 */
procedure items_not_grouped(
    o_xml                  out clob
  , i_participant_type  in     com_api_type_pkg.t_dict_value
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.items_not_grouped ';
    DATE_LAG          constant pls_integer := 30; -- for calculation limits for OPR_OPERATION.ID by input dates
    l_start_date               date;
    l_end_date                 date;
    l_lang                     com_api_type_pkg.t_dict_value;
    l_table                    xmltype;
    -- Incoming/outgoing flags for messages of some types, they are inverted for an issuer and an acquirer
    l_incoming_reprs_fee       com_api_type_pkg.t_boolean;
    l_incoming_rr_cbk_fee_frd  com_api_type_pkg.t_boolean;
begin
--    trc_log_pkg.debug(
--        i_text       => LOG_PREFIX || '<< i_participant_type [#4], i_start_date [#1], i_end_date [#2], i_lang [#3]'
--      , i_env_param1 => com_api_type_pkg.convert_to_char(i_start_date)
--      , i_env_param2 => com_api_type_pkg.convert_to_char(i_end_date)
--      , i_env_param3 => i_lang
--      , i_env_param4 => i_participant_type
--    );

    l_lang       := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());
    -- Report generating is only allowed for a past period
    l_start_date := trunc(least(i_start_date, com_api_sttl_day_pkg.get_sysdate() - 1));
    l_end_date   := trunc(least(i_end_date,   com_api_sttl_day_pkg.get_sysdate() - 1))
                  + 1 - com_api_const_pkg.ONE_SECOND;

    if i_participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then
        l_incoming_reprs_fee      := com_api_const_pkg.TRUE;
        l_incoming_rr_cbk_fee_frd := com_api_const_pkg.FALSE;
    else -- acquirer
        l_incoming_reprs_fee      := com_api_const_pkg.FALSE;
        l_incoming_rr_cbk_fee_frd := com_api_const_pkg.TRUE;
    end if;

    select xmlagg(xmlelement("record"
             , xmlelement("case_id",             (
                                                     select c.id
                                                       from csm_case c
                                                      where c.dispute_id = t.dispute_id
                                                 )
               )
             , xmlelement("direction",           t.direction)
             , xmlelement("card_number",         t.card_number)
             , xmlelement("dispute_message",     t.dispute_message)
             , xmlelement("oper_date",           t.oper_date)
             , xmlelement("oper_amount",         com_api_currency_pkg.get_amount_str(
                                                     i_amount         => t.oper_amount
                                                   , i_curr_code      => t.oper_currency
                                                   , i_mask_curr_code => com_api_const_pkg.FALSE
                                                   , i_format_mask    => null
                                                   , i_mask_error     => com_api_const_pkg.FALSE
                                                 ))
             , xmlelement("sttl_amount",         com_api_currency_pkg.get_amount_str(
                                                     i_amount         => t.sttl_amount
                                                   , i_curr_code      => t.sttl_currency
                                                   , i_mask_curr_code => com_api_const_pkg.FALSE
                                                   , i_format_mask    => null
                                                   , i_mask_error     => com_api_const_pkg.FALSE
                                                 ))
             , xmlelement("merchant_name",       t.merchant_name)
             , xmlelement("mcc",                 t.mcc)
             , xmlelement("reason_code",         t.reason_code)
             , xmlelement("member_msg_text",     t.member_msg_text)
             , xmlelement("document_indicator",  t.document_indicator)
           ))
      into l_table
      from (
          select o.dispute_id
               , case nvl(mcf.is_incoming, vsf.is_incoming)
                     when com_api_const_pkg.TRUE  then 'I' else 'O'
                 end
                                                                            as direction
               , iss_api_card_pkg.get_card_mask(
                     i_card_number => coalesce(
                                          vsf.card_mask
                                        , mcf.de002
                                        , (select max(oc.card_number)
                                             from opr_card oc
                                            where oc.oper_id = o.id)
                                      )
                 )                                                          as card_number
               , case
                     -- REPRS
                     when vsf.is_incoming = l_incoming_reprs_fee
                      and vsf.usage_code in ('2','9')
                      and vsf.trans_code in (
                              vis_api_const_pkg.TC_SALES
                            , vis_api_const_pkg.TC_VOUCHER
                            , vis_api_const_pkg.TC_CASH
                          )                                                         then 'REPRS'
                     when mcf.is_incoming = l_incoming_reprs_fee
                      and mcf.mti         = mcw_api_const_pkg.MSG_TYPE_PRESENTMENT
                      and mcf.de024 in (
                              mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_FULL
                            , mcw_api_const_pkg.FUNC_CODE_SECOND_PRES_PART
                          )                                                         then 'REPRS'
                     -- FEE (both incoming and outgoing messages)
                     when vsf.trans_code in (
                              vis_api_const_pkg.TC_FEE_COLLECTION
                          )                                                         then 'FEE'
                     when mcf.mti         = mcw_api_const_pkg.MSG_TYPE_FEE
                      and mcf.de024 in (
                              mcw_api_const_pkg.FUNC_CODE_MEMBER_FEE
                          )                                                         then 'FEE'
                     -- RR
                     when vsf.is_incoming = l_incoming_rr_cbk_fee_frd
                      and vsf.trans_code in (
                              vis_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY
                          )                                                         then 'RR'
                     when mcf.is_incoming = l_incoming_rr_cbk_fee_frd
                      and mcf.mti         = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                      and mcf.de024 in (
                              mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST
                          )                                                         then 'RR'
                     -- FRD
                     when vsf.is_incoming = l_incoming_rr_cbk_fee_frd
                      and vsf.trans_code in (
                              vis_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY
                          )                                                         then 'FRD'
                     -- CBK
                     when vsf.is_incoming = l_incoming_rr_cbk_fee_frd
                      and vsf.trans_code in (
                              vis_api_const_pkg.TC_SALES_CHARGEBACK
                            , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
                            , vis_api_const_pkg.TC_CASH_CHARGEBACK
                          )                                                         then 'CBK'
                     when mcf.is_incoming = l_incoming_rr_cbk_fee_frd
                      and mcf.mti         = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
                      and mcf.de024 in (
                              mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
                            , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
                          )                                                         then 'CBK'
                     -- ARBCBK
                     when mcf.is_incoming = l_incoming_rr_cbk_fee_frd
                      and mcf.mti         = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
                      and mcf.de024 in (
                              mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
                            , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART
                          )                                                         then 'ARBCBK'
                 end
                                                                            as dispute_message
               , to_char(o.oper_date, DATE_FORMAT_DAY)                      as oper_date
               , coalesce(mcf.de005, vsf.sttl_amount,   o.sttl_amount)      as sttl_amount
               , coalesce(mcf.de050, vsf.sttl_currency, o.sttl_currency)    as sttl_currency
               , coalesce(mcf.de004, vsf.oper_amount,   o.oper_amount)      as oper_amount
               , coalesce(mcf.de049, vsf.oper_currency, o.oper_currency)    as oper_currency
               , coalesce(
                     (select m.merchant_name
                        from acq_merchant m
                       where m.id = acq.merchant_id
                     )
                   , o.merchant_name
                 )                                                          as merchant_name
               , o.mcc                                                      as mcc
               , nvl(mcf.de025, vsf.reason_code)                            as reason_code
               , vsf.member_msg_text                                        as member_msg_text
               , nvl(to_char(mcf.p0262), vsf.docum_ind)                     as document_indicator
            from      opr_operation   o
            left join opr_participant iss    on iss.oper_id          = o.id
                                            and iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
            left join opr_participant acq    on acq.oper_id          = o.id
                                            and acq.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
            left join mcw_fin         mcf    on mcf.id = o.id
            left join vis_fin_message vsf    on vsf.id = o.id
           where o.id               >= com_api_id_pkg.get_from_id(i_date => l_start_date - DATE_LAG)
             and o.id               <= com_api_id_pkg.get_from_id(i_date => l_end_date   + DATE_LAG)
             and trunc(o.oper_date) >= l_start_date
             and trunc(o.oper_date) <= l_end_date
             and o.dispute_id is not null
             and (mcf.id is not null or vsf.id is not null)
      ) t
     where t.dispute_message is not null
     order by t.oper_date;

    if l_table is null then
        select xmlelement("record"
                 , xmlelement("case_id",             null)
                 , xmlelement("direction",           null)
                 , xmlelement("card_number",         null)
                 , xmlelement("dispute_message",     null)
                 , xmlelement("oper_date",           null)
                 , xmlelement("oper_amount",         null)
                 , xmlelement("sttl_amount",         null)
                 , xmlelement("merchant_name",       null)
                 , xmlelement("mcc",                 null)
                 , xmlelement("reason_code",         null)
                 , xmlelement("member_msg_text",     null)
                 , xmlelement("document_indicator",  null)
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
                             , to_char(l_start_date, DATE_FORMAT_DAY)
                               || ' - ' ||
                               to_char(l_end_date,   DATE_FORMAT_DAY)
                           )
                         , xmlelement("participant_type"
                             , upper(
                                   com_api_dictionary_pkg.get_article_text(
                                       i_article => i_participant_type
                                     , i_lang    => l_lang
                                   )
                               )
                           )
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
            i_text       => LOG_PREFIX || '>> FAILED; i_participant_type [#1], sqlerrm: ' || sqlerrm
          , i_env_param1 => i_participant_type
        );
        raise;
end items_not_grouped;

procedure issuing_items_not_grouped(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
begin
    items_not_grouped(
        o_xml               => o_xml
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_lang              => i_lang
    );
end issuing_items_not_grouped;

procedure acquiring_items_not_grouped(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
begin
    items_not_grouped(
        o_xml               => o_xml
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_lang              => i_lang
    );
end acquiring_items_not_grouped;

/*
 * The report displays a number and total amount of the incoming/outgoing (arbitration )chargebacks.
 * Note. It is considered that settlement currency is the same for all dispute messages (items) for
 * some certain IPS and message type, so that if there are several values of currency in tables
 * of financial messages (vis_fin_message/mcw_fin), there will be several group results in the report.
 */
procedure chargebacks_grouped(
    o_xml                  out clob
  , i_participant_type  in     com_api_type_pkg.t_dict_value
  , i_grouping_period   in     com_api_type_pkg.t_dict_value
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.chargeback_grouped ';
    DATE_LAG          constant pls_integer := 30; -- for calculation limits for OPR_OPERATION.ID by input dates
    l_start_date               date;
    l_end_date                 date;
    l_lang                     com_api_type_pkg.t_dict_value;
    l_grouping_date_format     com_api_type_pkg.t_oracle_name;
    l_table                    xmltype;
    -- Incoming/outgoing flag, it is inverted for an issuer and an acquirer
    l_incoming_chargeback      com_api_type_pkg.t_boolean;
begin
    l_lang       := coalesce(i_lang, com_ui_user_env_pkg.get_user_lang());
    -- Report generating is only allowed for a past period
    l_start_date := trunc(least(i_start_date, com_api_sttl_day_pkg.get_sysdate() - 1));
    l_end_date   := trunc(least(i_end_date,   com_api_sttl_day_pkg.get_sysdate() - 1))
                  + 1 - com_api_const_pkg.ONE_SECOND;

    l_grouping_date_format := case i_grouping_period
                                  when csm_api_const_pkg.GROUPING_PERIOD_MONTH then DATE_FORMAT_MONTH
                                  when csm_api_const_pkg.GROUPING_PERIOD_DAY   then DATE_FORMAT_DAY
                                                                               else DATE_FORMAT_DAY
                              end;

    if i_participant_type = com_api_const_pkg.PARTICIPANT_ISSUER then
        l_incoming_chargeback   := com_api_const_pkg.FALSE;
    else -- acquirer
        l_incoming_chargeback   := com_api_const_pkg.TRUE;
    end if;

    select xmlagg(xmlelement("record"
             , xmlelement("period",        period)
             , xmlelement("ips",           ips)
             , xmlelement("dispute_group", dispute_group)
             , xmlelement("sttl_currency", sttl_currency)
             , xmlelement("chbk_cnt",      sum(case msg_type
                                                   when aut_api_const_pkg.MESSAGE_TYPE_CHARGEBACK
                                                   then 1
                                                   else 0
                                               end))
             , xmlelement("chbk_amnt",     com_api_currency_pkg.get_amount_str(
                                               i_amount    => sum(case msg_type
                                                                      when aut_api_const_pkg.MESSAGE_TYPE_CHARGEBACK
                                                                      then sttl_amount
                                                                      else 0
                                                                  end)
                                             , i_curr_code => sttl_currency
                                           ))
             , xmlelement("arbt_chbk_cnt", sum(case msg_type
                                                   when aut_api_const_pkg.MESSAGE_TYPE_ARBITR_CHARGEBACK
                                                   then 1
                                                   else 0
                                               end))
             , xmlelement("arbt_chbk_amt", com_api_currency_pkg.get_amount_str(
                                               i_amount    => sum(case msg_type
                                                                      when aut_api_const_pkg.MESSAGE_TYPE_ARBITR_CHARGEBACK
                                                                      then sttl_amount
                                                                      else 0
                                                                  end)
                                             , i_curr_code => sttl_currency
                                           ))
           ))
      into l_table
      from (
          select case
                     when vsf.id is not null then 'Visa'
                     when mcf.id is not null then 'MasterCard'
                 end
                     as ips
                 -- Grouping by a month or a day
               , to_char(o.oper_date, l_grouping_date_format)
                     as period
               , case
                     -- Visa, chargeback
                     when vsf.is_incoming = l_incoming_chargeback
                      and vsf.trans_code  in (
                              vis_api_const_pkg.TC_SALES_CHARGEBACK
                            , vis_api_const_pkg.TC_VOUCHER_CHARGEBACK
                            , vis_api_const_pkg.TC_CASH_CHARGEBACK
                          )
                     then
                         aut_api_const_pkg.MESSAGE_TYPE_CHARGEBACK
                     -- MasterCard, chargeback
                     when mcf.is_incoming = l_incoming_chargeback
                      and mcf.mti         = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
                      and mcf.de024 in (
                              mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_FULL
                            , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK1_PART
                          )
                     then
                         aut_api_const_pkg.MESSAGE_TYPE_CHARGEBACK
                     -- MasterCard, arbitration chargeback
                     when mcf.is_incoming = l_incoming_chargeback
                      and mcf.mti         = mcw_api_const_pkg.MSG_TYPE_CHARGEBACK
                      and mcf.de024 in (
                              mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_FULL
                            , mcw_api_const_pkg.FUNC_CODE_CHARGEBACK2_PART
                          )
                     then
                         aut_api_const_pkg.MESSAGE_TYPE_ARBITR_CHARGEBACK
                 end
                     as msg_type
               , case
                     -- Visa
                     when vsf.reason_code in ('75')                                     then 'Request for information'
                     when vsf.reason_code in ('57', '62', '81', '83', '93', '10')       then 'Fraud'
                     when vsf.reason_code in ('70', '71', '72', '73', '78', '11')       then 'Authorization'
                     when vsf.reason_code in ('74', '76', '77', '80', '82', '86', '12') then 'Processing error'
                     when vsf.reason_code in ('41', '53', '85')                         then 'Cancelled/Returned'
                     when vsf.reason_code in ('30', '90')                               then 'Non-Receipt goods/services'
                     when vsf.reason_code in ('13')                                     then 'Consumer dispute'
                     -- MasterCard
                     when mcf.de025 in ('4807', '4808', '4812')                         then 'Authorization related'
                     when mcf.de025 in ('4841', '4853', '4855', '4859', '4860')         then 'Cardholder dispute'
                     when mcf.de025 in ('4837', '4840', '4849', '4863', '4870', '4871') then 'Fraud related'
                     when mcf.de025 in ('4831', '4834', '4842', '4846')                 then 'Point-of-Interaction error'
                     when mcf.de025 is not null                                         then 'Other'
                 end
                     as dispute_group
               , case
                     when vsf.id is not null then nvl(vsf.sttl_currency, vsf.oper_currency)
                     when mcf.id is not null then nvl(mcf.de050,         mcf.de049)
                 end
                     as sttl_currency
               , case
                     when vsf.id is not null then nvl(vsf.sttl_amount,   vsf.oper_amount)
                     when mcf.id is not null then nvl(mcf.de005,         mcf.de004)
                 end
                     as sttl_amount
            from      opr_operation   o
            left join opr_participant iss    on iss.oper_id          = o.id
                                            and iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
            left join mcw_fin         mcf    on mcf.id = o.id
            left join vis_fin_message vsf    on vsf.id = o.id
           where o.id               >= com_api_id_pkg.get_from_id(i_date => l_start_date - DATE_LAG)
             and o.id               <= com_api_id_pkg.get_from_id(i_date => l_end_date   + DATE_LAG)
             and trunc(o.oper_date) >= l_start_date
             and trunc(o.oper_date) <= l_end_date
             and o.dispute_id is not null
             and (mcf.id is not null or vsf.id is not null)
      )
     where msg_type is not null
     group by
           period
         , ips
         , dispute_group
         , sttl_currency;

    if l_table is null then
        select xmlelement("record"
                 , xmlelement("period",        to_char(l_start_date, l_grouping_date_format))
                 , xmlelement("ips",           null)
                 , xmlelement("dispute_group", null)
                 , xmlelement("sttl_currency", null)
                 , xmlelement("chbk_cnt",      null)
                 , xmlelement("chbk_amt",      null)
                 , xmlelement("arbt_chbk_cnt", null)
                 , xmlelement("arbt_chbk_amt", null)
               )
          into l_table
          from dual;
    end if;

    select xmlelement("report"
             , (select xmlelement("header"
                         , xmlelement("report_datetime"
                             , to_char(sysdate(), DATETIME_FORMAT)
                           )
                         , xmlelement("participant_type"
                             , upper(
                                   com_api_dictionary_pkg.get_article_text(
                                       i_article => i_participant_type
                                     , i_lang    => l_lang
                                   )
                               )
                           )
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
            i_text       => LOG_PREFIX || '>> FAILED; i_grouping_period [#1], sqlerrm: ' || sqlerrm
          , i_env_param1 => i_grouping_period
        );
        raise;
end chargebacks_grouped;

procedure issuing_chargebacks_grouped(
    o_xml                  out clob
  , i_grouping_period   in     com_api_type_pkg.t_dict_value
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
begin
    chargebacks_grouped(
        o_xml               => o_xml
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_grouping_period   => i_grouping_period
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_lang              => i_lang
    );
end issuing_chargebacks_grouped;

procedure acquiring_chargebacks_grouped(
    o_xml                  out clob
  , i_grouping_period   in     com_api_type_pkg.t_dict_value
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
begin
    chargebacks_grouped(
        o_xml               => o_xml
      , i_participant_type  => com_api_const_pkg.PARTICIPANT_ACQUIRER
      , i_grouping_period   => i_grouping_period
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_lang              => i_lang
    );
end acquiring_chargebacks_grouped;

/*
 * The report displays detail information about retrieval requests for both
 * an acquirer (incoming) and an issuer (outgoing) without grouping.
 */
procedure retrieval_requests_daily(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.retrieval_requests_daily ';
    DATE_LAG          constant pls_integer := 30; -- for calculation limits for OPR_OPERATION.ID by input dates
    l_start_date               date;
    l_end_date                 date;
    l_table                    xmltype;
begin
    -- Report generating is only allowed for a past period
    l_start_date := trunc(least(i_start_date, com_api_sttl_day_pkg.get_sysdate() - 1));
    l_end_date   := trunc(least(i_end_date,   com_api_sttl_day_pkg.get_sysdate() - 1))
                  + 1 - com_api_const_pkg.ONE_SECOND;

    select xmlagg(xmlelement("record"
             , xmlelement("case_id",             case_id)
             , xmlelement("direction",           direction)
             , xmlelement("card_number",         card_number)
             , xmlelement("oper_date",           oper_date)
             , xmlelement("oper_amount",         com_api_currency_pkg.get_amount_str(
                                                     i_amount         => oper_amount
                                                   , i_curr_code      => oper_currency
                                                   , i_mask_curr_code => com_api_const_pkg.FALSE
                                                   , i_format_mask    => null
                                                   , i_mask_error     => com_api_const_pkg.FALSE
                                                 ))
             , xmlelement("sttl_amount",         com_api_currency_pkg.get_amount_str(
                                                     i_amount         => sttl_amount
                                                   , i_curr_code      => sttl_currency
                                                   , i_mask_curr_code => com_api_const_pkg.FALSE
                                                   , i_format_mask    => null
                                                   , i_mask_error     => com_api_const_pkg.FALSE
                                                 ))
             , xmlelement("merchant_name",       merchant_name)
             , xmlelement("mcc",                 mcc)
             , xmlelement("reason_code",         reason_code)
           ))
      into l_table
      from (
          select o.dispute_id                                               as case_id
               , case nvl(mcf.is_incoming, vsf.is_incoming)
                     when com_api_const_pkg.TRUE  then 'I' else 'O'
                 end
                                                                            as direction
               , iss_api_card_pkg.get_card_mask(
                     i_card_number => coalesce(
                                          vsf.card_mask
                                        , mcf.de002
                                        , (select max(oc.card_number)
                                             from opr_card oc
                                            where oc.oper_id = o.id)
                                      )
                 )                                                          as card_number
               , to_char(o.oper_date, DATE_FORMAT_DAY)                      as oper_date
               , coalesce(mcf.de005, vsf.sttl_amount,   o.sttl_amount)      as sttl_amount
               , coalesce(mcf.de050, vsf.sttl_currency, o.sttl_currency)    as sttl_currency
               , coalesce(mcf.de004, vsf.oper_amount,   o.oper_amount)      as oper_amount
               , coalesce(mcf.de049, vsf.oper_currency, o.oper_currency)    as oper_currency
               , coalesce(
                     (select m.merchant_name
                        from acq_merchant m
                       where m.id = acq.merchant_id
                     )
                   , o.merchant_name
                 )                                                          as merchant_name
               , o.mcc                                                      as mcc
               , nvl(mcf.de025, vsf.reason_code)                            as reason_code
            from      opr_operation   o
            left join opr_participant iss    on iss.oper_id          = o.id
                                            and iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
            left join opr_participant acq    on acq.oper_id          = o.id
                                            and acq.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
            left join mcw_fin         mcf    on mcf.id = o.id
            left join vis_fin_message vsf    on vsf.id = o.id
           where o.id               >= com_api_id_pkg.get_from_id(i_date => l_start_date - DATE_LAG)
             and o.id               <= com_api_id_pkg.get_from_id(i_date => l_end_date   + DATE_LAG)
             and trunc(o.oper_date) >= l_start_date
             and trunc(o.oper_date) <= l_end_date
             and o.dispute_id is not null
             and (mcf.id is not null or vsf.id is not null)
             and case
                     when vsf.trans_code in (
                              vis_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY
                          )                                                         then 'RR'
                     when mcf.mti         = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                      and mcf.de024 in (
                              mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST
                          )                                                         then 'RR'
                 end = 'RR'
      )
     order by
           oper_date
         , direction
         , card_number;

    if l_table is null then
        select xmlelement("record"
                 , xmlelement("case_id",             null)
                 , xmlelement("direction",           null)
                 , xmlelement("card_number",         null)
                 , xmlelement("oper_date",           null)
                 , xmlelement("oper_amount",         null)
                 , xmlelement("sttl_amount",         null)
                 , xmlelement("merchant_name",       null)
                 , xmlelement("mcc",                 null)
                 , xmlelement("reason_code",         null)
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
                             , to_char(l_start_date, DATE_FORMAT_DAY)
                               || ' - ' ||
                               to_char(l_end_date,   DATE_FORMAT_DAY)
                           )
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
end retrieval_requests_daily;

/*
 * The report displays a number and total amount of retrieval requests for both
 * an acquirer (incoming) and an issuer (outgoing) grouped by dispute side and IPS.
 */
procedure retrieval_requests_monthly(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.retrieval_requests_mothly ';
    DATE_LAG          constant pls_integer := 30; -- for calculation limits for OPR_OPERATION.ID by input dates
    l_start_date               date;
    l_end_date                 date;
    l_table                    xmltype;
begin
    -- Report generating is only allowed for a past period
    l_start_date := trunc(least(i_start_date, com_api_sttl_day_pkg.get_sysdate() - 1));
    l_end_date   := trunc(least(i_end_date,   com_api_sttl_day_pkg.get_sysdate() - 1))
                  + 1 - com_api_const_pkg.ONE_SECOND;

    select xmlagg(xmlelement("record"
             , xmlelement("period",           period)
             , xmlelement("ips",              ips)
             , xmlelement("participant_type", participant_type)
             , xmlelement("currency_code",    oper_currency)
             , xmlelement("oper_count",       count(*))
             , xmlelement("oper_amount",      com_api_currency_pkg.get_amount_str(
                                                  i_amount         => sum(oper_amount)
                                                , i_curr_code      => oper_currency
                                                , i_mask_curr_code => com_api_const_pkg.FALSE
                                                , i_format_mask    => null
                                                , i_mask_error     => com_api_const_pkg.FALSE
                                              ))
           ))
      into l_table
      from (
          select case
                     when vsf.id is not null then 'Visa'
                     when mcf.id is not null then 'MasterCard'
                 end
                     as ips
                 -- Grouping by a month; there will be several period
                 -- if interval [start_date; end_date] is not within a single month
               , to_char(o.oper_date, DATE_FORMAT_MONTH)
                     as period
               , case
                     when nvl(mcf.is_incoming, vsf.is_incoming) = com_api_const_pkg.TRUE
                     then 'Acquirer'
                     else 'Issuer'
                 end
                     as participant_type
               , case
                     when vsf.id is not null then nvl(vsf.sttl_currency, vsf.oper_currency)
                     when mcf.id is not null then nvl(mcf.de050,         mcf.de049)
                 end
                     as oper_currency
               , case
                     when vsf.id is not null then nvl(vsf.sttl_amount,   vsf.oper_amount)
                     when mcf.id is not null then nvl(mcf.de005,         mcf.de004)
                 end
                     as oper_amount
            from      opr_operation   o
            left join opr_participant iss    on iss.oper_id          = o.id
                                            and iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
            left join mcw_fin         mcf    on mcf.id = o.id
            left join vis_fin_message vsf    on vsf.id = o.id
           where o.id               >= com_api_id_pkg.get_from_id(i_date => l_start_date - DATE_LAG)
             and o.id               <= com_api_id_pkg.get_from_id(i_date => l_end_date   + DATE_LAG)
             and trunc(o.oper_date) >= l_start_date
             and trunc(o.oper_date) <= l_end_date
             and o.dispute_id is not null
             and (mcf.id is not null or vsf.id is not null)
             and case
                     when vsf.trans_code in (
                              vis_api_const_pkg.TC_REQUEST_FOR_PHOTOCOPY
                          )                                                         then 'RR'
                     when mcf.mti         = mcw_api_const_pkg.MSG_TYPE_ADMINISTRATIVE
                      and mcf.de024 in (
                              mcw_api_const_pkg.FUNC_CODE_RETRIEVAL_REQUEST
                          )                                                         then 'RR'
                 end = 'RR'
      )
     group by
           period
         , ips
         , participant_type
         , oper_currency
     order by
           period
         , ips
         , participant_type desc
         , oper_currency;

    if l_table is null then
        select xmlelement("record"
                 , xmlelement("period",           to_char(l_start_date, DATE_FORMAT_MONTH))
                 , xmlelement("ips",              null)
                 , xmlelement("participant_type", null)
                 , xmlelement("currency_code",    null)
                 , xmlelement("oper_count",       null)
                 , xmlelement("oper_amount",      null)
               )
          into l_table
          from dual;
    end if;

    select xmlelement("report"
             , (select xmlelement("header"
                         , xmlelement("report_datetime"
                             , to_char(sysdate(), DATETIME_FORMAT)
                           )
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
end retrieval_requests_monthly;

/*
 * The report displays final accounting entries that may be qualified as
 * 'Credit card account' and 'Debit merchant/ATM account'.
 */
procedure accounting_transactions(
    o_xml                  out clob
  , i_grouping_period   in     com_api_type_pkg.t_dict_value
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.accounting_transactions ';
    DATE_LAG          constant pls_integer := 60; -- for calculation limits for OPR_OPERATION.ID by input dates
    l_start_date               date;
    l_end_date                 date;
    l_grouping_date_format     com_api_type_pkg.t_oracle_name;
    l_table                    xmltype;
begin
    -- Report generating is only allowed for a past period
    l_start_date := trunc(least(i_start_date, com_api_sttl_day_pkg.get_sysdate() - 1));
    l_end_date   := trunc(least(i_end_date,   com_api_sttl_day_pkg.get_sysdate() - 1))
                  + 1 - com_api_const_pkg.ONE_SECOND;

    l_grouping_date_format := case i_grouping_period
                                  when csm_api_const_pkg.GROUPING_PERIOD_MONTH then DATE_FORMAT_MONTH
                                  when csm_api_const_pkg.GROUPING_PERIOD_DAY   then DATE_FORMAT_DAY
                                                                               else DATE_FORMAT_DAY
                              end;

    select xmlagg(xmlelement("record"
             , xmlelement("period",          v.period)
             , xmlelement("case_id",         v.case_id)
             , xmlelement("account_number",  acc.account_number)
             , xmlelement("card_number",     iss_api_card_pkg.get_card_mask(i_card_number => v.card_number))
             , xmlelement("account_type",    case v.participant_type
                                                 when com_api_const_pkg.PARTICIPANT_ISSUER
                                                 then 'Credit card account'
                                                 when com_api_const_pkg.PARTICIPANT_ACQUIRER
                                                 then 'Debit merchant/ATM account'
                                             end)
             , xmlelement("entry_currency",  v.entry_currency)
             , xmlelement("entry_amount",    com_api_currency_pkg.get_amount_str(
                                                 i_amount         => v.entry_amount
                                               , i_curr_code      => v.entry_currency
                                               , i_mask_curr_code => com_api_const_pkg.FALSE
                                               , i_format_mask    => null
                                               , i_mask_error     => com_api_const_pkg.FALSE
                                             ))
           ))
      into l_table
      from (
          select -- Grouping by a month or a day
                 to_char(opr.oper_date, l_grouping_date_format)                     as period
               , opr.dispute_id                                                     as case_id
               , max(crd.card_number)                                               as card_number -- exception NULLs
               , prtp.participant_type                                              as participant_type
               , prtp.account_id                                                    as account_id
                 -- Get amount/currency of a last entry
               , max(entr.amount)
                     keep (dense_rank first order by entr.posting_order)            as entry_amount
               , max(entr.currency)
                     keep (dense_rank first order by entr.posting_order)            as entry_currency
            from      opr_operation    opr
            left join opr_card         crd   on crd.oper_id         = opr.id
                 join opr_participant prtp   on prtp.oper_id        = opr.id
                                            and prtp.participant_type in (
                                                    com_api_const_pkg.PARTICIPANT_ISSUER
                                                  , com_api_const_pkg.PARTICIPANT_ACQUIRER
                                                )
                 join acc_macros       mcs   on mcs.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                            and mcs.object_id       = opr.id
            -- Join credit entries for an issuing account and debit ones for an acquiring account
                 join acc_entry       entr   on entr.macros_id      = mcs.id
                                            and entr.account_id     = prtp.account_id
                                            and entr.split_hash     = prtp.split_hash
                                            and entr.balance_impact = case prtp.participant_type
                                                                          when com_api_const_pkg.PARTICIPANT_ISSUER
                                                                          then com_api_type_pkg.CREDIT
                                                                          when com_api_const_pkg.PARTICIPANT_ACQUIRER
                                                                          then com_api_type_pkg.DEBIT
                                                                      end
           where opr.id               >= com_api_id_pkg.get_from_id(i_date => l_start_date - DATE_LAG)
             and opr.id               <= com_api_id_pkg.get_from_id(i_date => l_end_date   + DATE_LAG)
             and trunc(opr.oper_date) >= l_start_date
             and trunc(opr.oper_date) <= l_end_date
             and opr.dispute_id is not null
        group by to_char(opr.oper_date, l_grouping_date_format)
               , opr.dispute_id
               , prtp.participant_type
               , prtp.account_id
      ) v
      join acc_account acc    on acc.id = v.account_id
    ;

    if l_table is null then
        select xmlelement("record"
                 , xmlelement("period",          to_char(l_start_date, l_grouping_date_format))
                 , xmlelement("case_id",         null)
                 , xmlelement("account_number",  null)
                 , xmlelement("card_number",     null)
                 , xmlelement("account_type",    null)
                 , xmlelement("entry_currency",  null)
                 , xmlelement("entry_amount",    null)
               )
          into l_table
          from dual;
    end if;

    select xmlelement("report"
             , (select xmlelement("header"
                         , xmlelement("report_datetime"
                             , to_char(sysdate(), DATETIME_FORMAT)
                           )
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
            i_text       => LOG_PREFIX || '>> FAILED; i_grouping_period [#1], sqlerrm: ' || sqlerrm
          , i_env_param1 => i_grouping_period
        );
        raise;
end accounting_transactions;

procedure accounting_transactions_day(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
begin
    accounting_transactions(
        o_xml               => o_xml
      , i_grouping_period   => csm_api_const_pkg.GROUPING_PERIOD_DAY
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_lang              => i_lang
    );
end accounting_transactions_day;

procedure accounting_transactions_month(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
begin
    accounting_transactions(
        o_xml               => o_xml
      , i_grouping_period   => csm_api_const_pkg.GROUPING_PERIOD_MONTH
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_lang              => i_lang
    );
end accounting_transactions_month;

procedure cases_by_team(
    o_xml                  out clob
  , i_team              in     com_api_type_pkg.t_tiny_id
  , i_inst_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_network_id        in     com_api_type_pkg.t_tiny_id       default null
  , i_participant_type  in     com_api_type_pkg.t_dict_value
  , i_start_date        in     date                             default null
  , i_end_date          in     date                             default null
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.cases_by_team: ';
    
    l_result                   xmltype;
    l_header                   xmltype;
    l_detail                   xmltype;
    l_start_date               date;
    l_end_date                 date;

begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'start, i_team [' || i_team || '] i_inst_id [' || i_inst_id || '] i_network_id [' || i_network_id || ' i_participant_type [' || i_participant_type ||
                  '] i_start_date [' || i_start_date || '] i_end_date [' || i_end_date || ']'
    );
    
    l_start_date := nvl(i_start_date, trunc(sysdate));
    l_end_date   := nvl(i_end_date, trunc(sysdate) + 1 - com_api_const_pkg.ONE_SECOND);
        
    -- process here
        
    -- header
    select xmlelement ("header",
                         xmlelement("p_head", 'CASES ASSIGNED TO THE SETTLEMENT TEAM - '
                          || case i_participant_type
                                 when com_api_const_pkg.PARTICIPANT_ACQUIRER then
                                     'ACQUIRER'
                                 when com_api_const_pkg.PARTICIPANT_ISSUER then
                                     'ISSUER'
                             end
                          || ' FOR '
                          || to_char(l_start_date, 'DD/MM/YYYY') || '-' || to_char(l_end_date, 'DD/MM/YYYY'))
                       , xmlelement("p_execdate" , to_char(sysdate, DATETIME_FORMAT))
                      )
    into l_header from dual;

    -- code for filling l_details
    with rawdata as (
       select
              case csm_api_case_pkg.get_card_category(
                       i_case_id => cc.id
                   )
                   when 1 then 'VISA'
                   when 2 then 'MasterCard'
                   when 3 then 'Maestro'
                   else ''
              end                                                               as ips
            , case
                  when app.flow_id =  app_api_const_pkg.FLOW_ID_DISPUTE_INTERNAL then
                      'internal'
                  when app.flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_DOMESTIC, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC) then
                      'domestic'
                  when app.flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_INTERNTNL, app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL) then
                      'international'
              end                                                               as categoty
            , cc.id                                                             as case_id
            , iss_api_card_pkg.get_card_mask(i_card_number => card.card_number) as card_number
            , cc.created_date                                                   as created_on
            , com_api_currency_pkg.get_amount_str(
                  i_amount     => cc.disputed_amount
                , i_curr_code  => cc.disputed_currency
                , i_mask_error => com_api_const_pkg.TRUE
              )                                                                 as disputed_summ
            , com_api_currency_pkg.get_amount_str(
                  i_amount     => cc.base_amount
                , i_curr_code  => cc.base_currency
                , i_mask_error => com_api_const_pkg.TRUE
              )                                                                 as base_summ
            , cc.merchant_name                                                  as merchant_name
            , o.mcc                                                             as mcc
            , cc.reason_code                                                    as reason_code
         from csm_case cc
         left join csm_card card on card.id = cc.id
         join app_application app on app.id = cc.id
          and app.appl_type = app_api_const_pkg.APPL_TYPE_DISPUTE
          and app.appl_status != APP_API_CONST_PKG.APPL_STATUS_CLOSED
         join (select op.id
                    , op.mcc
                    , op.dispute_id
                 from opr_operation op
                    , opr_participant p
                where op.dispute_id      is not null
                  and p.oper_id          = op.id
                  and p.participant_type = i_participant_type
                  and (network_id = i_network_id or i_network_id is null)
              ) o on o.id = cc.original_id
        where (cc.inst_id = i_inst_id or i_inst_id is null)
          and cc.team_id in (i_team)
        order by cc.inst_id
               , ips
               , categoty
    )
    select xmlelement("table"
             , xmlagg(
                   xmlelement("record"
                     , xmlelement("ips"          , ips)
                     , xmlelement("categoty"     , categoty)
                     , xmlelement("case_id"      , case_id)
                     , xmlelement("card_number"  , card_number)
                     , xmlelement("created_on"   , created_on)
                     , xmlelement("disputed_summ", disputed_summ)
                     , xmlelement("base_summ"    , base_summ)
                     , xmlelement("merchant_name", merchant_name)
                     , xmlelement("mcc"          , mcc)
                     , xmlelement("reason_code"  , reason_code)
                   )
               )
           )
    into l_detail
    from rawdata;

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                 , xmlagg(
                       xmlelement("record"
                         , xmlelement("ips"          , null)
                         , xmlelement("categoty"     , null)
                         , xmlelement("case_id"      , null)
                         , xmlelement("card_number"  , null)
                         , xmlelement("created_on"   , null)
                         , xmlelement("disputed_summ", null)
                         , xmlelement("base_summ"    , null)
                         , xmlelement("mcc"          , null)
                         , xmlelement("reason_code"  , null)
                       )
                   )
               )
          into l_detail
          from dual;
    end if;
        
    select xmlelement("report"
         , l_header
         , l_detail
           )
      into l_result
      from dual;
        
    o_xml := l_result.getclobval;
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'end '
    );
exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '>> FAILED; i_team [#1], sqlerrm: ' || sqlerrm
          , i_env_param1 => i_team
        );
        raise;    
end cases_by_team;

procedure cases_by_team_acq(
    o_xml                  out clob
  , i_team              in     com_api_type_pkg.t_tiny_id
  , i_inst_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_network_id        in     com_api_type_pkg.t_tiny_id       default null
  , i_start_date        in     date                             default null
  , i_end_date          in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
) is
begin
    cases_by_team(
        o_xml              => o_xml
      , i_team             => i_team
      , i_inst_id          => i_inst_id
      , i_network_id       => i_network_id
      , i_participant_type => com_api_const_pkg.PARTICIPANT_ACQUIRER
      , i_start_date       => i_start_date
      , i_end_date         => i_end_date
    );
end cases_by_team_acq;

procedure cases_by_team_iss(
    o_xml                  out clob
  , i_team              in     com_api_type_pkg.t_tiny_id
  , i_inst_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_network_id        in     com_api_type_pkg.t_tiny_id       default null
  , i_start_date        in     date                             default null
  , i_end_date          in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
) is
begin
    cases_by_team(
        o_xml              => o_xml
      , i_team             => i_team
      , i_inst_id          => i_inst_id
      , i_network_id       => i_network_id
      , i_participant_type => com_api_const_pkg.PARTICIPANT_ISSUER
      , i_start_date       => i_start_date
      , i_end_date         => i_end_date
    );
end cases_by_team_iss;

procedure late_presented_trans_acq(
    o_xml                  out clob
  , i_count_days        in     com_api_type_pkg.t_tiny_id
  , i_inst_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_card_type_id      in     com_api_type_pkg.t_tiny_id       default null
  , i_network_id        in     com_api_type_pkg.t_tiny_id       default null
  , i_start_date        in     date                             default null
  , i_end_date          in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.late_presented_trans_acq: ';
    
    l_result                   xmltype;
    l_header                   xmltype;
    l_detail                   xmltype;
    l_start_date               date;
    l_end_date                 date;
    
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'start, i_count_days [' || i_count_days || '] i_inst_id [' || i_inst_id || '] i_network_id [' || i_network_id || ' i_card_type_id [' || i_card_type_id ||
                  '] i_start_date [' || i_start_date || '] i_end_date [' || i_end_date || ']'
    );
    
    if i_network_id is not null and (i_network_id not in (mcw_api_const_pkg.MCW_NETWORK_ID, vis_api_const_pkg.VISA_NETWORK_ID)) then
        com_api_error_pkg.raise_error(
            i_error       => 'UNSUPPORTED_NETWORK'
          , i_env_param1  => i_network_id
        );
    end if;
    
    l_start_date := nvl(i_start_date, trunc(sysdate));
    l_end_date   := nvl(i_end_date, trunc(sysdate) + 1 - com_api_const_pkg.ONE_SECOND);
    
    -- header
    select xmlelement ("header",
                         xmlelement("p_head", 'LATE PRESENTED TRANSACTIONS – ACQUIRER FOR '  
                          || to_char(l_start_date, 'DD/MM/YYYY') || '-' || to_char(l_end_date, 'DD/MM/YYYY'))
                       , xmlelement("p_execdate" , to_char(sysdate, DATETIME_FORMAT))
                      )               
      into l_header
      from dual;
    
    -- code for filling l_details
    with rawdata as (
        select ips
             , card_number
             , to_char(oper_date, 'DD/MM/YYYY')   oper_date
             , to_char(upload_date, 'DD/MM/YYYY') upload_date
             , oper_summ
             , merchant_name
             , mcc
             , terminal_number
             , merchant_number
             , auth_code
          from (        
            select
                   case par.network_id
                       when mcw_api_const_pkg.MCW_NETWORK_ID then 
                           'MasterCard/Maestro'
                       when vis_api_const_pkg.VISA_NETWORK_ID then 
                           'Visa'
                       else null    
                   end                                                  as ips
                 , iss_api_card_pkg.get_card_mask(
                       i_card_number => ca.card_number
                   )                                                    as card_number
                 , o.oper_date                                          as oper_date
                 , case i_network_id 
                       when mcw_api_const_pkg.MCW_NETWORK_ID
                           then mfile.proc_date
                       when vis_api_const_pkg.VISA_NETWORK_ID
                           then vfile.proc_date
                       else
                           nvl(mfile.proc_date, vfile.proc_date) 
                   end                                                  as upload_date 
                 , com_api_currency_pkg.get_amount_str(
                       i_amount     => o.oper_amount
                     , i_curr_code  => o.oper_currency
                     , i_mask_error => com_api_const_pkg.TRUE
                   )                                                    as oper_summ
                 , o.merchant_name                                      as merchant_name
                 , o.mcc                                                as mcc
                 , o.terminal_number                                    as terminal_number
                 , o.merchant_number                                    as merchant_number
                 , par.auth_code                                        as auth_code
                 , par.inst_id                                          as inst_id
                 , par.card_type_id                                     as card_type_id
             from opr_operation o
             join opr_participant par on par.oper_id = o.id
                                     and par.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                                     and (par.inst_id = i_inst_id or i_inst_id is null)
                                     and (par.network_id = i_network_id or i_network_id is null)
                                     and (par.card_type_id = i_card_type_id or i_card_type_id is null)        
             left join opr_card ca on ca.oper_id = o.id
                                  and ca.participant_type = par.participant_type
             left join mcw_fin  mf on mf.id = o.id
                                   and (i_network_id = mcw_api_const_pkg.MCW_NETWORK_ID or i_network_id is null)                  
             left join mcw_file mfile on mf.file_id = mfile.id
                                     and (i_network_id = mcw_api_const_pkg.MCW_NETWORK_ID or i_network_id is null)
             left join vis_fin_message vf on vf.id = o.id 
                                         and (i_network_id = vis_api_const_pkg.VISA_NETWORK_ID or i_network_id is null)
             left join vis_file vfile on vf.file_id = vfile.id
                                     and (i_network_id = vis_api_const_pkg.VISA_NETWORK_ID or i_network_id is null)
            where o.msg_type = opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
              and o.sttl_type = opr_api_const_pkg.SETTLEMENT_THEMONUS
              and o.oper_date between l_start_date and l_end_date       
            )
         where upload_date > oper_date + i_count_days
         order by ips, inst_id, card_type_id
    ) 
    select xmlelement("table"
             , xmlagg(
                   xmlelement("record"
                     , xmlelement("ips"             , ips)
                     , xmlelement("card_number"     , card_number)
                     , xmlelement("oper_date"       , oper_date)
                     , xmlelement("upload_date"     , upload_date)
                     , xmlelement("oper_summ"       , oper_summ)
                     , xmlelement("merchant_name"   , merchant_name)
                     , xmlelement("mcc"             , mcc)
                     , xmlelement("terminal_number" , terminal_number)
                     , xmlelement("merchant_number" , merchant_number)
                     , xmlelement("auth_code"       , auth_code)
                   )
              )
            )
       into l_detail 
       from rawdata;        
    
    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                 , xmlagg(
                       xmlelement("record"
                         , xmlelement("ips"             , null)
                         , xmlelement("card_number"     , null)
                         , xmlelement("oper_date"       , null)
                         , xmlelement("upload_date"     , null)
                         , xmlelement("oper_summ"       , null)
                         , xmlelement("merchant_name"   , null)
                         , xmlelement("mcc"             , null)
                         , xmlelement("terminal_number" , null)
                         , xmlelement("merchant_number" , null)
                         , xmlelement("auth_code"       , null)
                       )
                   )
               )
          into l_detail
          from dual;
    end if;
        
    select xmlelement("report"
         , l_header
         , l_detail
           )
      into l_result
      from dual;
        
    o_xml := l_result.getclobval;
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'end '
    );
exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '>> FAILED; i_count_days [#1], sqlerrm: ' || sqlerrm
          , i_env_param1 => i_count_days
        );
        raise; 
end late_presented_trans_acq;

procedure late_presented_trans_iss(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_network_id        in     com_api_type_pkg.t_tiny_id       default null
  , i_start_date        in     date                             default null
  , i_end_date          in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.late_presented_trans_iss: ';
    
    l_result                   xmltype;
    l_header                   xmltype;
    l_detail                   xmltype;
    l_start_date               date;
    l_end_date                 date;
begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'start, i_inst_id [' || i_inst_id || '] i_network_id [' || i_network_id || 
                  '] i_start_date [' || i_start_date || '] i_end_date [' || i_end_date || ']'
    );
    
    if i_network_id is not null and (i_network_id not in (mcw_api_const_pkg.MCW_NETWORK_ID, vis_api_const_pkg.VISA_NETWORK_ID)) then
        com_api_error_pkg.raise_error(
            i_error       => 'UNSUPPORTED_NETWORK'
          , i_env_param1  => i_network_id
        );
    end if;
    
    l_start_date := nvl(i_start_date, trunc(sysdate));
    l_end_date   := nvl(i_end_date, trunc(sysdate) + 1 - com_api_const_pkg.ONE_SECOND);
    
    -- header
    select xmlelement ("header",
                         xmlelement("p_head", 'LATE PRESENTED TRANSACTIONS – ISSUER FOR '  
                          || to_char(l_start_date, 'DD/MM/YYYY') || '-' || to_char(l_end_date, 'DD/MM/YYYY'))
                       , xmlelement("p_execdate" , to_char(sysdate, DATETIME_FORMAT))
                      )               
    into l_header from dual;
    
    -- code for filling l_details    
    with rawdata as (
        select 
               case par.network_id
                   when mcw_api_const_pkg.MCW_NETWORK_ID then
                       'Mastercard/Maestro'
                   when vis_api_const_pkg.VISA_NETWORK_ID then 
                       'Visa'
                   else null    
               end                                                  as ips
             , to_char(o.oper_date, 'DD/MM/YYYY')                   as oper_date
             , iss_api_card_pkg.get_card_mask(
                   i_card_number => ca.card_number
               )                                                    as card_number
             , com_api_currency_pkg.get_amount_str(
                   i_amount     => o.oper_amount
                 , i_curr_code  => o.oper_currency
                 , i_mask_error => com_api_const_pkg.TRUE
               )                                                    as oper_summ
             , o.merchant_name                                      as merchant_name
             , o.mcc                                                as mcc
             , o.terminal_number                                    as terminal_number
             , o.merchant_number                                    as merchant_number
             , par.auth_code                                        as auth_code
             , o.acq_inst_bin                                       as acq_inst_bin
          from opr_operation o
          join opr_participant par on o.id = par.oper_id 
                                  and par.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                                  and (par.inst_id = i_inst_id or i_inst_id is null)
                                  and (par.network_id = i_network_id or i_network_id is null)
          join opr_card ca on ca.oper_id = o.id
                          and ca.participant_type = par.participant_type
         where o.msg_type      = opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
           and o.status        = OPR_API_CONST_PKG.OPERATION_STATUS_UNHOLDED
           and o.status_reason =  AUT_API_CONST_PKG.AUTH_REASON_UNHOLD_AUTO
           and o.oper_date between l_start_date and l_end_date
         order by ips, par.inst_id 
    ) 
    select xmlelement("table"
             , xmlagg(
                   xmlelement("record"
                     , xmlelement("ips"             , ips)                         
                     , xmlelement("oper_date"       , oper_date)
                     , xmlelement("card_number"     , card_number)                         
                     , xmlelement("oper_summ"       , oper_summ)
                     , xmlelement("merchant_name"   , merchant_name)
                     , xmlelement("mcc"             , mcc)
                     , xmlelement("terminal_number" , terminal_number)
                     , xmlelement("merchant_number" , merchant_number)
                     , xmlelement("auth_code"       , auth_code)
                     , xmlelement("acq_inst_bin"    , acq_inst_bin)
                   )
               )
          )
    into l_detail 
    from rawdata;
    
    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                 , xmlagg(
                       xmlelement("record"
                         , xmlelement("ips"             , null)                         
                         , xmlelement("oper_date"       , null)
                         , xmlelement("card_number"     , null)                         
                         , xmlelement("oper_summ"       , null)
                         , xmlelement("merchant_name"   , null)
                         , xmlelement("mcc"             , null)
                         , xmlelement("terminal_number" , null)
                         , xmlelement("merchant_number" , null)
                         , xmlelement("auth_code"       , null)
                         , xmlelement("acq_inst_bin"    , null)
                       )
                   )
               )
          into l_detail
          from dual;
    end if;
        
    select xmlelement("report"
         , l_header
         , l_detail
           )
      into l_result
      from dual;
        
    o_xml := l_result.getclobval;
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'end '
    );
exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '>> FAILED; i_network_id [#1], sqlerrm: ' || sqlerrm
          , i_env_param1 => i_network_id
        );
        raise; 
end late_presented_trans_iss;

procedure duplicated_transaction_iss(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_network_id        in     com_api_type_pkg.t_tiny_id       default null
  , i_start_date        in     date                             default null
  , i_end_date          in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.dublicated_transaction_iss: ';
    
    l_result                   xmltype;
    l_header                   xmltype;
    l_detail                   xmltype;
    l_start_date               date;
    l_end_date                 date;
begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'start, i_inst_id [' || i_inst_id || '] i_network_id [' || i_network_id || 
                  '] i_start_date [' || i_start_date || '] i_end_date [' || i_end_date || ']'
    );
    
    if i_network_id is not null and (i_network_id not in (mcw_api_const_pkg.MCW_NETWORK_ID, vis_api_const_pkg.VISA_NETWORK_ID)) then
        com_api_error_pkg.raise_error(
            i_error       => 'UNSUPPORTED_NETWORK'
          , i_env_param1  => i_network_id
        );
    end if;
    
    l_start_date := nvl(i_start_date, trunc(sysdate));
    l_end_date   := nvl(i_end_date, trunc(sysdate) + 1 - com_api_const_pkg.ONE_SECOND);
    
    -- header
    select xmlelement ("header",
                         xmlelement("p_head", 'DUPLICATED TRANSACTIONS – ISSUER FOR '  
                          || to_char(l_start_date, 'DD/MM/YYYY') || '-' || to_char(l_end_date, 'DD/MM/YYYY'))
                       , xmlelement("p_execdate" , to_char(sysdate, DATETIME_FORMAT))
                      )               
    into l_header from dual;
    
    -- code for filling l_detailss
    with rawdata as (
        select distinct
               ips
             , id
             , inst_id
             , oper_date
             , card_number
             , oper_summ
             , merchant_name
             , mcc
             , terminal_number
             , merchant_number
             , auth_code
             , acq_inst_bin
         from (    
            select case opa.network_id
                       when mcw_api_const_pkg.MCW_NETWORK_ID then
                           'Mastercard/Maestro'
                       when vis_api_const_pkg.VISA_NETWORK_ID then
                           'Visa'
                       else null    
                   end                                                  as ips
                 , o.id
                 , opa.inst_id                                          as inst_id                                                        
                 , to_char(o.oper_date, 'DD/MM/YYYY')                   as oper_date
                 , iss_api_card_pkg.get_card_mask(
                       i_card_number => ca.card_number
                   )                                                    as card_number
                 , com_api_currency_pkg.get_amount_str(
                       i_amount     => o.oper_amount
                     , i_curr_code  => o.oper_currency
                     , i_mask_error => com_api_const_pkg.TRUE
                   )                                                    as oper_summ
                 , o.merchant_name                                      as merchant_name
                 , o.mcc                                                as mcc
                 , o.terminal_number                                    as terminal_number
                 , o.merchant_number                                    as merchant_number
                 , opi.auth_code                                        as auth_code
                 , o.acq_inst_bin                                       as acq_inst_bin
                 , count (*) over (partition by
                                             o.acq_inst_bin
                                           , o.oper_type
                                           , o.msg_type
                                           , o.merchant_name
                                           , o.terminal_number
                                           , opi.auth_code
                                           , ca.card_number
                                  )                                     as cnt
              from opr_operation o
              join opr_participant opa on o.id = opa.oper_id 
                                       and opa.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
                                       and (opa.network_id = i_network_id or i_network_id is null)
                                       and (opa.inst_id = i_inst_id or i_inst_id is null)
              join opr_participant opi on o.id = opi.oper_id 
                                      and opi.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER   
              left join opr_card ca on ca.oper_id = o.id
                              and ca.participant_type = opi.participant_type                                       
             where o.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
               and o.oper_date between l_start_date and l_end_date
         ) where cnt > 1
           order by ips, inst_id
    )
    select xmlelement("table"
             , xmlagg(
                   xmlelement("record"
                     , xmlelement("ips"             , ips)                         
                     , xmlelement("oper_date"       , oper_date)
                     , xmlelement("card_number"     , card_number)                         
                     , xmlelement("oper_summ"       , oper_summ)
                     , xmlelement("merchant_name"   , merchant_name)
                     , xmlelement("mcc"             , mcc)
                     , xmlelement("terminal_number" , terminal_number)
                     , xmlelement("merchant_number" , merchant_number)
                     , xmlelement("auth_code"       , auth_code)
                     , xmlelement("acq_inst_bin"    , acq_inst_bin)
                   )
               )
             )
      into l_detail 
      from rawdata;
    
    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                 , xmlagg(
                       xmlelement("record"
                         , xmlelement("ips"             , null)                         
                         , xmlelement("oper_date"       , null)
                         , xmlelement("card_number"     , null)                         
                         , xmlelement("oper_summ"       , null)
                         , xmlelement("merchant_name"   , null)
                         , xmlelement("mcc"             , null)
                         , xmlelement("terminal_number" , null)
                         , xmlelement("merchant_number" , null)
                         , xmlelement("auth_code"       , null)
                         , xmlelement("acq_inst_bin"    , null)
                       )
                   )
               )
          into l_detail
          from dual;
    end if;
        
    select xmlelement("report"
         , l_header
         , l_detail
           )
      into l_result
      from dual;
        
    o_xml := l_result.getclobval;
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'end '
    );
exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '>> FAILED; i_network_id [#1], sqlerrm: ' || sqlerrm
          , i_env_param1 => i_network_id
        );
        raise; 
end duplicated_transaction_iss;

procedure duplicated_transaction_acq(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_tiny_id       default null
  , i_network_id        in     com_api_type_pkg.t_tiny_id       default null
  , i_date              in     date                             default null
  , i_lang              in     com_api_type_pkg.t_dict_value    default null
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.dublicated_transaction_iss: ';
    
    l_result                   xmltype;
    l_header                   xmltype;
    l_detail                   xmltype;
    l_start_date               date;
    l_end_date                 date;
begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'start, i_inst_id [' || i_inst_id || '] i_network_id [' || i_network_id || 
                  '] i_date [' || i_date || ']'
    );
    
    if i_network_id is not null and (i_network_id not in (mcw_api_const_pkg.MCW_NETWORK_ID, vis_api_const_pkg.VISA_NETWORK_ID)) then
        com_api_error_pkg.raise_error(
            i_error       => 'UNSUPPORTED_NETWORK'
          , i_env_param1  => i_network_id
        );
    end if;
    
    l_start_date := trunc(nvl(i_date, sysdate));
    l_end_date   := trunc(nvl(i_date, sysdate)) + 1 - com_api_const_pkg.ONE_SECOND;
    
    trc_log_pkg.debug('l_start_date=' || to_char(l_start_date, DATETIME_FORMAT) || ' l_end_date=' || to_char(l_end_date, DATETIME_FORMAT));
    
    -- header
    select xmlelement ("header",
                         xmlelement("p_head", 'DUPLICATED TRANSACTIONS – ACQUIRER FOR '  
                          || to_char(l_start_date, 'DD/MM/YYYY') || '-' || to_char(l_end_date, 'DD/MM/YYYY'))
                       , xmlelement("p_execdate" , to_char(sysdate, DATETIME_FORMAT))
                      )               
    into l_header from dual;
    
    -- code for filling l_detailss
    with src as (
        select ips
             , inst_id
             , oper_date
             , card_number
             , oper_summ
             , merchant_name
             , mcc
             , terminal_number
             , merchant_number
             , auth_code
         from (     
            select case op.network_id
                       when mcw_api_const_pkg.MCW_NETWORK_ID then
                           'Mastercard/Maestro'
                       when vis_api_const_pkg.VISA_NETWORK_ID then
                           'Visa'
                       else null    
                   end                                                  as ips
                 , op.inst_id                                           as inst_id
                 , to_char(o.oper_date, 'DD/MM/YYYY')                   as oper_date
                 , ca.card_number                                       as card_number
                 , com_api_currency_pkg.get_amount_str(
                       i_amount     => o.oper_amount
                     , i_curr_code  => o.oper_currency
                     , i_mask_error => com_api_const_pkg.TRUE
                   )                                                    as oper_summ         
                 , o.merchant_name                                      as merchant_name
                 , o.mcc                                                as mcc
                 , o.terminal_number                                    as terminal_number
                 , o.merchant_number                                    as merchant_number
                 , op.auth_code                                         as auth_code
                 , count (*) over (partition by ca.card_number
                                              , trunc(o.oper_date)
                                              , o.merchant_name
                                              , o.oper_amount
                                              , o.oper_currency                             
                                    )                                   as cnt
              from opr_operation o                               
              join opr_participant op on o.id = op.oper_id 
                                     and op.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                                     and (network_id = i_network_id or i_network_id is null)
                                     and (inst_id = i_inst_id or i_inst_id is null)   
              left join opr_card ca on ca.oper_id = o.id
                                   and ca.participant_type = op.participant_type                                       
             where o.msg_type = OPR_API_CONST_PKG.MESSAGE_TYPE_AUTHORIZATION
               and o.oper_date between l_start_date and l_end_date                              
         ) where cnt > 1
     ), rawdata as (
         select distinct
                ips
              , oper_date
              , iss_api_card_pkg.get_card_mask(
                    i_card_number => card_number
                ) as card_number
              , oper_summ
              , merchant_name
              , mcc
              , terminal_number
              , merchant_number
              , auth_code
           from src s1
                where exists (
                    select 1 from src s2 
                     where s1.oper_date = s2.oper_date and s1.merchant_name = s2.merchant_name and s1.oper_summ = s2.oper_summ and  s1.card_number = s2.card_number
                       and s1.auth_code != s2.auth_code
                )
          order by ips, oper_date
    )
    select xmlelement("table"
             , xmlagg(
                   xmlelement("record"
                     , xmlelement("ips"             , ips)                         
                     , xmlelement("oper_date"       , oper_date)
                     , xmlelement("card_number"     , card_number)                         
                     , xmlelement("oper_summ"       , oper_summ)
                     , xmlelement("merchant_name"   , merchant_name)
                     , xmlelement("mcc"             , mcc)
                     , xmlelement("terminal_number" , terminal_number)
                     , xmlelement("merchant_number" , merchant_number)
                     , xmlelement("auth_code"       , auth_code)
                   )
               )
             )
      into l_detail 
      from rawdata;
    
    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                 , xmlagg(
                       xmlelement("record"
                         , xmlelement("ips"             , null)                         
                         , xmlelement("oper_date"       , null)
                         , xmlelement("card_number"     , null)                         
                         , xmlelement("oper_summ"       , null)
                         , xmlelement("merchant_name"   , null)
                         , xmlelement("mcc"             , null)
                         , xmlelement("terminal_number" , null)
                         , xmlelement("merchant_number" , null)
                         , xmlelement("auth_code"       , null)
                       )
                   )
               )
          into l_detail
          from dual;
    end if;
        
    select xmlelement("report"
         , l_header
         , l_detail
           )
      into l_result from dual;
        
    o_xml := l_result.getclobval;
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'end '
    );
exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error
    then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '>> FAILED; i_network_id [#1], sqlerrm: ' || sqlerrm
          , i_env_param1 => i_network_id
        );
        raise; 
end duplicated_transaction_acq;

end csm_api_report_pkg;
/
