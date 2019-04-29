create or replace package body cst_cfc_api_report_pkg as

procedure approved_appl_report(
    o_xml                  out      clob
  , i_inst_id               in      com_api_type_pkg.t_inst_id      default null
  , i_start_date            in      date                            default null
  , i_end_date              in      date                            default null
  , i_appl_status           in      com_api_type_pkg.t_dict_value   default null
  , i_lang                  in      com_api_type_pkg.t_dict_value   default null
) as
    l_start_date                  date;
    l_end_date                    date;
    l_lang                        com_api_type_pkg.t_dict_value;
    l_detail                      xmltype;
begin
    trc_log_pkg.debug (
        i_text          => 'cst_cfc_api_report_pkg.approved_appl_report [#1][#2][#3][#4]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => i_appl_status
        , i_env_param3  => com_api_type_pkg.convert_to_char(i_start_date)
        , i_env_param4  => com_api_type_pkg.convert_to_char(i_end_date)
    );

    l_lang       := nvl(i_lang, get_user_lang);
    l_start_date := trunc(nvl(i_start_date, get_sysdate));
    l_end_date   := nvl(trunc(i_end_date), l_start_date) + 1 - com_api_const_pkg.ONE_SECOND; 
    
    select xmlelement(
                "details"
              , xmlagg(
                  xmlelement(
                      "application"
                    , xmlelement("appl_id", h.appl_id)
                    , xmlelement(
                          "appl_date"
                        , (select to_char(min(change_date), com_api_const_pkg.XML_DATE_FORMAT)
                             from app_history h 
                            where h.appl_id = a.id 
                              and h.id between com_api_id_pkg.get_from_id(a.id) and com_api_id_pkg.get_till_id(a.id)
                          )
                      )
                    , xmlelement("change_date", to_char(h.change_date, com_api_const_pkg.XML_DATE_FORMAT))
                    , xmlelement("appl_number", a.appl_number)
                    , xmlelement(
                          "appl_status"
                        , com_api_dictionary_pkg.get_article_text(
                              i_article => a.appl_status
                            , i_lang    => l_lang
                          )
                      ) 
                    , xmlelement(
                          "user_name"
                        , acm_api_user_pkg.get_user_name(
                              i_user_id       => h.change_user
                            , i_mask_error    => com_api_const_pkg.TRUE
                          )
                      )
                    , xmlelement("comments", h.comments)
                  )
                )
           ) 
      into l_detail
      from app_history h
         , app_application a
     where h.change_date between l_start_date and l_end_date
       and h.appl_id = a.id
       and a.inst_id = i_inst_id
       and ((
               i_appl_status is null 
           and h.appl_status in (select element_value from com_array_element where array_id = cst_cfc_api_const_pkg.ARRAY_APPL_APPROVED_STATUSES)
           )
           or (
               i_appl_status is not null
           and h.appl_status = i_appl_status
           )
       );


    select xmlelement(
               "report"
             , xmlelement(
                   "inst_name"
                 , com_api_i18n_pkg.get_text(
                       i_table_name  => 'OST_INSTITUTION'
                     , i_column_name => 'NAME'
                     , i_object_id   => i_inst_id
                     , i_lang        => l_lang
                   )
               )
             , xmlelement("start_date", to_char(l_start_date, com_api_const_pkg.XML_DATE_FORMAT))
             , xmlelement("end_date"  , to_char(l_end_date, com_api_const_pkg.XML_DATE_FORMAT))
             , l_detail
           ).getclobval()
      into o_xml
      from dual;

    trc_log_pkg.debug(
         i_text => 'cst_cfc_api_report_pkg.approved_appl_report - ok'
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text   => sqlerrm
        );
        raise; 
end;

