create or replace package body app_api_payment_order_pkg is
/*********************************************************
 *  API for Payment Order in application <br />
 *  Created by Kopachev A.(kopachev@bpc.ru)  at 29.05.2012 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: APP_API_PAYMENT_ORDER_PKG  <br />
 *  @headcom
 **********************************************************/
procedure process_parameter(
    i_parameter_id         in            com_api_type_pkg.t_long_id
  , i_order_id             in            com_api_type_pkg.t_long_id
  , i_payment_purpose_id   in            com_api_type_pkg.t_short_id
) is
    l_param_name            com_api_type_pkg.t_name;
    l_param_value           com_api_type_pkg.t_param_value;
begin
    app_api_application_pkg.get_element_value(
        i_element_name   => 'PAYMENT_PARAMETER_NAME'
      , i_parent_id      => i_parameter_id
      , o_element_value  => l_param_name
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'PAYMENT_PARAMETER_VALUE'
      , i_parent_id      => i_parameter_id
      , o_element_value  => l_param_value
    );

    trc_log_pkg.debug(
        i_text => 'app_api_payment_order_pkg.process_order l_order_id [#3] l_payment_purpose_id [#4] l_param_name [#1] l_param_value [#2]'
        , i_env_param1 => l_param_name
        , i_env_param2 => l_param_value
        , i_env_param3 => i_order_id
        , i_env_param4 => i_payment_purpose_id
    );

    pmo_api_order_pkg.add_order_data(
        i_order_id     => i_order_id
      , i_param_name   => l_param_name
      , i_param_value  => l_param_value
      , i_purpose_id   => i_payment_purpose_id
    );
end;

