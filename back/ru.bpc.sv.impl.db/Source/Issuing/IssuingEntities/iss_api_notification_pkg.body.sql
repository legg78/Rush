create or replace package body iss_api_notification_pkg as

procedure report_card_status (
    o_xml                  out  clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
) is
    l_result            xmltype;
begin
     trc_log_pkg.debug (
        i_text       => 'Card status notification [#1] [#2] [#3] [#4] [#5]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );
    
    select xmlelement("report",
            xmlagg(case x.rn when 1 then xmlelement("change_date", to_char(x.change_date, com_api_const_pkg.XML_DATETIME_FORMAT)) else null end)
          , xmlagg(case x.rn when 1 then xmlelement("card_mask", x.card_mask) else null end)  
          , xmlagg(
                case x.rn 
                when 1 then 
                    xmlelement("new_status", com_api_dictionary_pkg.get_article_text(i_article => x.status, i_lang => i_lang)) 
                else null 
                end
            )
          , xmlagg(
                case x.rn 
                when 2 then 
                    xmlelement("old_status", com_api_dictionary_pkg.get_article_text(i_article => x.status, i_lang => i_lang))  
                else null 
                end
            )  
       )
      into l_result    
      from (
            select l.object_id
                 , l.change_date
                 , l.status
                 , iss_api_card_pkg.get_card_mask(n.card_number) card_mask
                 , row_number() over (order by l.change_date desc) rn
              from evt_status_log l
                 , iss_card_instance ci
                 , iss_card c
                 , iss_card_number n
             where l.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
               and l.status like 'CSTS%'
               and l.object_id = i_object_id 
               and ci.id = l.object_id
               and c.id = ci.card_id
               and n.card_id = c.id  
             order by l.change_date desc 
      ) x
    where x.rn <= 2;
    
    o_xml := l_result.getclobval();
    
exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );      
end;

procedure report_card_event (
    o_xml                  out  clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
) is
    l_result            xmltype;
    l_object_id         com_api_type_pkg.t_long_id;
begin
     trc_log_pkg.debug (
        i_text       => 'Card event notification [#1] [#2] [#3] [#4] [#5]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );
    
    l_object_id := i_object_id;
    
    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        
        select card_id
          into l_object_id
          from iss_card_instance 
         where id = l_object_id;
    end if;
    
    select xmlelement("report"
                , xmlelement("card_mask", iss_api_card_pkg.get_card_mask(n.card_number))
                , xmlelement("network_type", get_text (i_table_name    => 'net_network'
                                                     , i_column_name   => 'name'
                                                     , i_object_id     => ct.network_id
                                                     , i_lang          => i_lang)
                            )
                     )                               
     into l_result
     from iss_card c
        , net_card_type ct
        , iss_card_number n
    where c.id = l_object_id 
      and c.card_type_id = ct.id
      and n.card_id = c.id;   
      
    o_xml := l_result.getclobval();  

exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );          
end;    

procedure report_card_expire (
    o_xml                  out  clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_lang              in      com_api_type_pkg.t_dict_value
) is
    l_result            xmltype;
begin
     trc_log_pkg.debug (
        i_text       => 'Card expire notification [#1] [#2] [#3] [#4] [#5]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );

    select xmlelement("report"
                , xmlelement("card_mask", iss_api_card_pkg.get_card_mask(n.card_number))
                , xmlelement("network_type", get_text (i_table_name    => 'net_network'
                                                     , i_column_name   => 'name'
                                                     , i_object_id     => ct.network_id
                                                     , i_lang          => i_lang)
                            )
                , xmlelement("expire_date", to_char(ci.expir_date, com_api_const_pkg.XML_DATE_FORMAT))  
           )
     into l_result
     from iss_card_instance ci
        , iss_card c
        , net_card_type ct
        , iss_card_number n
    where ci.id = i_object_id 
      and ci.card_id = c.id
      and c.card_type_id = ct.id
      and n.card_id = c.id;   

    o_xml := l_result.getclobval();
   
exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );      
end;   

procedure report_card_by_branch(
    o_xml                  out  clob
  , i_event_type        in      com_api_type_pkg.t_dict_value
  , i_eff_date          in      date
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id       default NULL
  , i_lang              in      com_api_type_pkg.t_dict_value    default NULL
) is
    l_result                    xmltype;
    l_lang                      com_api_type_pkg.t_dict_value;
    l_credit_service_id         com_api_type_pkg.t_short_id;
    l_sysdate                   date;