procedure cards_operation(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_rejected_only     in     com_api_type_pkg.t_boolean
  , i_lang              in     com_api_type_pkg.t_dict_value default com_api_const_pkg.DEFAULT_LANGUAGE
) 
is    
    l_lang                 com_api_type_pkg.t_dict_value;
    
    l_result               xmltype;
    l_header               xmltype;
    l_detail               xmltype;
    l_cnt                  com_api_type_pkg.t_long_id := 0; 
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.cards_operation: ';
begin
    trc_log_pkg.debug (
        i_text => LOG_PREFIX || ' START i_inst_id=' || i_inst_id || ' i_start_date=' || i_start_date || ' i_end_date=' || i_end_date
    );    
    l_lang := nvl(i_lang, get_user_lang);
        
    -- header
    select xmlelement ("header",
                 xmlelement("p_date_start" , to_char(i_start_date, 'DD/MM/YYYY'))
               , xmlelement("p_date_end"   , to_char(i_end_date, 'DD/MM/YYYY'  ))
               , xmlelement("p_inst_id"    , decode (i_inst_id, null, '0'
                                                   , i_inst_id||' - '||get_text('OST_INSTITUTION','NAME', i_inst_id, l_lang))
                           )
           )
    into l_header from dual;
    
    -- code for filling l_details 
 
    with rawdata as (
        select o.id as oper_id
             , to_char(oper_date, 'DD/MM/YYYY') oper_date
             , com_api_dictionary_pkg.get_article_text(
                   i_article => o.oper_type
               ) as oper_type
             , iss_api_card_pkg.get_card_mask(i_card_number => oc.card_number) as card_mask
             , com_api_currency_pkg.get_amount_str(
                   i_amount     => o.oper_amount
                 , i_curr_code  => o.oper_currency
                 , i_mask_error => com_api_const_pkg.TRUE  
               ) as oper_amount
             , com_api_dictionary_pkg.get_article_text(
                   i_article => o.status
               ) as oper_status
          from opr_operation o
          join opr_participant p 
            on p.oper_id = o.id
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and p.inst_id = i_inst_id
          join opr_card oc 
            on oc.oper_id = o.id
           and oc.participant_type = p.participant_type          
         where o.sttl_type = opr_api_const_pkg.SETTLEMENT_USONUS
           and oper_date between i_start_date and i_end_date
           and (i_rejected_only = com_api_const_pkg.FALSE
                    or o.status not in ('OPST0400', 'OPST0401', 'OPST0402', 'OPST0403', 'OPST0404', 'OPST0800')
               )
         order by oper_date 
    )
    select xmlelement("table"
             , xmlagg(
                   xmlelement("record"
                     , xmlelement("oper_id", oper_id)
                     , xmlelement("oper_date", oper_date)
                     , xmlelement("oper_type", oper_type)
                     , xmlelement("card_mask", card_mask)
                     , xmlelement("oper_amount", oper_amount)
                     , xmlelement("oper_status", oper_status)
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
                         , xmlelement("oper_id", null)
                         , xmlelement("oper_date", null)
                         , xmlelement("oper_type", null)
                         , xmlelement("card_mask", null)
                         , xmlelement("oper_amount", null)
                         , xmlelement("oper_status", null)
                       )
               )
           )
        into l_detail from dual;
    end if;
    
    select xmlelement ( "report"
             , l_header
             , l_detail
           )
    into l_result from dual;
    
    o_xml := l_result.getclobval;
    
    trc_log_pkg.debug (
        i_text => LOG_PREFIX || ' END, result ' || l_cnt
    );
        
exception when others then
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || sqlerrm
    );
    raise;
end cards_operation;

procedure rejected_cards_operation(
    o_xml                  out clob 
  , i_start_date        in     date
  , i_end_date          in     date
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value default com_api_const_pkg.DEFAULT_LANGUAGE  
)
is
begin
    cards_operation(
        o_xml           => o_xml 
      , i_start_date    => i_start_date
      , i_end_date      => i_end_date
      , i_inst_id       => i_inst_id
      , i_lang          => i_lang
      , i_rejected_only => com_api_const_pkg.TRUE
    );
end rejected_cards_operation;
     

procedure all_cards_operation(
    o_xml                  out clob
  , i_start_date        in     date
  , i_end_date          in     date
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value default com_api_const_pkg.DEFAULT_LANGUAGE  
)
is
begin
    cards_operation(
        o_xml           => o_xml
      , i_start_date    => i_start_date
      , i_end_date      => i_end_date
      , i_inst_id       => i_inst_id
      , i_lang          => i_lang
      , i_rejected_only => com_api_const_pkg.FALSE
    );
end all_cards_operation;

procedure report_card_account_operation(
    o_xml                  out  clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_notify_party_type in      com_api_type_pkg.t_dict_value
  , i_src_entity_type   in      com_api_type_pkg.t_dict_value
  , i_src_object_id     in      com_api_type_pkg.t_long_id
) is
    l_result            xmltype;
