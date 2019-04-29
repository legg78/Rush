create or replace package body aut_api_report_pkg is

procedure approved_auth_statistics(
    o_xml                         out clob
  , i_start_date                   in date
  , i_end_date                     in date
  , i_currency                     in com_api_type_pkg.t_curr_code  default null
  , i_inst_id                      in com_api_type_pkg.t_inst_id    default null
  , i_party_type                   in com_api_type_pkg.t_dict_value default null
  , i_lang                         in com_api_type_pkg.t_dict_value default null
) is
    LOG_PREFIX                     constant    com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.approved_auth_statistics: ';
    l_start_date                   date;
    l_end_date                     date;
    l_currency                     com_api_type_pkg.t_curr_code;
    l_inst_id                      com_api_type_pkg.t_inst_id;
    l_party_type                   com_api_type_pkg.t_dict_value;
    l_lang                         com_api_type_pkg.t_dict_value;
    l_header                       xmltype;
    l_detail                       xmltype; 
    l_logo_path                    xmltype;		

begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' start_date [#1] end_date [#2] currency [#3] inst_id [#4] party_type [#5] lang [#6]'
      , i_env_param1 => com_api_type_pkg.convert_to_char(trunc(nvl(i_start_date, com_api_sttl_day_pkg.get_sysdate)))
      , i_env_param2 => com_api_type_pkg.convert_to_char(nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND)
      , i_env_param3 => i_currency
      , i_env_param4 => i_inst_id
      , i_env_param5 => i_party_type
      , i_env_param6 => i_lang
    );

    l_start_date := trunc(nvl(i_start_date, get_sysdate));
    l_end_date   := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
    l_currency   := i_currency;
    l_inst_id    := i_inst_id;
    l_party_type := i_party_type;
    l_lang       := nvl(i_lang, get_user_lang);

    -- header      
		l_logo_path := rpt_api_template_pkg.logo_path_xml;
    select
        xmlconcat(
            xmlelement("header"        
						  , l_logo_path
              , xmlelement("generated", to_char(com_api_sttl_day_pkg.get_sysdate, 'dd.mm.yyyy hh24:mi:ss'))
              , xmlelement("start_date_filter", to_char(l_start_date, 'dd.mm.yyyy'))
              , xmlelement("end_date_filter", to_char(l_end_date, 'dd.mm.yyyy'))
              , xmlelement("currency_filter", l_currency || ' ' || com_api_currency_pkg.get_currency_full_name(l_currency, l_lang))
              , xmlelement("institution_filter", l_inst_id || ' ' || com_api_i18n_pkg.get_text('OST_INSTITUTION', com_api_const_pkg.TEXT_IN_NAME, l_inst_id, l_lang))
              , xmlelement("party_type_filter", com_api_dictionary_pkg.get_article_desc(l_party_type, l_lang))
            )
        )
      into
          l_header
      from
          dual;

    select
        xmlelement("table"
          , xmlagg(
                xmlelement("record"
                  , xmlelement("party_type", party_type)
                  , xmlelement("currency", (com_api_currency_pkg.get_currency_name(currency)))
                  , xmlelement("institution", institution)
                  , xmlelement("operation", oper_name)
                  , xmlelement("reversal", reversal)
                  , xmlelement("amount", amount)
                  , xmlelement("volume", volume)
                )
                order by party_type desc
                  , currency
                  , gr_id
                  , institution
                  , oper_name
            )
        )
      into 
          l_detail
      from (
          select a.party_type
               , a.currency
               , a.gr_id
               , a.inst_id || ' ' || com_api_i18n_pkg.get_text('OST_INSTITUTION', com_api_const_pkg.TEXT_IN_NAME, a.inst_id, l_lang) as institution
               , com_api_dictionary_pkg.get_article_desc(a.oper_type, l_lang) as oper_name
               , a.reversal
               , (com_api_currency_pkg.get_amount_str(i_amount => a.amount, i_curr_code => a.currency, i_mask_curr_code => 1)) as amount
               , a.volume
            from (
                select com_api_const_pkg.PARTICIPANT_ISSUER as party_type
                     , grouping_id(oop.oper_currency, opi.inst_id, oop.oper_type, oop.is_reversal) as gr_id
                     , oop.oper_currency    as currency
                     , opi.inst_id          as inst_id
                     , oop.oper_type        as oper_type
                     , oop.is_reversal      as reversal
                     , sum(decode(oop.is_reversal, 0, oop.oper_amount, -oop.oper_amount)) as amount
                     , count(*)             as volume
                  from opr_operation    oop
                     , opr_participant  opi
                 where trunc(oop.oper_date) >= l_start_date
                   and trunc(oop.oper_date)  < l_end_date
                   and not exists (select null
                                     from net_sttl_map nsp
                                    where nsp.sttl_type   = oop.sttl_type
                                      and nsp.iss_inst_id = nsp.acq_inst_id)
                   and exists (select null
                                 from aut_auth ath
                                where ath.id         = oop.id
                                  and ath.resp_code  = aup_api_const_pkg.RESP_CODE_OK)
                   and oop.oper_currency             = decode(l_currency, null, oop.oper_currency, l_currency)
                   and oop.id                        = opi.oper_id
                   and opi.participant_type          = com_api_const_pkg.PARTICIPANT_ISSUER
                   and nvl(l_party_type, com_api_const_pkg.PARTICIPANT_ISSUER) = decode(l_party_type, com_api_const_pkg.PARTICIPANT_ACQUIRER, 'PRTY~~~', com_api_const_pkg.PARTICIPANT_ISSUER)
                   and opi.inst_id                   = decode(l_inst_id, null, opi.inst_id, ost_api_const_pkg.DEFAULT_INST, opi.inst_id, l_inst_id)
                 group by cube(oop.oper_currency, opi.inst_id, oop.oper_type, oop.is_reversal)
                 union all
                select com_api_const_pkg.PARTICIPANT_ACQUIRER as party_type
                     , grouping_id(oop.oper_currency, opa.inst_id, oop.oper_type, oop.is_reversal) as gr_id
                     , oop.oper_currency    as currency
                     , opa.inst_id          as inst_id
                     , oop.oper_type        as oper_type
                     , oop.is_reversal      as reversal
                     , sum(decode(oop.is_reversal, 0, oop.oper_amount, -oop.oper_amount)) as amount
                     , count(*)             as volume
                  from opr_operation    oop
                     , opr_participant  opa
                 where trunc(oop.oper_date) >= l_start_date
                   and trunc(oop.oper_date)  < l_end_date
                   and not exists (select null
                                     from net_sttl_map nsp
                                    where nsp.sttl_type   = oop.sttl_type
                                      and nsp.iss_inst_id = nsp.acq_inst_id)
                   and exists (select null
                                 from aut_auth ath
                                where ath.id         = oop.id
                                  and ath.resp_code  = aup_api_const_pkg.RESP_CODE_OK)
                   and oop.oper_currency             = decode(i_currency, null, oop.oper_currency, i_currency)
                   and oop.id                        = opa.oper_id
                   and opa.participant_type          = com_api_const_pkg.PARTICIPANT_ACQUIRER
                   and nvl(l_party_type, com_api_const_pkg.PARTICIPANT_ACQUIRER) = decode(l_party_type, com_api_const_pkg.PARTICIPANT_ISSUER, 'PRTY~~~', com_api_const_pkg.PARTICIPANT_ACQUIRER)
                   and opa.inst_id                   = decode(l_inst_id, null, opa.inst_id, ost_api_const_pkg.DEFAULT_INST, opa.inst_id, l_inst_id)
                 group by cube(oop.oper_currency, opa.inst_id, oop.oper_type, oop.is_reversal)
                ) a
     where gr_id         in (0, 7)
           );

    --if no data
    if l_detail.getclobval() = '<table></table>' then
        select xmlelement("table"
                 , xmlagg(
                       xmlelement("record"
                         , xmlelement("party_type", null)
                         , xmlelement("currency", null)
                         , xmlelement("institution", null)
                         , xmlelement("operation", null)
                         , xmlelement("reversal", null)
                         , xmlelement("amount", null)
                         , xmlelement("volume", null)
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
           ).getclobval()
      into o_xml
      from dual;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'End'
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text  => 'aut_api_report_pkg.approved_auth_statistics i_start_date [' || com_api_type_pkg.convert_to_char(i_start_date)
                    || '], i_end_date [' || com_api_type_pkg.convert_to_char(i_end_date)
                    || '], i_currency [' || i_currency
                    || '], i_inst_id [' || i_inst_id
                    || '], i_party_type [' || i_party_type
        );

        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE
            and com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
        then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;

end approved_auth_statistics;

end aut_api_report_pkg;
/
