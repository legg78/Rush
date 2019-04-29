create or replace package body iap_api_card_pkg as
/*************************************************************
*  Application - cards <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 04.03.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: IAP_API_CARD_PKG <br />
*  @headcom
**************************************************************/

g_card_count               com_api_type_pkg.t_short_id := 1;
g_batch_card_count         com_api_type_pkg.t_short_id := null;
g_inst_id                  com_api_type_pkg.t_inst_id;
g_is_customer_agent        com_api_type_pkg.t_boolean  := com_api_type_pkg.FALSE;
g_app_merch_serv_count_tab com_api_type_pkg.t_param_tab;

/*
 * It modifies record <io_card> if there is element <REISSUE_REASON> and some of these elements don't exist:
 *     reissue command, flag PIN request, flag PIN mailer request or flag embossing request.
 */
procedure process_reissue_reason(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , io_card                in out nocopy iss_api_type_pkg.t_card
) is
    LOG_PREFIX                  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_reissue_reason: ';
    l_reissue_command                    com_api_type_pkg.t_dict_value;
    l_pin_request                        com_api_type_pkg.t_dict_value;
    l_pin_mailer_request                 com_api_type_pkg.t_dict_value;
    l_embossing_request                  com_api_type_pkg.t_dict_value;
    l_reiss_start_date_rule              com_api_type_pkg.t_dict_value;
    l_reiss_expir_date_rule              com_api_type_pkg.t_dict_value;
    l_perso_priority                     com_api_type_pkg.t_dict_value;
    l_clone_optional_services            com_api_type_pkg.t_boolean;
begin
    -- If reissue command or some reissue flags aren't defined then try to define them by reissuing reason
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with the reissuing command and flags: ' ||
                        'reissue_command [#1], pin_request [#2], pin_mailer_request [#3], embossing_request [#4]'
      , i_env_param1 => io_card.reissue_command
      , i_env_param2 => io_card.pin_request
      , i_env_param3 => io_card.pin_mailer_request
      , i_env_param4 => io_card.embossing_request
    );

    app_api_application_pkg.get_element_value(
        i_element_name  => 'REISSUE_REASON'
      , i_parent_id     => i_appl_data_id
      , o_element_value => io_card.reissue_reason
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'reissuing reason [#1] has been found'
      , i_env_param1 => io_card.reissue_reason
    );

    if io_card.reissue_reason is not null then
        iss_api_reissue_reason_pkg.get_command_and_flags(
            i_reissue_reason            => io_card.reissue_reason
          , i_inst_id                   => i_inst_id
          , o_reissue_command           => l_reissue_command
          , o_pin_request               => l_pin_request
          , o_pin_mailer_request        => l_pin_mailer_request
          , o_embossing_request         => l_embossing_request
          , o_reiss_start_date_rule     => l_reiss_start_date_rule
          , o_reiss_expir_date_rule     => l_reiss_expir_date_rule
          , o_perso_priority            => l_perso_priority
          , o_clone_optional_services   => l_clone_optional_services
        );

        -- command and flags are defined by the reissuing reason do not overwrite explicitly specified ones
        io_card.reissue_command             := nvl(l_reissue_command, io_card.reissue_command);
        io_card.pin_request                 := nvl(l_pin_request, io_card.pin_request);
        io_card.pin_mailer_request          := nvl(l_pin_mailer_request, io_card.pin_mailer_request);
        io_card.embossing_request           := nvl(l_embossing_request, io_card.embossing_request);
        io_card.perso_priority              := nvl(l_perso_priority, io_card.perso_priority);
        io_card.expir_date_rule             := nvl(l_reiss_expir_date_rule, io_card.expir_date_rule);
        io_card.start_date_rule             := nvl(l_reiss_start_date_rule, io_card.start_date_rule);
        io_card.clone_optional_services     := nvl(l_clone_optional_services, io_card.clone_optional_services);

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'reissuing command and flags that are defined by the reissuing reason: '
                         || 'reissue_command [#1], pin_request [#2], pin_mailer_request [#3], embossing_request [#4]'
          , i_env_param1 => io_card.reissue_command
          , i_env_param2 => io_card.pin_request
          , i_env_param3 => io_card.pin_mailer_request
          , i_env_param4 => io_card.embossing_request
        );
    end if;
end process_reissue_reason;

procedure get_appl_data(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , o_card                    out nocopy iss_api_type_pkg.t_card
) is
    l_icc_card_id          com_api_type_pkg.t_medium_id;
    l_root_id              com_api_type_pkg.t_long_id;
    l_customer_data_id     com_api_type_pkg.t_long_id;
    l_company_data_id      com_api_type_pkg.t_long_id;
    l_appl_data_rec        app_api_type_pkg.t_appl_data_rec;
    l_card_uid             com_api_type_pkg.t_name; 
    l_card_number          com_api_type_pkg.t_card_number;
    l_cardholder_data_id   com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_appl_data START');

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CATEGORY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.category
    );
    o_card.category := nvl(o_card.category, iss_api_const_pkg.CARD_CATEGORY_UNDEFINED);

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.card_type_id
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_BLANK_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.blank_type_id
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_DELIVERY_CHANNEL'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.delivery_channel
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_DELIVERY_STATUS'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.delivery_status
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_COUNT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => g_card_count
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'BATCH_CARD_COUNT'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => g_batch_card_count
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'START_DATE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.start_date
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'START_DATE_RULE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.start_date_rule
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'EXPIRATION_DATE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.expir_date
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'EXPIRATION_DATE_RULE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.expir_date_rule
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'PERSO_PRIORITY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.perso_priority
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'PIN_REQUEST'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.pin_request
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'PIN_MAILER_REQUEST'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.pin_mailer_request
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'EMBOSSING_REQUEST'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.embossing_request
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'ICC_CARD_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_icc_card_id
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.card_number
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_card_uid --o_card.id
    );
    
    -- search card_id by card_uid
    if l_card_uid is not null then
        l_card_number := 
            iss_api_card_pkg.get_card_number (
                i_card_uid     => l_card_uid
                , o_card_id    => o_card.id
            );
    end if;

    -- check that uid match card_number
    if     l_card_uid is not null
       and o_card.card_number is not null
       and l_card_number != o_card.card_number then
       
            com_api_error_pkg.raise_error(
                i_error      => 'CARD_ID_AND_NUMBER_MISMATCH'
              , i_env_param1 => l_card_uid
              , i_env_param2 => o_card.card_number
            );
    end if;
    
    if o_card.card_number is null then
        o_card.card_number := l_card_number;
    end if;
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'DELIVERY_AGENT_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.delivery_agent_number
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_STATE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.state
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'SEQUENTIAL_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.sequential_number
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_STATUS'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.status
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'STATUS_REASON'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.status_reason
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_ISS_DATE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.iss_date
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'REISSUE_COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.reissue_command
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CLONE_OPTIONAL_SERVICES'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.clone_optional_services
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARDHOLDER_NAME'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_card.cardholder_name
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'EMBOSSED_LINE_ADDITIONAL'
      , i_parent_id     => i_appl_data_id
      , o_element_value => o_card.embossed_line_additional
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'SUPPLEMENTARY_INFO_1'
      , i_parent_id     => i_appl_data_id
      , o_element_value => o_card.supplementary_info_1
    );

    -- Trying to define reissuing command and flags by reissuing reason if it's necessary
    process_reissue_reason(
        i_appl_data_id      => i_appl_data_id
      , i_inst_id           => i_inst_id
      , io_card             => o_card
    );

    o_card.icc_instance_id := iss_api_card_instance_pkg.get_card_instance_id(
        i_card_id  => l_icc_card_id
    );
    o_card.inst_id := g_inst_id;
    o_card.agent_id := app_api_application_pkg.get_app_agent_id;

    rul_api_param_pkg.set_param(
        i_value    => o_card.category
      , i_name     => 'CARD_CATEGORY'
      , io_params  => app_api_application_pkg.g_params
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_root_id
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'CUSTOMER'
      , i_parent_id      => l_root_id
      , o_appl_data_id   => l_customer_data_id
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'COMPANY'
      , i_parent_id     => l_customer_data_id
      , o_appl_data_id  => l_company_data_id
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'EMBOSSED_NAME'
      , i_parent_id     => l_company_data_id
      , o_element_value => o_card.company_name
    );
    -- Get embossed surname, first name, middle name and title
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'CARDHOLDER'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_cardholder_data_id
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'EMBOSSED_SURNAME'
      , i_parent_id     => l_cardholder_data_id
      , o_element_value => o_card.embossed_surname
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'EMBOSSED_FIRST_NAME'
      , i_parent_id     => l_cardholder_data_id
      , o_element_value => o_card.embossed_first_name
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'EMBOSSED_SECOND_NAME'
      , i_parent_id     => l_cardholder_data_id
      , o_element_value => o_card.embossed_second_name
    );
    app_api_application_pkg.get_element_value(
        i_element_name  => 'EMBOSSED_TITLE'
      , i_parent_id     => l_cardholder_data_id
      , o_element_value => o_card.embossed_title
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARDHOLDER_PHOTO_FILE_NAME'
      , i_parent_id      => l_cardholder_data_id
      , o_element_value  => o_card.cardholder_photo_file_name
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARDHOLDER_SIGN_FILE_NAME'
      , i_parent_id      => l_cardholder_data_id
      , o_element_value  => o_card.cardholder_sign_file_name
    );
 
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_appl_data END');