begin
    trc_log_pkg.debug(
        i_text       => 'Account operation notification [#1] [#2] [#3] [#4] [#5]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );

    select
        xmlelement("report"
            , xmlelement("oper_type"
                , xmlelement("code", o.oper_type)
                , xmlelement("name", upper(get_article_text(i_article => o.oper_type, i_lang => i_lang)))
              )
            , xmlelement("msg_type"
                , xmlelement("code", o.msg_type)
                , xmlelement("name", get_article_text(i_article => o.msg_type, i_lang => i_lang))
              )
            , xmlelement("oper_date", to_char(o.oper_date, com_api_const_pkg.XML_DATETIME_FORMAT))
            , xmlelement("oper_amount"
                , xmlelement("amount_value", to_char(o.oper_amount/power(10, oc.exponent), com_api_const_pkg.XML_NUMBER_FORMAT || rpad('.', case oc.exponent when 0 then 0 else oc.exponent+1 end, '0')))
                , xmlelement("currency", o.oper_currency)
                , xmlelement("name", oc.name)
              )
            , xmlelement(
                  "short_card_mask"
                , iss_api_card_pkg.get_short_card_mask(
                      i_card_number => coalesce(
                                           (select cn.card_number
                                              from iss_card_number_vw cn
                                             where cn.card_id = i_src_object_id
                                               and i_src_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           )
                                         , c.card_number
                                       )
                  )
              )
            , xmlelement(
                  "card_mask"
                , iss_api_card_pkg.get_card_mask(
                      i_card_number => coalesce(
                                           (select  cn.card_number
                                              from iss_card_number_vw cn
                                             where cn.card_id = i_src_object_id
                                               and i_src_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                                           )
                                         , c.card_number
                                       )
                  )
              )
            , xmlelement("account_mask", '*' || substr(p.account_number, -5, 5))
            , xmlelement("short_account_mask", '*' || substr(p.account_number, -4, 4))
            , xmlelement("balance"
                , xmlelement("amount_value", to_char(av.balance/power(10, ac.exponent), com_api_const_pkg.XML_NUMBER_FORMAT || rpad('.', case ac.exponent when 0 then 0 else ac.exponent+1 end, '0')))
                , xmlelement("currency", ac.code)
                , xmlelement("name", ac.name)
              )
            , xmlelement("merchant"
                , xmlelement("merchant_name", rtrim(o.merchant_name))
                , xmlelement("merchant_postcode", rtrim(o.merchant_postcode))
                , xmlelement("merchant_street", rtrim(o.merchant_street))
                , xmlelement("merchant_city", rtrim(o.merchant_city))
                , xmlelement("merchant_region", nvl(trim(o.merchant_region), mc.name))
                , xmlelement("merchant_country", rtrim(o.merchant_country))
              )
            , xmlelement("institution_name", ost_ui_institution_pkg.get_inst_name(i_inst_id => av.inst_id, i_lang => i_lang))
            , xmlelement("agent_name", ost_ui_agent_pkg.get_agent_name(i_agent_id => av.agent_id, i_lang => i_lang))
            , xmlelement("cbs_transfer_bank_name", pod1.param_value)
            , xmlelement("cbs_transfer_recipient_account", pod2.param_value)
        )
      into l_result
      from opr_operation    o
         , opr_participant  p
         , acc_ui_account_vs_aval_vw av
         , opr_card         c
         , com_currency     ac
         , com_currency     oc
         , com_country      mc
         , pmo_order        po
         , pmo_order_data   pod1
         , pmo_order_data   pod2
     where o.id                  = i_object_id
       and p.oper_id             = o.id
       and p.participant_type    = nvl(i_notify_party_type, com_api_const_pkg.PARTICIPANT_ISSUER)
       and av.id(+)              = p.account_id
       and c.oper_id(+)          = p.oper_id
       and c.participant_type(+) = p.participant_type
       and ac.code(+)            = av.currency
       and oc.code(+)            = o.oper_currency
       and mc.code(+)            = o.merchant_country
       and po.id(+)              = o.payment_order_id
       and pod1.order_id(+)      = po.id
       and pod2.order_id(+)      = po.id
       and pod1.param_id(+)      = 10000002
       and pod2.param_id(+)      = 10000004;

    o_xml := l_result.getclobval();

exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end;

procedure export_account_info(
    o_xml                   out clob
  , i_inst_id           in      com_api_type_pkg.t_inst_id      default ost_api_const_pkg.DEFAULT_INST
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_lang              in      com_api_type_pkg.t_dict_value   default com_api_const_pkg.DEFAULT_LANGUAGE
)
is
    l_cardholder_name   com_api_type_pkg.t_name;
    l_limit_balance     com_api_type_pkg.t_money;
    l_account_id        com_api_type_pkg.t_account_id;
    l_extra_due_date    com_api_type_pkg.t_byte_char;
    l_app_id            com_api_type_pkg.t_long_id;
begin

    trc_log_pkg.debug (
        i_text          => 'cst_cfc_api_report_pkg.export_account_info [#1][#2]'
      , i_env_param1  => i_entity_type
      , i_env_param2  => i_object_id
    );

    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        select max(appl_id)
          into l_app_id
          from app_object
         where entity_type  = i_entity_type
           and object_id    = i_object_id;
    end if;

    if l_app_id is not null or i_entity_type = app_api_const_pkg.ENTITY_TYPE_APPLICATION then
        select c.cardholder_name
             , b.balance
             , a.enttacct_id
          into l_cardholder_name
             , l_limit_balance
             , l_account_id
          from iss_cardholder   c
             , acc_balance      b
             , (select *
                  from (select entity_type, object_id
                          from app_object
                         where appl_id =  nvl(l_app_id, i_object_id))
                 pivot (min(object_id) as ID for(entity_type) in ('ENTTCRDH' as ENTTCRDH, 'ENTTACCT' as ENTTACCT))
               ) a
         where c.id             = a.enttcrdh_id
           and b.account_id     = a.enttacct_id
           and b.balance_type   = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED;--'BLTP1001'

        l_extra_due_date := cst_cfc_com_pkg.get_extra_due_date(i_account_id => l_account_id);

        select xmlelement("report"
                 , xmlelement("application_id"  , nvl(l_app_id, i_object_id))
                 , xmlelement("emboss_name"     , l_cardholder_name)
                 , xmlelement("credit_limit"    , l_limit_balance)
                 , xmlelement("due_date_1"      , l_extra_due_date)
               ).getclobval()
          into o_xml
          from dual;
    end if;
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => i_entity_type
        );
end;

end;
/
