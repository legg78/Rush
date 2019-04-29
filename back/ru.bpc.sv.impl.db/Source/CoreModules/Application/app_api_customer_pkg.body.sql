create or replace package body app_api_customer_pkg as
/*********************************************************
*  Application - customer <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 24.01.2011 <br />
*  Module: app_api_customer_pkg <br />
*  @headcom
**********************************************************/

g_person_id     com_api_type_pkg.t_person_id;
g_customer_id   com_api_type_pkg.t_medium_id;

procedure search_customer_by_entities (
    i_appl_data_id  in      com_api_type_pkg.t_long_id
  , i_inst_id       in      com_api_type_pkg.t_inst_id
  , o_customer_id      out  com_api_type_pkg.t_medium_id
) is
    l_count                 com_api_type_pkg.t_long_id;
    l_id_tab                com_api_type_pkg.t_number_tab;
    l_card_number           com_api_type_pkg.t_card_number;
    l_card_uid              com_api_type_pkg.t_name;
    l_card                  iss_api_type_pkg.t_card_rec;
    l_account_number        com_api_type_pkg.t_account_number;
    l_account               acc_api_type_pkg.t_account_rec;
    l_merchant_number       com_api_type_pkg.t_name;
    l_merchant_id           com_api_type_pkg.t_short_id;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_terminal_number       com_api_type_pkg.t_name;
    l_contract_appl_id      com_api_type_pkg.t_long_id;
    l_tmp_customer_id       com_api_type_pkg.t_medium_id;
    l_contract_number       com_api_type_pkg.t_name;
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.search_customer_by_entities: ';
begin
    trc_log_pkg.debug(LOG_PREFIX || 'Start. ');

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'CONTRACT'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_contract_appl_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'CONTRACT_NUMBER'
      , i_parent_id     => l_contract_appl_id
      , o_element_value => l_contract_number
    );

    select min(id)
         , count(id)
      into l_tmp_customer_id
         , l_count
      from prd_contract
     where contract_number = l_contract_number
       and inst_id         = i_inst_id;

    if l_count = 1 then

        o_customer_id := l_tmp_customer_id;
        trc_log_pkg.debug(LOG_PREFIX || ' customer_id [' || o_customer_id || '] found  by customer');

    elsif l_count > 1 or l_count = 0 then

        app_api_application_pkg.get_appl_data_id(
            i_element_name  => 'CARD'
          , i_parent_id     => l_contract_appl_id
          , o_appl_data_id  => l_id_tab
        );

        if nvl(l_id_tab.count, 0) > 0 and app_api_error_pkg.g_app_errors.count = 0 then
            for i in 1..nvl(l_id_tab.count, 0) loop

                app_api_application_pkg.get_element_value(
                    i_element_name   => 'CARD_NUMBER'
                  , i_parent_id      => l_id_tab(i)
                  , o_element_value  => l_card_number
                );
                trc_log_pkg.debug(
                    i_text       => LOG_PREFIX || 'l_card_number [#1]'
                  , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => l_card_number)
                );

                if l_card_number is not null then

                    l_card := iss_api_card_pkg.get_card (
                        i_card_number    => l_card_number
                        , i_mask_error   => com_api_const_pkg.TRUE
                    );

                    if l_card.contract_id is not null then

                        o_customer_id := l_card.customer_id;
                        trc_log_pkg.debug(LOG_PREFIX || ' customer_id [' || o_customer_id || '] found by card');
                        return;
                    end if;
                end if;

                -- fetching card_id, actually it's card_uid
                app_api_application_pkg.get_element_value(
                    i_element_name   => 'CARD_ID'
                  , i_parent_id      => l_id_tab(i)
                  , o_element_value  => l_card_uid
                );

                if l_card_uid is not null then
                    l_card := iss_api_card_pkg.get_card (
                        i_card_uid   =>  l_card_uid
                      , i_mask_error => com_api_const_pkg.TRUE
                    );

                    if l_card.contract_id is not null then
                        o_customer_id := l_card.customer_id;
                        trc_log_pkg.debug(
                            i_text => LOG_PREFIX || ' customer_id [' || o_customer_id || '] found by card uid'
                        );
                        return;
                    end if;
                end if;
            end loop;
        end if;

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
                    trc_log_pkg.debug(LOG_PREFIX || 'l_account.contract_id [' || l_account.contract_id || ']');

                    if l_account.contract_id is not null then

                        o_customer_id := l_account.customer_id;
                        trc_log_pkg.debug(LOG_PREFIX || ' customer_id [' || o_customer_id || '] found by account');
                        return;

                    end if;
                end if;
            end loop;
        end if;

        if nvl(l_id_tab.count, 0) > 0 and app_api_error_pkg.g_app_errors.count = 0 then
            app_api_application_pkg.get_appl_data_id(
                i_element_name  => 'MERCHANT'
              , i_parent_id     => l_contract_appl_id
              , o_appl_data_id  => l_id_tab
            );

            for i in 1..nvl(l_id_tab.count, 0) loop

                app_api_application_pkg.get_element_value(
                    i_element_name   => 'MERCHANT_NUMBER'
                  , i_parent_id      => l_id_tab(i)
                  , o_element_value  => l_merchant_number
                );

                if l_merchant_number is not null then
                    acq_api_merchant_pkg.get_merchant (
                        i_inst_id         => i_inst_id
                      , i_merchant_number => l_merchant_number
                      , o_merchant_id     => l_merchant_id
                      , o_split_hash      => l_split_hash
                    );

                    -- merchant already found, therefore without block exceptions
                    if l_merchant_id is not null then

                        select c.customer_id
                          into o_customer_id
                          from acq_merchant m
                             , prd_contract c
                         where m.id = l_merchant_id
                           and c.id = m.contract_id;

                        trc_log_pkg.debug(LOG_PREFIX || ' customer_id [' || o_customer_id || '] found by merchant');
                        return;
                    end if;
                end if;
            end loop;
        end if;

        if nvl(l_id_tab.count, 0) > 0 and app_api_error_pkg.g_app_errors.count = 0 then

            app_api_application_pkg.get_appl_data_id(
                i_element_name  => 'TERMINAL'
              , i_parent_id     => l_contract_appl_id
              , o_appl_data_id  => l_id_tab
            );

            for i in 1..nvl(l_id_tab.count, 0) loop

                app_api_application_pkg.get_element_value(
                    i_element_name   => 'TERMINAL_NUMBER'
                  , i_parent_id      => l_id_tab(i)
                  , o_element_value  => l_terminal_number
                );

                if l_terminal_number is not null then
                    begin
                        select c.customer_id
                          into o_customer_id
                          from acq_terminal t
                             , prd_contract c
                         where decode(nvl(t.is_template, 0), 0, t.terminal_number) = l_terminal_number
                           and t.inst_id = i_inst_id
                           and c.id      = t.contract_id;

                        trc_log_pkg.debug(LOG_PREFIX || ' customer_id [' || o_customer_id || '] found by terminal');
                        return;
                    exception
                        when no_data_found then
                            o_customer_id := null;
                    end;
                end if;
            end loop;

        end if;

        -- since not found by card, account or merchant, return one of them
        o_customer_id := l_tmp_customer_id;

        trc_log_pkg.debug(LOG_PREFIX || 'End. Customer not found by card, account or merchant, return by contract, id=' || o_customer_id);
    end if;