exception
    when com_api_error_pkg.e_value_error or com_api_error_pkg.e_invalid_number then
        l_appl_data_rec := app_api_application_pkg.get_last_appl_data_rec(); -- receive data of last processed element
        app_api_error_pkg.raise_error(
            i_appl_data_id => i_appl_data_id
          , i_error        => 'INCORRECT_ELEMENT_VALUE'
          , i_env_param1   => l_appl_data_rec.element_value
          , i_env_param2   => l_appl_data_rec.element_name
          , i_env_param3   => l_appl_data_rec.data_type
          , i_env_param4   => l_appl_data_rec.parent_id
          , i_env_param5   => l_appl_data_rec.element_type
          , i_env_param6   => l_appl_data_rec.serial_number
          , i_element_name => l_appl_data_rec.element_name
        );
end get_appl_data;

function get_preceding_card_instance_id(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_medium_id
is
    LOG_PREFIX                  constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_preceding_card_instance_id: ';
    l_preceding_card_data_id             com_api_type_pkg.t_long_id;
    l_seq_number                         com_api_type_pkg.t_tiny_id;
    l_card_id                            com_api_type_pkg.t_long_id;
    l_card_number                        com_api_type_pkg.t_card_number;
    l_expir_date                         date;
    l_card_instance_id                   com_api_type_pkg.t_medium_id;
    l_card_uid                           com_api_type_pkg.t_name;
begin
    declare
        l_appl_data_rec    app_api_type_pkg.t_appl_data_rec;
    begin
        app_api_application_pkg.get_appl_data_id(
            i_element_name => 'PRECEDING_CARD'
          , i_parent_id    => i_appl_data_id
          , o_appl_data_id => l_preceding_card_data_id
        );

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'i_appl_data_id [#1], l_preceding_card_data_id [#2]'
          , i_env_param1 => i_appl_data_id
          , i_env_param2 => l_preceding_card_data_id
        );

        if l_preceding_card_data_id is not null then
            app_api_application_pkg.get_element_value(
                i_element_name  => 'CARD_ID'
              , i_parent_id     => l_preceding_card_data_id
              , o_element_value => l_card_uid--l_card_id
            );
            app_api_application_pkg.get_element_value(
                i_element_name  => 'SEQUENTIAL_NUMBER'
              , i_parent_id     => l_preceding_card_data_id
              , o_element_value => l_seq_number
            );
            app_api_application_pkg.get_element_value(
                i_element_name  => 'CARD_NUMBER'
              , i_parent_id     => l_preceding_card_data_id
              , o_element_value => l_card_number
            );
            app_api_application_pkg.get_element_value(
                i_element_name  => 'EXPIRATION_DATE'
              , i_parent_id     => l_preceding_card_data_id
              , o_element_value => l_expir_date
            );

            if l_card_uid is not null then            
                l_card_number := 
                    iss_api_card_pkg.get_card_number (
                        i_card_uid     => l_card_uid
                        , o_card_id    => l_card_id
                    );                
            end if;
            
            l_card_instance_id := iss_api_card_instance_pkg.get_card_instance_id(
                                      i_card_id     => l_card_id
                                    , i_card_number => l_card_number
                                    , i_seq_number  => l_seq_number
                                    , i_expir_date  => l_expir_date
                                  );
        end if;
    exception
        when com_api_error_pkg.e_value_error or com_api_error_pkg.e_invalid_number then
            l_appl_data_rec := app_api_application_pkg.get_last_appl_data_rec(); -- receive data of last processed element
            app_api_error_pkg.raise_error(
                i_appl_data_id => i_appl_data_id
              , i_error        => 'INCORRECT_ELEMENT_VALUE'
              , i_env_param1   => l_appl_data_rec.element_value
              , i_env_param2   => l_appl_data_rec.element_name
              , i_env_param3   => l_appl_data_rec.data_type
              , i_env_param4   => l_appl_data_rec.parent_id
              , i_env_param5   => l_appl_data_rec.element_type
              , i_env_param6   => l_appl_data_rec.serial_number
              , i_element_name => l_appl_data_rec.element_name
            );
        when others then
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'FAILED with l_card_id [' || l_card_id
                                           || '], l_card_number [#1], l_seq_number [' || l_seq_number
                                           || '], l_expir_date [#2], l_card_instance_id [' || l_card_instance_id || ']'
              , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => l_card_number)
              , i_env_param2 => l_expir_date
            );
            raise;
    end;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'END with l_card_id [' || l_card_id
                    || '], l_card_number [#1], l_seq_number [' || l_seq_number
                    || '], l_expir_date [#2], l_card_instance_id [' || l_card_instance_id || ']'
      , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => l_card_number)
      , i_env_param2 => l_expir_date
    );

    -- If some elements have been passed by using block <PRECEDING_CARD>
    -- but appropriate card's instance hasn't been located then an error should be raised
    if l_card_instance_id is null
        and (l_card_id is not null
          or l_card_number is not null
          or l_seq_number is not null
          or l_expir_date is not null
        )
    then
        app_api_error_pkg.raise_error(
            i_error         => 'INCONSISTENT_DATA_IN_BLOCK_PRECEDING_CARD'
          , i_env_param1    => l_card_id
          , i_env_param2    => iss_api_card_pkg.get_card_mask(i_card_number => l_card_number)
          , i_env_param3    => l_seq_number
          , i_env_param4    => l_expir_date
          , i_appl_data_id  => l_preceding_card_data_id
          , i_element_name  => 'PRECEDING_CARD'
        );
    end if;

    return l_card_instance_id;
end get_preceding_card_instance_id;

procedure attach_card_to_application (
    i_card_id              in            com_api_type_pkg.t_long_id
) is
    l_count                com_api_type_pkg.t_count := 0;
begin
    if i_card_id is null then
        return;
    end if;

    select count(appl_id)
      into l_count
      from app_object
     where object_id = i_card_id
       and appl_id = app_api_application_pkg.get_appl_id
       and entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD;

    trc_log_pkg.debug (
        i_text        => 'Attach card to application: cards count [#1], card_id [#2], application_id [#3]'
      , i_env_param1  => l_count
      , i_env_param2  => i_card_id
      , i_env_param3  => app_api_application_pkg.get_appl_id
    );

    if l_count = 0 then
        app_api_appl_object_pkg.add_object(
            i_appl_id     => app_api_application_pkg.get_appl_id
          , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id   => i_card_id
          , i_seqnum      => 1
        );
    end if;
end attach_card_to_application;

procedure process_product(
    i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_card_id              in            com_api_type_pkg.t_long_id
) is
    l_service_value_tab    com_api_type_pkg.t_number_tab;
    l_service_id_tab       com_api_type_pkg.t_number_tab;
    l_object_value_tab     com_api_type_pkg.t_number_tab;
    l_object_id_tab        com_api_type_pkg.t_number_tab;
    l_customer_data_id     com_api_type_pkg.t_long_id;
begin
    l_customer_data_id := app_api_application_pkg.get_customer_appl_data_id;

    app_api_application_pkg.get_appl_id_value(
        i_element_name   => 'SERVICE'
      , i_parent_id      => l_customer_data_id
      , o_element_value  => l_service_value_tab
      , o_appl_data_id   => l_service_id_tab
    );

    for i in 1 .. nvl(l_service_id_tab.last, 0) loop
        app_api_application_pkg.get_appl_id_value(
            i_element_name   => 'SERVICE_OBJECT'
          , i_parent_id      => l_service_id_tab(i)
          , o_element_value  => l_object_value_tab
          , o_appl_data_id   => l_object_id_tab
        );
        for j in 1 .. nvl(l_object_id_tab.last, 0) loop
            if l_object_value_tab(j) = i_appl_data_id then
                trc_log_pkg.debug('Service_block_id = ' || l_object_value_tab(j) || ', service_id = ' || l_service_value_tab(i));

                app_api_product_pkg.process_product(
                    i_service_id   =>  l_service_value_tab(i)
                  , i_object_id    =>  i_card_id
                  , i_entity_type  =>  iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_inst_id      =>  i_inst_id
                );
            end if;
        end loop;
    end loop;
end process_product;

procedure change_objects(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_card_id              in            com_api_type_pkg.t_short_id
  , i_contract_id          in            com_api_type_pkg.t_long_id
) is
--    l_card_new             iss_api_type_pkg.t_card;
    l_id_tab               com_api_type_pkg.t_number_tab;
    l_check_cnt            com_api_type_pkg.t_count := 0;
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.change_objects: i_appl_data_id [' || i_appl_data_id
                                          || ', i_card_id [' || i_card_id || ']');

    -- Obviously it's the meaningless call because l_card_new never uses in the procedure,
    -- and <get_appl_data> procedure doesn't modify any data
