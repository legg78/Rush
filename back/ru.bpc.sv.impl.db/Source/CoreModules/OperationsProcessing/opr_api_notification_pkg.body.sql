create or replace package body opr_api_notification_pkg as

procedure report_card_operation (
    o_xml                  out  clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_notify_party_type in      com_api_type_pkg.t_dict_value
) is
    l_result            xmltype;
begin
    trc_log_pkg.debug (
        i_text       => 'Card operation notification [#1] [#2] [#3] [#4] [#5]'
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
                , xmlelement(
                      "amount_value"
                     , to_char(
                           o.oper_amount / power(10, oc.exponent)
                         , com_api_const_pkg.XML_NUMBER_FORMAT || rpad('.', case oc.exponent when 0 then 0 else oc.exponent+1 end, '0')
                       )
                  )
                , xmlelement("currency", o.oper_currency)
                , xmlelement("name", oc.name)
              )
            , xmlelement(
                  "fee_amounts"
                , (select xmlagg(
                              xmlelement("fee_amount"
                                , xmlelement("fee_type"
                                    , xmlelement("code", m.amount_purpose)
                                    , xmlelement("name", get_article_text(i_article => m.amount_purpose
                                                                        , i_lang    => i_lang)
                                      )
                                  )
                                , xmlelement("amount_value"
                                           , to_char(
                                                 m.amount/power(10, mc.exponent)
                                               , com_api_const_pkg.XML_NUMBER_FORMAT
                                                 || rpad('.' , case mc.exponent when 0 then 0 else mc.exponent+1 end, '0')
                                             )
                                  )
                                , xmlelement("currency", m.currency)
                                , xmlelement("currency_name", mc.name)
                              )
                          )
                     from acc_macros m
                        , com_currency mc
                    where mc.code(+)    = m.currency
                      and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                      and m.object_id   = o.id
                      and substr(m.amount_purpose, 1, 4) = fcl_api_const_pkg.FEE_TYPE_STATUS_KEY)
              )
            , xmlelement("card_mask", p.card_mask)
            , xmlelement("short_card_mask", iss_api_card_pkg.get_short_card_mask(i_card_number => c.card_number))
            , xmlelement("balance"
                , xmlelement(
                      "amount_value"
                    , to_char(
                          av.balance/power(10, ac.exponent)
                        , com_api_const_pkg.XML_NUMBER_FORMAT || rpad('.', case ac.exponent when 0 then 0 else ac.exponent+1 end, '0')
                      )
                  )
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
            , xmlelement("note_text", com_api_i18n_pkg.get_text('ntb_note', 'text', n.id, i_lang))
        )
    into
        l_result
    from
        opr_operation o
        , opr_participant p
        , opr_card c
        , acc_ui_account_vs_aval_vw av
        , com_currency ac
        , com_currency oc
        , com_country mc
        , ntb_note n
    where
        o.id = i_object_id
        and p.oper_id = o.id
        and p.participant_type = nvl(i_notify_party_type, com_api_const_pkg.PARTICIPANT_ISSUER)
        and c.oper_id(+) = o.id 
        and c.participant_type(+) = nvl(i_notify_party_type, com_api_const_pkg.PARTICIPANT_ISSUER)
        and av.id(+) = p.account_id
        and ac.code(+) = av.currency
        and oc.code(+) = o.oper_currency
        and mc.code(+) = o.merchant_country
        and n.object_id(+) = o.id
        and n.entity_type(+) = opr_api_const_pkg.ENTITY_TYPE_OPERATION
        ;

    o_xml := l_result.getclobval();

exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end;

procedure report_account_operation (
    o_xml                  out  clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_notify_party_type in      com_api_type_pkg.t_dict_value
) is
    l_result            xmltype;
begin
     trc_log_pkg.debug (
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
            , xmlelement("account_number", p.account_number)
            , xmlelement("account_mask", '*' || substr(p.account_number, -5, 5))
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
        )
    into
        l_result
    from
        opr_operation o
        , opr_participant p
        , acc_ui_account_vs_aval_vw av
        , com_currency ac
        , com_currency oc
        , com_country mc
    where
        o.id = i_object_id
        and p.oper_id = o.id
        and p.participant_type = nvl(i_notify_party_type, com_api_const_pkg.PARTICIPANT_ISSUER)
        and av.id(+) = p.account_id
        and ac.code(+) = av.currency
        and oc.code(+) = o.oper_currency
        and mc.code(+) = o.merchant_country;

    o_xml := l_result.getclobval();

exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end;

procedure report_card_account_operation (
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
     trc_log_pkg.debug (
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
        )
    into
        l_result
    from
        opr_operation o
        , opr_participant p
        , acc_ui_account_vs_aval_vw av
        , opr_card c
        , com_currency ac
        , com_currency oc
        , com_country mc
    where
        o.id = i_object_id
        and p.oper_id = o.id
        and p.participant_type = nvl(i_notify_party_type, com_api_const_pkg.PARTICIPANT_ISSUER)
        and av.id(+) = p.account_id
        and c.oper_id(+) = p.oper_id
        and c.participant_type(+) = p.participant_type
        and ac.code(+) = av.currency
        and oc.code(+) = o.oper_currency
        and mc.code(+) = o.merchant_country;

    o_xml := l_result.getclobval();

exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end;

end opr_api_notification_pkg;
/