end search_customer_by_entities;

function get_customer_person_id return com_api_type_pkg.t_person_id is
begin
    return g_person_id;
end;

function get_customer_id  return com_api_type_pkg.t_medium_id is
begin
    return g_customer_id;
end;

function get_customer_count return com_api_type_pkg.t_short_id is
    l_root_id              com_api_type_pkg.t_long_id;
    l_customer_data_id     com_api_type_pkg.t_long_id;
    l_customer_count       com_api_type_pkg.t_short_id;
begin
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

    app_api_application_pkg.get_element_value(
        i_element_name  => 'CUSTOMER_COUNT'
      , i_parent_id     => l_customer_data_id
      , o_element_value => l_customer_count
    );

    return nvl(l_customer_count, 1);
end;

procedure check_customer_person(
    i_person_id        in com_api_type_pkg.t_person_id
  , i_customer_id      in com_api_type_pkg.t_medium_id
  , i_inst_id          in com_api_type_pkg.t_inst_id
) as
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.check_customer_person: ';
    l_old_customer_number   com_api_type_pkg.t_name;
begin
    if set_ui_value_pkg.get_inst_param_n(
           i_param_name => 'ALLOW_CUSTOMER_PERSON_DUPLICATE'
         , i_inst_id    => i_inst_id
       ) = com_api_const_pkg.FALSE then

        trc_log_pkg.debug(LOG_PREFIX || 'Search for duplicate customers with person id [' || i_person_id || ']');

        begin
            select c.customer_number into l_old_customer_number
              from prd_customer c
             where c.inst_id   = i_inst_id
               and c.object_id  = i_person_id
               and c.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
               and c.status = prd_api_const_pkg.CUSTOMER_STATUS_ACTIVE
               and (c.id <> i_customer_id or i_customer_id is null)
               and rownum <= 1;
        exception when no_data_found then
            null;
        end;

        if l_old_customer_number is not null then
            com_api_error_pkg.raise_error(
                i_error       => 'DUPLICATE_CUSTOMER'
              , i_env_param1  => i_person_id
              , i_env_param2  => l_old_customer_number
            );
        end if;
    end if;
end;