--    get_appl_data(
--        i_appl_data         => io_appl_data
--      , i_appl_data_id      => i_appl_data_id
--      , o_card              => l_card_new
--    );

    -- process secure word
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'SEC_WORD'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_id_tab
    );

    if l_id_tab.count > 0 then
        for i in 1..l_id_tab.count loop
            app_api_sec_question_pkg.process_sec_question(
                i_appl_data_id    => l_id_tab(i)
              , i_object_id       => i_card_id
              , i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD
            );
        end loop;
    end if;

    -- Process ntf_custom_objects
    if iap_cardholder_pkg.g_custom_event_tab.first is not null then
        for l_index in iap_cardholder_pkg.g_custom_event_tab.first..iap_cardholder_pkg.g_custom_event_tab.last loop
            if iap_cardholder_pkg.g_custom_event_tab.exists(l_index) then
                trc_log_pkg.debug(
                    i_text => 'g_custom_event_tab(l_index): custom_event_id ['
                           || iap_cardholder_pkg.g_custom_event_tab(l_index).custom_event_id
                           || '], is_active ['
                           || iap_cardholder_pkg.g_custom_event_tab(l_index).is_active || ']'
                );
                ntf_api_custom_pkg.set_custom_object(
                    i_custom_event_id  => iap_cardholder_pkg.g_custom_event_tab(l_index).custom_event_id
                  , i_object_id        => i_card_id
                  , i_entity_type      => iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_is_active        => iap_cardholder_pkg.g_custom_event_tab(l_index).is_active
                );
            end if;
        end loop;
    end if;

    trc_log_pkg.debug('g_is_customer_agent [' || g_is_customer_agent || ']');

    -- Check is card closed
    select count(id)
      into l_check_cnt
      from iss_card_instance
     where card_id = i_card_id
       and state   = iss_api_const_pkg.CARD_STATE_CLOSED
       and rownum  = 1;
    
    -- Process services for ENTTCARD
    if    (g_is_customer_agent = com_api_const_pkg.FALSE
        or get_app_merchant_service_count(app_api_application_pkg.get_appl_id) > 0)
       and l_check_cnt = 0
    then
        app_api_service_pkg.process_entity_service(
            i_appl_data_id => i_appl_data_id
          , i_element_name => 'CARD'
          , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id    => i_card_id
          , i_contract_id  => i_contract_id
          , io_params      => app_api_application_pkg.g_params
        );
    end if;

    app_api_flexible_field_pkg.process_flexible_fields(
        i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
      , i_object_type   => null
      , i_object_id     => i_card_id
      , i_inst_id       => g_inst_id
      , i_appl_data_id  => i_appl_data_id
    );

    -- Update document link
    app_api_report_pkg.process_report(
        i_appl_data_id  => i_appl_data_id
      , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
      , i_object_id     => i_card_id
    );
end change_objects;

function get_app_merchant_service_count(
    i_appl_id         in            com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_short_id
is
begin
    if not g_app_merch_serv_count_tab.exists(i_appl_id) then
        select count(1)
          into g_app_merch_serv_count_tab(i_appl_id)
          from app_ui_data_vw d
             , prd_service st
         where d.appl_id          = i_appl_id
           and d.name             = 'SERVICE'
           and st.id              = com_api_type_pkg.convert_to_number(d.element_value)
           and st.service_type_id = iss_api_const_pkg.SERVICE_TYPE_MERCH_CARD_MAINT;
    end if;

    return to_number(g_app_merch_serv_count_tab(i_appl_id));

end get_app_merchant_service_count;

procedure create_card(
    i_appl_data_id          in            com_api_type_pkg.t_long_id
  , i_inst_id               in            com_api_type_pkg.t_inst_id
  , i_cardholder_id         in            com_api_type_pkg.t_medium_id
  , i_customer_id           in            com_api_type_pkg.t_medium_id
  , i_contract_id           in            com_api_type_pkg.t_long_id
  , i_product_id            in            com_api_type_pkg.t_short_id
  , i_preceding_instance_id in            com_api_type_pkg.t_medium_id -- this parameter is used to maintenance cards' history
  , o_card_id_tab              out nocopy com_api_type_pkg.t_medium_tab
  , o_agent_id                 out        com_api_type_pkg.t_agent_id
  , o_card_type_id             out        com_api_type_pkg.t_tiny_id
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_card: ';
    l_card                 iss_api_type_pkg.t_card;
    l_card_instance_id     com_api_type_pkg.t_medium_id;
    l_card_block_id        com_api_type_pkg.t_long_id;
    l_skipped_elements     com_api_type_pkg.t_param_tab;
    l_card_block_rec       app_api_type_pkg.t_appl_data_rec;
    l_appl_id              com_api_type_pkg.t_long_id;
    l_account_tab          com_api_type_pkg.t_desc_tab;
    l_account_list         com_api_type_pkg.t_short_desc;
    l_batch_id             com_api_type_pkg.t_short_id;
    l_seqnum               com_api_type_pkg.t_seqnum;
    l_warning_msg          com_api_type_pkg.t_text;
    l_card_uid             com_api_type_pkg.t_name; 
    l_pin_block            com_api_type_pkg.t_pin_block;
    l_postponed_event_tab  evt_api_type_pkg.t_postponed_event_tab;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_appl_data_id [' || i_appl_data_id || '], i_product_id [' || i_product_id || ']');

    get_appl_data(
        i_appl_data_id   => i_appl_data_id
      , i_inst_id        => i_inst_id
      , o_card           => l_card
    );

    l_appl_id := app_api_application_pkg.get_appl_id;

    select d.element_value
      bulk collect into l_account_tab
      from app_element e
         , app_data    d
         , acc_account a
     where e.name           = 'ACCOUNT_NUMBER'
       and d.appl_id        = l_appl_id
       and d.element_id+0   = e.id
       and a.account_number = d.element_value
       and a.status         = acc_api_const_pkg.ACCOUNT_STATUS_CLOSED
       and a.inst_id        = i_inst_id;

    if l_account_tab.count > 0 then
        -- It is instead of function "listagg" for decrease CPU load.
        for i in 1 .. l_account_tab.count loop
            if l_account_list is not null then
                l_account_list := l_account_list || ',';
            end if;
            l_account_list := l_account_list || l_account_tab(i);
        end loop;  

        com_api_error_pkg.raise_error(
            i_error         => 'ACCOUNT_ALREADY_CLOSED'
          , i_env_param1    => l_account_list
        );    
    end if;

    o_card_type_id       := l_card.card_type_id;
    trc_log_pkg.debug('o_card_type_id [' || o_card_type_id ||']');

    l_card.cardholder_id := i_cardholder_id;
    l_card.customer_id   := i_customer_id;
    l_card.contract_id   := i_contract_id;

    l_card.cardholder_name :=
        nvl(
            iss_api_cardholder_pkg.get_cardholder_name(
                i_id => i_cardholder_id
            )
          , l_card.cardholder_name
        );

    begin
        if g_is_customer_agent = com_api_const_pkg.TRUE then
            trc_log_pkg.debug('g_is_customer_agent = TRUE, searching service by product and card type');

            select p.service_id
              into l_card.service_id
              from iss_product_card_type p
             where p.product_id     = i_product_id
               and p.card_type_id   = l_card.card_type_id
               and rownum           = 1;

            l_card.expir_date := null;

        else
            trc_log_pkg.debug('g_is_customer_agent = FALSE, searching service by SERVICE_OBJECT');

            select service_id
              into l_card.service_id
              from (
                    select e.service_id
                      from app_ui_data_vw a
                         , app_ui_data_vw b
                         , app_data c
                         , iss_product_card_type e
                     where a.appl_id       = l_appl_id
                       and a.id            = i_appl_data_id
                       and a.name          = 'CARD'
                       and b.appl_id       = a.appl_id
                       and b.element_value = to_char(a.id, com_api_const_pkg.NUMBER_FORMAT)
                       and b.name          = 'SERVICE_OBJECT'
                       and c.id            = b.parent_id
                       and e.product_id    = i_product_id
                       and e.card_type_id  = l_card.card_type_id
                       and to_char(e.service_id, com_api_const_pkg.NUMBER_FORMAT) = c.element_value
                     order by e.seq_number_low
              )
             where rownum = 1;
        end if;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'UNDEFINED_CARD_TYPE_FOR_PRODUCT'
              , i_env_param1 => i_product_id
              , i_env_param2 => l_card.card_type_id
            );
    end;
    trc_log_pkg.debug('Service found: l_card.service_id [' || l_card.service_id || ']');

    if l_card.delivery_agent_number is not null then
        begin
            select id
              into l_card.agent_id
              from ost_agent
             where agent_number = l_card.delivery_agent_number
               and inst_id      = l_card.inst_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'AGENT_NOT_FOUND'
                    , i_env_param1  => l_card.delivery_agent_number
                );
        end;
    end if;

    o_agent_id := l_card.agent_id;

    -- Variable g_card_count > 1 when element CARD_COUNT is used in an application.
    -- In this case it is needed to issue required number of cards, but for every
    -- additional card we should add a new CARD block to an application's structure
    -- because PAN and ID of every generated card should be contained in an
    -- application's structure (for example, for unloading applications' responses).
    --
    -- Also if some services are linked with block CARD is being processed then
    -- all new cards will be linked with this service via PRD_SERVICE_OBJECT but
    -- additional elements SERVICE_OBJECT are NOT added to an appication's structure.
    for i in 1..nvl(g_card_count, 1) loop
        trc_log_pkg.debug('Start issuing cards, i=' || i || ' (of ' || nvl(g_card_count, 1) || ')');

        -- Clear card number on a new iteration
        if g_card_count > 1 then
            l_card.card_number := null;
        end if;

        iss_api_card_pkg.issue(
            o_id                         => o_card_id_tab(i)
          , io_card_number               => l_card.card_number
          , o_card_instance_id           => l_card_instance_id
          , i_inst_id                    => l_card.inst_id
          , i_agent_id                   => l_card.agent_id
          , i_contract_id                => l_card.contract_id
          , i_cardholder_id              => l_card.cardholder_id
          , i_card_type_id               => l_card.card_type_id
          , i_customer_id                => l_card.customer_id
          , i_category                   => l_card.category
          , i_cardholder_name            => l_card.cardholder_name
          , i_company_name               => l_card.company_name
          , i_perso_priority             => l_card.perso_priority
          , i_start_date                 => l_card.start_date
          , io_expir_date                => l_card.expir_date
          , i_service_id                 => l_card.service_id
          , i_icc_instance_id            => l_card.icc_instance_id
          , i_delivery_channel           => l_card.delivery_channel
          , i_blank_type_id              => l_card.blank_type_id
          , i_seq_number                 => l_card.sequential_number
          , i_status                     => l_card.status
          , i_state                      => l_card.state
          , i_iss_date                   => l_card.iss_date
          , i_preceding_instance_id      => i_preceding_instance_id
          , i_reissue_reason             => l_card.reissue_reason
          , i_reissue_date               => case when l_card.reissue_reason is not null
                                                 then com_api_sttl_day_pkg.get_sysdate()
                                                 else null
                                            end
          , i_pin_request                => l_card.pin_request
          , i_embossing_request          => l_card.embossing_request
          , i_delivery_status            => l_card.delivery_status
          , i_embossed_surname           => l_card.embossed_surname
          , i_embossed_first_name        => l_card.embossed_first_name
          , i_embossed_second_name       => l_card.embossed_second_name
          , i_embossed_title             => l_card.embossed_title
          , i_embossed_line_additional   => l_card.embossed_line_additional
          , i_supplementary_info_1       => l_card.supplementary_info_1
          , i_cardholder_photo_file_name => l_card.cardholder_photo_file_name
          , i_cardholder_sign_file_name  => l_card.cardholder_sign_file_name
          , i_pin_mailer_request         => l_card.pin_mailer_request
          , i_need_postponed_event       => com_api_const_pkg.TRUE
          , io_postponed_event_tab       => l_postponed_event_tab
        );

        l_card.id := o_card_id_tab(i);

        -- add card into batch
        trc_log_pkg.debug('g_card_count [' || g_card_count || '], g_batch_card_count [' || g_batch_card_count || ']');        
        if g_card_count > 1 and nvl(g_batch_card_count, 0) > 0 then

            if i = 1 or g_batch_card_count = 1 or mod(i, g_batch_card_count) = 1 then

                trc_log_pkg.debug('i [' || i || '], mod(i, g_batch_card_count) [' || mod(i, g_batch_card_count) || ']');        

                --add new batch
                prs_ui_batch_pkg.add_batch (
                    o_id                => l_batch_id
                    , o_seqnum          => l_seqnum
                    , i_inst_id         => l_card.inst_id
                    , i_agent_id        => l_card.agent_id
                    , i_product_id      => i_product_id
                    , i_card_type_id    => l_card.card_type_id
                    , i_blank_type_id   => l_card.blank_type_id
                    , i_card_count      => null
                    , i_hsm_device_id   => null
                    , i_status          => prs_api_const_pkg.BATCH_STATUS_INITIAL
                    , i_sort_id         => null
                    , i_perso_priority  => null
                    , i_lang            => com_api_const_pkg.DEFAULT_LANGUAGE
                    , i_batch_name      => to_char(systimestamp, com_api_const_pkg.TIMESTAMP_FORMAT)
                );

                trc_log_pkg.debug (
                    i_text          => 'Added personalization batch [#1], seq_num [#2]'
                    , i_env_param1  => l_batch_id
                    , i_env_param2  => l_seqnum
                );
            end if;

            -- add instance into batch
            prs_ui_batch_card_pkg.add_batch_card (
                i_batch_id              => l_batch_id
                , i_card_instance_id    => l_card_instance_id
                , o_warning_msg         => l_warning_msg
            );
            trc_log_pkg.debug('added instance [' || l_card_instance_id || '], into batch [' || l_batch_id || ']');        
        end if;

        --This code wasn't used because the check was passed only for flow #1009, but in this case there aren't services for processing