procedure process_order(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_object_id            in            com_api_type_pkg.t_long_id
  , i_agent_id             in            com_api_type_pkg.t_short_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
) is
    l_is_template           com_api_type_pkg.t_boolean;
    l_order_id              com_api_type_pkg.t_long_id;
    l_schedule_id           com_api_type_pkg.t_long_id;
    l_seqnum                com_api_type_pkg.t_seqnum;

    l_payment_purpose_id    com_api_type_pkg.t_short_id;
    l_payment_date          date;
    l_payment_amount        com_api_type_pkg.t_money;
    l_payment_currency      com_api_type_pkg.t_curr_code;

    l_parameter_id          com_api_type_pkg.t_number_tab;
    l_param_name            com_api_type_pkg.t_name;
    l_param_value           com_api_type_pkg.t_param_value;
    l_purpose_label         com_api_type_pkg.t_text;
    l_event_type            com_api_type_pkg.t_desc_tab;
    l_payment_amount_algo   com_api_type_pkg.t_dict_value;
    l_command               com_api_type_pkg.t_dict_value;
    l_payment_order_number  com_api_type_pkg.t_name;
    l_split_hash            com_api_type_pkg.t_tiny_id;
    l_is_prepared_order     com_api_type_pkg.t_boolean;
    l_status                com_api_type_pkg.t_dict_value;
    l_label                 com_api_type_pkg.t_multilang_desc_tab;
    l_description           com_api_type_pkg.t_multilang_desc_tab;
    l_template_status       com_api_type_pkg.t_dict_value;
    l_attempt_count         com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug (
        i_text => 'app_api_payment_order_pkg.process_order'
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    l_command := nvl(l_command, app_api_const_pkg.COMMAND_CREATE_OR_UPDATE);

    app_api_application_pkg.get_element_value (
        i_element_name   => 'PAYMENT_ORDER_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_payment_order_number
    );

    app_api_application_pkg.get_element_value (
        i_element_name   => 'IS_PAYMENT_ORDER_TEMPLATE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_is_template
    );

    l_is_template := nvl(l_is_template, com_api_type_pkg.FALSE);

    if l_payment_order_number is not null then
        begin
            select id
                 , purpose_id
                 , is_prepared_order
                 , split_hash
              into l_order_id
                 , l_payment_purpose_id
                 , l_is_prepared_order
                 , l_split_hash
              from pmo_order
             where customer_id = i_customer_id
               and is_template = l_is_template
               and payment_order_number = l_payment_order_number;
        exception
            when no_data_found then
                l_order_id := null;
        end;
    end if;

    app_api_application_pkg.get_element_value (
        i_element_name   => 'PAYMENT_AMOUNT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_payment_amount
    );
    app_api_application_pkg.get_element_value (
        i_element_name   => 'CURRENCY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_payment_currency
    );

    app_api_application_pkg.get_element_value (
        i_element_name   => 'PAYMENT_PURPOSE_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_payment_purpose_id
    );

    app_api_application_pkg.get_element_value (
        i_element_name   => 'PAYMENT_AMOUNT_ALGO'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_payment_amount_algo
    );

    trc_log_pkg.debug (
        i_text => 'app_api_payment_order_pkg.process_order l_is_template [#1] l_order_id [#2]'
        , i_env_param1 => l_is_template
        , i_env_param2 => l_order_id
    );

    if l_is_template = com_api_type_pkg.TRUE then

        -- process multi-language label
        app_api_application_pkg.get_element_value(
            i_element_name  => 'LABEL'
          , i_parent_id     => i_appl_data_id
          , o_element_value => l_label
        );

        app_api_application_pkg.get_element_value(
            i_element_name  => 'DESCRIPTION'
          , i_parent_id     => i_appl_data_id
          , o_element_value => l_description
        );

        app_api_application_pkg.get_element_value (
            i_element_name   => 'TEMPLATE_STATUS'
          , i_parent_id      => i_appl_data_id
          , o_element_value  => l_template_status
        );

        app_api_application_pkg.get_element_value (
            i_element_name   => 'ATTEMPT_COUNT'
          , i_parent_id      => i_appl_data_id
          , o_element_value  => l_attempt_count
        );
        trc_log_pkg.debug (
            i_text => 'app_api_payment_order_pkg.process_order l_template_status [#1] l_attempt_count [#2]'
            , i_env_param1 => l_template_status
            , i_env_param2 => l_attempt_count
        );

        if l_order_id is not null then
            -- payment order update
            if l_command in (app_api_const_pkg.COMMAND_CREATE_OR_UPDATE,
                             app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE) then

                pmo_ui_template_pkg.modify(
                    i_id                => l_order_id
                  , i_customer_id       => i_customer_id
                  , i_purpose_id        => l_payment_purpose_id
                  , i_status            => l_template_status
                  , i_inst_id           => null
                  , i_is_prepared_order => l_is_prepared_order
                  , i_label             => null
                  , i_description       => null
                  , i_lang              => null
                  , i_amount            => l_payment_amount
                  , i_currency          => l_payment_currency
                );

                trc_log_pkg.debug(
                    i_text          => 'Count of labels [#1], count of descriptions [#2] for order [#3]'
                  , i_env_param1    => l_label.count
                  , i_env_param2    => l_description.count
                  , i_env_param3    => l_order_id
                );

                -- set new label and description
                for i in 1..nvl(l_label.count, 0) loop
                    com_api_i18n_pkg.add_text(
                        i_table_name   => 'pmo_order'
                      , i_column_name  => 'label'
                      , i_object_id    => l_order_id
                      , i_text         => l_label(i).value
                      , i_lang         => l_label(i).lang
                    );
                end loop;

                for i in 1..nvl(l_description.count, 0) loop
                    com_api_i18n_pkg.add_text(
                        i_table_name   => 'pmo_order'
                      , i_column_name  => 'description'
                      , i_object_id    => l_order_id
                      , i_text         => l_description(i).value
                      , i_lang         => l_description(i).lang
                    );
                end loop;

                -- update event_type
                app_api_application_pkg.get_element_value(
                    i_element_name   => 'EVENT_TYPE'
                  , i_parent_id      => i_appl_data_id
                  , o_element_value  => l_event_type
                );

                if l_payment_amount_algo is not null then
                    for i in 1..nvl(l_event_type.count, 0) loop
                        for r in (
                            select id schedule_id
                                 , seqnum
                              from pmo_schedule
                             where order_id   = l_order_id
                               and event_type = l_event_type(i)
                        ) loop
                            trc_log_pkg.debug(
                                i_text          => 'l_attempt_count = ' || l_attempt_count || ', r.schedule_id = ' || r.schedule_id
                            );
                            l_seqnum := r.seqnum;
                            pmo_api_order_pkg.modify_schedule(
                                i_id                  => r.schedule_id
                              , io_seqnum             => l_seqnum
                              , i_amount_algorithm    => l_payment_amount_algo
                              , i_attempt_limit       => l_attempt_count
                              , i_cycle_id            => null
                              , i_event_type          => l_event_type(i)
                            );
                        end loop;
                    end loop;
                end if;

                app_api_application_pkg.get_appl_data_id (
                    i_element_name   => 'PAYMENT_PARAMETER'
                  , i_parent_id      => i_appl_data_id
                  , o_appl_data_id   => l_parameter_id
                );

                for i in 1..nvl(l_parameter_id.count,0) loop
                    process_parameter(
                        i_parameter_id       => l_parameter_id(i)
                      , i_order_id           => l_order_id
                      , i_payment_purpose_id => l_payment_purpose_id
                    );
                end loop;

            -- raise error
            elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then

                com_api_error_pkg.raise_error (
                    i_error         => 'PAYMENT_ORDER_NUMBER_NOT_UNIQUE'
                  , i_env_param1    => l_payment_order_number
                );

            -- payment order delete
            elsif l_command in (app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE,
                                app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE) then

                pmo_ui_template_pkg.remove(
                    i_id => l_order_id
                );

                delete from fcl_cycle_counter
                 where (cycle_type, entity_type, object_id, split_hash) in
                   (
                    select event_type, entity_type, object_id, l_split_hash
                      from pmo_schedule
                     where order_id = l_order_id
                   );
            else
                null;
            end if;
        else
            -- payment order create new
            if l_command in (app_api_const_pkg.COMMAND_CREATE_OR_UPDATE,
                             app_api_const_pkg.COMMAND_CREATE_OR_PROCEED,
                             app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT) then

                if l_label.count is null then

                    for r in (
                        select
                            get_text('pmo_service', 'label', service_id, get_def_lang) || ' - ' ||
                            get_text('pmo_provider', 'label', provider_id, get_def_lang) label
                        from
                            pmo_purpose_vw
                        where
                            id = l_payment_purpose_id
                    ) loop
                        l_purpose_label := r.label;
                        exit;
                    end loop;
                end if;

                pmo_ui_template_pkg.add(
                    o_id                 => l_order_id
                  , i_customer_id        => i_customer_id
                  , i_purpose_id         => l_payment_purpose_id
                  , i_status             => pmo_api_const_pkg.PAYMENT_TMPL_STATUS_VALD
                  , i_inst_id            => i_inst_id
                  , i_is_prepared_order  => com_api_type_pkg.FALSE
                  , i_label              => l_purpose_label
                  , i_description        => null
                  , i_entity_type        => i_entity_type
                  , i_object_id          => i_object_id
                  , i_lang               => get_def_lang
                  , i_amount             => l_payment_amount
                  , i_currency           => l_payment_currency
                );

                trc_log_pkg.debug(
                    i_text          => 'Count of labels [#1], count of descriptions [#2] for order [#3]'
                  , i_env_param1    => l_label.count
                  , i_env_param2    => l_description.count
                  , i_env_param3    => l_order_id
                );

                for i in 1..nvl(l_label.count, 0) loop
                    com_api_i18n_pkg.add_text(
                        i_table_name   => 'pmo_order'
                      , i_column_name  => 'label'
                      , i_object_id    => l_order_id
                      , i_text         => l_label(i).value
                      , i_lang         => l_label(i).lang
                    );
                end loop;

                for i in 1..nvl(l_description.count, 0) loop
                    com_api_i18n_pkg.add_text(
                        i_table_name   => 'pmo_order'
                      , i_column_name  => 'description'
                      , i_object_id    => l_order_id
                      , i_text         => l_description(i).value
                      , i_lang         => l_description(i).lang
                    );
                end loop;

                app_api_application_pkg.get_element_value(
                    i_element_name   => 'EVENT_TYPE'
                  , i_parent_id      => i_appl_data_id
                  , o_element_value  => l_event_type
                );

                if l_payment_amount_algo is not null and nvl(l_event_type.count, 0) > 0 then
                    for i in 1..nvl(l_event_type.count,0) loop
                        pmo_api_order_pkg.add_schedule(
                            o_id                  => l_schedule_id
                          , o_seqnum              => l_seqnum
                          , i_order_id            => l_order_id
                          , i_event_type          => l_event_type(i)
                          , i_amount_algorithm    => l_payment_amount_algo
                          , i_entity_type         => i_entity_type
                          , i_object_id           => i_object_id
                          , i_attempt_limit       => l_attempt_count
                          , i_cycle_id            => null
                        );
                    end loop;
                end if;

                app_api_application_pkg.get_appl_data_id (
                    i_element_name   => 'PAYMENT_PARAMETER'
                  , i_parent_id      => i_appl_data_id
                  , o_appl_data_id   => l_parameter_id
                );

                for i in 1..nvl(l_parameter_id.count,0) loop
                    process_parameter(
                        i_parameter_id       => l_parameter_id(i)
                      , i_order_id           => l_order_id
                      , i_payment_purpose_id => l_payment_purpose_id
                    );
                end loop;

                app_api_service_pkg.process_entity_service(
                    i_appl_data_id  => i_appl_data_id
                  , i_element_name  => 'PAYMENT_ORDER'
                  , i_entity_type   => pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
                  , i_object_id     => l_order_id
                  , i_contract_id   => i_contract_id
                  , io_params       => app_api_application_pkg.g_params
                );

            elsif l_command in (app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED,
                             app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE,
                             app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE) then
                com_api_error_pkg.raise_error (
                    i_error         => 'PAYMENT_ORDER_NOT_FOUND'
                  , i_env_param1    => l_payment_order_number
                );
            else
                null;
            end if;

        end if;

    else
        if l_command in (app_api_const_pkg.COMMAND_CREATE_OR_UPDATE,
                         app_api_const_pkg.COMMAND_CREATE_OR_PROCEED,
                         app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT) then

            app_api_application_pkg.get_element_value(
                i_element_name   => 'PAYMENT_DATE'
              , i_parent_id      => i_appl_data_id
              , o_element_value  => l_payment_date
            );

            begin
                select split_hash
                  into l_split_hash
                  from prd_customer
                 where id = i_customer_id;
            exception
                when no_data_found then
                    l_split_hash := null;
            end;

            pmo_api_order_pkg.add_order(
                o_id                    => l_order_id
              , i_customer_id           => i_customer_id
              , i_entity_type           => i_entity_type
              , i_object_id             => i_object_id
              , i_purpose_id            => l_payment_purpose_id
              , i_template_id           => null
              , i_amount                => l_payment_amount
              , i_currency              => l_payment_currency
              , i_event_date            => nvl(l_payment_date, get_sysdate)
              , i_status                => pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC
              , i_inst_id               => i_inst_id
              , i_attempt_count         => null
              , i_is_prepared_order     => com_api_type_pkg.FALSE
              , i_is_template           => com_api_type_pkg.FALSE
              , i_split_hash            => l_split_hash
              , i_payment_order_number  => l_payment_order_number
            );

            trc_log_pkg.debug (
                i_text => 'Order [' || l_order_id || '] was created'
            );

            app_api_application_pkg.get_appl_data_id(
                i_element_name   => 'PAYMENT_PARAMETER'
              , i_parent_id      => i_appl_data_id
              , o_appl_data_id   => l_parameter_id
            );

            for i in 1..nvl(l_parameter_id.count,0) loop
                process_parameter(
                    i_parameter_id       => l_parameter_id(i)
                  , i_order_id           => l_order_id
                  , i_payment_purpose_id => l_payment_purpose_id
                );
            end loop;

        else
            com_api_error_pkg.raise_error (
                i_error         => 'INVALID_COMMAND'
              , i_env_param1    => l_command
              , i_env_param2    => 'PAYMENT_ORDER'
              , i_env_param3    => 'ACCOUNT'
              , i_env_param4    => app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
            );
        end if;
    end if;

    trc_log_pkg.debug (
        i_text => 'app_api_payment_order_pkg.process_order - ok'
    );
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error (
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'PAYMENT_ORDER'
        );
end;

procedure process_branch(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
    , i_inst_id            in            com_api_type_pkg.t_inst_id
    , i_agent_id           in            com_api_type_pkg.t_short_id
    , i_account_id         in            com_api_type_pkg.t_long_id
    , i_customer_id        in            com_api_type_pkg.t_medium_id
    , i_contract_id        in            com_api_type_pkg.t_medium_id
) is
    l_id_tab               com_api_type_pkg.t_number_tab;
begin
    trc_log_pkg.debug (
        i_text => 'app_api_payment_order_pkg.process_branch'
    );
    trc_log_pkg.debug (
        i_text => 'app_api_payment_order_pkg.process_branch - ok'
    );
end;

end;
/
