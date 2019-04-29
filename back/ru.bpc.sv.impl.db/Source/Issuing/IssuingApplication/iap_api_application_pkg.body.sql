create or replace package body iap_api_application_pkg as
/************************************************************
*  API for issuer application <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 26.02.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: IAP_API_APPLICATION_PKG <br />
*  @headcom
*************************************************************/

procedure search_agent_by_entities (
    i_appl_data_id  in      com_api_type_pkg.t_long_id
  , i_inst_id       in      com_api_type_pkg.t_inst_id
  , o_agent_id         out  com_api_type_pkg.t_medium_id
) is
    l_id_tab                com_api_type_pkg.t_number_tab;
    l_account_number        com_api_type_pkg.t_account_number;
    l_account               acc_api_type_pkg.t_account_rec;
    l_customer_appl_id      com_api_type_pkg.t_long_id;
    l_contract_appl_id      com_api_type_pkg.t_long_id;
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.search_agent_by_entities: ';
begin
    trc_log_pkg.debug(LOG_PREFIX || 'Start.');

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'CUSTOMER'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_customer_appl_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'CONTRACT'
      , i_parent_id     => l_customer_appl_id
      , o_appl_data_id  => l_contract_appl_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'ACCOUNT'
      , i_parent_id     => l_contract_appl_id
      , o_appl_data_id  => l_id_tab
    );

    if nvl(l_id_tab.count, 0) > 0 and app_api_error_pkg.g_app_errors.count = 0 then
        for i in 1..nvl(l_id_tab.count, 0) loop

            app_api_application_pkg.get_element_value(
                i_element_name   => 'ACCOUNT_NUMBER'
              , i_parent_id      => l_id_tab(i)
              , o_element_value  => l_account_number
            );
            trc_log_pkg.debug(LOG_PREFIX || 'l_account_number [' || l_account_number || ']');

            if l_account_number is not null then
                l_account := acc_api_account_pkg.get_account(
                    i_account_id     => null
                  , i_account_number => l_account_number
                  , i_inst_id        => i_inst_id
                  , i_mask_error     => com_api_const_pkg.TRUE
                );
                trc_log_pkg.debug(LOG_PREFIX || 'l_account.agent_id [' || l_account.agent_id || ']');

                if l_account.agent_id is not null then

                    o_agent_id := l_account.agent_id;
                    trc_log_pkg.debug(LOG_PREFIX || 'agent_id [' || o_agent_id || '] found by account');
                    return;

                end if;
            end if;
        end loop;
    end if;
end;

procedure process_application(
    i_appl_id              in            com_api_type_pkg.t_long_id  default null
) is
    l_root_id              com_api_type_pkg.t_long_id;
    l_customer_data_id     com_api_type_pkg.t_long_id;
    l_customer_id          com_api_type_pkg.t_long_id;
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_agent_id             com_api_type_pkg.t_short_id;
    l_appl_id              com_api_type_pkg.t_long_id;
    l_agent_number         com_api_type_pkg.t_name;
    l_customer_count       com_api_type_pkg.t_short_id;
    l_id_tab               com_api_type_pkg.t_number_tab;
