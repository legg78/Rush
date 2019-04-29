create or replace package body cpn_api_application_pkg is

e_skip_processing    exception;
e_unknown_command    exception;

procedure attach_campaign_to_application(
    i_campaign_id          in            com_api_type_pkg.t_short_id
) is
    l_count                              com_api_type_pkg.t_count    := 0;
    l_appl_id                            com_api_type_pkg.t_long_id;
begin
    if i_campaign_id is null then
        return;
    end if;

    l_appl_id := app_api_application_pkg.get_appl_id();

    select count(appl_id)
      into l_count
      from app_object
     where object_id   = i_campaign_id
       and appl_id     = l_appl_id
       and entity_type = cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN;

    trc_log_pkg.debug(
        i_text       => 'Attach campaign [#1] to application [#2]'
      , i_env_param1 => i_campaign_id
      , i_env_param2 => l_appl_id
    );

    if l_count = 0 then
        app_api_appl_object_pkg.add_object(
            i_appl_id     => l_appl_id
          , i_entity_type => cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
          , i_object_id   => i_campaign_id
          , i_seqnum      => 1
        );
    end if;
end attach_campaign_to_application;

/*
 * Processing block CAMPAIGN of an issuing/acquiring application, it doesn't relate to campaign application;
 * the procedure activate/deactivate promo campaign for all appropriate entity objects of incoming customer.
 */