begin
    trc_log_pkg.debug (
        i_text       => 'Delivered card by branch [#1] [#2] [#3] [#4] [#5]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );
    
    l_lang    := nvl(i_lang, get_user_lang);
    l_sysdate := get_sysdate;
    
    -- convert instance to the card, if required, others entities are not supported
    if i_entity_type != iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        com_api_error_pkg.raise_error(
            i_error             => 'UNSUPPORTED_ENTITY_TYPE'
          , i_env_param1        => i_entity_type
        );
    end if;
    
    begin
        -- check credit service
        select prd_api_service_pkg.get_active_service_id (
                   i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 , i_object_id         => aao.account_id
                 , i_attr_name         => null
                 , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
                 , i_split_hash        => aao.split_hash
                 , i_eff_date          => i_eff_date
                 , i_mask_error        => com_api_const_pkg.TRUE
                 , i_inst_id           => ic.inst_id
               )
          into l_credit_service_id
          from acc_account_object aao
             , iss_card_instance ici
             , iss_card ic
         where aao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
           and aao.object_id   = ici.card_id
           and ici.id          = i_object_id
           and ici.card_id     = ic.id;   
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error => 'REPORT_DATA_NOT_FOUND'
            );
    end;

    begin
        select xmlelement("report"
                 , xmlelement("card_mask", card_mask)
                 , xmlelement("short_card_mask", short_card_mask)
                 , xmlelement("card_type", case when is_prepaid = 1
                                                then 'Prepaid Card'
                                                when is_credit  = 1
                                                then 'Khidmah Card'
                                                else 'Debit Card'
                                           end
                   )
                 , xmlelement("cardholder_name", cardholder_name)
                 , xmlelement("agent_name", agent_name)
                 , xmlelement("agent_phone", agent_phone)
              )             
         into l_result
         from (
                select iss_api_card_pkg.get_card_mask(
                           i_card_number => icn.card_number
                       ) as card_mask
                     , iss_api_card_pkg.get_short_card_mask(
                           i_card_number => icn.card_number
                       ) as short_card_mask
                     , ici.cardholder_name
                     , ost_ui_agent_pkg.get_agent_name(
                           i_agent_id => ici.agent_id
                         , i_lang     => l_lang
                       ) as agent_name
                     , coalesce(com_api_contact_pkg.get_contact_string(
                                    i_contact_id    => cco.contact_id
                                  , i_commun_method => com_api_const_pkg.COMMUNICATION_METHOD_PHONE
                                  , i_start_date    => l_sysdate
                                )
                              , com_api_contact_pkg.get_contact_string(
                                    i_contact_id    => cco.contact_id
                                  , i_commun_method => com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                                  , i_start_date    => l_sysdate
                                ) 
                         ) as agent_phone
                       , ic.id as card_id
                       , ic.inst_id
                       , case when con.contract_type = prd_api_const_pkg.CONTRACT_TYPE_PREPAID_CARD 
                              then 1      -- only Prepayd card contract
                              else 0
                         end as is_prepaid
                       , case when l_credit_service_id is not null
                              then 1
                              else 0
                         end as is_credit 
                  from iss_card_instance ici
                     , iss_card ic                  
                     , iss_card_number icn
                     , prd_contract con
                     , (select object_id
                             , contact_id
                          from (select object_id
                                     , contact_id
                                     , row_number() over (partition by entity_type, object_id order by id desc) rn
                                  from com_contact_object
                                 where entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT)
                         where rn = 1
                       ) cco
                 where ici.id         = i_object_id
                   and ic.id          = ici.card_id
                   and ic.id          = icn.card_id
                   and ici.state      = iss_api_const_pkg.CARD_STATE_DELIVERED
                   and cco.object_id(+)  = ici.agent_id
                   and (ici.inst_id   = i_inst_id or i_inst_id is null)
                   and ic.contract_id = con.id(+)
              ) x;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error => 'REPORT_DATA_NOT_FOUND'
            );
    end;

    if l_result is not null then        
        o_xml := l_result.getclobval();
    end if;        
    
    trc_log_pkg.debug(
        i_text       => 'END'
    );
    
exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );  
end;

end iss_api_notification_pkg;
/
