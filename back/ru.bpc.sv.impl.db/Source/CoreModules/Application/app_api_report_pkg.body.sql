create or replace package body app_api_report_pkg is
/*********************************************************
 *  API for Report Document in application <br />
 *  Created by Kryukov E.(krukov@bpcbt.com)  at 19.07.2012 <br />
 *  Last changed by Gogolev I.(i.gogolev@bpcbt.com) <br />
 *  at 30.09.2016 18:34:00                          <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: APP_API_REPORT_PKG  <br />
 *  @headcom
 **********************************************************/
 
procedure process_report(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
) is
    l_document_id_tab      com_api_type_pkg.t_number_tab;
    l_contract_id_tab      com_api_type_pkg.t_number_tab;
    l_object_data_id       com_api_type_pkg.t_long_id;
    l_document_id          com_api_type_pkg.t_long_id;
begin
    app_api_application_pkg.get_appl_data_id(
        i_element_name    => 'CONTRACT'
      , i_parent_id       => app_api_application_pkg.get_customer_appl_data_id
      , o_appl_data_id    => l_contract_id_tab
    );

    trc_log_pkg.debug('Contract objects count=' || nvl(l_contract_id_tab.count, 0));

    for i in 1..nvl(l_contract_id_tab.count,0)
    loop
        app_api_application_pkg.get_appl_data_id(
            i_element_name    => 'DOCUMENT'
          , i_parent_id       => l_contract_id_tab(i)
          , o_appl_data_id    => l_document_id_tab
        );

        trc_log_pkg.debug('documents objects count=' || nvl(l_document_id_tab.count, 0));

        for j in 1..nvl(l_document_id_tab.count,0)
        loop
            app_api_application_pkg.get_element_value(
                i_element_name       => 'DOCUMENT_OBJECT'
                , i_parent_id        => l_document_id_tab(j)
                , o_element_value    => l_object_data_id
            );

            if l_object_data_id is not null and l_object_data_id = i_appl_data_id then
            -- get document_id
                select
                    to_number(max(a.element_value), com_api_const_pkg.NUMBER_FORMAT)
                into
                    l_document_id
                from
                    app_data a
                where
                    a.id = l_document_id_tab(j);

                --update document
                trc_log_pkg.info(
                    i_text    => 'update document link: document_id=' || l_document_id ||
                                 ', new entity_type = ' || i_entity_type ||
                                 ', new object_id = ' || i_object_id
                );

                update
                    rpt_document a
                set
                    a.entity_type = i_entity_type
                  , a.object_id   = i_object_id
                where
                    a.id = l_document_id;
            end if;
        end loop;
    end loop;

end process_report;

procedure appl_response(
    o_xml                  out   clob
  , i_application_id    in       com_api_type_pkg.t_long_id     default null
  , i_lang              in       com_api_type_pkg.t_dict_value  default null
) is
    l_result            xmltype;
    l_customer_id_tab    num_tab_tpt;
    l_logo_path         xmltype;
begin
    if i_application_id is not null then
        select o.object_id 
          bulk collect into l_customer_id_tab
          from app_object o
         where o.appl_id = i_application_id
           and o.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER;
    else
        select c.id
          bulk collect into l_customer_id_tab
          from prd_customer c
         where c.status = prd_api_const_pkg.CUSTOMER_STATUS_ACTIV_REQUIRED
         ;
    end if;
    
    trc_log_pkg.debug(
        i_text       => 'application_responses [#1], l_customer_id_tab.count [#2]'
      , i_env_param1 => i_application_id
      , i_env_param2 => l_customer_id_tab.count
    );
    l_logo_path := rpt_api_template_pkg.logo_path_xml;
    select xmlelement("report"
             , xmlagg(
                   xmlelement("application"  
                     , l_logo_path
                     , xmlelement("application_id", i_application_id)
                     , xmlelement("inst_id", c.inst_id)
                     , xmlelement("customer_number", c.customer_number)
                     , xmlelement("first_name", p.first_name)
                     , xmlelement("second_name", p.second_name)
                     , xmlelement("surname", p.surname)
                     , xmlelement("customer_status", c.status)
                     , xmlelement("contract_type", ct.contract_type)
                     , xmlelement("contract_number", ct.contract_number)
                     , xmlelement("product_id", ct.product_id)
                     , xmlelement("product_number", pr.product_number)
                     , xmlelement("card_number", iss_api_card_pkg.get_card_mask(i_card_number =>  cn.card_number))
                     , xmlelement("expir_date", to_char(ci.expir_date, com_api_const_pkg.DATE_FORMAT))
                     , xmlelement("card_state", ci.state)
                     , xmlelement("card_status", ci.status)
                     , xmlelement("card_seq_number", ci.seq_number)
                     , xmlelement("agent_id", ct.agent_id)
                     , xmlelement("card_type_id", ic.card_type_id)
                     , xmlelement("cardholder_number", ch.cardholder_number)
                     , xmlelement("cardholder_name", ci.cardholder_name)
                     , xmlelement("company_name", ci.company_name)
                     , xmlelement("account_number", ac.account_number)
                     , xmlelement("account_type", ac.account_type)
                     , xmlelement("account_currency", ac.currency)
                     , xmlelement("account_status", ac.status)
                   )
               )
           )
      into l_result
      from prd_customer c
         , com_person p
         , prd_contract ct
         , prd_product pr
         , iss_card ic
         , iss_card_number cn
         , iss_card_instance ci
         , iss_cardholder ch
         , acc_account_object ao
         , acc_account ac
     where c.id in (select column_value from table(cast(l_customer_id_tab as num_tab_tpt)))
       and case when c.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON then c.object_id end = p.id(+)
       and c.contract_id     = ct.id
       and ct.product_id     = pr.id
       and c.id              = ic.customer_id(+)
       and ic.id             = cn.card_id(+)
       and iss_api_card_instance_pkg.get_card_instance_id(i_card_id => ic.id) = ci.id(+)
       and ic.cardholder_id  = ch.id(+)
       and ic.id             = ao.object_id(+)
       and ao.entity_type(+) = iss_api_const_pkg.ENTITY_TYPE_CARD
       and ao.account_id     = ac.id(+);

	if l_result.getclobval() = '<report></report>' then
        trc_log_pkg.warn(
            i_text       => 'Report has been returned empty result.'
        );
    end if;

    o_xml := l_result.getclobval();
exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );          
end;

procedure process_rejected_application(
    o_xml                  out   clob
  , i_event_type        in       com_api_type_pkg.t_dict_value  default null
  , i_eff_date          in       date                           default null
  , i_entity_type       in       com_api_type_pkg.t_dict_value
  , i_object_id         in       com_api_type_pkg.t_long_id
  , i_inst_id           in       com_api_type_pkg.t_inst_id     default null
  , i_lang              in       com_api_type_pkg.t_dict_value  default null  
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_rejected_application: ';
    l_result              xmltype;
    l_inst_id             com_api_type_pkg.t_tiny_id := nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST);
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'start i_event_type [#1], i_eff_date [#2], i_entity_type [#3], i_object_id [#4], i_inst_id [#5], i_lang [#6]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_eff_date
      , i_env_param3 => i_entity_type
      , i_env_param4 => i_object_id
      , i_env_param5 => i_inst_id
      , i_env_param6 => i_lang
    );
 
    if i_event_type != app_api_const_pkg.EVENT_APPL_CUST_REJECTED then
        com_api_error_pkg.raise_error(
            i_error       => 'EVENT_TYPE_NOT_SUPPORT_IN_PROC'
          , i_env_param1  => i_event_type
          , i_env_param2  => i_entity_type
          , i_env_param3  => 'process_rejected_application'
        );
    end if;
    
    if i_entity_type != app_api_const_pkg.ENTITY_TYPE_APPLICATION then
        com_api_error_pkg.raise_error(
            i_error       => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1  => i_entity_type
        );
    end if;
    
    select xmlelement("report"
             , xmlelement("appl_id"          , a.id)
             , xmlelement("flow_id"          , a.flow_id)
             , xmlelement("appl_status"      , a.appl_status)
             , xmlelement("reject_code"      , a.reject_code)
             , xmlelement("reject_code_name" , com_api_dictionary_pkg.get_article_text(a.reject_code
                                                                                     , i_lang))
             , xmlelement("inst_id"          , a.inst_id)
             , xmlelement("agent_number"     , ag.agent_number)
             , xmlelement("customer_number"  , c.customer_number)
             , xmlelement("contract_number"  , co.contract_number)
             , xmlelement("first_name"       , p.first_name)
             , xmlelement("second_name"      , p.second_name)
             , xmlelement("surname"          , p.surname)
             , xmlelement("change_date"      , ah.change_date)
           )
      into l_result
      from app_application a
      left join ost_agent ag on a.agent_id = ag.id
      left join (select appl_id
                      , change_date
                   from (select appl_id
                              , change_date
                              , row_number() over (partition by appl_id order by id desc) rn
                           from app_history)
                  where rn = 1 
                ) ah on a.id = ah.appl_id
      -- find out customer by application data
      left join (select appl_id
                      , customer_id
                   from (select appl_id
                              , object_id as customer_id
                              , row_number() over (partition by appl_id order by object_id) rn
                           from app_object
                          where entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER -- 'ENTTCUST'
                        )
                   where rn = 1
                ) ao on ao.appl_id = a.id
      left join prd_customer c on c.id = ao.customer_id
      left join prd_contract co on co.id = c.contract_id
      left join com_person p on c.object_id = p.id 
                            and c.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON -- 'ENTTPERS'
     where a.id = i_object_id
       and (a.inst_id = l_inst_id or l_inst_id = ost_api_const_pkg.DEFAULT_INST);

    o_xml := l_result.getclobval();
    
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'done'
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ' failed ' || sqlerrm
        );
        raise;
end process_rejected_application;

end app_api_report_pkg;
/
