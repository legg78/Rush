create or replace package body app_api_notification_pkg is
/*******************************************************************
*  API for notification processing in application's structure <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 18.01.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_API_NOTIFICATION_PKG <br />
*  @headcom
******************************************************************/

procedure process_notification(
    i_appl_data_id         in      com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in      com_api_type_pkg.t_long_id
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_inst_id              in      com_api_type_pkg.t_tiny_id
  , i_customer_id          in      com_api_type_pkg.t_long_id
  , i_linked_object_id     in      com_api_type_pkg.t_long_id       default null
  , o_custom_event_id      out     com_api_type_pkg.t_medium_id  
  , o_is_active            out     com_api_type_pkg.t_boolean  
) is
    l_id                   com_api_type_pkg.t_medium_id;
    l_event_id             com_api_type_pkg.t_medium_id;
    l_channel              com_api_type_pkg.t_tiny_id;
    l_is_active            com_api_type_pkg.t_boolean;
    l_address              com_api_type_pkg.t_full_desc;
    l_event_type           com_api_type_pkg.t_dict_value;
    l_contact_type         com_api_type_pkg.t_dict_value;
    l_command              com_api_type_pkg.t_dict_value;
    l_params               com_api_type_pkg.t_param_tab;
    l_sysdate              date := get_sysdate();
    l_start_date           date;
    l_end_date             date;
    l_ntf_start_date       date;
    l_ntf_end_date         date;

    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_notification: ';
begin
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START i_appl_data_id=' || ' i_entity_type=' || i_entity_type || ' i_object_i=' || i_object_id
                             || ' i_inst_id=' || i_inst_id || ' i_customer_id=' || i_customer_id || ' i_linked_object_id=' || i_linked_object_id
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'DELIVERY_ADDRESS'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_address
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'DELIVERY_CHANNEL'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_channel
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'IS_ACTIVE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_is_active
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'NOTIFICATION_EVENT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_event_type
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CONTACT_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_contact_type
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'START_DATE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_start_date
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'END_DATE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_end_date
    );

    if l_event_type is not null then
        select min(id)
          into l_event_id
          from ntf_scheme_event
         where event_type = l_event_type;

        if l_event_id is null then
            com_api_error_pkg.raise_error(
                i_error         => 'CANNOT_FIND_NOTIFICATION_EVENT'
              , i_env_param1    => l_event_type
            );
        end if;
    end if;
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'l_event_id=' || l_event_id || ' l_event_type=' || l_event_type || 'l_start_date=' || l_start_date || ' l_end_date=' || l_end_date
    );

    begin
        select id
             , start_date
             , end_date
          into l_id
             , l_ntf_start_date
             , l_ntf_end_date
          from ntf_custom_event
         where object_id        = i_object_id
           and entity_type      = i_entity_type
           and (event_type      = l_event_type   or (event_type   is null and l_event_type   is null))
           and (contact_type    = l_contact_type or (contact_type is null and l_contact_type is null))
           and delivery_address = l_address
           and channel_id       = l_channel;
    exception
        when no_data_found then
            null;
    end;

    if l_id is not null then
        -- event found
        if l_command = app_api_const_pkg.COMMAND_CREATE_OR_PROCEED then
            null;
        elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error(
                i_error      => 'NOTIF_EVENT_ALREADY_EXIST'
              , i_env_param1 => i_object_id
              , i_env_param2 => i_entity_type
              , i_env_param3 => l_event_id
              , i_env_param4 => l_event_type
            );
        elsif l_command in (
                  app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
              )
        then
            ntf_api_custom_pkg.set_event_with_object( 
                io_id               => l_id
              , i_event_type        => l_event_type
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_channel_id        => l_channel
              , i_delivery_address  => l_address
              , i_delivery_time     => ntf_api_const_pkg.DEFAULT_DELIVERY_TIME
              , i_status            => null
              , i_mod_id            => null
              , i_start_date        => coalesce(l_start_date, l_ntf_start_date, l_sysdate) 
              , i_end_date          => case when l_is_active = com_api_const_pkg.FALSE
                                            then coalesce(l_end_date, l_ntf_end_date, l_sysdate)
                                            else l_end_date
                                       end
              , i_customer_id       => i_customer_id
              , i_contact_type      => l_contact_type
              , i_linked_object_id  => i_linked_object_id
              , i_is_active         => l_is_active
            );
        else
            null;
        end if;
    else
        if l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
            null;
        elsif l_command in (
                  app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
                , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
              )
        then
            com_api_error_pkg.raise_error(
                i_error      => 'NOTIF_EVENT_NOT_FOUND'
              , i_env_param1 => i_object_id
              , i_env_param2 => i_entity_type
              , i_env_param3 => l_event_id
              , i_env_param4 => l_event_type
            );
        --elsif l_command in (
        --          app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
        --        , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
        --        , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
        --      )
        else
            ntf_api_custom_pkg.set_event_with_object( 
                io_id               => l_id
              , i_event_type        => l_event_type
              , i_entity_type       => i_entity_type
              , i_object_id         => i_object_id
              , i_channel_id        => l_channel
              , i_delivery_address  => l_address
              , i_delivery_time     => ntf_api_const_pkg.DEFAULT_DELIVERY_TIME
              , i_status            => null
              , i_mod_id            => null
              , i_start_date        => coalesce(l_start_date, l_sysdate) 
              , i_end_date          => case when l_is_active = com_api_const_pkg.FALSE
                                            then coalesce(l_end_date, l_sysdate)
                                            else l_end_date
                                       end
              , i_customer_id       => i_customer_id
              , i_contact_type      => l_contact_type
              , i_linked_object_id  => i_linked_object_id
              , i_is_active         => l_is_active
            );
            
            evt_api_event_pkg.register_event(
                i_event_type   => ntf_api_const_pkg.EVNT_CHNG_NTF_ADDR
              , i_eff_date     => null
              , i_entity_type  => i_entity_type
              , i_object_id    => i_object_id
              , i_inst_id      => i_inst_id
              , i_split_hash   => null
              , i_param_tab    => l_params
            );
        end if;
    end if;
   
    o_custom_event_id := l_id;  
    o_is_active       := l_is_active;  
    
    trc_log_pkg.debug(LOG_PREFIX || 'END o_custom_event_id=' || o_custom_event_id || ' o_is_active=' || o_is_active);

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'NOTIFICATION'
        );