procedure process_entity(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_customer_type        in            com_api_type_pkg.t_dict_value
  , io_object_id           in out nocopy com_api_type_pkg.t_long_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_pool_number          in            com_api_type_pkg.t_short_id   default 1
  , i_customer_count       in            com_api_type_pkg.t_short_id   default 1
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_entity: ';
    l_appl_data_id         com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_appl_data_id [' || i_appl_data_id || ']');

    if i_customer_type in (
        com_api_const_pkg.ENTITY_TYPE_COMPANY
      , ost_api_const_pkg.ENTITY_TYPE_AGENT
    ) then
        app_api_application_pkg.get_appl_data_id(
            i_element_name  => 'COMPANY'
          , i_parent_id     => i_appl_data_id
          , o_appl_data_id  => l_appl_data_id
        );
        app_api_company_pkg.process_company(
            i_appl_data_id  => l_appl_data_id
          , i_inst_id       => i_inst_id
          , io_company_id   => io_object_id
        );

        app_api_flexible_field_pkg.process_flexible_fields(
            i_entity_type   => com_api_const_pkg.ENTITY_TYPE_COMPANY
          , i_object_type   => null
          , i_object_id     => io_object_id
          , i_inst_id       => i_inst_id
          , i_appl_data_id  => l_appl_data_id
        );

    elsif i_customer_type  = com_api_const_pkg.ENTITY_TYPE_PERSON then
        g_person_id := io_object_id;

        app_api_application_pkg.get_appl_data_id(
            i_element_name  => 'PERSON'
          , i_parent_id     => i_appl_data_id
          , o_appl_data_id  => l_appl_data_id
        );

        if i_customer_count > 1 then
            app_api_person_pkg.process_dummy_person(
                i_appl_data_id  => l_appl_data_id
              , i_pool_number   => i_pool_number
              , io_person_id    => io_object_id
            );
        else
            app_api_person_pkg.process_person(
                i_appl_data_id  => l_appl_data_id
              , io_person_id    => io_object_id
            );
        end if;
        check_customer_person(
            i_person_id        => io_object_id
          , i_customer_id      => i_customer_id
          , i_inst_id          => i_inst_id
        );
        g_person_id := nvl(io_object_id, g_person_id);

    elsif i_customer_type = com_api_const_pkg.ENTITY_TYPE_UNDEFINED then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'no actions are defined for customer type [#1]'
          , i_env_param1 => i_customer_type
        );

    else
        com_api_error_pkg.raise_error(
            i_error         => 'UNKNOWN_CUSTOMER_TYPE'
          , i_env_param1    => i_customer_type
        );
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'END with io_object_id [' || io_object_id || ']');
end process_entity;