begin

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'APPLICATION'
      , i_parent_id     => null
      , o_appl_data_id  => l_root_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'APPLICATION_ID'
      , i_parent_id     => l_root_id
      , o_element_value => l_appl_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'INSTITUTION_ID'
      , i_parent_id     => l_root_id
      , o_element_value => l_inst_id
    );

    rul_api_param_pkg.set_param(
        i_value         => l_inst_id
      , i_name          => 'INST_ID'
      , io_params       => app_api_application_pkg.g_params
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'AGENT_NUMBER'
      , i_parent_id     => l_root_id
      , o_element_value => l_agent_number
    );

    if l_agent_number is not null then
        begin

            select id
              into l_agent_id
              from ost_agent_vw
             where agent_number = l_agent_number
               and inst_id      = l_inst_id;

        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'AGENT_NOT_FOUND'
                    , i_env_param1  => l_agent_number
                );
        end;
    else
        app_api_application_pkg.get_element_value(
            i_element_name  => 'AGENT_ID'
          , i_parent_id     => l_root_id
          , o_element_value => l_agent_id
        );

        if l_agent_id is null then
            search_agent_by_entities(
                i_appl_data_id  => l_root_id
              , i_inst_id       => l_inst_id
              , o_agent_id      => l_agent_id
            );
        end if;

        begin
            select id
              into l_agent_id
              from ost_agent_vw
             where id = l_agent_id;

        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'AGENT_NOT_FOUND'
                  , i_env_param1  => l_agent_id
                );
        end;
    end if;

    rul_api_param_pkg.set_param(
        i_value         => l_agent_id
      , i_name          => 'AGENT_ID'
      , io_params       => app_api_application_pkg.g_params
    );

    -- process customer
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'CUSTOMER'
      , i_parent_id     => l_root_id
      , o_appl_data_id  => l_customer_data_id
    );

    if l_customer_data_id is not null then
        app_api_application_pkg.get_element_value(
            i_element_name  => 'CUSTOMER_COUNT'
          , i_parent_id     => l_customer_data_id
          , o_element_value => l_customer_count
        );

        l_customer_count := nvl(l_customer_count, 1);

        for i in 1..l_customer_count
        loop
            app_api_customer_pkg.process_customer(
                i_appl_data_id  => l_customer_data_id
              , i_inst_id       => l_inst_id
              , o_customer_id   => l_customer_id
              , i_pool_number   => i
            );

            if i <> l_customer_count then
                select d.id
                  bulk collect into l_id_tab
                  from app_element e
                     , app_data    d
                 where e.name           IN ('CARD_NUMBER', 'CARD_ID', 'ACCOUNT_NUMBER', 'CARDHOLDER_NAME', 'CARDHOLDER_NUMBER')
                   and d.appl_id        = l_appl_id
                   and d.element_id+0   = e.id;

                if l_id_tab.count > 0 then
                    for i in 1 .. l_id_tab.count loop
                        app_api_application_pkg.remove_element(i_appl_data_id => l_id_tab(i));
                    end loop;
                end if;
            end if;
        end loop;
    end if;

    app_api_flexible_field_pkg.process_flexible_fields(
        i_entity_type   => app_api_const_pkg.ENTITY_TYPE_APPLICATION
      , i_object_type   => null
      , i_object_id     => l_appl_id
      , i_inst_id       => l_inst_id
      , i_appl_data_id  => l_root_id
    );

    app_api_note_pkg.process_note(
        i_appl_data_id => l_appl_id
      , i_entity_type  => app_api_const_pkg.ENTITY_TYPE_APPLICATION
      , i_object_id    => l_appl_id
    );

-- Now we will process customer services.
-- We cannot do it in app_api_customer_pkg because contract is created later than customer.
-- We do it in app_api_contract_pkg before change_objects.

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => l_root_id
          , i_element_name  => 'APPLICATION'
        );

end process_application;

procedure process_rejected_application(
    i_appl_id              in            com_api_type_pkg.t_long_id
) is
    l_appl_id              com_api_type_pkg.t_long_id := i_appl_id;
    l_root_id              com_api_type_pkg.t_long_id;
    l_customer_data_id     com_api_type_pkg.t_long_id;
    l_customer_id          com_api_type_pkg.t_long_id;
    l_customer_number      com_api_type_pkg.t_name;
    l_inst_id              com_api_type_pkg.t_inst_id;
begin
    trc_log_pkg.debug(
        i_text       => 'process_rejected_application for appl_id [#1]'
      , i_env_param1 => l_appl_id
    );
    
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'APPLICATION'
      , i_parent_id     => null
      , o_appl_data_id  => l_root_id
    );
    
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'CUSTOMER'
      , i_parent_id     => l_root_id
      , o_appl_data_id  => l_customer_data_id
    );
    trc_log_pkg.debug('l_customer_data_id=' || l_customer_data_id);
    
    app_api_application_pkg.get_element_value(
        i_element_name  => 'INSTITUTION_ID'
      , i_parent_id     => l_root_id
      , o_element_value => l_inst_id
    );
    trc_log_pkg.debug('INSTITUTION_ID=' || l_inst_id);
    
    app_api_application_pkg.get_element_value(
        i_element_name  => 'CUSTOMER_NUMBER'
      , i_parent_id     => l_customer_data_id
      , o_element_value => l_customer_number
    );
    
    l_customer_id := prd_api_customer_pkg.get_customer_id(
        i_customer_number => l_customer_number
      , i_inst_id         => l_inst_id
      , i_mask_error      => com_api_const_pkg.FALSE
    );
       
    app_api_appl_object_pkg.add_object(
        i_appl_id       => l_appl_id
      , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id     => l_customer_id
      , i_seqnum        => 1
    );
    
    trc_log_pkg.debug(
        i_text       => 'process_rejected_application done for customer ' || l_customer_number
    );
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => l_root_id
          , i_element_name  => 'APPLICATION'
        );
    when others then
        trc_log_pkg.debug(
            i_text       => 'process_rejected_application [#1]'
          , i_env_param1 => sqlerrm
        );
        raise;
end process_rejected_application;

end iap_api_application_pkg;
/