procedure process_campaign(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
) is
    LOG_PREFIX                  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_campaign';
    l_campaign_data_id                   com_api_type_pkg.t_long_id;
    l_command                            com_api_type_pkg.t_dict_value;
    l_campaign_number                    com_api_type_pkg.t_name;
    l_sysdate                            date;
    l_start_date                         date;
    l_end_date                           date;
    l_campaign                           cpn_api_type_pkg.t_campaign_rec;
    l_count                              com_api_type_pkg.t_count := 0;
    l_attr_value_id_tab                  com_api_type_pkg.t_medium_tab;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' << i_appl_data_id [#1], i_customer_id [#2], i_inst_id [#3]'
      , i_env_param1 => i_appl_data_id
      , i_env_param2 => i_customer_id
      , i_env_param3 => i_inst_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'CAMPAIGN'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_campaign_data_id
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'COMMAND'
      , i_parent_id     => l_campaign_data_id
      , o_element_value => l_command
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'CAMPAIGN_NUMBER'
      , i_parent_id     => l_campaign_data_id
      , o_element_value => l_campaign_number
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'START_DATE'
      , i_parent_id     => l_campaign_data_id
      , o_element_value => l_start_date
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'END_DATE'
      , i_parent_id     => l_campaign_data_id
      , o_element_value => l_end_date
    );

    l_sysdate := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id);

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ': l_command [#1], l_sysdate'
      , i_env_param1 => l_command
      , i_env_param2 => l_sysdate
    );

    l_campaign :=
        cpn_api_campaign_pkg.get_campaign(
            i_campaign_number  => l_campaign_number
          , i_inst_id          => i_inst_id
          , i_mask_error       => com_api_const_pkg.FALSE
        );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ': l_campaign = {ID [#1], number [#2], type [#3], start_date [#4], end_date [#5]}'
      , i_env_param1 => l_campaign.id
      , i_env_param2 => l_campaign.campaign_number
      , i_env_param3 => l_campaign.campaign_type
      , i_env_param4 => l_campaign.start_date
      , i_env_param5 => l_campaign.end_date
    );

    if l_campaign.campaign_type not in (cpn_api_const_pkg.CAMPAIGN_TYPE_PROMO_CAMPAIGN) then
        com_api_error_pkg.raise_error(
            i_error       => 'CPN_CAMPAIGN_IS_NOT_AVALIABLE_FOR_ENTITY'
          , i_env_param1  => l_campaign.campaign_number
          , i_env_param2  => i_inst_id
          , i_env_param3  => l_campaign.campaign_type
          , i_env_param4  => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
        );
    end if;

    if l_sysdate > l_campaign.end_date then
        com_api_error_pkg.raise_error(
            i_error       => 'CPN_CAMPAIGN_IS_NOT_ACTIVE'
          , i_env_param1  => l_campaign.campaign_number
          , i_env_param2  => i_inst_id
          , i_env_param3  => l_campaign.end_date
          , i_env_param4  => l_sysdate
        );
    end if;

    -- Depending on incoming COMMAND, it is required to activate or remove promo-campaign (i. e. add/close
    -- service terms) for all entities associated with the promo-campaign products and services
    for r in (
        select cntr.id as contract_id
             , so.entity_type
             , so.object_id
             , cpnp.product_id
             , cpns.service_id
             , cntr.split_hash
             , cntr.start_date as contract_start_date
             , so.start_date   as service_start_date
          from cpn_campaign         cpn
          join cpn_campaign_product cpnp    on cpnp.campaign_id   = cpn.id
          join cpn_campaign_service cpns    on cpns.campaign_id   = cpn.id
          join prd_contract         cntr    on cntr.product_id    = cpnp.product_id
                                           and cntr.customer_id   = i_customer_id
                                           and l_sysdate         <= nvl(cntr.end_date, l_sysdate)
          join prd_service_object   so      on so.service_id      = cpns.service_id
                                           and so.contract_id     = cntr.id
                                           and so.status          = prd_api_const_pkg.SERVICE_OBJECT_STATUS_ACTIVE
                                           and l_sysdate         <= nvl(so.end_date, l_sysdate)
         where cpn.id = l_campaign.id
    ) loop
        l_count := l_count + 1;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || ': N#5 - entity [#1][#2], product_id [#3], service_id [#4]'
          , i_env_param1 => r.entity_type
          , i_env_param2 => r.object_id
          , i_env_param3 => r.product_id
          , i_env_param4 => r.service_id
          , i_env_param5 => l_count
        );

        l_attr_value_id_tab :=
            cpn_api_attribute_value_pkg.get_attribute_value_id(
                i_campaign_id  => l_campaign.id
              , i_entity_type  => r.entity_type
              , i_object_id    => r.object_id
              , i_split_hash   => r.split_hash
            );

        begin
            if l_attr_value_id_tab.count() > 0 then
                -- Campaign is already set to the entity object, its <end_date> can be changed only
                case l_command
                    when app_api_const_pkg.COMMAND_CREATE_OR_PROCEED then
                        null;
                    when app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
                        com_api_error_pkg.raise_error(
                            i_error       => 'CPN_CAMPAIGN_IS_ALREADY_ACTIVE_FOR_OBJECT'
                          , i_env_param1  => l_campaign.id
                          , i_env_param2  => r.entity_type
                          , i_env_param3  => r.object_id
                        );
                    when app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
                        -- Set expiration date for all campaign values for the entity object, tag START_DATE is ignored.
                        -- End date can't be less than current system date.
                        cpn_api_attribute_value_pkg.update_attribute_value(
                            i_id_tab    => l_attr_value_id_tab
                          , i_end_date  => greatest(l_sysdate, nvl(l_end_date, l_sysdate))
                        );
                    else
                        raise e_unknown_command;
                end case;
            else
                -- Campaign is not active for the entity object
                case
                    when l_command in (app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                                     , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT)
                    then
                        -- Copy promo campaign attributes values from entity <Campaign> to current entity object.
                        -- Start date passed via tag START_DATE can't be less than entity's service/contract start date.
                        -- End date is calculated using Promo campaign cycle, tag END_DATE is ignored.
                        cpn_api_attribute_value_pkg.add_attribute_value(
                            i_campaign     => l_campaign
                          , i_entity_type  => r.entity_type
                          , i_object_id    => r.object_id
                          , i_split_hash   => r.split_hash
                          , i_start_date   => greatest(
                                                  nvl(l_start_date, l_sysdate)
                                                , r.contract_start_date
                                                , r.service_start_date
                                              )
                        );
                    when l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
                        null;
                    else
                        raise e_unknown_command;
                end case;
            end if;
        exception
            when e_unknown_command then
                com_api_error_pkg.raise_error(
                    i_error      => 'INVALID_COMMAND'
                  , i_env_param1 => l_command
                  , i_env_param2 => 'CAMPAIGN'
                  , i_env_param3 => l_campaign_data_id
                  , i_env_param4 => app_api_const_pkg.COMMAND_CREATE_OR_PROCEED -- List of valid commands
                                 || app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
                                 || app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
                );
        end;
    end loop;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' >> [#1] entity objects processed'
      , i_env_param1 => l_count
    );
end process_campaign;