--        if g_is_customer_agent = com_api_const_pkg.TRUE then
--            trc_log_pkg.debug('Start process card product');
--            process_product(
--                i_inst_id      => l_card.inst_id
--              , i_appl_data_id => i_appl_data_id
--              , i_card_id      => l_card.id
--            );
--            trc_log_pkg.debug('End process card product');
--        end if;

        change_objects(
            i_appl_data_id  => i_appl_data_id
          , i_card_id       => l_card.id
          , i_contract_id   => i_contract_id
        );
        trc_log_pkg.info('Created new card with id [' || o_card_id_tab(i) || ']');

        -- Register event when the Card/CardInstance services is created
        evt_api_event_pkg.register_postponed_event(
            io_postponed_event_tab => l_postponed_event_tab
        );

        if i = 1 then
            l_card_block_id  := i_appl_data_id;
            l_card_block_rec := app_api_application_pkg.get_appl_data_rec(
                                    i_appl_data_id => i_appl_data_id
                                );
        else
            -- Create an associative array with elements that should be skipped
            -- during copying (cloning) an entire block with root i_appl_data_id
            l_skipped_elements('CARD_COUNT') := null;
            l_skipped_elements('COMMAND')    := null;
            -- Add a new block CARD to block CONTRACT
            app_api_application_pkg.clone_block(
                i_root_appl_id     => i_appl_data_id
              , i_dest_appl_id     => l_card_block_rec.parent_id
              , i_skipped_elements => l_skipped_elements
              , i_serial_number    => l_card_block_rec.serial_number + i - 1
              , o_new_appl_id      => l_card_block_id
            );
        end if;

        trc_log_pkg.info('appl_data_id of a new block <card> [' || l_card_block_id || ']');
        
        l_card_uid := iss_api_card_instance_pkg.get_card_uid (
            i_card_instance_id  => l_card_instance_id
        );
        
        app_api_application_pkg.merge_element(
            i_element_name      => 'CARD_ID'
          , i_parent_id         => l_card_block_id
          , i_element_value     => l_card_uid
        );
        
        app_api_application_pkg.merge_element(
            i_element_name      => 'CARD_NUMBER'
          , i_parent_id         => l_card_block_id
          , i_element_value     => l_card.card_number
        );
        
        app_api_application_pkg.merge_element(
            i_element_name      => 'EXPIRATION_DATE'
          , i_parent_id         => l_card_block_id
          , i_element_value     => l_card.expir_date
        );
        
        if nvl(g_card_count, 1) = 1 then
            app_api_application_pkg.get_element_value(
                i_element_name   => 'PIN_BLOCK'
              , i_parent_id      => l_card_block_id
              , o_element_value  => l_pin_block
            );
            
            if l_pin_block is not null then
                iss_api_card_instance_pkg.update_sensitive_data(
                    i_id                    => l_card_instance_id
                    , i_pvk_index           => null
                    , i_pvv                 => null
                    , i_pin_offset          => null
                    , i_pin_block           => l_pin_block
                    , i_pin_block_format    => null
                );
            end if;
        end if;

        attach_card_to_application (
            i_card_id  => l_card.id
        );
    end loop;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end create_card;

