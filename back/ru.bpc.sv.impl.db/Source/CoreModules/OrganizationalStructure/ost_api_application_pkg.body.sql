create or replace package body ost_api_application_pkg as
/************************************************************
 * API for institution applications <br />
 * Created by Gerbeev I.(gerbeev@bpcbt.com)  at 07.02.2018  <br />
 * Module: ost_api_application_pkg <br />
 * @headcom
 ************************************************************/
procedure process_application(
    i_appl_id              in           com_api_type_pkg.t_long_id
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name      := lower($$PLSQL_UNIT) || '.process_application';
    l_root_id              com_api_type_pkg.t_long_id;
    l_appl_data_id         com_api_type_pkg.t_long_id;
    l_appl_id              com_api_type_pkg.t_long_id;
    l_inst_id              com_api_type_pkg.t_inst_id;
begin
    trc_log_pkg.debug(LOG_PREFIX || '. Application processing started, i_appl_id [' || i_appl_id || '].');

    -- Get Root Element
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_root_id
    );

    -- Application ID
    app_api_application_pkg.get_element_value(
        i_element_name  => 'APPLICATION_ID'
      , i_parent_id     => l_root_id
      , o_element_value => l_appl_id
    );

    -- Institution ID
    app_api_application_pkg.get_element_value(
        i_element_name   => 'INSTITUTION_ID'
      , i_parent_id      => l_root_id
      , o_element_value  => l_inst_id
    );

    -- Institution Application Element
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'INSTITUTION'
      , i_parent_id      => l_root_id
      , o_appl_data_id   => l_appl_data_id
    );

    -- Process Application
    if l_appl_data_id is not null then
        process_institution(
            i_appl_data_id  => l_appl_data_id
          , i_appl_id       => l_appl_id
        );
    end if;

    app_api_flexible_field_pkg.process_flexible_fields(
        i_entity_type   => app_api_const_pkg.ENTITY_TYPE_APPLICATION
      , i_object_type   => null
      , i_object_id     => l_appl_data_id
      , i_inst_id       => l_inst_id
      , i_appl_data_id  => l_root_id
    );

    app_api_note_pkg.process_note(
        i_appl_data_id => l_root_id
      , i_entity_type  => app_api_const_pkg.ENTITY_TYPE_APPLICATION
      , i_object_id    => l_appl_id
    );

    trc_log_pkg.debug(LOG_PREFIX || '. Application processing has been finished.');

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => l_appl_data_id
          , i_element_name  => 'APPLICATION'
        );
end;