procedure process_attribute(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_campaign_id          in            com_api_type_pkg.t_short_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_service_id           in            com_api_type_pkg.t_short_id
  , i_product_id           in            com_api_type_pkg.t_short_id
) is
    LOG_PREFIX                  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_attribute: ';
    l_id_tab                             com_api_type_pkg.t_number_tab;
    l_campaign                           cpn_api_type_pkg.t_campaign_rec;
    l_params                             com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with parent i_appl_data_id [#1]'
      , i_env_param1 => i_appl_data_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'ATTRIBUTE_VALUE'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    l_campaign :=
        cpn_api_campaign_pkg.get_campaign(
            i_campaign_id  => i_campaign_id
          , i_mask_error   => com_api_const_pkg.FALSE
        );

    for i in 1..nvl(l_id_tab.count(), 0) loop
        trc_log_pkg.debug(
            i_text        => LOG_PREFIX || 'attribute [#2] of [#3]: appl_data_id [#1]'
          , i_env_param1  => l_id_tab(i)
          , i_env_param2  => i
          , i_env_param3  => l_id_tab.count()
        );
        app_api_service_pkg.process_attribute(
            i_entity_type  => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
          , i_object_id    => i_product_id
          , i_inst_id      => i_inst_id
          , i_service_id   => i_service_id
          , i_product_id   => i_product_id
          , i_appl_data_id => l_id_tab(i)
          , i_params       => l_params
          , i_campaign_id  => i_campaign_id
          , i_start_date   => l_campaign.start_date
          , i_end_date     => l_campaign.end_date
        );
    end loop;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'FINISH with processed [#1] attributes'
      , i_env_param1 => l_id_tab.count()
    );
end process_attribute;

procedure process_service(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_campaign_id          in            com_api_type_pkg.t_short_id
  , i_product_id           in            com_api_type_pkg.t_short_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
) is
    l_service_data_id_tab                com_api_type_pkg.t_number_tab;
    l_service_number                     com_api_type_pkg.t_name;
    l_service_id                         com_api_type_pkg.t_short_id;
    l_command                            com_api_type_pkg.t_dict_value;
    l_campaign_service_id                com_api_type_pkg.t_long_id;
begin
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'PRODUCT_SERVICE'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_service_data_id_tab
    );

    for i in 1 .. nvl(l_service_data_id_tab.count, 0) loop
        trc_log_pkg.debug(
            i_text          => 'Processing campaign service: appl_data_id [#1]'
          , i_env_param1    => l_service_data_id_tab(i)
        );

        app_api_application_pkg.get_element_value(
            i_element_name  => 'SERVICE_NUMBER'
          , i_parent_id     => l_service_data_id_tab(i)
          , o_element_value => l_service_number
        );

        l_service_id :=
            prd_api_service_pkg.get_service_id(
                i_service_number => l_service_number
              , i_inst_id        => i_inst_id
              , i_mask_error     => com_api_const_pkg.FALSE
            );

        app_api_application_pkg.get_element_value(
            i_element_name  => 'COMMAND'
          , i_parent_id     => l_service_data_id_tab(i)
          , o_element_value => l_command
        );

        select min(id)
          into l_campaign_service_id
          from cpn_campaign_service c
         where c.campaign_id = i_campaign_id
           and c.service_id  = l_service_id
           and c.product_id  = i_product_id;

        trc_log_pkg.debug(
            i_text         => 'l_campaign_service_id [#1], l_command [#2]'
          , i_env_param1   => l_command
          , i_env_param2   => l_campaign_service_id
          , i_entity_type  => cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
          , i_object_id    => i_campaign_id
        );

        begin
            if l_campaign_service_id is null then
                -- Campaign service is NOT found
                if l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
                    raise e_skip_processing;

                elsif l_command in (app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
                                  , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
                                  , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED)
                then
                    com_api_error_pkg.raise_error(
                        i_error      => 'SERVICE_NOT_FOUND'
                      , i_env_param2 => l_service_number
                      , i_env_param3 => i_inst_id
                    );

                elsif l_command in (app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                                  , app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                                  , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT)
                then
                    cpn_ui_campaign_pkg.add_campaign_service(
                        o_id          => l_campaign_service_id
                      , i_campaign_id => i_campaign_id
                      , i_product_id  => i_product_id
                      , i_service_id  => l_service_id
                    );

                else
                    raise e_unknown_command;
                end if;

            else
                -- Service is found
                if l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
                    com_api_error_pkg.raise_error(
                        i_error         => 'SERVICE_ALREADY_EXIST'
                      , i_env_param1    => l_service_number
                    );
                elsif l_command in (app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                                  , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE)
                then
                    raise e_unknown_command;

                elsif l_command in (app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
                                  , app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE)
                then
                    for rec in (
                        select id
                          from cpn_campaign_service cs
                         where cs.campaign_id = i_campaign_id
                           and cs.product_id  = i_product_id
                           and cs.service_id  = l_service_id
                    ) loop
                        cpn_ui_campaign_pkg.remove_campaign_service(i_id => rec.id);
                    end loop;

                elsif l_command in (app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                                  , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED)
                then
                    null;

                else
                    raise e_unknown_command;
                end if;
            end if;

            process_attribute(
                i_appl_data_id => l_service_data_id_tab(i)
              , i_campaign_id  => i_campaign_id
              , i_inst_id      => i_inst_id
              , i_service_id   => l_service_id
              , i_product_id   => i_product_id
            );
        exception
            when e_skip_processing then
                trc_log_pkg.debug(
                    i_text       => 'Skip processing due to command [#1]'
                  , i_env_param1 => l_command
                );
            when e_unknown_command then
                com_api_error_pkg.raise_error(
                    i_error      => 'INVALID_COMMAND'
                  , i_env_param1 => l_command
                  , i_env_param2 => 'PRODUCT_SERVICE'
                  , i_env_param3 => l_service_data_id_tab(i)
                  , i_env_param4 => 'CMMDCRPR, CMMDCREX, CMMDEXRE, CMMDEXPR, CMMDPRRE' -- list of valid commands
                );
        end;
    end loop;