procedure change_card(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_contract_id          in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_cardholder_id        in            com_api_type_pkg.t_long_id
  , o_card_id                 out        com_api_type_pkg.t_medium_id
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_card: ';
    l_card_new                  iss_api_type_pkg.t_card;
    l_card_old                  iss_api_type_pkg.t_card;
    l_card_instance_id          com_api_type_pkg.t_medium_id;
    l_params                    com_api_type_pkg.t_param_tab;

    l_card_uid                  com_api_type_pkg.t_name;
    l_card_state                com_api_type_pkg.t_dict_value;
    l_pin_block                 com_api_type_pkg.t_pin_block;
    l_card_instance_id_tab      num_tab_tpt;
    l_card_number               com_api_type_pkg.t_card_number;
    l_card_hash                 com_api_type_pkg.t_long_id;
    l_inherit_pin_offset        com_api_type_pkg.t_boolean;
    l_postponed_event_tab       evt_api_type_pkg.t_postponed_event_tab;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START with i_inst_id [' || i_inst_id
                             || '], i_contract_id [' || i_contract_id
                             || '], i_cardholder_id [' || i_cardholder_id || ']'
    );
    -- get new card data
    get_appl_data(
        i_appl_data_id  => i_appl_data_id
      , i_inst_id       => i_inst_id
      , o_card          => l_card_new
    );

    -- retrieving cardholder's name
    l_card_new.cardholder_name :=
        get_translit(
            i_text => iss_api_cardholder_pkg.get_cardholder_name(i_id => i_cardholder_id)
        );

    l_card_number := iss_api_token_pkg.encode_card_number(i_card_number => l_card_new.card_number);
    l_card_hash   := com_api_hash_pkg.get_card_hash(l_card_new.card_number);

    -- get old card data
    begin
        select *
          into l_card_old.id
             , l_card_old.inst_id
             , l_card_old.agent_id
             , l_card_old.card_type_id
             , l_card_old.card_number
             , l_card_old.cardholder_id
             , l_card_old.cardholder_name
             , l_card_old.company_name
             , l_card_old.contract_id
             , l_card_old.start_date
             , l_card_old.expir_date
             , l_card_old.customer_id
             , l_card_old.category
             , l_card_old.perso_priority
             , l_card_old.pin_request
             , l_card_old.pin_mailer_request
             , l_card_old.embossing_request
             , l_card_old.blank_type_id
             , l_card_instance_id
             , l_card_state
             , l_card_new.sequential_number
             , l_card_old.delivery_status
             , l_card_old.embossed_surname
             , l_card_old.embossed_first_name
             , l_card_old.embossed_second_name
             , l_card_old.embossed_title
             , l_card_old.embossed_line_additional
             , l_card_old.supplementary_info_1
             , l_card_old.cardholder_photo_file_name
             , l_card_old.cardholder_sign_file_name
          from (
              select c.id
                   , i.inst_id
                   , i.agent_id
                   , c.card_type_id
                   , l_card_new.card_number as card_number
                   , c.cardholder_id
                   , i.cardholder_name
                   , i.company_name
                   , c.contract_id
                   , i.start_date
                   , i.expir_date
                   , c.customer_id
                   , c.category
                   , i.perso_priority
                   , i.pin_request
                   , i.pin_mailer_request
                   , i.embossing_request
                   , i.blank_type_id
                   , i.id as card_instance_id
                   , i.state
                   , i.seq_number
                   , i.delivery_status
                   , i.embossed_surname
                   , i.embossed_first_name
                   , i.embossed_second_name
                   , i.embossed_title
                   , i.embossed_line_additional
                   , i.supplementary_info_1
                   , i.cardholder_photo_file_name
                   , i.cardholder_sign_file_name
                from iss_card c
                   , iss_card_number cn
                   , net_card_type t
                   , iss_card_instance i
               where c.card_hash             = l_card_hash
                 and reverse(cn.card_number) = reverse(l_card_number)
                 and cn.card_id              = c.id
                 and c.card_type_id          = t.id
                 and i.card_id               = c.id
                 and (l_card_new.expir_date is null or trunc(i.expir_date, 'MON') = trunc(nvl(l_card_new.expir_date, i.expir_date), 'MON'))
                 and i.seq_number            = nvl(l_card_new.sequential_number, i.seq_number)
               order by i.seq_number desc
          )
         where rownum = 1;

    exception
        when no_data_found then
            app_api_error_pkg.raise_error(
                i_error         => 'CARD_NOT_FOUND'
              , i_env_param1    => iss_api_card_pkg.get_card_mask(i_card_number => l_card_old.card_number)
              , i_env_param2    => l_card_new.sequential_number
              , i_appl_data_id  => i_appl_data_id
              , i_element_name  => 'CARD_NUMBER'
            );
    end;

    trc_log_pkg.debug('Old card found, id [' || l_card_old.id || ']');

    if l_card_new.delivery_agent_number is not null then
        begin
            select id
              into l_card_new.agent_id
              from ost_agent
             where agent_number = l_card_new.delivery_agent_number
               and inst_id      = l_card_new.inst_id;

        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'AGENT_NOT_FOUND'
                  , i_env_param1  => l_card_new.delivery_agent_number
                );
        end;
    end if;

    cst_api_application_pkg.change_card_before(
        i_appl_data_id  => i_appl_data_id
      , i_contract_id   => i_contract_id
      , i_inst_id       => i_inst_id
      , i_cardholder_id => i_cardholder_id
      , io_card_old     => l_card_old
      , io_card_new     => l_card_new
    );

    if l_card_new.reissue_command is null and l_card_new.reissue_reason is null then
        if l_card_new.status is not null then
            evt_api_status_pkg.change_status(
                i_initiator      => evt_api_const_pkg.INITIATOR_CLIENT
              , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
              , i_object_id      => l_card_instance_id
              , i_new_status     => l_card_new.status
              , i_inst_id        => l_card_new.inst_id
              , i_reason         => l_card_new.status_reason
              , o_status         => l_card_new.status
              , i_eff_date       => null
              , i_raise_error    => com_api_const_pkg.TRUE
              , i_register_event => com_api_const_pkg.TRUE
              , i_params         => l_params
            );
        end if;

        if l_card_old.agent_id != l_card_new.agent_id then
            update iss_card_instance
               set agent_id = l_card_new.agent_id
             where id = l_card_instance_id;
        end if;

        if nvl (l_card_old.delivery_channel, '0') != nvl (l_card_new.delivery_channel, '0') then
            update iss_card_instance
               set delivery_channel = l_card_new.delivery_channel
             where id = l_card_instance_id;
        end if;

        if l_card_old.delivery_status != l_card_new.delivery_status then
            select id
              bulk collect
              into l_card_instance_id_tab
              from iss_card_instance
             where id = l_card_instance_id;

            iss_ui_card_instance_pkg.modify_delivery_status(
                i_card_instance_id_tab  => l_card_instance_id_tab
              , i_delivery_status       => l_card_new.delivery_status
              , i_event_date            => com_api_sttl_day_pkg.get_sysdate()
            );
        end if;

        o_card_id := l_card_old.id;
    else
        -- using new card number and expiration date for reissuing
        if l_card_new.reissue_command = iss_api_const_pkg.REISS_COMMAND_NEW_NUMBER then
            app_api_application_pkg.get_element_value(
                i_element_name   => 'REISSUE_CARD_NUMBER'
              , i_parent_id      => i_appl_data_id
              , o_element_value  => l_card_new.card_number
            );        
            if l_card_new.card_number = l_card_old.card_number then
                com_api_error_pkg.raise_error(
                    i_error       => 'REISSUE_SAME_CARD_NUMBER'
                  , i_env_param1  => iss_api_card_pkg.get_card_mask(i_card_number => l_card_new.card_number)
                );
            end if;
        elsif l_card_new.reissue_command = iss_api_const_pkg.REISS_COMMAND_RENEWAL
              and l_card_state = iss_api_const_pkg.CARD_STATE_CLOSED
         then
            com_api_error_pkg.raise_error(
                i_error       => 'IMPOSSIBLE_RENEWAL_FOR_CLOSED_CARD'
              , i_env_param1  => l_card_old.id
            );
        end if;

        app_api_application_pkg.get_element_value(
            i_element_name   => 'REISSUE_EXPIRATION_DATE'
          , i_parent_id      => i_appl_data_id
          , o_element_value  => l_card_new.expir_date
        );
        
        app_api_application_pkg.get_element_value(
            i_element_name   => 'REISSUE_CARD_ID'
          , i_parent_id      => i_appl_data_id
          , o_element_value  => l_card_uid
        );
        
        app_api_application_pkg.get_element_value(
            i_element_name   => 'INHERIT_PIN_OFFSET'
          , i_parent_id      => i_appl_data_id
          , o_element_value  => l_inherit_pin_offset
        );
        
        iss_api_card_pkg.reissue(
            i_card_number                => l_card_old.card_number
          , io_seq_number                => l_card_new.sequential_number
          , io_card_number               => l_card_new.card_number
          , i_command                    => l_card_new.reissue_command
          , i_agent_id                   => nvl(l_card_new.agent_id, l_card_old.agent_id)
          , i_contract_id                => i_contract_id
          , i_card_type_id               => nvl(l_card_new.card_type_id, l_card_old.card_type_id)
          , i_category                   => nvl(l_card_new.category, l_card_old.category)
          , i_start_date                 => l_card_new.start_date
          , i_start_date_rule            => l_card_new.start_date_rule
          , io_expir_date                => l_card_new.expir_date
          , i_expir_date_rule            => l_card_new.expir_date_rule
          , i_cardholder_name            => nvl(l_card_new.cardholder_name, l_card_old.cardholder_name)
          , i_company_name               => nvl(l_card_new.company_name, l_card_old.company_name)
          , i_perso_priority             => nvl(l_card_new.perso_priority, l_card_old.perso_priority)
          , i_pin_request                => l_card_new.pin_request
          , i_pin_mailer_request         => l_card_new.pin_mailer_request
          , i_embossing_request          => l_card_new.embossing_request
          , i_delivery_channel           => nvl(l_card_new.delivery_channel, l_card_old.delivery_channel)
          , i_blank_type_id              => l_card_new.blank_type_id
          , i_reissue_reason             => l_card_new.reissue_reason
          , i_reissue_date               => com_api_sttl_day_pkg.get_sysdate()
          , i_clone_optional_services    => l_card_new.clone_optional_services
          , i_delivery_status            => l_card_new.delivery_status
          , i_embossed_surname           => l_card_new.embossed_surname
          , i_embossed_first_name        => l_card_new.embossed_first_name
          , i_embossed_second_name       => l_card_new.embossed_second_name
          , i_embossed_title             => l_card_new.embossed_title
          , i_embossed_line_additional   => l_card_new.embossed_line_additional
          , i_supplementary_info_1       => l_card_new.supplementary_info_1
          , i_cardholder_photo_file_name => l_card_new.cardholder_photo_file_name
          , i_cardholder_sign_file_name  => l_card_new.cardholder_sign_file_name
          , i_card_uid                   => l_card_uid
          , i_inherit_pin_offset         => l_inherit_pin_offset
          , i_need_postponed_event       => com_api_const_pkg.TRUE
          , io_postponed_event_tab       => l_postponed_event_tab
        );

        -- after creating a new card instance it is necessary to change status of
        -- the preceding one by using i_reissue_reason to determine new status itself
        if l_card_instance_id is not null and l_card_new.reissue_reason is not null
           and l_card_new.reissue_command = iss_api_const_pkg.REISS_COMMAND_OLD_NUMBER then
                evt_api_status_pkg.change_status(
                    i_event_type     => l_card_new.reissue_reason
                  , i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
                  , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                  , i_object_id      => l_card_instance_id
                  , i_inst_id        => l_card_new.inst_id
                  , i_reason         => null
                  , i_params         => l_params
                );
        end if;
        
        app_api_application_pkg.merge_element(
            i_element_name      => 'REISSUE_CARD_NUMBER'
          , i_parent_id         => i_appl_data_id
          , i_element_value     => l_card_new.card_number
        );
        
        app_api_application_pkg.merge_element(
            i_element_name      => 'EXPIRATION_DATE'
          , i_parent_id         => i_appl_data_id
          , i_element_value     => l_card_old.expir_date
        );
        
        app_api_application_pkg.merge_element(
            i_element_name      => 'REISSUE_EXPIRATION_DATE'
          , i_parent_id         => i_appl_data_id
          , i_element_value     => l_card_new.expir_date
        );
        
        app_api_application_pkg.merge_element(
            i_element_name      => 'SEQUENTIAL_NUMBER'
          , i_parent_id         => i_appl_data_id
          , i_element_value     => l_card_new.sequential_number
        );
        
        app_api_application_pkg.merge_element(
            i_element_name      => 'CARD_DELIVERY_STATUS'
          , i_parent_id         => i_appl_data_id
          , i_element_value     => l_card_new.delivery_status
        );

        l_card_uid := iss_api_card_instance_pkg.get_card_uid (
            i_card_instance_id  => l_card_instance_id
        );
        
        app_api_application_pkg.merge_element(
            i_element_name      => 'CARD_ID'
          , i_parent_id         => i_appl_data_id
          , i_element_value     => l_card_uid
        );
        
        l_card_new.id := iss_api_card_pkg.get_card(
                             i_card_number => l_card_new.card_number
                           , i_mask_error  => com_api_type_pkg.FALSE
                         ).id;

        trc_log_pkg.info('Reissue card with id = ' || l_card_new.id);

        l_card_instance_id := iss_api_card_instance_pkg.get_card_instance_id(i_card_id => l_card_new.id);

        l_card_uid := iss_api_card_instance_pkg.get_card_uid (
            i_card_instance_id  => l_card_instance_id
        );
        
        app_api_application_pkg.merge_element(
            i_element_name      => 'REISSUE_CARD_ID'
          , i_parent_id         => i_appl_data_id
          , i_element_value     => l_card_uid
        );
        o_card_id := l_card_new.id;
        
        app_api_application_pkg.get_element_value(
            i_element_name   => 'PIN_BLOCK'
          , i_parent_id      => i_appl_data_id
          , o_element_value  => l_pin_block
        );
            
        if l_pin_block is not null then
            iss_api_card_instance_pkg.update_sensitive_data(
                i_id                    => l_card_instance_id
                , i_pvk_index           => null
                , i_pvv                 => null
                , i_pin_offset          => null
                , i_pin_block           => l_pin_block
                , i_pin_block_format    => null
            );
        end if;

    end if;

    change_objects(
        i_appl_data_id        => i_appl_data_id
      , i_card_id             => o_card_id
      , i_contract_id         => i_contract_id
    );

    -- Register event when the Card/CardInstance services is created
    evt_api_event_pkg.register_postponed_event(
        io_postponed_event_tab => l_postponed_event_tab
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end change_card;

procedure reconnect_card(
    i_card_id              in            com_api_type_pkg.t_long_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_contract_id          in            com_api_type_pkg.t_long_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_cardholder_id        in            com_api_type_pkg.t_long_id
  , i_is_pool_card         in            com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.reconnect_card: ';
    l_cardholder_data_id           com_api_type_pkg.t_long_id;
    l_cardholder_photo_file_name   iss_api_type_pkg.t_file_name;
    l_cardholder_sign_file_name    iss_api_type_pkg.t_file_name;
    
    l_params                       com_api_type_pkg.t_param_tab;
    l_instance                     iss_api_type_pkg.t_card_instance;
    l_preceding_instance_id        com_api_type_pkg.t_medium_id;
    l_card_status                  com_api_type_pkg.t_dict_value;
    l_account_status               com_api_type_pkg.t_dict_value;
    l_appl_id                      com_api_type_pkg.t_long_id;
    l_card_category                com_api_type_pkg.t_dict_value;
    l_status_reason                com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'START with i_card_id [#1], i_customer_id [#2], i_contract_id [#3], i_cardholder_id [#4]'
      , i_env_param1 => i_card_id
      , i_env_param2 => i_customer_id
      , i_env_param3 => i_contract_id
      , i_env_param4 => i_cardholder_id
    );
    l_appl_id := app_api_application_pkg.get_appl_id;
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_STATUS'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_card_status
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'STATUS_REASON'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_status_reason
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CATEGORY'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_card_category
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'CARDHOLDER'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_cardholder_data_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARDHOLDER_PHOTO_FILE_NAME'
      , i_parent_id      => l_cardholder_data_id
      , o_element_value  => l_cardholder_photo_file_name
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARDHOLDER_SIGN_FILE_NAME'
      , i_parent_id      => l_cardholder_data_id
      , o_element_value  => l_cardholder_sign_file_name
    );

    iss_api_card_pkg.reconnect_card(
        i_card_id                    => i_card_id
      , i_customer_id                => i_customer_id
      , i_contract_id                => i_contract_id
      , i_cardholder_id              => i_cardholder_id
      , i_cardholder_photo_file_name => l_cardholder_photo_file_name
      , i_cardholder_sign_file_name  => l_cardholder_sign_file_name
      , i_card_category              => l_card_category
    );

    change_objects(
        i_appl_data_id        => i_appl_data_id
      , i_card_id             => i_card_id
      , i_contract_id         => i_contract_id
    );
    
    l_instance :=
        iss_api_card_instance_pkg.get_instance(
            i_id          => iss_api_card_instance_pkg.get_card_instance_id(i_card_id  => i_card_id)
          , i_raise_error => com_api_const_pkg.TRUE
        );
    
    if i_is_pool_card = com_api_const_pkg.TRUE then
        l_card_status := nvl(l_card_status, iss_api_const_pkg.CARD_STATUS_VALID_CARD);

        evt_api_status_pkg.change_status(
            i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id      => l_instance.id
          , i_new_status     => l_card_status
          , i_reason         => l_status_reason
          , o_status         => l_card_status
          , i_eff_date       => null
          , i_raise_error    => com_api_const_pkg.TRUE
          , i_register_event => com_api_const_pkg.TRUE
          , i_params         => l_params
        );

        for r in (
            select ao.id
                 , ao.account_id
                 , a.account_number
                 , d.parent_id
                 , d.account_status
                 , d.account_number as app_account_number
              from acc_account_object ao
                 , acc_account a
                 , (
                       select parent_id
                            , max(decode(upper(e.name), 'ACCOUNT_NUMBER', d.element_value)) as account_number
                            , max(decode(upper(e.name), 'ACCOUNT_STATUS', d.element_value)) as account_status
                         from app_element e
                            , app_data    d
                        where upper(e.name)    in ('ACCOUNT_NUMBER', 'ACCOUNT_STATUS')
                          and d.appl_id        = l_appl_id
                          and d.element_id+0   = e.id
                        group by d.parent_id
                   ) d
             where ao.object_id     = i_card_id
               and ao.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD
               and ao.account_id    = a.id
               and a.account_number = d.account_number(+)
        )
        loop
            if r.app_account_number is not null then
                acc_api_account_pkg.reconnect_account(
                    i_account_id     => r.account_id
                  , i_customer_id    => i_customer_id
                  , i_contract_id    => i_contract_id
                );
                

                l_account_status := nvl(r.account_status, acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE);

                evt_api_status_pkg.change_status(
                    i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
                  , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id      => r.account_id
                  , i_new_status     => l_account_status
                  , i_reason         => null
                  , o_status         => l_account_status
                  , i_eff_date       => null
                  , i_raise_error    => com_api_const_pkg.TRUE
                  , i_register_event => com_api_const_pkg.TRUE
                  , i_params         => l_params
                );
            else
                trc_log_pkg.debug(
                    i_text       => 'Removing acc_account_object of account_id [#1]'
                  , i_env_param1 => r.account_id
                );
                
                acc_api_account_pkg.remove_account_object(i_account_object_id => r.id);
            end if;
        end loop;
        
        -- process services
        if g_is_customer_agent = com_api_const_pkg.TRUE then
            app_api_service_pkg.process_entity_service(
                i_appl_data_id => i_appl_data_id
              , i_element_name => 'CARD'
              , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id    => i_card_id
              , i_contract_id  => i_contract_id
              , io_params      => app_api_application_pkg.g_params
            );
        end if;
    end if;
    
    l_preceding_instance_id := get_preceding_card_instance_id(i_appl_data_id => i_appl_data_id);
    
    if l_preceding_instance_id is not null then
        iss_api_card_instance_pkg.set_preceding_instance_id(
            i_instance_id           => l_instance.id
          , i_preceding_instance_id => l_preceding_instance_id
        );
    end if;
    
    evt_api_event_pkg.register_event(
        i_event_type   => iss_api_const_pkg.EVENT_CARD_RECONNECTION
      , i_eff_date     => com_api_sttl_day_pkg.get_calc_date(l_instance.inst_id)
      , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
      , i_object_id    => i_card_id
      , i_inst_id      => l_instance.inst_id
      , i_split_hash   => l_instance.split_hash
      , i_param_tab    => l_params
    );
    
    trc_log_pkg.debug(i_text => LOG_PREFIX || 'END');
