create or replace package body cst_bnv_napas_report_pkg as

procedure reconciliate_results_not_napas(
    o_xml                  out clob 
  , i_start_date        in     date
  , i_end_date          in     date
  , i_inst_id           in     com_api_type_pkg.t_inst_id default null
  , i_lang              in     com_api_type_pkg.t_dict_value default null
) is
    l_lang              com_api_type_pkg.t_dict_value;
    l_start_id          com_api_type_pkg.t_long_id;
    l_end_id            com_api_type_pkg.t_long_id;

    l_header            xmltype;
    l_detail            xmltype;
    l_result            xmltype; 
begin
    trc_log_pkg.debug(
        i_text        => 'cst_bnv_napas_report_pkg.reconciliate_results_not_napas [#1][#2][#3]'
      , i_env_param1  => i_start_date
      , i_env_param2  => i_end_date
      , i_env_param3  => i_lang
    );

    l_lang       := coalesce( i_lang, get_user_lang );
    l_start_id   := com_api_id_pkg.get_from_id(i_start_date);
    l_end_id     := com_api_id_pkg.get_till_id(i_end_date);

    select xmlelement("header",
               xmlelement("report_name", 'CARD SYSTEM UNMATCHED REPORT')
             , xmlelement("start_date", to_char(i_start_date, cst_bnv_napas_api_const_pkg.XML_DATETIME_FORMAT))
             , xmlelement("end_date", to_char(i_end_date, cst_bnv_napas_api_const_pkg.XML_DATETIME_FORMAT))
             , xmlelement("inst_id", i_inst_id)
             , xmlelement("inst_name", get_text('OST_INSTITUTION','NAME', i_inst_id, l_lang))
             , xmlelement("division_name", 'E-Banking Division')
           )
      into l_header
      from dual;
     
     select xmlelement("details"
             , xmlagg(
                   xmlelement("detail"
                     , xmlelement("transaction_type", get_article_text(
                                                          i_article => o.oper_type
                                                        , i_lang => l_lang
                                                      )
                       )
                     , xmlelement("transaction_date", to_char(o.oper_date, cst_bnv_napas_api_const_pkg.XML_DATETIME_FORMAT))
                     , xmlelement("card_number", iss_api_token_pkg.decode_card_number(i_card_number => c.card_number))
                     , xmlelement("sys_trace_number", nvl(a.system_trace_audit_number,''))
                     , xmlelement("auth_code", p.auth_code)
                     , xmlelement("terminal_number", o.terminal_number)
                     , xmlelement("transaction_amount", o.oper_amount)
                     , xmlelement("iss_fee", null)
                     , xmlelement("acq_fee", null)
                     , xmlelement("bnb_fee", null)
                     , xmlelement("status", 'An operation is exist in SV not exist in NAPAS')
                   )
               )
            )
       into l_detail
       from opr_operation o
          , opr_card c
          , opr_participant p
          , aut_auth a
      where o.id between l_start_id and l_end_id
        and o.oper_date between i_start_date and i_end_date
        and o.id = a.id(+) 
        and o.id = p.oper_id
        and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
        and p.oper_id = c.oper_id(+)
        and p.participant_type = c.participant_type(+)
        and not exists (select 1 from cst_bnv_napas_fin_msg m
                         where m.match_oper_id = o.id)
        and not exists (select 1 from cst_bnv_napas_fin_msg m
                         where m.id = o.id);

    --if no data
    if l_detail.getclobval() = '<details></details>' then
        select xmlelement(
                   "details"
                 , xmlagg(
                       xmlelement(
                           "detail"
                         , xmlelement("transaction_type", null)
                         , xmlelement("transaction_date", null)
                         , xmlelement("card_number", null)
                         , xmlelement("sys_trace_number", null)
                         , xmlelement("auth_code", null)
                         , xmlelement("terminal_number", null)
                         , xmlelement("transaction_amount", null)
                         , xmlelement("iss_fee", null)
                         , xmlelement("acq_fee", null)
                         , xmlelement("bnb_fee", null)
                         , xmlelement("status", null)
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

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'cst_bnv_napas_report_pkg.reconciliate_results_not_napas Finished' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ; 
end reconciliate_results_not_napas;

procedure reconciliate_results_not_sv(
    o_xml                  out clob 
  , i_start_date        in     date
  , i_end_date          in     date
  , i_inst_id           in     com_api_type_pkg.t_inst_id default null
  , i_lang              in     com_api_type_pkg.t_dict_value default null
) is
    l_lang              com_api_type_pkg.t_dict_value;

    l_header            xmltype;
    l_detail            xmltype;
    l_result            xmltype; 
begin
    trc_log_pkg.debug(
        i_text        => 'cst_bnv_napas_report_pkg.reconciliate_results_not_sv [#1][#2][#3]'
      , i_env_param1  => i_start_date
      , i_env_param2  => i_end_date
      , i_env_param3  => i_lang
    );

    l_lang       := nvl( i_lang, get_user_lang );

    select xmlelement("header",
               xmlelement("report_name", 'NAPAS UNMATCHED REPORT')
             , xmlelement("start_date", to_char(i_start_date, cst_bnv_napas_api_const_pkg.XML_DATETIME_FORMAT))
             , xmlelement("end_date", to_char(i_end_date, cst_bnv_napas_api_const_pkg.XML_DATETIME_FORMAT))
             , xmlelement("inst_id", i_inst_id)
             , xmlelement("inst_name", get_text('OST_INSTITUTION','NAME', i_inst_id, l_lang))
             , xmlelement("division_name", 'E-Banking Division')
           )
      into l_header
      from dual;
     
     select xmlelement("details"
             , xmlagg(
                   xmlelement("detail"
                     , xmlelement("transaction_type", get_article_text(
                                                          i_article => o.oper_type
                                                        , i_lang => l_lang
                                                      )
                       )
                     , xmlelement("transaction_date", to_char(o.oper_date, cst_bnv_napas_api_const_pkg.XML_DATETIME_FORMAT))
                     , xmlelement("card_number", iss_api_token_pkg.decode_card_number(i_card_number => c.card_number))
                     , xmlelement("sys_trace_number", m.sys_trace_number)
                     , xmlelement("auth_code", m.auth_code)
                     , xmlelement("terminal_number", m.terminal_number)
                     , xmlelement("transaction_amount", m.oper_amount)
                     , xmlelement("iss_fee", m.iss_fee_napas)
                     , xmlelement("acq_fee", m.acq_fee_napas)
                     , xmlelement("bnb_fee", m.bnb_fee_napas)
                     , xmlelement("status", decode(m.status
                                                 , cst_bnv_napas_api_const_pkg.MSG_STATUS_NOT_FOUND_IN_SV
                                                 , 'An operation is exist in NAPAS not exist in SV'
                                                 , 'An operation has a difference. Transaction amount does not equal.'
                                            )
                       )
                   )
               )
            )
       into l_detail
       from cst_bnv_napas_fin_msg m
          , cst_bnv_napas_card c
          , opr_operation o
      where m.id = c.id
        and m.id = o.id
        and m.trans_date between i_start_date and i_end_date
        and m.status in (cst_bnv_napas_api_const_pkg.MSG_STATUS_NOT_FOUND_IN_SV
                       , cst_bnv_napas_api_const_pkg.MSG_STATUS_DIFFERENCE)
      order by m.status;

    --if no data
    if l_detail.getclobval() = '<details></details>' then
        select xmlelement(
                   "details"
                 , xmlagg(
                       xmlelement(
                           "detail"
                         , xmlelement("transaction_type", null)
                         , xmlelement("transaction_date", null)
                         , xmlelement("card_number", null)
                         , xmlelement("sys_trace_number", null)
                         , xmlelement("auth_code", null)
                         , xmlelement("terminal_number", null)
                         , xmlelement("transaction_amount", null)
                         , xmlelement("iss_fee", null)
                         , xmlelement("acq_fee", null)
                         , xmlelement("bnb_fee", null)
                         , xmlelement("status", null)
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

    o_xml := l_result.getclobval();

    trc_log_pkg.debug ( i_text => 'cst_bnv_napas_report_pkg.reconciliate_results_not_sv Finished' );

exception when others then
    trc_log_pkg.debug ( i_text => sqlerrm );
    raise ; 
end reconciliate_results_not_sv;

end;
/