end process_service;

procedure process_product(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_campaign_id          in            com_api_type_pkg.t_short_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
) is
    l_product_data_id_tab                com_api_type_pkg.t_number_tab;
    l_product_number                     com_api_type_pkg.t_name;
    l_product_id                         com_api_type_pkg.t_short_id;
    l_command                            com_api_type_pkg.t_dict_value;
    l_campaign_product_id                com_api_type_pkg.t_short_id;
begin
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'CAMPAIGN_PRODUCT'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_product_data_id_tab
    );

    for i in 1 .. nvl(l_product_data_id_tab.count(), 0) loop
        trc_log_pkg.debug(
            i_text          => 'Processing campaign product: appl_data_id [#1]'
          , i_env_param1    => l_product_data_id_tab(i)
        );

        app_api_application_pkg.get_element_value(
            i_element_name  => 'PRODUCT_NUMBER'
          , i_parent_id     => l_product_data_id_tab(i)
          , o_element_value => l_product_number
        );

        l_product_id :=
            prd_api_product_pkg.get_product_id(
                i_product_number => l_product_number
              , i_inst_id        => i_inst_id
              , i_mask_error     => com_api_const_pkg.FALSE
            );

        app_api_application_pkg.get_element_value(
            i_element_name  => 'COMMAND'
          , i_parent_id     => l_product_data_id_tab(i)
          , o_element_value => l_command
        );

        select min(id)
          into l_campaign_product_id
          from cpn_campaign_product cp
         where cp.campaign_id = i_campaign_id
           and cp.product_id  = l_product_id;

        trc_log_pkg.debug(
            i_text         => 'l_campaign_product_id [#1], l_command [#2]'
          , i_env_param1   => l_campaign_product_id
          , i_env_param2   => l_command
          , i_entity_type  => cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
          , i_object_id    => i_campaign_id
        );

        begin
            if l_campaign_product_id is null then
                -- Campaign product is NOT found
                if l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
                    raise e_skip_processing;

                elsif l_command in (app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
                                  , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
                                  , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED)
                then
                    com_api_error_pkg.raise_error(
                        i_error      => 'CPN_CAMPAIGN_DOES_NOT_INCLUDE_PRODUCT'
                      , i_env_param1 => i_campaign_id
                      , i_env_param2 => l_product_id
                      , i_env_param3 => l_product_number
                    );

                elsif l_command in (app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                                  , app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                                  , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT)
                then
                    cpn_ui_campaign_pkg.add_campaign_product(
                        o_id          => l_campaign_product_id
                      , i_campaign_id => i_campaign_id
                      , i_product_id  => l_product_id
                    );

                else
                    raise e_unknown_command;
                end if;

            else
                -- Campaign product is found
                if l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
                    com_api_error_pkg.raise_error(
                        i_error      => 'CPN_CAMPAIGN_ALREADY_INCLUDES_PRODUCT'
                      , i_env_param1 => i_campaign_id
                      , i_env_param2 => l_product_id
                      , i_env_param3 => l_product_number
                    );

                elsif l_command in (app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                                  , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE)
                then
                    raise e_unknown_command;

                elsif l_command in (app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
                                  , app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE)
                then
                    for rec in (
                        select id
                          from cpn_campaign_product p
                         where p.campaign_id = i_campaign_id
                           and p.product_id  = l_product_id
                    ) loop
                        cpn_ui_campaign_pkg.remove_campaign_product(i_id => rec.id);
                    end loop;

                elsif l_command in (app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                                  , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED)
                then
                    null;

                else
                    raise e_unknown_command;
                end if;
            end if;

            process_service(
                i_appl_data_id  => l_product_data_id_tab(i)
              , i_campaign_id   => i_campaign_id
              , i_product_id    => l_product_id
              , i_inst_id       => i_inst_id
            );
        exception
            when e_skip_processing then
                trc_log_pkg.debug(
                    i_text       => 'Skip processing due to command [#1]'
                  , i_env_param1 => l_command
                );
            when e_unknown_command then
                com_api_error_pkg.raise_error(
                    i_error      => 'INVALID_COMMAND'
                  , i_env_param1 => l_command
                  , i_env_param2 => 'CAMPAIGN_PRODUCT'
                  , i_env_param3 => l_product_data_id_tab(i)
                  , i_env_param4 => 'CMMDCRPR, CMMDCREX, CMMDEXRE, CMMDEXPR, CMMDPRRE' -- list of valid commands
                );
        end;
    end loop;