procedure change_objects(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_agent_id             in            com_api_type_pkg.t_short_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_pool_number          in            com_api_type_pkg.t_short_id   default 1
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_objects: ';
    l_id_tab               com_api_type_pkg.t_number_tab;
    l_address_id           com_api_type_pkg.t_long_id;
    l_changed              com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_contract_id          com_api_type_pkg.t_medium_id;
    l_appl_status          com_api_type_pkg.t_dict_value;
    l_command              com_api_type_pkg.t_dict_value;
    l_root_id              com_api_type_pkg.t_long_id;
    l_custom_event_id      com_api_type_pkg.t_medium_id;
    l_is_active            com_api_type_pkg.t_boolean;
    l_app_referral_prog    com_api_type_pkg.t_long_id;
    l_referrer_code        com_api_type_pkg.t_name;
    l_referral_code        com_api_type_pkg.t_name;
    l_referr_service_id    com_api_type_pkg.t_short_id;
    l_id_referrer          com_api_type_pkg.t_medium_id;
    l_id_referral          com_api_type_pkg.t_medium_id;
    l_customer_id          com_api_type_pkg.t_medium_id;
    l_referrer_id          com_api_type_pkg.t_medium_id;
    l_inst_id              com_api_type_pkg.t_inst_id;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_appl_data_id [' || i_appl_data_id || ']');

    --  processing contacts
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'CONTACT'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_id_tab
    );

    app_api_flexible_field_pkg.process_flexible_fields(
        i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_type   => null
      , i_object_id     => i_customer_id
      , i_inst_id       => i_inst_id
      , i_appl_data_id  => i_appl_data_id
    );

    for i in 1..nvl(l_id_tab.count, 0) loop
        app_api_contact_pkg.process_contact(
            i_appl_data_id         => l_id_tab(i)
          , i_parent_appl_data_id  => i_appl_data_id
          , i_object_id            => i_customer_id
          , i_entity_type          => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
        );
        l_changed := com_api_type_pkg.TRUE;
    end loop;

    -- process contract
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'CONTRACT'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'APPLICATION'
      , i_parent_id     => null
      , o_appl_data_id  => l_root_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'APPLICATION_STATUS'
      , i_parent_id     => l_root_id
      , o_element_value => l_appl_status
    );

    trc_log_pkg.debug(LOG_PREFIX || 'l_appl_status [' || l_appl_status || ']');

    if nvl(l_id_tab.count, 0) > 0 and app_api_error_pkg.g_app_errors.count = 0 then
        for i in 1..nvl(l_id_tab.count, 0) loop
            app_api_application_pkg.get_element_value(
                i_element_name  => 'COMMAND'
              , i_parent_id     => l_id_tab(i)
              , o_element_value => l_command
            );

            trc_log_pkg.debug(LOG_PREFIX || 'l_command [' || l_command || ']');

            if  l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
                or
                l_appl_status != 'APST5004'
            then
                app_api_contract_pkg.process_contract(
                    i_appl_data_id  => l_id_tab(i)
                  , i_inst_id       => i_inst_id
                  , i_agent_id      => i_agent_id
                  , i_customer_id   => i_customer_id
                  , o_contract_id   => l_contract_id
                  , i_pool_number   => i_pool_number
                );
            end if;
        end loop;
    end if;

    --  processing merchant address
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'ADDRESS'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );
    for i in 1..nvl(l_id_tab.count, 0) loop
        app_api_address_pkg.process_address(
            i_appl_data_id         => l_id_tab(i)
          , i_parent_appl_data_id  => i_appl_data_id
          , i_object_id            => i_customer_id
          , i_entity_type          => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , o_address_id           => l_address_id
        );
        l_changed := com_api_type_pkg.TRUE;
    end loop;

    -- process secure word
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'SEC_WORD'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_id_tab
    );

    if nvl(l_id_tab.count, 0) > 0 then
        for i in 1..l_id_tab.count loop
            app_api_sec_question_pkg.process_sec_question(
                i_appl_data_id  => l_id_tab(i)
              , i_object_id     => i_customer_id
              , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
            );
        end loop;
    end if;

    -- Processing notification
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'NOTIFICATION'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    for i in 1..l_id_tab.count loop
        app_api_notification_pkg.process_notification(
            i_appl_data_id         => l_id_tab(i)
          , i_parent_appl_data_id  => i_appl_data_id
          , i_entity_type          => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , i_object_id            => i_customer_id
          , i_inst_id              => i_inst_id
          , i_customer_id          => i_customer_id
          , o_custom_event_id      => l_custom_event_id
          , o_is_active            => l_is_active
        );
    end loop;

    app_api_flexible_field_pkg.process_flexible_fields(
        i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_type   => null
      , i_object_id     => i_customer_id
      , i_inst_id       => i_inst_id
      , i_appl_data_id  => i_appl_data_id
    );

    if l_changed = com_api_type_pkg.TRUE then
        prd_api_customer_pkg.set_last_modify(
            i_customer_id  => i_customer_id
        );
    end if;

    app_api_report_pkg.process_report(
        i_appl_data_id  => i_appl_data_id
      , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id     => i_customer_id
    );

    cpn_api_application_pkg.process_campaign(
        i_appl_data_id  => i_appl_data_id
      , i_customer_id   => i_customer_id
      , i_inst_id       => i_inst_id
    );

    -- Referral program
    l_referr_service_id := prd_api_service_pkg.get_active_service_id(
                               i_entity_type      => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                             , i_object_id        => i_customer_id
                             , i_attr_name        => null
                             , i_service_type_id  => prd_api_const_pkg.CUSTOMER_REFERRER_CODE_SERVICE
                             , i_eff_date         => com_api_sttl_day_pkg.get_sysdate()
                             , i_mask_error       => com_api_const_pkg.TRUE
                             , i_inst_id          => i_inst_id
                           );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'REFERRAL_PROGRAM'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_app_referral_prog
    );

    if l_app_referral_prog is not null then
        app_api_application_pkg.get_element_value(
            i_element_name   => 'REFERRER_CODE'
          , i_parent_id      => l_app_referral_prog
          , o_element_value  => l_referrer_code
        );
        app_api_application_pkg.get_element_value(
            i_element_name   => 'REFERRAL_CODE'
          , i_parent_id      => l_app_referral_prog
          , o_element_value  => l_referral_code
        );

        if l_referr_service_id is null then
            com_api_error_pkg.raise_error(
                i_error      => 'REFERRER_SERVICE_NOT_FOUND'
              , i_env_param1 => i_customer_id
              , i_env_param2 => prd_api_const_pkg.CUSTOMER_REFERRER_CODE_SERVICE
            );
        else
            declare
                l_cust_number   com_api_type_pkg.t_name;
                l_prod_number   com_api_type_pkg.t_name;
                l_agent_number  com_api_type_pkg.t_name;
            begin
                begin
                    select c.customer_number
                         , p.product_number
                         , t.agent_id
                      into l_cust_number
                         , l_prod_number
                         , l_agent_number
                      from prd_customer c
                         , prd_contract t
                         , prd_product p
                     where c.split_hash = t.split_hash
                       and t.product_id = p.id
                       and p.product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS
                       and c.id           = i_customer_id
                       and rownum < 2;
                exception
                    when no_data_found then
                        null;
                end;

                prd_api_referral_pkg.add_referrer(
                    o_id            => l_id_referrer
                  , i_inst_id       => i_inst_id
                  , i_split_hash    => null
                  , i_customer_id   => i_customer_id
                  , i_referral_code => l_referrer_code
                  , i_cust_number   => l_cust_number
                  , i_prod_number   => l_prod_number
                  , i_agent_number  => l_agent_number
                );
            exception
                when com_api_error_pkg.e_application_error then
                    app_api_error_pkg.intercept_error(
                        i_appl_data_id => l_app_referral_prog
                      , i_element_name => 'REFERRAL_PROGRAM'
                    );
            end;
        end if;

        if l_referral_code is not null then
            begin
                select distinct cc.id
                     , cc.referrer_id
                     , cc.inst_id
                  into l_customer_id
                     , l_referrer_id
                     , l_inst_id
                  from prd_ui_customers_vw cc
                 where cc.referral_code = l_referral_code;

                l_referr_service_id :=
                    prd_api_service_pkg.get_active_service_id(
                        i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
                      , i_object_id           => l_customer_id
                      , i_attr_name           => null
                      , i_service_type_id     => prd_api_const_pkg.CUSTOMER_REFERRER_CODE_SERVICE
                      , i_eff_date            => com_api_sttl_day_pkg.get_sysdate()
                      , i_mask_error          => com_api_const_pkg.TRUE
                      , i_inst_id             => l_inst_id
                    );
                if l_referr_service_id is null then
                    com_api_error_pkg.raise_error(
                        i_error       => 'REFERRAL_SERVICE_NOT_FOUND'
                      , i_env_param1  => l_customer_id
                      , i_env_param2  => prd_api_const_pkg.CUSTOMER_REFERRER_CODE_SERVICE
                    );
                else
                    prd_api_referral_pkg.add_referral(
                        o_id          => l_id_referral
                      , i_inst_id     => i_inst_id
                      , i_split_hash  => null
                      , i_customer_id => i_customer_id
                      , i_referrer_id => l_referrer_id
                    );
                end if;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error(
                        i_error      => 'REFERRAL_CODE_NOT_FOUND'
                      , i_env_param1 => l_referral_code
                    );
            end;
        end if;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end change_objects;

