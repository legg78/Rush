create or replace package body rus_api_form_259_pkg is

procedure get_header_footer(
    i_lang             in     com_api_type_pkg.t_dict_value
  , i_inst_id          in     com_api_type_pkg.t_tiny_id
  , i_agent_id         in     com_api_type_pkg.t_short_id   default null
  , i_date_end         in     date
  , o_header              out xmltype
  , o_footer              out xmltype
)
is
    l_bank_name     com_api_type_pkg.t_name;
    l_bank_address  com_api_type_pkg.t_name;
    l_bic           com_api_type_pkg.t_name;
    l_code_okpo     com_api_type_pkg.t_name;
    l_reg_no        com_api_type_pkg.t_name;
    l_serial_no     com_api_type_pkg.t_name;
    l_code_okato    com_api_type_pkg.t_name;
    l_agent_name    com_api_type_pkg.t_name;
    l_contact_data  com_api_type_pkg.t_name;
begin
    begin
        select get_text('OST_INSTITUTION', 'NAME', i_inst_id, i_lang)
             , nvl(com_api_flexible_data_pkg.get_flexible_value('FLX_BANK_ID_CODE', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, i_inst_id), 99999)
             , com_api_flexible_data_pkg.get_flexible_value('RUS_OKPO', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, i_inst_id)
             , com_api_flexible_data_pkg.get_flexible_value('RUS_OGRN', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, i_inst_id)
             , com_api_flexible_data_pkg.get_flexible_value('RUS_REG_NUM', ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, i_inst_id)
             , get_text('OST_AGENT', 'NAME', i_agent_id, i_lang)
          into l_bank_name
             , l_bic
             , l_code_okpo
             , l_reg_no
             , l_serial_no
             , l_agent_name
          from dual;
    exception 
        when others 
        then null;
    end;

    begin
        select com_api_address_pkg.get_address_string(o.address_id, i_lang) address
             , a.region_code
          into l_bank_address
             , l_code_okato
          from com_address_object o
             , com_address a
         where o.entity_type  = decode(i_agent_id, null, ost_api_const_pkg.ENTITY_TYPE_INSTITUTION, ost_api_const_pkg.ENTITY_TYPE_AGENT)
           and o.object_id    = decode(i_agent_id, null, i_inst_id, i_agent_id)
           and o.address_type = 'ADTPLGLA' --'ADTPBSNA'
           and a.id           = o.address_id ;
    exception 
        when others 
        then null;
    end;

    begin
        select phone || decode(phone, null, null, ', ') || e_mail
          into l_contact_data
          from (
               select max(decode(d.commun_method, com_api_const_pkg.COMMUNICATION_METHOD_MOBILE, commun_address, null)) as phone
                    , max(decode(d.commun_method, com_api_const_pkg.COMMUNICATION_METHOD_EMAIL, commun_address, null)) as e_mail
                 from com_contact_object o
                    , com_contact_data   d
                where o.object_id    = com_ui_user_env_pkg.get_person_id
                  and o.entity_type  = com_api_const_pkg.ENTITY_TYPE_PERSON
                  and o.contact_type = com_api_const_pkg.CONTACT_TYPE_PRIMARY
                  and d.contact_id   = o.contact_id
                  and commun_method in (com_api_const_pkg.COMMUNICATION_METHOD_MOBILE, com_api_const_pkg.COMMUNICATION_METHOD_EMAIL)  -- mobile phone, e-mail
               );
    exception 
        when others 
        then null;
    end;

    -- header
    select xmlelement("header"
             , xmlelement("bank_name", l_bank_name)
             , xmlelement("bank_address", l_bank_address)
             , xmlelement("agent_name", l_agent_name)
             , xmlelement("bic", l_bic)
             , xmlelement("code_okpo", l_code_okpo)
             , xmlelement("reg_no", l_reg_no)
             , xmlelement("serial_no", l_serial_no)
             , xmlelement("code_okato", l_code_okato)
             , xmlelement("date", to_char(i_date_end + 1, 'dd month yyyy', 'nls_date_language = russian'))
           ) xml
      into o_header
      from dual;

    -- footer
    select xmlelement("footer"
             , xmlelement("user_name", com_ui_person_pkg.get_person_name(acm_api_user_pkg.get_person_id(get_user_name), i_lang))
             , xmlelement("rpt_date", to_char(com_api_sttl_day_pkg.get_sysdate, 'dd.mm.yyyy hh24:mi'))
             , xmlelement("phone", l_contact_data)
           ) xml
      into o_footer
      from dual;