end process_product;

procedure process_cycle(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_campaign_id          in            com_api_type_pkg.t_short_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
) is
    l_cycle_data_id                      com_api_type_pkg.t_long_id;
    l_cycle_type                         com_api_type_pkg.t_dict_value;
    l_length_type                        com_api_type_pkg.t_dict_value;
    l_cycle_length                       com_api_type_pkg.t_short_id;
    l_is_workdays_only                   com_api_type_pkg.t_boolean;
    l_cycle_id                           com_api_type_pkg.t_short_id;
    l_shift_value_tab                    com_api_type_pkg.t_number_tab;
    l_shift_data_id_tab                  com_api_type_pkg.t_number_tab;
    l_shift_type                         com_api_type_pkg.t_dict_value;
    l_shift_priority                     com_api_type_pkg.t_tiny_id;
    l_shift_sign                         com_api_type_pkg.t_sign;
    l_shift_length_type                  com_api_type_pkg.t_dict_value;
    l_shift_length                       com_api_type_pkg.t_tiny_id;
    l_cycle_shift_id                     com_api_type_pkg.t_short_id;
begin
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'CAMPAIGN_CYCLE'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_cycle_data_id
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'CYCLE_TYPE'
      , i_parent_id     => l_cycle_data_id
      , o_element_value => l_cycle_type
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'CYCLE_LENGTH_TYPE'
      , i_parent_id     => l_cycle_data_id
      , o_element_value => l_length_type
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'CYCLE_LENGTH'
      , i_parent_id     => l_cycle_data_id
      , o_element_value => l_cycle_length
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'CYCLE_WORKDAYS_ONLY'
      , i_parent_id     => l_cycle_data_id
      , o_element_value => l_is_workdays_only
    );

    fcl_ui_cycle_pkg.add_cycle(
        i_cycle_type    => nvl(l_cycle_type, cpn_api_const_pkg.CYCLE_TYPE_PROMO_CAMPAIGN)
      , i_length_type   => l_length_type
      , i_cycle_length  => l_cycle_length
      , i_trunc_type    => null
      , i_inst_id       => i_inst_id
      , i_workdays_only => l_is_workdays_only
      , o_cycle_id      => l_cycle_id
    );

    app_api_application_pkg.get_appl_id_value(
        i_element_name  => 'SHIFT'
      , i_parent_id     => l_cycle_data_id
      , o_element_value => l_shift_value_tab
      , o_appl_data_id  => l_shift_data_id_tab
    );
    for i in 1 .. l_shift_data_id_tab.count() loop
        app_api_application_pkg.get_element_value(
            i_element_name   => 'SHIFT_TYPE'
          , i_parent_id      => l_shift_data_id_tab(i)
          , o_element_value  => l_shift_type
        );
        app_api_application_pkg.get_element_value(
            i_element_name   => 'SHIFT_PRIORITY'
          , i_parent_id      => l_shift_data_id_tab(i)
          , o_element_value  => l_shift_priority
        );
        app_api_application_pkg.get_element_value(
            i_element_name   => 'SHIFT_SIGN'
          , i_parent_id      => l_shift_data_id_tab(i)
          , o_element_value  => l_shift_sign
        );
        app_api_application_pkg.get_element_value(
            i_element_name   => 'SHIFT_LENGTH_TYPE'
          , i_parent_id      => l_shift_data_id_tab(i)
          , o_element_value  => l_shift_length_type
        );
        app_api_application_pkg.get_element_value(
            i_element_name   => 'SHIFT_LENGTH'
          , i_parent_id      => l_shift_data_id_tab(i)
          , o_element_value  => l_shift_length
        );
        fcl_ui_cycle_pkg.add_cycle_shift(
            i_cycle_id       => l_cycle_id
          , i_shift_type     => l_shift_type
          , i_priority       => l_shift_priority
          , i_shift_sign     => l_shift_sign
          , i_length_type    => l_shift_length_type
          , i_shift_length   => l_shift_length
          , o_cycle_shift_id => l_cycle_shift_id
        );
    end loop;