procedure process_institution(
    i_appl_data_id  in     com_api_type_pkg.t_long_id
  , i_appl_id       in     com_api_type_pkg.t_long_id
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_institution';

    l_command               com_api_type_pkg.t_dict_value;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_inst_name             com_api_type_pkg.t_name;
    l_parent_inst_id        com_api_type_pkg.t_inst_id;
    l_inst_type             com_api_type_pkg.t_dict_value;
    l_network_id            com_api_type_pkg.t_inst_id; 
    l_description           com_api_type_pkg.t_full_desc;
    l_lang                  com_api_type_pkg.t_dict_value;
    l_refresh_matview       com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_participant_type      com_api_type_pkg.t_dict_value;
    l_seqnum                com_api_type_pkg.t_seqnum;
    l_address_id_tab        com_api_type_pkg.t_number_tab;
    l_address_id            com_api_type_pkg.t_long_id;
    l_customer_id           com_api_type_pkg.t_medium_id;
    l_customer_data_id      com_api_type_pkg.t_long_id;
    l_agent_id_tab          com_api_type_pkg.t_number_tab;
    l_account_id_tab        com_api_type_pkg.t_number_tab;
    l_account_id_out_tab    com_api_type_pkg.t_medium_tab;
    l_contact_id_tab        com_api_type_pkg.t_number_tab;
    l_contract_id           com_api_type_pkg.t_long_id;
    l_cust_contract_id_tab  com_api_type_pkg.t_number_tab;
    l_product_id            com_api_type_pkg.t_long_id;
    l_inst_status           com_api_type_pkg.t_dict_value;
    e_invalid_application_command exception;

    procedure clone_prd_attributes(
        i_product_id        in  com_api_type_pkg.t_long_id
      , i_inst_id           in  com_api_type_pkg.t_short_id
    )
    is
        l_attr_id           com_api_type_pkg.t_medium_id;
        l_eff_date          date    := com_api_sttl_day_pkg.get_sysdate;
    begin
        for c in (
            select a.data_type
                 , a.attr_name
                 , av.service_id
                 , av.mod_id
                 , av.start_date
                 , av.end_date
                 , av.attr_value
              from prd_attribute_value av
                 , prd_attribute a
             where av.entity_type   = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
               and av.object_id     = i_product_id
               and av.attr_id       = a.id
        ) loop
            l_attr_id := null;

            if c.end_date > l_eff_date or c.end_date is null then
                    prd_api_attribute_value_pkg.set_attr_value(
                        io_id               => l_attr_id
                      , i_service_id        => c.service_id
                      , i_entity_type       => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                      , i_object_id         => i_inst_id
                      , i_attr_name         => c.attr_name
                      , i_mod_id            => c.mod_id
                      , i_start_date        => l_eff_date
                      , i_end_date          => c.end_date
                      , i_value_num         =>
                            case c.data_type
                                when com_api_const_pkg.DATA_TYPE_NUMBER then
                                    to_number(c.attr_value, com_api_const_pkg.NUMBER_FORMAT)
                            end
                      , i_value_char        =>
                            case c.data_type
                                when com_api_const_pkg.DATA_TYPE_CHAR then
                                    c.attr_value
                            end
                      , i_value_date        =>
                            case c.data_type
                                when com_api_const_pkg.DATA_TYPE_DATE then
                                    to_date(c.attr_value, com_api_const_pkg.DATE_FORMAT)
                            end
                      , i_data_type         => c.data_type
                      , i_check_start_date  => com_api_type_pkg.FALSE
                      , i_inst_id           => i_inst_id
                    );
            end if;
        end loop;
    end clone_prd_attributes;

begin
    trc_log_pkg.debug(LOG_PREFIX || ' has been started. Parameters: i_appl_data_id [' || i_appl_data_id || ']');

    app_api_application_pkg.get_element_value (
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'INST_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_inst_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'INSTITUTION_NAME'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_inst_name
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'INSTITUTION_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_inst_type
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'PARENT_INSTITUTION_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_parent_inst_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'NETWORK_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_network_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'INST_STATUS'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_inst_status
    );

    if l_command is null then
        com_api_error_pkg.raise_error(
            i_error       => 'ABSENT_MANDATORY_ELEMENT'
          , i_env_param1  => 'COMMAND'
        );
    end if;

    -- institution
    if l_inst_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'ABSENT_MANDATORY_ELEMENT'
          , i_env_param1  => 'INSTITUTION_ID'
        );
    else

        begin
            select id
              into l_inst_id
              from ost_institution_vw
             where id  = l_inst_id
               and rownum   = 1;
            trc_log_pkg.debug('Institution with ID [' || l_inst_id || '] found');
            case
                when l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT 
                then
                    com_api_error_pkg.raise_error(
                        i_error      => 'INSTITUTION_ALREADY_EXISTS'
                      , i_env_param1 => l_inst_id
                      , i_env_param2 => case when l_inst_id is null then l_inst_name end
                    );
                when l_command in (app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                                 , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE)
                then
                    ost_ui_institution_pkg.modify_institution(
                        i_inst_id           =>      l_inst_id
                      , i_name              =>      l_inst_name
                      , i_parent_inst_id    =>      l_parent_inst_id
                      , i_inst_type         =>      l_inst_type
                      , i_network_id        =>      l_network_id
                      , i_description       =>      l_description
                      , i_lang              =>      l_lang
                      , i_refresh_matview   =>      l_refresh_matview
                      , i_participant_type  =>      l_participant_type
                      , i_status            =>      l_inst_status
                      , io_seqnum           =>      l_seqnum
                    );
                else
                    raise e_invalid_application_command;
            end case;
        exception
            when no_data_found then
                trc_log_pkg.debug('Institution not found');
                case
                    when l_command in (app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                                     , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT)
                    then
                        ost_ui_institution_pkg.add_institution(
                            i_inst_id           =>      l_inst_id
                          , i_name              =>      l_inst_name
                          , i_parent_inst_id    =>      l_parent_inst_id
                          , i_inst_type         =>      l_inst_type
                          , i_network_id        =>      l_network_id
                          , i_description       =>      l_description
                          , i_lang              =>      l_lang
                          , i_refresh_matview   =>      l_refresh_matview
                          , i_participant_type  =>      l_participant_type
                          , i_status            =>      l_inst_status
                          , o_seqnum            =>      l_seqnum
                        );
                    when l_command in (app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE)
                    then
                        com_api_error_pkg.raise_error(
                            i_error      => 'INSTITUTION_DOES_NOT_EXIST'
                          , i_env_param1 => l_inst_id
                          , i_env_param2 => case when l_inst_id is null then l_inst_name end
                        );
                    else
                        raise e_invalid_application_command;
                end case;
        end;
    end if;

    --  processing agent
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'AGENT'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_agent_id_tab
    );

    trc_log_pkg.debug(LOG_PREFIX || ' blocks <AGENT> have been read: ' || l_agent_id_tab.count());

    if nvl(l_agent_id_tab.count, 0) > 0 then
        for i in 1.. nvl(l_agent_id_tab.count, 0) loop
            ost_api_application_pkg.process_agent(
                i_appl_data_id         => l_agent_id_tab(i)
              , i_inst_id              => l_inst_id
              , i_appl_id              => i_appl_id
            );
        end loop;
    else
        com_api_error_pkg.raise_error(
            i_error      => 'DEF_AGENT_NOT_FOUND'
          , i_env_param1 => l_inst_id
        );
    end if;

    --  processing customer
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'CUSTOMER'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_customer_data_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'CONTRACT'
      , i_parent_id     => l_customer_data_id
      , o_appl_data_id  => l_cust_contract_id_tab
    );

    trc_log_pkg.debug(LOG_PREFIX || ': app_api_customer_pkg.process_customer. l_customer_data_id = ' || l_customer_data_id || ', l_cust_contract_id_tab.count() = ' || l_cust_contract_id_tab.count());

    if l_customer_data_id is not null and nvl(l_cust_contract_id_tab.count(), 0) > 0 then
        app_api_customer_pkg.process_customer(
            i_appl_data_id => l_customer_data_id
          , i_inst_id      => l_inst_id
          , o_customer_id  => l_customer_id
        );
    end if;

    --  processing address
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'ADDRESS'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_address_id_tab
    );

    trc_log_pkg.debug(LOG_PREFIX || ' blocks <ADDRESS> have been read: ' || l_address_id_tab.count());

    for i in 1.. nvl(l_address_id_tab.count, 0) loop
        app_api_address_pkg.process_address(
            i_appl_data_id         => l_address_id_tab(i)
          , i_parent_appl_data_id  => i_appl_data_id
          , i_object_id            => l_inst_id
          , i_entity_type          => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
          , o_address_id           => l_address_id
        );
    end loop;

    --  processing contact
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'CONTACT'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_contact_id_tab
    );

    trc_log_pkg.debug(LOG_PREFIX || ' blocks <CONTACT> have been read: ' || l_contact_id_tab.count());

    for i in 1..nvl(l_contact_id_tab.count, 0) loop
        app_api_contact_pkg.process_contact(
            i_appl_data_id          => l_contact_id_tab(i)
          , i_parent_appl_data_id   => i_appl_data_id
          , i_object_id             => l_inst_id
          , i_entity_type           => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
        );
    end loop;

    -- processing account
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'ACCOUNT'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_account_id_tab
    );

    l_contract_id :=
        rul_api_param_pkg.get_param_num(
            i_name    => 'CONTRACT_ID'
          , io_params => app_api_application_pkg.g_params
        );

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type   => com_api_const_pkg.ENTITY_TYPE_CONTRACT
          , i_object_id     => l_contract_id
        );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' l_contract_id [#1], l_product_id [#2], blocks <ACCOUNT> have been read [#3].'
      , i_env_param1 => l_contract_id
      , i_env_param2 => l_product_id
      , i_env_param3 => l_account_id_tab.count()
    );

    if nvl(l_account_id_tab.count, 0) > 0
       and app_api_error_pkg.g_app_errors.count = 0
    then
        l_account_id_out_tab.delete; 
        for i in 1..nvl(l_account_id_tab.count, 0) loop
            app_api_account_pkg.process_account(
                i_appl_data_id  => l_account_id_tab(i)
              , i_inst_id       => l_inst_id
              , i_agent_id      => null
              , i_customer_id   => l_customer_id
              , i_contract_id   => l_contract_id
              , o_account_id    => l_account_id_out_tab(i)
            );
        end loop;
        trc_log_pkg.debug(LOG_PREFIX || 'blocks <ACCOUNT> have been processed');
    end if;

    app_api_service_pkg.process_entity_service(
        i_appl_data_id  => i_appl_data_id
      , i_element_name  => 'INSTITUTION'
      , i_entity_type   => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
      , i_object_id     => l_inst_id
      , i_contract_id   => l_contract_id
      , io_params       => app_api_application_pkg.g_params
    );

    app_api_appl_object_pkg.add_object(
        i_appl_id           => i_appl_id
      , i_entity_type       => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
      , i_object_id         => l_inst_id
      , i_seqnum            => l_seqnum
    );

    app_api_flexible_field_pkg.process_flexible_fields(
        i_entity_type   => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
      , i_object_type   => null
      , i_object_id     => l_inst_id
      , i_inst_id       => l_inst_id
      , i_appl_data_id  => i_appl_data_id
    );

    app_api_note_pkg.process_note(
        i_appl_data_id => i_appl_data_id
      , i_entity_type  => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
      , i_object_id    => l_inst_id
    );

    trc_log_pkg.debug(LOG_PREFIX || 'Institution with id [' || l_inst_id || '] has been processed');