end reconnect_card;

/*
 * Create historical card instances according to data contained in blocks <CARD_INSTANCE>.
 */
procedure create_card_instances(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_agent_id             in            com_api_type_pkg.t_agent_id
  , i_product_id           in            com_api_type_pkg.t_short_id
  , i_card_type_id         in            com_api_type_pkg.t_tiny_id
  , i_card_id_tab          in            com_api_type_pkg.t_medium_tab
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_card_instances: ';
    l_id_tab               com_api_type_pkg.t_number_tab;
    l_card_instance        iss_api_type_pkg.t_card_instance;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_inst_id [#1], i_agent_id [#2], i_product_id [#3], i_card_type_id [#4]'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_agent_id
      , i_env_param3 => i_product_id
      , i_env_param4 => i_card_type_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'CARD_INSTANCE'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    -- Blocks <CARD_INSTANCE> cannot be used when a value passed through the element <CARD_COUNT> is greater than 1
    if nvl(l_id_tab.count, 0) > 0 and nvl(i_card_id_tab.count, 0) > 1 then
        app_api_error_pkg.raise_error(
            i_error         => 'INCONSISTENT_DATA_IN_BLOCK_CARD'
          , i_appl_data_id  => i_appl_data_id
          , i_env_param1    => i_card_id_tab.count
          , i_env_param2    => l_id_tab.count
        );
    end if;

    for i in 1..nvl(l_id_tab.count, 0) loop
        l_card_instance := null;
        declare
            l_appl_data_rec    app_api_type_pkg.t_appl_data_rec;
        begin
            app_api_application_pkg.get_element_value(
                i_element_name   => 'SEQUENTIAL_NUMBER'
              , i_parent_id      => l_id_tab(i)
              , o_element_value  => l_card_instance.seq_number
            );
            app_api_application_pkg.get_element_value(
                i_element_name   => 'CARD_STATUS'
              , i_parent_id      => l_id_tab(i)
              , o_element_value  => l_card_instance.status
            );
            app_api_application_pkg.get_element_value(
                i_element_name   => 'CARD_STATE'
              , i_parent_id      => l_id_tab(i)
              , o_element_value  => l_card_instance.state
            );
            app_api_application_pkg.get_element_value(
                i_element_name   => 'EXPIRATION_DATE'
              , i_parent_id      => l_id_tab(i)
              , o_element_value  => l_card_instance.expir_date
            );
            app_api_application_pkg.get_element_value(
                i_element_name   => 'CARD_ISS_DATE'
              , i_parent_id      => l_id_tab(i)
              , o_element_value  => l_card_instance.iss_date
            );
            app_api_application_pkg.get_element_value(
                i_element_name   => 'CARD_START_DATE'
              , i_parent_id      => l_id_tab(i)
              , o_element_value  => l_card_instance.start_date
            );
            app_api_application_pkg.get_element_value(
                i_element_name   => 'CARDHOLDER_NAME'
              , i_parent_id      => l_id_tab(i)
              , o_element_value  => l_card_instance.cardholder_name
            );
            app_api_application_pkg.get_element_value(
                i_element_name   => 'COMPANY_EMBOSSED_NAME'
              , i_parent_id      => l_id_tab(i)
              , o_element_value  => l_card_instance.company_name
            );
        exception
            when com_api_error_pkg.e_value_error or com_api_error_pkg.e_invalid_number then
                l_appl_data_rec := app_api_application_pkg.get_last_appl_data_rec(); -- receive data of last processed element
                app_api_error_pkg.raise_error(
                    i_appl_data_id => l_appl_data_rec.appl_data_id
                  , i_error        => 'INCORRECT_ELEMENT_VALUE'
                  , i_env_param1   => l_appl_data_rec.element_value
                  , i_env_param2   => l_appl_data_rec.element_name
                  , i_env_param3   => l_appl_data_rec.data_type
                  , i_env_param4   => l_appl_data_rec.parent_id
                  , i_env_param5   => l_appl_data_rec.element_type
                  , i_env_param6   => l_appl_data_rec.serial_number
                  , i_element_name => l_appl_data_rec.element_name
                );
        end;

        -- Filling some of the required fields with default values
        l_card_instance.reg_date :=           com_api_sttl_day_pkg.get_sysdate();
        l_card_instance.pin_request :=        iss_api_const_pkg.PIN_REQUEST_DONT_GENERATE;
        l_card_instance.pin_mailer_request := iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT;
        l_card_instance.embossing_request :=  iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS;
        l_card_instance.perso_priority :=     iss_api_const_pkg.PERSO_PRIORITY_NORMAL;
        l_card_instance.inst_id :=            i_inst_id;
        l_card_instance.agent_id :=           i_agent_id;
        l_card_instance.card_uid :=           i_card_id_tab(1); 

        begin
            select p.perso_method_id
                 , p.bin_id
                 , p.blank_type_id
              into l_card_instance.perso_method_id
                 , l_card_instance.bin_id
                 , l_card_instance.blank_type_id
              from iss_product_card_type p
             where p.product_id         = i_product_id
               and p.card_type_id       = i_card_type_id
               and rownum               = 1;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'UNDEFINED_CARD_TYPE_FOR_PRODUCT'
                  , i_env_param1 => i_product_id
                  , i_env_param2 => i_card_type_id
                );
        end;

        l_card_instance.card_id    := i_card_id_tab(1);
        iss_api_card_instance_pkg.add_card_instance(
            i_card_number    => null
          , io_card_instance => l_card_instance
        );
    end loop;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end create_card_instances;

procedure process_card(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_contract_id          in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_agent_id             in            com_api_type_pkg.t_agent_id
  , i_product_id           in            com_api_type_pkg.t_short_id
  , o_card_id                 out        com_api_type_pkg.t_medium_id
) is
    l_command              com_api_type_pkg.t_dict_value;
    l_card                 iss_api_type_pkg.t_card_rec;
    l_card_number          com_api_type_pkg.t_card_number;
    l_card_id              com_api_type_pkg.t_medium_id;
    l_card_instance_id     com_api_type_pkg.t_medium_id;
    l_cardholder_id        com_api_type_pkg.t_long_id;
    l_cardholder_data_id   com_api_type_pkg.t_long_id;
    l_expir_date           date;
    l_seq_number           com_api_type_pkg.t_tiny_id;
    l_is_instant_card      com_api_type_pkg.t_boolean;
    l_status               com_api_type_pkg.t_dict_value;
    l_params               com_api_type_pkg.t_param_tab;
    l_card_id_tab          com_api_type_pkg.t_medium_tab;
    l_agent_id             com_api_type_pkg.t_agent_id;
    l_card_type_id         com_api_type_pkg.t_tiny_id;
    l_contract_id          com_api_type_pkg.t_long_id;
    l_contract_type        com_api_type_pkg.t_dict_value;
    l_card_uid             com_api_type_pkg.t_name; 
    l_card_instance        iss_api_type_pkg.t_card_instance;
    l_is_pool_card         com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.process_card, i_appl_data_id [' || i_appl_data_id || ']');

    g_inst_id     := i_inst_id;
    l_contract_id := i_contract_id;

    cst_api_application_pkg.process_card_before(
        i_appl_data_id  => i_appl_data_id
      , i_customer_id   => i_customer_id
      , io_contract_id  => l_contract_id
      , i_inst_id       => i_inst_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_card_number
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_card_uid--l_card_id
    );

    trc_log_pkg.debug(
        i_text       => 'l_command [#1], l_card_number [#2], l_card_uid [#3]'
      , i_env_param1 => l_command
      , i_env_param2 => iss_api_card_pkg.get_card_mask(i_card_number => l_card_number)
      , i_env_param3 => l_card_uid--l_card_id
    );

    if l_card_number is null and l_card_uid is not null then
    
        l_card_number := 
            iss_api_card_pkg.get_card_number(
                i_card_uid    => l_card_uid
                , o_card_id   => l_card_id
            );
            
        trc_log_pkg.debug(
            i_text       => 'Card with card_number [#1] was found by identifier l_card_uid'
          , i_env_param1 => iss_api_card_pkg.get_card_mask(i_card_number => l_card_number)
        );
    end if;

    -- search for card
    if l_card_number is not null then
        l_card := iss_api_card_pkg.get_card(
                      i_card_number => l_card_number
                    , i_mask_error  => com_api_type_pkg.TRUE
                  );
        trc_log_pkg.debug(
            i_text       => 'Card with identifier [#1] was found by l_card_number'
          , i_env_param1 => l_card.id
        );

        -- check contract type
        l_is_instant_card := iss_api_card_pkg.is_instant_card(
                                 i_contract_id  =>  l_card.contract_id
                               , i_customer_id  =>  l_card.customer_id
                             );
        
        if l_is_instant_card = com_api_const_pkg.FALSE then
            l_card_instance := 
                iss_api_card_instance_pkg.get_instance(
                    i_id => iss_api_card_instance_pkg.get_card_instance_id(i_card_id  => l_card.id)
                );
            
            l_is_pool_card :=
                iss_api_card_pkg.is_pool_card(
                    i_customer_id => l_card.customer_id
                  , i_card_status => l_card_instance.status
                );
        end if;

    else
        -- check contract type
        trc_log_pkg.debug('Check contract_type from contract and from agent');

        begin
            select contract_type
              into l_contract_type
              from prd_contract
             where id = i_contract_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'CONTRACT_NOT_FOUND'
                  , i_env_param1 => i_contract_id
                );
        end;

        trc_log_pkg.debug('l_contract_type [' || l_contract_type || ']');

        g_is_customer_agent := iss_api_card_pkg.is_customer_agent(
                                   i_agent_id           => i_agent_id
                                 , i_appl_contract_type => l_contract_type
                               );

    end if;

    -- process cardholder
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'CARDHOLDER'
      , i_parent_id      => i_appl_data_id
      , o_appl_data_id   => l_cardholder_data_id
    );
    if l_cardholder_data_id is not null then
        iap_cardholder_pkg.process_cardholder(
            i_appl_data_id        => l_cardholder_data_id
          , i_parent_appl_data_id => i_appl_data_id
          , i_card_id             => case l_is_instant_card
                                         when com_api_const_pkg.TRUE
                                         then null
                                         else l_card.id
                                     end
          , i_customer_id         => i_customer_id
          , i_inst_id             => g_inst_id
          , i_is_pool_card        => l_is_pool_card
          , o_cardholder_id       => l_cardholder_id
        );
    end if;

    trc_log_pkg.debug('l_command [' || l_command || '], g_is_customer_agent [' || g_is_customer_agent || ']');

    -- card found
    if l_card.id > 0 then
        trc_log_pkg.debug('Card found: l_card.id [' || l_card.id || ']');

        if l_is_instant_card = com_api_const_pkg.FALSE
           and l_card.customer_id != i_customer_id
        then
            app_api_error_pkg.raise_error(
                i_error         => 'CARD_ALREADY_EXISTS'
              , i_env_param1    => iss_api_card_pkg.get_card_mask(i_card_number => l_card_number)
              , i_appl_data_id  => i_appl_data_id
              , i_element_name  => 'CARD_NUMBER'
            );
        end if;

        if l_command = app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
        or l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED then

            if l_is_instant_card = com_api_const_pkg.TRUE or l_is_pool_card = com_api_const_pkg.TRUE then
                reconnect_card(
                    i_card_id       => l_card.id
                  , i_customer_id   => i_customer_id
                  , i_contract_id   => l_contract_id
                  , i_appl_data_id  => i_appl_data_id
                  , i_cardholder_id => l_cardholder_id
                  , i_is_pool_card  => l_is_pool_card
                );
            else
                change_objects(
                    i_appl_data_id  => i_appl_data_id
                  , i_card_id       => l_card.id
                  , i_contract_id   => l_contract_id
                );
            end if;

        elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            app_api_error_pkg.raise_error(
                i_error         => 'CARD_ALREADY_EXISTS'
              , i_env_param1    => iss_api_card_pkg.get_card_mask(i_card_number => l_card_number)
              , i_appl_data_id  => i_appl_data_id
              , i_element_name  => 'CARD_NUMBER'
            );

        elsif l_command in (
                  app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
              )
        then
            if l_is_instant_card = com_api_const_pkg.TRUE or l_is_pool_card = com_api_const_pkg.TRUE then
                reconnect_card(
                    i_card_id       => l_card.id
                  , i_customer_id   => i_customer_id
                  , i_contract_id   => l_contract_id
                  , i_appl_data_id  => i_appl_data_id
                  , i_cardholder_id => l_cardholder_id
                  , i_is_pool_card  => l_is_pool_card
                );
            else
                change_card(
                    i_appl_data_id  => i_appl_data_id
                  , i_contract_id   => l_contract_id
                  , i_inst_id       => i_inst_id
                  , i_cardholder_id => l_cardholder_id
                  , o_card_id       => l_card.id
                );
            end if;

        elsif l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE then
            trc_log_pkg.debug (
                i_text        => 'app_api_service_pkg.close_service [#1], i_object_id [#2], i_inst_id [#3]'
              , i_env_param1  => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_env_param2  => l_card.id
              , i_env_param3  => g_inst_id
            );
            rul_api_param_pkg.set_param (
                i_value    => nvl(l_card.category, iss_api_const_pkg.CARD_CATEGORY_UNDEFINED)
              , i_name     => 'CARD_CATEGORY'
              , io_params  => app_api_application_pkg.g_params
            );

            app_api_service_pkg.close_service(
                i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id     => l_card.id
              , i_inst_id       => g_inst_id
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'REISSUE_EXPIRATION_DATE'
              , i_parent_id      => i_appl_data_id
              , o_element_value  => l_expir_date
            );
            app_api_application_pkg.get_element_value(
                i_element_name   => 'SEQUENTIAL_NUMBER'
              , i_parent_id      => i_appl_data_id
              , o_element_value  => l_seq_number
            );

            begin
                select
                    id
                into
                    l_card_instance_id
                from (
                    select
                        i.id
                    from
                        iss_card_instance i
                    where
                        i.card_id = l_card.id
                        and (l_expir_date is null or trunc(i.expir_date, 'MON') = trunc(nvl(l_expir_date, i.expir_date), 'MON'))
                        and i.seq_number = nvl(l_seq_number, i.seq_number)
                    order by
                        i.seq_number desc
                ) where
                    rownum = 1;
            exception
                when no_data_found then
                    app_api_error_pkg.raise_error(
                        i_error         => 'CARD_INSTANCE_NOT_FOUND'
                      , i_env_param1    => iss_api_card_pkg.get_card_mask(i_card_number => l_card_number)
                      , i_env_param2    => l_seq_number
                      , i_appl_data_id  => i_appl_data_id
                      , i_element_name  => 'CARD_NUMBER'
                    );
            end;

            --status
            evt_api_status_pkg.change_status(
                i_event_type     => iss_api_const_pkg.EVENT_TYPE_CARD_DEACTIVATION
              , i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
              , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
              , i_object_id      => l_card_instance_id
              , i_reason         => null
              , i_eff_date       => null
              , i_inst_id        => i_inst_id
              , i_params         => l_params
              , i_register_event => com_api_const_pkg.TRUE
            );
            --state
            trc_log_pkg.debug('New state ' || iss_api_const_pkg.CARD_STATE_CLOSED);
            evt_api_status_pkg.change_status(
                i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
              , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
              , i_object_id      => l_card_instance_id
              , i_inst_id        => i_inst_id
              , i_new_status     => iss_api_const_pkg.CARD_STATE_CLOSED
              , i_reason         => null
              , o_status         => l_status
              , i_eff_date       => null
              , i_raise_error    => com_api_const_pkg.FALSE
              , i_register_event => com_api_const_pkg.TRUE
              , i_params         => l_params
            );
            trc_log_pkg.debug('Return state ' || l_status);

            if l_status <> iss_api_const_pkg.CARD_STATE_CLOSED then
                trc_log_pkg.debug('Status card not changed: ' || l_status);
            end if;

        else
            if l_is_instant_card = com_api_const_pkg.TRUE or l_is_pool_card = com_api_const_pkg.TRUE then
                reconnect_card(
                    i_card_id       => l_card.id
                  , i_customer_id   => i_customer_id
                  , i_contract_id   => l_contract_id
                  , i_appl_data_id  => i_appl_data_id
                  , i_cardholder_id => l_cardholder_id
                  , i_is_pool_card  => l_is_pool_card
                );
            else
                change_card(
                    i_appl_data_id  => i_appl_data_id
                  , i_contract_id   => l_contract_id
                  , i_inst_id       => i_inst_id
                  , i_cardholder_id => l_cardholder_id
                  , o_card_id       => l_card.id
                );
            end if;
        end if;

        attach_card_to_application(
            i_card_id  => l_card.id
        );

        o_card_id := l_card.id;

    else -- card not found
        trc_log_pkg.debug('Card NOT found');

        -- getting id of the preceding card by processing block <preceding_card> to maintenance card's history
        l_card_instance_id := get_preceding_card_instance_id(
            i_appl_data_id      => i_appl_data_id
        );

        if l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
            null;

        elsif l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
            app_api_error_pkg.raise_error(
                i_error         => 'CARD_NOT_FOUND'
              , i_env_param1    => iss_api_card_pkg.get_card_mask(i_card_number => l_card_number)
              , i_appl_data_id  => i_appl_data_id
              , i_element_name  => 'CARD_NUMBER'
            );

        --elsif l_command in (
        --    app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
        --  , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
        --  , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
        --) then
        else
            create_card(
                i_appl_data_id          => i_appl_data_id
              , i_inst_id               => i_inst_id
              , i_cardholder_id         => l_cardholder_id
              , i_customer_id           => i_customer_id
              , i_contract_id           => l_contract_id
              , i_product_id            => i_product_id
              , i_preceding_instance_id => l_card_instance_id -- this parameter is used to maintenance cards' history
              , o_card_id_tab           => l_card_id_tab
              , o_agent_id              => l_agent_id         -- actual agent_id which has been used for issuing a card (or cards)
              , o_card_type_id          => l_card_type_id
            );

            -- if it isn't pool of cards (flow id 1009).
            if l_card_id_tab.count = 1 then
                o_card_id := l_card_id_tab(1);
            end if;
        end if;

        -- processing blocks <card_instance> (0..999)
        create_card_instances(
            i_appl_data_id      => i_appl_data_id
          , i_inst_id           => i_inst_id
          , i_agent_id          => l_agent_id
          , i_product_id        => i_product_id
          , i_card_type_id      => l_card_type_id
          , i_card_id_tab       => l_card_id_tab
        );
    end if;

    app_api_note_pkg.process_note(
        i_appl_data_id => i_appl_data_id
      , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
      , i_object_id    => o_card_id
    );

    cst_api_application_pkg.process_card_after(
        i_appl_data_id  => i_appl_data_id
      , i_customer_id   => i_customer_id
      , i_contract_id   => l_contract_id
      , i_inst_id       => i_inst_id
    );

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'CARD'
        );
end process_card;

end iap_api_card_pkg;
/