end process_cycle;

procedure process_campaign_name(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_campaign_id          in            com_api_type_pkg.t_short_id
) is
    l_short_names                        com_api_type_pkg.t_multilang_desc_tab;
    l_descriptions                       com_api_type_pkg.t_multilang_desc_tab;
    l_id_tab                             com_api_type_pkg.t_number_tab;
    l_lang_tab                           com_api_type_pkg.t_dict_tab;
begin
    app_api_application_pkg.get_appl_data_id(
        i_element_name    => 'CAMPAIGN_NAME'
      , i_parent_id       => i_appl_data_id
      , o_appl_data_id    => l_id_tab
      , o_appl_data_lang  => l_lang_tab
    );

    for i in 1..l_id_tab.count() loop
        trc_log_pkg.debug(
            i_text        => 'Updating campaign name [#1] of [#2] for language [#3]'
          , i_env_param1  => i
          , i_env_param2  => l_id_tab.count()
          , i_env_param3  => l_lang_tab(i)
        );

        com_api_i18n_pkg.add_text(
            i_table_name   => 'cpn_campaign'
          , i_column_name  => 'label'
          , i_object_id    => i_campaign_id
          , i_text         => app_api_application_pkg.get_element_value_v(
                                  i_element_name  => 'CAMPAIGN_SHORT_NAME'
                                , i_parent_id     => l_id_tab(i)
                              )
          , i_lang         => l_lang_tab(i)
        );

        com_api_i18n_pkg.add_text(
            i_table_name   => 'cpn_campaign'
          , i_column_name  => 'description'
          , i_object_id    => i_campaign_id
          , i_text         => app_api_application_pkg.get_element_value_v(
                                  i_element_name  => 'CAMPAIGN_DESCRIPTION'
                                , i_parent_id     => l_id_tab(i)
                              )
          , i_lang         => l_lang_tab(i)
        );
    end loop;
end process_campaign_name;