exception
    when e_invalid_application_command then
        com_api_error_pkg.raise_error(
            i_error      => 'INVALID_COMMAND'
          , i_env_param1 => l_command
          , i_env_param2 => 'INSTITUTION'
          , i_env_param3 => i_appl_data_id
          , i_env_param4 => app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                         || ', '
                         || app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
                         || ', '
                         || app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
        );
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'INSTITUTION'
        );
end process_institution;

procedure process_agent(
    i_appl_data_id   in     com_api_type_pkg.t_long_id
  , i_inst_id        in     com_api_type_pkg.t_inst_id
  , i_appl_id        in     com_api_type_pkg.t_long_id
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_agent';

    l_command               com_api_type_pkg.t_dict_value;
    l_agent_id              com_api_type_pkg.t_agent_id;
    l_inst_id               com_api_type_pkg.t_inst_id;
    l_agent_type            com_api_type_pkg.t_dict_value;
    l_agent_name            com_api_type_pkg.t_short_desc;
    l_parent_agent_id       com_api_type_pkg.t_agent_id;
    l_is_default            com_api_type_pkg.t_boolean;
    l_agent_number          com_api_type_pkg.t_name;
    l_seqnum                com_api_type_pkg.t_seqnum;
    l_refresh_matview       com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;

    e_invalid_application_command exception;
begin
    trc_log_pkg.debug(LOG_PREFIX || ' has been started. Parameters: i_appl_data_id [' || i_appl_data_id || '], i_inst_id [' || i_inst_id || ']');

    app_api_application_pkg.get_element_value (
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    if l_command is null then
        com_api_error_pkg.raise_error(
            i_error       => 'ABSENT_MANDATORY_ELEMENT'
          , i_env_param1  => 'COMMAND'
        );
    end if;

    app_api_application_pkg.get_element_value (
        i_element_name   => 'INSTITUTION_AGENT_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_agent_id
    );

    app_api_application_pkg.get_element_value (
        i_element_name   => 'AGENT_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_agent_number
    );

    app_api_application_pkg.get_element_value (
        i_element_name   => 'AGENT_NAME'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_agent_name
    );

    app_api_application_pkg.get_element_value (
        i_element_name   => 'AGENT_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_agent_type
    );

    app_api_application_pkg.get_element_value (
        i_element_name   => 'PARENT_AGENT_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_parent_agent_id
    );

    app_api_application_pkg.get_element_value (
        i_element_name   => 'IS_DEFAULT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_is_default
    );

    if l_agent_id is null then
        com_api_error_pkg.raise_error(
            i_error       => 'ABSENT_MANDATORY_ELEMENT'
          , i_env_param1  => 'AGENT_ID'
        );
    else
        begin
            select id
                 , seqnum
              into l_agent_id
                 , l_seqnum
              from ost_agent_vw
             where id  = l_agent_id
               and rownum   = 1;
            trc_log_pkg.debug('Agent with ID [' || l_agent_id || '] found');
            case
                when l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT 
                then
                    com_api_error_pkg.raise_error(
                        i_error      => 'AGENT_ALREADY_EXISTS'
                      , i_env_param1 => l_agent_id
                      , i_env_param2 => case when l_agent_id is null then l_agent_name end
                    );
                when l_command in (app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                                 , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE)
                then
                    ost_ui_agent_pkg.modify_agent(
                        i_agent_id          =>  l_agent_id
                      , i_name              =>  l_agent_name
                      , i_parent_agent_id   =>  l_parent_agent_id
                      , i_is_default        =>  l_is_default
                      , i_seqnum            =>  l_seqnum
                      , i_agent_number      =>  l_agent_number
                      , i_refresh_matview   =>  l_refresh_matview
                    );
                else
                    raise e_invalid_application_command;
            end case;
        exception
            when no_data_found then
                trc_log_pkg.debug('Agent not found');
            case
                when l_command in (app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                                 , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT)
                then
                    ost_ui_agent_pkg.add_agent(
                        o_agent_id          =>  l_agent_id
                      , i_inst_id           =>  i_inst_id
                      , i_agent_type        =>  l_agent_type
                      , i_name              =>  l_agent_name
                      , i_parent_agent_id   =>  l_parent_agent_id
                      , i_is_default        =>  l_is_default
                      , i_agent_number      =>  l_agent_number
                      , i_refresh_matview   =>  l_refresh_matview
                    );
                when l_command in (app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE)
                then
                    com_api_error_pkg.raise_error(
                        i_error      => 'AGENT_DOES_NOT_EXIST'
                      , i_env_param1 => l_inst_id
                      , i_env_param2 => case when l_agent_id is null then l_agent_name end
                    );
                else
                    raise e_invalid_application_command;
            end case;
        end;
    end if;

    rul_api_param_pkg.set_param(
        i_value         => l_agent_id
      , i_name          => 'AGENT_ID'
      , io_params       => app_api_application_pkg.g_params
    );

    app_api_appl_object_pkg.add_object(
        i_appl_id           => i_appl_id
      , i_entity_type       => ost_api_const_pkg.ENTITY_TYPE_AGENT
      , i_object_id         => l_agent_id
      , i_seqnum            => l_seqnum
    );

    trc_log_pkg.debug(LOG_PREFIX || 'Agent with id [' || i_inst_id || '] has been processed');

exception
    when e_invalid_application_command then
        com_api_error_pkg.raise_error(
            i_error      => 'INVALID_COMMAND'
          , i_env_param1 => l_command
          , i_env_param2 => 'AGENT'
          , i_env_param3 => i_appl_data_id
          , i_env_param4 => app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                         || ', '
                         || app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
                         || ', '
                         || app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
        );
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'AGENT'
        );
end process_agent;

end;
/