procedure get_customer_optional_field(
    i_appl_data_id         in     com_api_type_pkg.t_long_id
  , i_customer_id          in     com_api_type_pkg.t_medium_id default null
  , io_customer            in out prd_api_type_pkg.t_customer
) is

begin
    if i_customer_id is not null then
        select c.credit_rating
             , c.employment_status
             , c.employment_period
             , c.residence_type
             , c.marital_status
             , c.marital_status_date
             , c.income_range
             , c.number_of_children
          into io_customer.credit_rating
             , io_customer.employment_status
             , io_customer.employment_period
             , io_customer.residence_type
             , io_customer.marital_status
             , io_customer.marital_status_date
             , io_customer.income_range
             , io_customer.number_of_children
          from prd_customer c
         where c.id = i_customer_id;
    end if;
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CREDIT_RATING'
      , i_parent_id      => i_appl_data_id
      , i_current_value  => io_customer.credit_rating
      , o_element_value  => io_customer.credit_rating
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'EMPLOYMENT_STATUS'
      , i_parent_id      => i_appl_data_id
      , i_current_value  => io_customer.employment_status
      , o_element_value  => io_customer.employment_status
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'EMPLOYMENT_PERIOD'
      , i_parent_id      => i_appl_data_id
      , i_current_value  => io_customer.employment_period
      , o_element_value  => io_customer.employment_period
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'RESIDENCE_TYPE'
      , i_parent_id      => i_appl_data_id
      , i_current_value  => io_customer.residence_type
      , o_element_value  => io_customer.residence_type
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MARITAL_STATUS'
      , i_parent_id      => i_appl_data_id
      , i_current_value  => io_customer.marital_status
      , o_element_value  => io_customer.marital_status
    );

    app_api_application_pkg.get_element_value(
       i_element_name   => 'MARITAL_STATUS_DATE'
     , i_parent_id      => i_appl_data_id
     , i_current_value  => io_customer.marital_status_date
     , o_element_value  => io_customer.marital_status_date
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'INCOME_RANGE'
      , i_parent_id      => i_appl_data_id
      , i_current_value  => io_customer.income_range
      , o_element_value  => io_customer.income_range
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'NUMBER_OF_CHILDREN'
      , i_parent_id      => i_appl_data_id
      , i_current_value  => io_customer.number_of_children
      , o_element_value  => io_customer.number_of_children
    );
end;