procedure process_application(
    i_appl_id              in            com_api_type_pkg.t_long_id
) is
    LOG_PREFIX                  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_application: ';
    l_root_id                            com_api_type_pkg.t_long_id;
    l_appl_id                            com_api_type_pkg.t_long_id;
    l_command                            com_api_type_pkg.t_dict_value;
    l_campaign_data_id                   com_api_type_pkg.t_long_id;
    l_campaign_number                    com_api_type_pkg.t_name;
    l_inst_id                            com_api_type_pkg.t_inst_id;
    l_campaign                           cpn_api_type_pkg.t_campaign_rec;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' START i_appl_id [' || i_appl_id || ']'
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_root_id
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
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'CAMPAIGN'
      , i_parent_id     => l_root_id
      , o_appl_data_id  => l_campaign_data_id
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'CAMPAIGN_NUMBER'
      , i_parent_id     => l_campaign_data_id
      , o_element_value => l_campaign_number
    );

    l_campaign :=
        cpn_api_campaign_pkg.get_campaign(
            i_campaign_number  => l_campaign_number
          , i_inst_id          => l_inst_id
          , i_mask_error       => com_api_const_pkg.TRUE
        );

    if l_campaign.id is not null then
        trc_log_pkg.debug(
            i_text         => LOG_PREFIX || 'campaign with ID [#1] found by number [#2] and institution [#3]'
          , i_env_param1   => l_campaign.id
          , i_env_param2   => l_campaign_number
          , i_env_param3   => l_inst_id
          , i_entity_type  => cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
          , i_object_id    => l_campaign.id
        );
    end if;

    app_api_application_pkg.get_element_value(
        i_element_name  => 'COMMAND'
      , i_parent_id     => l_campaign_data_id
      , o_element_value => l_command
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'CAMPAIGN_TYPE'
      , i_parent_id     => l_campaign_data_id
      , o_element_value => l_campaign.campaign_type
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'START_DATE'
      , i_parent_id     => l_campaign_data_id
      , o_element_value => l_campaign.start_date
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'END_DATE'
      , i_parent_id     => l_campaign_data_id
      , o_element_value => l_campaign.end_date
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'application campaign fields = {type [#1], start_date [#2], end_date [#3]}; command [#4]'
      , i_env_param1 => l_campaign.campaign_type
      , i_env_param2 => l_campaign.start_date
      , i_env_param3 => l_campaign.end_date
      , i_env_param4 => l_command
    );

    if l_campaign.id is null then
        -- Campaign is NOT found
        if l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
            raise e_skip_processing;
        elsif l_command in (app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
                          , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
                          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED)
        then
            com_api_error_pkg.raise_error(
                i_error      => 'CAMPAIGN_NOT_FOUND'
              , i_env_param2 => l_campaign_number
              , i_env_param3 => l_inst_id
            );
        elsif l_command in (app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                          , app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                          , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT)
        then
            cpn_ui_campaign_pkg.add_campaign(
                o_id              => l_campaign.id
              , o_seqnum          => l_campaign.seqnum
              , i_campaign_number => l_campaign_number
              , i_campaign_type   => l_campaign.campaign_type
              , i_inst_id         => l_inst_id
              , i_start_date      => l_campaign.start_date
              , i_end_date        => l_campaign.end_date
              , i_lang            => null
              , i_label           => null
              , i_description     => null
            );
            process_campaign_name(
                i_appl_data_id    => l_campaign_data_id
              , i_campaign_id     => l_campaign.id
            );
        end if;
    else
        -- Campaign is found
        if l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error(
                i_error       => 'CPN_CAMPAIGN_ALREADY_EXISTS'
              , i_env_param1  => l_campaign.campaign_number
              , i_env_param2  => l_campaign.inst_id
            );
        elsif l_command in (app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                          , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE)
        then
            cpn_ui_campaign_pkg.modify_campaign(
                i_id              => l_campaign.id
              , io_seqnum         => l_campaign.seqnum
              , i_campaign_number => l_campaign.campaign_number
              , i_campaign_type   => l_campaign.campaign_type
              , i_start_date      => l_campaign.start_date
              , i_end_date        => l_campaign.end_date
              , i_lang            => l_campaign.lang
              , i_label           => l_campaign.name
              , i_description     => l_campaign.description
            );
            process_campaign_name(
                i_appl_data_id    => l_campaign_data_id
              , i_campaign_id     => l_campaign.id
            );
        elsif l_command in (app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED)
        then
            null;
        elsif l_command in (app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
                          , app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE)
        then
            -- Closing a campaign is not implemented
            raise e_skip_processing;
        end if;
    end if;

    attach_campaign_to_application(i_campaign_id => l_campaign.id);

    process_product(
        i_appl_data_id  => l_campaign_data_id
      , i_campaign_id   => l_campaign.id
      , i_inst_id       => l_inst_id
    );

    if l_campaign.campaign_type in (cpn_api_const_pkg.CAMPAIGN_TYPE_PROMO_CAMPAIGN) then
        process_cycle(
            i_appl_data_id  => l_campaign_data_id
          , i_campaign_id   => l_campaign.id
          , i_inst_id       => l_inst_id
        );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'FINISH'
    );
exception
    when e_skip_processing then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'skip processing due to command [#1]'
          , i_env_param1 => l_command
        );
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => l_root_id
          , i_element_name  => 'APPLICATION'
        );
end process_application;

end;
/