end get_header_footer;

procedure run_rpt_form_259_1(
    o_xml                 out clob
  , i_lang             in     com_api_type_pkg.t_dict_value
  , i_inst_id          in     com_api_type_pkg.t_tiny_id
  , i_agent_id         in     com_api_type_pkg.t_short_id   default null
  , i_start_date       in     date
  , i_end_date         in     date
)
is
    l_result        xmltype;
    l_part_1        xmltype;
    l_header        xmltype;
    l_footer        xmltype;
begin
    trc_log_pkg.debug(
        i_text         => 'rus_api_form_259_pkg.run_rpt_form_259_1 [#1][#2][#3][#4]'
      , i_env_param1   => i_lang
      , i_env_param2   => i_inst_id
      , i_env_param3   => i_agent_id
      , i_env_param4   => i_start_date
    );

    get_header_footer (
        i_lang         => i_lang
      , i_inst_id      => i_inst_id
      , i_agent_id     => i_agent_id
      , i_date_end     => i_end_date
      , o_header       => l_header
      , o_footer       => l_footer
    ) ;

    -- data
    select xmlelement("part1", xmlagg(t.xml))
      into l_part_1
      from (
           select xmlagg( 
                      xmlelement("table"
                        , xmlelement("customer_type", x.customer_type)
                        , xmlelement("row_type", x.row_type)
                        , xmlelement("pmode", x.pmode)
                        , xmlelement("contract_type", x.contract_type)
                        , xmlelement("network_id", x.network_id)
                        , xmlelement("network_name", x.network_name)
                        , xmlelement("card_count", x.card_count)
                        , xmlelement("active_card_count", x.active_card_count)
                        , xmlelement("balance_amount", x.balance_amount)
                        , xmlelement("credit_count", x.credit_count)
                        , xmlelement("credit_amount", x.credit_amount)
                        , xmlelement("credit_mobile_count", x.credit_mobile_count)
                        , xmlelement("credit_mobile_amount", x.credit_mobile_amount)
                        , xmlelement("debit_count", x.debit_count)
                        , xmlelement("debit_amount", x.debit_amount)
                        , xmlelement("debit_bank_count", x.debit_bank_count)
                        , xmlelement("debit_bank_amount", x.debit_bank_amount)
                        , xmlelement("debit_bank_other_count", x.debit_bank_other_count)
                        , xmlelement("debit_bank_other_amount", x.debit_bank_other_amount)
                        , xmlelement("debit_cash_count", x.debit_cash_count)
                        , xmlelement("debit_cash_amount", x.debit_cash_amount)
                      )
                  ) xml
             from (
                    select customer_type
                         , case when pmode is not null and customer_type is null and contract_type is null and network_id is null then 8
                                when pmode is not null and customer_type is null and contract_type is null and network_id is not null then 7
                                when pmode is not null and customer_type is not null and contract_type is null and network_id is not null then 6
                                when pmode is not null and customer_type is not null and contract_type is not null and network_id is not null then 5
                                when pmode is null and customer_type is null and contract_type is null and network_id is null then 4
                                when pmode is null and customer_type is null and contract_type is null and network_id is not null then 3
                                when pmode is null and customer_type is not null and contract_type is null and network_id is not null then 2
                                when pmode is null and customer_type is not null and contract_type is not null and network_id is not null then 1
                           end as row_type
                         , pmode
                         , contract_type
                         , network_id
                         , com_api_flexible_data_pkg.get_flexible_value (
                                 i_field_name      => 'NETWORK_NAME_CBRF250'
                               , i_entity_type     => net_api_const_pkg.ENTITY_TYPE_NETWORK
                               , i_object_id       => network_id
                           ) as network_name
                         , card_count
                         , active_card_count
                         , /*to_char(*/balance_amount/*, com_api_const_pkg.XML_FLOAT_FORMAT)*/ as balance_amount
                         , to_char(credit_count) as credit_count
                         , /*to_char(*/credit_amount/*, com_api_const_pkg.XML_FLOAT_FORMAT)*/ as credit_amount
                         , to_char(credit_mobile_count) as credit_mobile_count
                         , /*to_char(*/credit_mobile_amount/*, com_api_const_pkg.XML_FLOAT_FORMAT)*/ as credit_mobile_amount
                         , to_char(debit_count) as debit_count
                         , /*to_char(*/debit_amount/*, com_api_const_pkg.XML_FLOAT_FORMAT)*/ as debit_amount
                         , to_char(debit_bank_count) as debit_bank_count
                         , /*to_char(*/debit_bank_amount/*, com_api_const_pkg.XML_FLOAT_FORMAT)*/ as debit_bank_amount
                         , to_char(debit_bank_other_count) as debit_bank_other_count
                         , /*to_char(*/debit_bank_other_amount/*, com_api_const_pkg.XML_FLOAT_FORMAT)*/ as debit_bank_other_amount
                         , to_char(debit_cash_count) as debit_cash_count
                         , /*to_char(*/debit_cash_amount/*, com_api_const_pkg.XML_FLOAT_FORMAT)*/ as debit_cash_amount
                      from ( select customer_type
                                  , contract_type
                                  , network_id
                                  , null as pmode
                                  , sum(card_count) as card_count
                                  , sum(active_card_count) as active_card_count
                                  , sum(balance_amount) as balance_amount
                                  , sum(credit_count) as credit_count
                                  , sum(credit_amount) as credit_amount
                                  , sum(credit_mobile_count) as credit_mobile_count
                                  , sum(credit_mobile_amount) as credit_mobile_amount
                                  , sum(debit_count) as debit_count
                                  , sum(debit_amount) as debit_amount
                                  , sum(debit_bank_count) as debit_bank_count
                                  , sum(debit_bank_amount) as debit_bank_amount
                                  , sum(debit_bank_other_count) as debit_bank_other_count
                                  , sum(debit_bank_other_amount) as debit_bank_other_amount
                                  , sum(debit_cash_count) as debit_cash_count
                                  , sum(debit_cash_amount) as debit_cash_amount
                               from rus_form_259_1_report
                              where inst_id     = i_inst_id
                                and report_date = trunc(i_start_date, 'Q')
                           group by customer_type
                                  , contract_type
                                  , network_id
                           )
                  order by pmode nulls last
                         , network_id nulls first
                         , decode (customer_type, null, null
                                                , com_api_const_pkg.ENTITY_TYPE_PERSON, 1
                                                , com_api_const_pkg.ENTITY_TYPE_UNDEFINED, 2
                                                , com_api_const_pkg.ENTITY_TYPE_COMPANY, 3) nulls first
                         , decode (contract_type, null, null
                                                , prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD, 1) nulls first
                  ) x
           ) t;

    select xmlelement("report"
             , l_header
             , l_part_1
             , l_footer
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'rus_api_form_259_pkg.run_rpt_form_259_1 - ok');