procedure process_customer(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , o_customer_id             out nocopy com_api_type_pkg.t_medium_id
  , i_pool_number          in            com_api_type_pkg.t_short_id   default 1
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_customer: ';
    l_command              com_api_type_pkg.t_dict_value;
    l_customer             prd_api_type_pkg.t_customer;
    l_customer_type        com_api_type_pkg.t_dict_value;
    l_customer_category    com_api_type_pkg.t_dict_value;
    l_old_customer_type    com_api_type_pkg.t_dict_value;
    l_account_scheme       com_api_type_pkg.t_tiny_id;
    l_appl_data_id         com_api_type_pkg.t_long_id;
    l_object_id            com_api_type_pkg.t_long_id;
    l_root_id              com_api_type_pkg.t_long_id;
    l_appl_type            com_api_type_pkg.t_dict_value;
    l_old_status           com_api_type_pkg.t_dict_value;
    l_agent_id             com_api_type_pkg.t_agent_id;
    l_id_tab               com_api_type_pkg.t_number_tab;
    l_id_tab_child         com_api_type_pkg.t_number_tab;
    l_product_type         com_api_type_pkg.t_dict_value;
    l_params               com_api_type_pkg.t_param_tab;
    l_customer_count       com_api_type_pkg.t_short_id;
    l_customer_status      com_api_type_pkg.t_dict_value;
    l_status_reason        com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_appl_data_id [' || i_appl_data_id || '], i_inst_id [' || i_inst_id || ']');

    l_agent_id    := app_api_application_pkg.get_app_agent_id;
    g_customer_id := null;
    g_person_id   := null;

    cst_api_application_pkg.process_customer_before(
        i_appl_data_id  => i_appl_data_id
      , i_inst_id       => i_inst_id
      , o_customer_id   => o_customer_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CUSTOMER_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_customer.customer_number
    );

    trc_log_pkg.debug('l_command [' || l_command || '], customer_number [' || l_customer.customer_number || ']');

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CUSTOMER_CATEGORY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_customer_category
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CUSTOMER_RELATION'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_customer.relation
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'RESIDENT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_customer.resident
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'NATIONALITY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_customer.nationality
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MONEY_LAUNDRY_RISK'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_customer.money_laundry_risk
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MONEY_LAUNDRY_REASON'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_customer.money_laundry_reason
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_root_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'APPLICATION_TYPE'
      , i_parent_id      => l_root_id
      , o_element_value  => l_appl_type
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CUSTOMER_TYPE'
      , i_parent_id      => l_root_id
      , o_element_value  => l_customer_type
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CUSTOMER_EXT_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_customer.ext_entity_type
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CUSTOMER_EXT_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_customer.ext_object_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'CUSTOMER_COUNT'
      , i_parent_id     => i_appl_data_id
      , o_element_value => l_customer_count
    );

    l_customer_count := nvl(l_customer_count, 1);

    app_api_application_pkg.get_element_value(
        i_element_name  => 'CUSTOMER_STATUS'
      , i_parent_id     => i_appl_data_id
      , o_element_value => l_customer_status
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'STATUS_REASON'
      , i_parent_id     => i_appl_data_id
      , o_element_value => l_status_reason
    );

    if l_appl_type = app_api_const_pkg.APPL_TYPE_INSTITUTION then
        if  l_customer.ext_entity_type != ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then
            com_api_error_pkg.raise_error(
                i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
              , i_env_param1 => l_customer.ext_entity_type
            );
        else
            l_customer.ext_entity_type  := ost_api_const_pkg.ENTITY_TYPE_INSTITUTION;
            l_customer.ext_object_id    := i_inst_id;
        end if;
    end if;

    trc_log_pkg.debug(
        i_text => 'l_agent_id [' || l_agent_id
               || '], l_appl_type [' || l_appl_type
               || '], l_customer_type [' || l_customer_type
               || '], l_customer.ext_entity_type [' || l_customer.ext_entity_type
               || '], l_customer.ext_object_id [' || l_customer.ext_object_id
               || '], l_customer_category [' || l_customer_category || ']'
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'FLEXIBLE_FIELD'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    l_product_type  :=
        case l_appl_type
            when app_api_const_pkg.APPL_TYPE_ISSUING then prd_api_const_pkg.PRODUCT_TYPE_ISS
            when app_api_const_pkg.APPL_TYPE_ACQUIRING then prd_api_const_pkg.PRODUCT_TYPE_ACQ
            else null
        end;

    if l_appl_type = app_api_const_pkg.APPL_TYPE_ACQUIRING then
        app_api_application_pkg.get_element_value(
            i_element_name   => 'ACCOUNT_SCHEME'
          , i_parent_id      => i_appl_data_id
          , o_element_value  => l_account_scheme
        );
    end if;
    trc_log_pkg.debug('l_account_scheme [' || l_account_scheme || ']');

    if  l_customer.ext_entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT
        and
        o_customer_id is null -- Searching should be skipped if <o_customer_id> is defined in <cst_api_application_pkg>
    then
        if l_agent_id is null then
            com_api_error_pkg.raise_error(
                i_error => 'AGENT_NOT_FOUND'
            );
        end if;

        -- Searching customer associated with agent, if there is no appropriate customer,
        -- then association will be defined during adding/modifing a customer
        begin
            select id
                 , customer_number
                 , entity_type
                 , object_id
              into l_customer.id
                 , l_customer.customer_number
                 , l_customer_type
                 , l_object_id
              from prd_customer
             where ext_entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT
               and ext_object_id = l_agent_id;

            o_customer_id := l_customer.id;
            g_customer_id := l_customer.id;

        exception
            when no_data_found then
                trc_log_pkg.debug('Customer isn''t found by the agent, continue search by its number...');
        end;
    end if;

    if o_customer_id is null then
        select min(id)
             , min(seqnum)
             , min(entity_type)
             , min(object_id)
             , min(status)
          into o_customer_id
             , l_customer.seqnum
             , l_old_customer_type
             , l_object_id
             , l_old_status
          from prd_customer_vw
         where reverse(customer_number) = reverse(upper(l_customer.customer_number))
           and inst_id                  = i_inst_id;

        g_customer_id := o_customer_id;

        if l_customer_type is not null and l_old_customer_type is not null and l_customer_type != l_old_customer_type then
            com_api_error_pkg.raise_error(
                i_error       => 'CANNOT_CHANGE_CUSTOMER_TYPE'
              , i_env_param1  => l_customer.customer_number
              , i_env_param2  => i_inst_id
              , i_env_param3  => l_old_customer_type
              , i_env_param4  => l_customer_type
            );
        end if;

        l_customer_type := nvl(l_customer_type, l_old_customer_type);
    end if;

    trc_log_pkg.debug('o_customer_id [' || o_customer_id || '], l_customer_type [' || l_customer_type || ']');

    -- Checking for consistency of external entity object
    if l_customer.ext_object_id is null then
        if l_customer.ext_entity_type is not null then
            trc_log_pkg.debug('l_customer.ext_object_id is NULL, so l_customer.ext_entity_type will be ignored during adding/creating a customer...');
            l_customer.ext_entity_type := null;
        end if;
    else
        trc_log_pkg.debug('l_customer.ext_object_id is NOT NULL, validating l_customer_type...');
        com_api_dictionary_pkg.check_article(
            i_dict => substr(l_customer.ext_entity_type, 1, 4)
          , i_code => l_customer.ext_entity_type
        );
    end if;

    if o_customer_id is null and l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED then
        search_customer_by_entities(
            i_appl_data_id => i_appl_data_id
          , i_inst_id      => i_inst_id
          , o_customer_id  => o_customer_id
        );
    end if;

    if o_customer_id is not null then
        if l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error(
                i_error      => 'CUSTOMER_ALREADY_EXISTS'
              , i_env_param1 => l_customer.customer_number
              , i_env_param2 => i_inst_id
            );

        elsif l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
        ) then
            if l_old_status = prd_api_const_pkg.CUSTOMER_STATUS_INACTIVE then
                com_api_error_pkg.raise_error(
                    i_error      => 'CANNOT_MODIFY_CLOSED_CUSTOMER'
                  , i_env_param1 => o_customer_id
                );
            end if;

            process_entity(
                i_appl_data_id   => i_appl_data_id
              , i_inst_id        => i_inst_id
              , i_customer_type  => l_customer_type
              , io_object_id     => l_object_id
              , i_customer_id    => o_customer_id
              , i_pool_number    => i_pool_number
              , i_customer_count => l_customer_count
            );

            if l_customer_status is not null and (l_old_status is null or l_old_status != l_customer_status) then
                evt_api_status_pkg.change_status(
                    i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
                  , i_entity_type    => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                  , i_object_id      => o_customer_id
                  , i_new_status     => l_customer_status
                  , i_eff_date       => com_api_sttl_day_pkg.get_sysdate()
                  , i_reason         => l_status_reason
                  , o_status         => l_customer_status
                  , i_raise_error    => com_api_const_pkg.TRUE
                  , i_register_event => com_api_const_pkg.TRUE
                  , i_params         => app_api_application_pkg.g_params
                );
            end if;

            get_customer_optional_field(
                i_appl_data_id => i_appl_data_id
              , io_customer    => l_customer
              , i_customer_id  => o_customer_id
            );

            prd_api_customer_pkg.modify_customer(
                i_id                   => o_customer_id
              , io_seqnum              => l_customer.seqnum
              , i_object_id            => l_object_id
              , i_customer_number      => l_customer.customer_number
              , i_category             => l_customer_category
              , i_relation             => l_customer.relation
              , i_resident             => l_customer.resident
              , i_nationality          => l_customer.nationality
              , i_credit_rating        => l_customer.credit_rating
              , i_money_laundry_risk   => l_customer.money_laundry_risk
              , i_money_laundry_reason => l_customer.money_laundry_reason
              , i_status               => l_customer_status
              , i_ext_entity_type      => l_customer.ext_entity_type
              , i_ext_object_id        => l_customer.ext_object_id
              , i_product_type         => l_product_type
              , i_employment_status    => l_customer.employment_status
              , i_employment_period    => l_customer.employment_period
              , i_residence_type       => l_customer.residence_type
              , i_marital_status       => l_customer.marital_status
              , i_marital_status_date  => l_customer.marital_status_date
              , i_income_range         => l_customer.income_range
              , i_number_of_children   => l_customer.number_of_children
            );

            if l_appl_type = app_api_const_pkg.APPL_TYPE_ACQUIRING then
                acq_ui_account_customer_pkg.modify_account_customer(
                    i_customer_id => o_customer_id
                  , i_scheme_id   => l_account_scheme
                );
            end if;

            change_objects(
                i_appl_data_id  => i_appl_data_id
              , i_inst_id       => i_inst_id
              , i_agent_id      => l_agent_id
              , i_customer_id   => o_customer_id
              , i_pool_number   => i_pool_number
            );

        elsif l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED then
            if l_old_status = prd_api_const_pkg.CUSTOMER_STATUS_INACTIVE then
                com_api_error_pkg.raise_error(
                    i_error      => 'CANNOT_MODIFY_CLOSED_CUSTOMER'
                  , i_env_param1 => o_customer_id
                );
            end if;

            process_entity(
                i_appl_data_id   => i_appl_data_id
              , i_inst_id        => i_inst_id
              , i_customer_type  => l_customer_type
              , io_object_id     => l_object_id
              , i_customer_id    => o_customer_id
              , i_pool_number    => i_pool_number
              , i_customer_count => l_customer_count
            );

            change_objects(
                i_appl_data_id  => i_appl_data_id
              , i_inst_id       => i_inst_id
              , i_agent_id      => l_agent_id
              , i_customer_id   => o_customer_id
              , i_pool_number   => i_pool_number
            );

        elsif l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE then
            l_params := app_api_application_pkg.g_params;
            l_params('PRODUCT_TYPE')   := l_product_type;

            prd_api_customer_pkg.close_customer(
                i_customer_id   => o_customer_id
              , i_inst_id       => i_inst_id
              , i_end_date      => com_api_sttl_day_pkg.get_sysdate()
              , i_params        => l_params
            );

        else
            process_entity(
                i_appl_data_id   => i_appl_data_id
              , i_inst_id        => i_inst_id
              , i_customer_type  => l_customer_type
              , io_object_id     => l_object_id
              , i_customer_id    => o_customer_id
              , i_pool_number    => i_pool_number
              , i_customer_count => l_customer_count
            );

            -- unknown l_command
            change_objects(
                i_appl_data_id  => i_appl_data_id
              , i_inst_id       => i_inst_id
              , i_agent_id      => l_agent_id
              , i_customer_id   => o_customer_id
              , i_pool_number   => i_pool_number
            );
        end if;
    else -- if o_customer_id is null then
        if l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
          , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
        ) then
            com_api_error_pkg.raise_error(
                i_error         => 'CUSTOMER_NOT_FOUND'
              , i_env_param1    => l_customer.customer_number
              , i_env_param2    => i_inst_id
            );

        --elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
        else
            process_entity(
                i_appl_data_id   => i_appl_data_id
              , i_inst_id        => i_inst_id
              , i_customer_type  => l_customer_type
              , io_object_id     => l_object_id
              , i_customer_id    => o_customer_id
              , i_pool_number    => i_pool_number
              , i_customer_count => l_customer_count
            );

            if l_object_id is null
               and
               l_customer_type != com_api_const_pkg.ENTITY_TYPE_UNDEFINED
            then
                -- Block <#1> should be defined in application''s structure for customer type [#2] and command [#3]
                com_api_error_pkg.raise_error(
                    i_error      => 'MANDATORY_ENTITY_IS_NOT_DEFINED_FOR_CUSTOMER'
                  , i_env_param1 => case l_customer_type
                                        when com_api_const_pkg.ENTITY_TYPE_PERSON then 'PERSON'
                                                                                  else 'COMPANY'
                                    end
                  , i_env_param2 => l_customer_type
                  , i_env_param3 => l_command
                );
            end if;

            get_customer_optional_field(
                i_appl_data_id => i_appl_data_id
              , io_customer    => l_customer
            );

            prd_api_customer_pkg.add_customer(
                o_id                   => o_customer_id
              , o_seqnum               => l_customer.seqnum
              , i_entity_type          => l_customer_type
              , i_object_id            => l_object_id
              , io_customer_number     => l_customer.customer_number
              , i_inst_id              => i_inst_id
              , i_category             => l_customer_category
              , i_relation             => l_customer.relation
              , i_resident             => l_customer.resident
              , i_nationality          => l_customer.nationality
              , i_credit_rating        => l_customer.credit_rating
              , i_money_laundry_risk   => l_customer.money_laundry_risk
              , i_money_laundry_reason => l_customer.money_laundry_reason
              , i_status               => l_customer_status
              , i_ext_entity_type      => l_customer.ext_entity_type
              , i_ext_object_id        => l_customer.ext_object_id
              , i_product_type         => l_product_type
              , i_employment_status    => l_customer.employment_status
              , i_employment_period    => l_customer.employment_period
              , i_residence_type       => l_customer.residence_type
              , i_marital_status       => l_customer.marital_status
              , i_marital_status_date  => l_customer.marital_status_date
              , i_income_range         => l_customer.income_range
              , i_number_of_children   => l_customer.number_of_children
            );

            if l_appl_type = app_api_const_pkg.APPL_TYPE_ACQUIRING then
                acq_ui_account_customer_pkg.add_account_customer(
                    i_customer_id      => o_customer_id
                  , i_scheme_id        => l_account_scheme
                );
            end if;

            change_objects(
                i_appl_data_id  => i_appl_data_id
              , i_inst_id       => i_inst_id
              , i_agent_id      => l_agent_id
              , i_customer_id   => o_customer_id
              , i_pool_number   => i_pool_number
            );
        end if;
    end if;

    app_api_note_pkg.process_note(
        i_appl_data_id => i_appl_data_id
      , i_entity_type  => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id    => o_customer_id
    );

    if i_pool_number = l_customer_count then
        -- save CUSTOMER_NUMBER
        app_api_application_pkg.get_appl_data_id(
            i_element_name      => 'CUSTOMER_NUMBER'
          , i_parent_id         => i_appl_data_id
          , o_appl_data_id      => l_appl_data_id
        );

        if l_appl_data_id is null then
            app_api_application_pkg.add_element(
                i_element_name   => 'CUSTOMER_NUMBER'
              , i_parent_id      => i_appl_data_id
              , i_element_value  => l_customer.customer_number
            );
        else
            app_api_application_pkg.modify_element(
                i_appl_data_id   => l_appl_data_id
              , i_element_value  => l_customer.customer_number
            );
        end if;
    end if;

    cst_api_application_pkg.process_customer_after(
        i_appl_data_id   => i_appl_data_id
      , i_inst_id        => i_inst_id
      , io_customer_id   => o_customer_id
    );

    g_customer_id := o_customer_id;

    app_api_appl_object_pkg.add_object(
        i_appl_id           => app_api_application_pkg.get_appl_id
      , i_entity_type       => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id         => o_customer_id
      , i_seqnum            => l_customer.seqnum
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END with customer_id [' || o_customer_id || ']');
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id => i_appl_data_id
          , i_element_name => 'CUSTOMER'
        );
end process_customer;

end;
/
