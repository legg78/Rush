create or replace package body rus_api_form_407_pkg is

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
    l_contact_data  com_api_type_pkg.t_full_desc;
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
               select max(decode(d.commun_method, com_api_const_pkg.COMMUNICATION_METHOD_MOBILE,commun_address, null)) as phone
                    , max(decode(d.commun_method, com_api_const_pkg.COMMUNICATION_METHOD_EMAIL,commun_address, null)) as e_mail
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
             , xmlelement("date", to_char(i_date_end, 'q yyyy', 'nls_date_language = russian' ))
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

procedure run_rpt_form_407_3 (
    o_xml                 out clob
  , i_lang             in     com_api_type_pkg.t_dict_value
  , i_inst_id          in     com_api_type_pkg.t_tiny_id
  , i_agent_id         in     com_api_type_pkg.t_short_id   default null
  , i_start_date       in     date
  , i_end_date         in     date
)
is
    l_result        xmltype;
    l_part_3        xmltype;
    l_header        xmltype;
    l_footer        xmltype;
begin
    trc_log_pkg.debug(
        i_text         => 'rus_api_form_407_pkg.run_rpt_form_407_3 [#1][#2][#3][#4]'
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
    select xmlelement("part3", xmlagg(t.xml))
      into l_part_3
      from (
           select xmlagg( 
                      xmlelement("table"
                        , xmlelement("transaction_direction", x.transaction_direction)
                        , xmlelement("counterparty", x.counterparty)
                        , xmlelement("country", x.country)
                        , xmlelement("currency", x.currency)
                        , xmlelement("network_id", x.network_id)
                        , xmlelement("network_name", x.network_name)
                        , xmlelement("oper_count", x.oper_count)
                        , xmlelement("oper_amount", x.oper_amount)
                      )
                  ) xml
             from (
                    select transaction_direction
                         , counterparty
                         , country
                         , currency
                         , network_id
                         , get_text ('net_network', 'name', network_id, i_lang ) as network_name
                         , to_char(oper_count) as oper_count
                         , to_char(oper_amount, com_api_const_pkg.XML_FLOAT_FORMAT) as oper_amount
                      from rus_form_407_3_report
                     where inst_id     = i_inst_id
                       and report_date = trunc(i_start_date, 'Q')
                     order by network_id
                  ) x
           ) t;

    select xmlelement("report"
             , l_header
             , l_part_3
             , l_footer
           )
      into l_result
      from dual;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug(i_text => 'rus_api_form_407_pkg.run_rpt_form_407_3 - ok');

exception
    when others 
    then trc_log_pkg.debug(i_text => sqlerrm);
         raise_application_error(-20001, sqlerrm);
end run_rpt_form_407_3;

---------------------------
end;
/