end;

procedure report_user_appl_changed(
    o_xml                  out     clob
  , i_event_type           in      com_api_type_pkg.t_dict_value    default null
  , i_eff_date             in      date                             default null
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_object_id            in      com_api_type_pkg.t_long_id
  , i_inst_id              in      com_api_type_pkg.t_inst_id       default ost_api_const_pkg.DEFAULT_INST
  , i_lang                 in      com_api_type_pkg.t_dict_value
) is
    l_result            xmltype;
begin
     trc_log_pkg.debug (
        i_text       => 'Application changed notification [#1] [#2] [#3] [#4] [#5]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );

    if i_entity_type = app_api_const_pkg.ENTITY_TYPE_APPLICATION then

        select xmlelement("report"
                    , xmlelement("application_id", appl_id)
                    , xmlelement("appl_status", com_api_dictionary_pkg.get_article_text(
                                                    i_article => appl_status
                                                  , i_lang    => nvl(i_lang, get_user_lang)
                                                )
                      )
                    , xmlelement("comments", comments)  
                    , xmlelement("person_name", acm_ui_user_pkg.get_user_full_name(i_user_id => change_user))
               )
         into l_result
         from app_history
        where appl_id = i_object_id
          and id in (select first_value(id) over (partition by appl_id order by change_date desc, id desc)
                       from app_history
                      where appl_id = i_object_id
                        and substr(change_action, 1, 4) = evt_api_const_pkg.EVENT_KEY
                        and ( i_event_type is null
                           or i_event_type = change_action
                            )
                        and ( i_eff_date is null
                           or change_date <= i_eff_date
                            ));

        o_xml := l_result.getclobval();
    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => i_entity_type
        );
    end if;
exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );      
end report_user_appl_changed;

end;
/