exception
    when others 
    then trc_log_pkg.debug(i_text => sqlerrm);
         raise_application_error(-20001, sqlerrm);
end run_rpt_form_259_1;

procedure run_rpt_form_259_2(
    o_xml                 out clob
  , i_lang             in     com_api_type_pkg.t_dict_value
  , i_inst_id          in     com_api_type_pkg.t_tiny_id
  , i_agent_id         in     com_api_type_pkg.t_short_id   default null
  , i_start_date       in     date
  , i_end_date         in     date
)
is
    l_result        xmltype;
    l_part_2        xmltype;
    l_header        xmltype;
    l_footer        xmltype;
begin
    trc_log_pkg.debug(
        i_text         => 'rus_api_form_259_pkg.run_rpt_form_259_2 [#1][#2][#3][#4]'
      , i_env_param1   => i_lang
      , i_env_param2   => i_inst_id
      , i_env_param3   => i_agent_id
      , i_env_param4   => i_start_date
    );

    get_header_footer (
        i_lang         => i_lang
      , i_inst_id      => i_inst_id
      , i_agent_id     => i_agent_id
      , i_date_end     => i_end_date
      , o_header       => l_header
      , o_footer       => l_footer
    ) ;

    -- data
    select xmlelement("part2", xmlagg(t.xml))
      into l_part_2
      from (
           select xmlagg( 
                      xmlelement("table"
                        , xmlelement("customer_type", x.customer_type)
                        , xmlelement("row_type", x.row_type)
                        , xmlelement("pmode", x.pmode)
                        , xmlelement("contract_type", x.contract_type)
                        , xmlelement("network_id", x.network_id)
                        , xmlelement("network_name", x.network_name)
                        , xmlelement("legal_foreign_count", x.legal_foreign_count)
                        , xmlelement("legal_foreign_amount", x.legal_foreign_amount)
                        , xmlelement("person_foreign_count", x.person_foreign_count)
                        , xmlelement("person_foreign_amount", x.person_foreign_amount)
                        , xmlelement("legal_domestic_count", x.legal_domestic_count)
                        , xmlelement("legal_domestic_amount", x.legal_domestic_amount)
                        , xmlelement("person_domestic_count", x.person_domestic_count)
                        , xmlelement("person_domestic_amount", x.person_domestic_amount)
                      )
                  ) xml
             from (
                    select customer_type
                         , case when pmode is not null and customer_type is null and contract_type is null and network_id is null then 8
                                when pmode is not null and customer_type is null and contract_type is null and network_id is not null then 7
                                when pmode is not null and customer_type is not null and contract_type is null and network_id is not null then 6
                                when pmode is not null and customer_type is not null and contract_type is not null and network_id is not null then 5
                                when pmode is null and customer_type is null and contract_type is null and network_id is null then 4
                                when pmode is null and customer_type is  null and contract_type is null and network_id is not null then 3
                                when pmode is null and customer_type is not null and contract_type is null and network_id is not null then 2
                                when pmode is null and customer_type is not null and contract_type is not null and network_id is not null then 1
                           end as row_type
                         , pmode
                         , contract_type
                         , network_id
                         , com_api_flexible_data_pkg.get_flexible_value (
                                 i_field_name      => 'NETWORK_NAME_CBRF250'
                               , i_entity_type     => net_api_const_pkg.ENTITY_TYPE_NETWORK
                               , i_object_id       => network_id
                           ) as network_name
                         , to_char(legal_foreign_count) as legal_foreign_count
                         , /*to_char(*/legal_foreign_amount/*, com_api_const_pkg.XML_FLOAT_FORMAT)*/ as legal_foreign_amount
                         , to_char(person_foreign_count) as person_foreign_count
                         , /*to_char(*/person_foreign_amount/*, com_api_const_pkg.XML_FLOAT_FORMAT)*/ as person_foreign_amount
                         , to_char(legal_domestic_count) as legal_domestic_count
                         , /*to_char(*/legal_domestic_amount/*, com_api_const_pkg.XML_FLOAT_FORMAT)*/ as legal_domestic_amount
                         , to_char(person_domestic_count) as person_domestic_count
                         , /*to_char(*/person_domestic_amount/*, com_api_const_pkg.XML_FLOAT_FORMAT)*/ as person_domestic_amount
                      from ( select customer_type
                                  , contract_type
                                  , network_id
                                  , sum(legal_foreign_count) as legal_foreign_count
                                  , sum(legal_foreign_amount) as legal_foreign_amount
                                  , sum(person_foreign_count) as person_foreign_count
                                  , sum(person_foreign_amount) as person_foreign_amount
                                  , sum(legal_domestic_count) as legal_domestic_count
                                  , sum(legal_domestic_amount) as legal_domestic_amount
                                  , sum(person_domestic_count) as person_domestic_count
                                  , sum(person_domestic_amount) as person_domestic_amount
                                  , null as pmode
                               from rus_form_259_2_report
                              where inst_id     = i_inst_id
                                and report_date = trunc(i_start_date, 'Q')
                           group by customer_type
                                  , contract_type
                                  , network_id
                           )
                  order by pmode nulls last
                         , network_id nulls first
                         , decode (customer_type, null, null
                                                , com_api_const_pkg.ENTITY_TYPE_PERSON, 1
                                                , com_api_const_pkg.ENTITY_TYPE_UNDEFINED, 2
                                                , com_api_const_pkg.ENTITY_TYPE_COMPANY, 3) nulls first
                         , decode (contract_type, null, null
                                                , prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD, 1) nulls first
                  ) x
           ) t;

    select xmlelement("report"
             , l_header
             , l_part_2
             , l_footer
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'rus_api_form_259_pkg.run_rpt_form_259_2 - ok');

exception
    when others 
    then trc_log_pkg.debug(i_text => sqlerrm);
         raise_application_error(-20001, sqlerrm);
end run_rpt_form_259_2;

---------------------------
end;
/
