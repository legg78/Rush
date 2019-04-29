create or replace package body aap_api_merchant_pkg as
/*********************************************************
 *  Acquiring applications merchants API  <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 10.11.2010 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: AAP_API_MERCHANT_PKG <br />
 *  @headcom
 **********************************************************/

procedure get_appl_data(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_data_id       in            com_api_type_pkg.t_long_id
  , o_merchant                out nocopy aap_api_type_pkg.t_merchant
) is
    l_appl_id              com_api_type_pkg.t_long_id;
    l_parent_number        com_api_type_pkg.t_name;
    l_appl_data_rec        app_api_type_pkg.t_appl_data_rec;
begin
    trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_appl_data START');

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MERCHANT_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_merchant.merchant_number
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MERCHANT_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_merchant.merchant_type
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MCC'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_merchant.mcc
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MERCHANT_NAME'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_merchant.merchant_name
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MERCHANT_STATUS'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_merchant.status
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'STATUS_REASON'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_merchant.status_reason
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MERCHANT_LABEL'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_merchant.merchant_label
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MERCHANT_DESC'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_merchant.merchant_desc
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'PARTNER_ID_CODE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_merchant.partner_id_code
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'RISK_INDICATOR'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_merchant.risk_indicator
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MC_ASSIGNED_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => o_merchant.mc_assigned_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_appl_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'INSTITUTION_ID'
      , i_parent_id      => l_appl_id
      , o_element_value  => o_merchant.inst_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MERCHANT_NUMBER'
      , i_parent_id      => i_parent_data_id
      , o_element_value  => l_parent_number
    );

    select min(id)
      into o_merchant.parent_id
      from acq_merchant
     where merchant_number = l_parent_number
       and inst_id         = o_merchant.inst_id;

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

procedure get_product_id(
    i_parent_id            in            com_api_type_pkg.t_short_id
  , o_product_id              out nocopy com_api_type_pkg.t_short_id
) is
    cursor cu_merchants is
    select product_id
    from (select c.product_id, m.id, m.parent_id
          from acq_merchant m, prd_contract c
          where m.contract_id = c.id) x
    where product_id is not null
    connect by prior id = parent_id
    start with id = i_parent_id;
begin
    open cu_merchants;
    fetch cu_merchants into o_product_id;
    close cu_merchants;
end;

function get_merchant_id return com_api_type_pkg.t_short_id
is
begin
    return acq_merchant_seq.nextval;
end;

procedure check_merchant(
    i_merchant_number      in            com_api_type_pkg.t_name
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
) is
    l_count                pls_integer;
begin
    trc_log_pkg.debug('aap_merchant_pkg.check_merchant: i_merchant_number='||i_merchant_number
                    ||', i_inst_id='||i_inst_id||', i_appl_data_id='||i_appl_data_id);
    select count(1)
      into l_count
      from acq_merchant
     where merchant_number = i_merchant_number
       and inst_id         = i_inst_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error             => 'MERCHANT_NUMBER_IS_NOT_UNIQUE'
          , i_env_param1        => i_merchant_number
          , i_env_param2        => i_inst_id
        );
    end if;
end check_merchant;

procedure check_merchant_tree(
    i_parent_id            in            com_api_type_pkg.t_short_id
  , i_merchant_type        in            com_api_type_pkg.t_dict_value
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
) is
    l_count                pls_integer;
    l_parent_merchant_type com_api_type_pkg.t_dict_value;
begin
    select min(merchant_type)
      into l_parent_merchant_type
      from acq_merchant
     where id = i_parent_id;

    trc_log_pkg.debug('aap_merchant_pkg.check_merchant_tree: i_parent_id='||i_parent_id
                    ||', l_merchant_type='||i_merchant_type
                    ||', l_parent_merchant_type='||l_parent_merchant_type
                    ||', i_inst_id='||i_inst_id);

    select count(1)
      into l_count
      from acq_merchant_type_tree
     where merchant_type = i_merchant_type
       and (parent_merchant_type = l_parent_merchant_type
            or
            parent_merchant_type is null and l_parent_merchant_type is null)
       and (
            inst_id = i_inst_id
            or
            inst_id = ost_api_const_pkg.DEFAULT_INST
           );

    if l_count = 0 then
        com_api_error_pkg.raise_error(
            i_error       => 'MERCHANT_TYPE_NOT_CORRESPOND_PARENT'
          , i_env_param1  => i_merchant_type
          , i_env_param2  => l_parent_merchant_type
        );
    end if;
end check_merchant_tree;

procedure check_mcc(
    i_mcc                  in            varchar2
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
) is
    l_count                pls_integer;
begin
    select 1
      into l_count
      from com_mcc
     where mcc = i_mcc;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error             => 'MCC_NOT_FOUND'
          , i_env_param1        => i_mcc
        );
end check_mcc;

procedure process_merchant_card(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_merchant_id          in            com_api_type_pkg.t_medium_id
) as
    l_card_number                        com_api_type_pkg.t_card_number;
    l_card                               iss_api_type_pkg.t_card_rec;
    l_contract                           prd_api_type_pkg.t_contract;
begin
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_card_number
    );
    
    l_card := 
        iss_api_card_pkg.get_card(
            i_card_number => l_card_number
          , i_mask_error  => com_api_const_pkg.FALSE
        );
    l_contract := prd_api_contract_pkg.get_contract(i_contract_id => l_card.contract_id);
    
    g_merchant_card_tab(g_merchant_card_tab.count + 1).card_id := l_card.id;
    g_merchant_card_tab(g_merchant_card_tab.count).card_number := l_card_number; 
    g_merchant_card_tab(g_merchant_card_tab.count).card_contract_type := l_contract.contract_type;
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_PRODUCT_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => g_merchant_card_tab(g_merchant_card_tab.count).card_product_id
    );
    g_merchant_card_tab(g_merchant_card_tab.count).card_product_id := 
        nvl(g_merchant_card_tab(g_merchant_card_tab.count).card_product_id
          , l_contract.product_id
        );
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CARD_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => g_merchant_card_tab(g_merchant_card_tab.count).card_type_id
    );
    
    ntf_api_custom_pkg.clone_custom_event(
        i_src_object_id    => i_merchant_id
      , i_src_entity_type  => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
      , i_dst_object_id    => l_card.cardholder_id
      , i_dst_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
      , i_linked_object_id => l_card.id
      , i_is_active        => com_api_const_pkg.TRUE
    );
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id      => i_appl_data_id
          , i_element_name      => 'MERCHANT_CARD'
        );
end;

procedure change_objects(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_merchant_id          in            com_api_type_pkg.t_long_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , i_address_is_mandatory in            com_api_type_pkg.t_boolean        default com_api_type_pkg.FALSE
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_objects: ';
    l_new                  aap_api_type_pkg.t_merchant;
    l_id_tab               com_api_type_pkg.t_number_tab;
    l_address_id           com_api_type_pkg.t_long_id;
    l_custom_event_id      com_api_type_pkg.t_medium_id;
    l_is_active            com_api_type_pkg.t_boolean;
    l_contract_rec         prd_api_type_pkg.t_contract;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_appl_data_id [' || i_appl_data_id
                                 || '], i_parent_appl_data_id [' || i_parent_appl_data_id
                                 || '], i_address_is_mandatory [' || i_address_is_mandatory || ']');
    g_merchant_card_tab.delete;

    get_appl_data(
        i_appl_data_id   => i_appl_data_id
      , i_parent_data_id => i_parent_appl_data_id
      , o_merchant       => l_new
    );

    app_api_flexible_field_pkg.process_flexible_fields(
        i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
      , i_object_type   => null
      , i_object_id     => i_merchant_id
      , i_inst_id       => i_inst_id
      , i_appl_data_id  => i_appl_data_id
    );

    -- Processing merchant contacts
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'CONTACT'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );
    trc_log_pkg.debug(LOG_PREFIX || 'CONTACT count [' || l_id_tab.count || ']');

    for i in 1..nvl(l_id_tab.count, 0) loop
        app_api_contact_pkg.process_contact(
            i_appl_data_id        => l_id_tab(i)
          , i_parent_appl_data_id => i_appl_data_id
          , i_object_id           => i_merchant_id
          , i_entity_type         => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
        );
    end loop;

    -- Processing merchant payment orders
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'PAYMENT_ORDER'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    if l_id_tab.count > 0 then
        l_contract_rec :=
            prd_api_contract_pkg.get_contract(
                i_contract_id   => i_contract_id
            );

        for i in 1 .. l_id_tab.count loop
            app_api_payment_order_pkg.process_order(
                i_appl_data_id => l_id_tab(i)
              , i_inst_id      => i_inst_id
              , i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
              , i_object_id    => i_merchant_id
              , i_agent_id     => l_contract_rec.agent_id
              , i_customer_id  => i_customer_id
              , i_contract_id  => i_contract_id
            );
        end loop;
    end if;

    -- Processing merchant address
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'ADDRESS'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    if i_address_is_mandatory = com_api_type_pkg.TRUE and l_id_tab.count = 0 then
        com_api_error_pkg.raise_error(
            i_error => 'ADDRESS_IS_MANDATORY_FOR_NEW_MERCHANT'
        );
    end if;

    for i in 1..nvl(l_id_tab.count, 0) loop
        app_api_address_pkg.process_address(
            i_appl_data_id         => l_id_tab(i)
          , i_parent_appl_data_id  => i_appl_data_id
          , i_object_id            => i_merchant_id
          , i_entity_type          => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
          , o_address_id           => l_address_id
        );
    end loop;

    app_api_service_pkg.process_entity_service(
        i_appl_data_id  => i_appl_data_id
      , i_element_name  => 'MERCHANT'
      , i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
      , i_object_id     => i_merchant_id
      , i_contract_id   => i_contract_id
      , io_params       => app_api_application_pkg.g_params
    );

    --  processing merchant terminals
    app_api_application_pkg.get_appl_data_id(
        i_element_name  =>  'TERMINAL'
      , i_parent_id     =>  i_appl_data_id
      , o_appl_data_id  =>  l_id_tab
    );

    for i in 1..l_id_tab.count loop
        aap_api_terminal_pkg.process_terminal(
            i_appl_data_id         => l_id_tab(i)
          , i_parent_appl_data_id  => i_appl_data_id
          , i_merchant_id          => i_merchant_id
          , i_inst_id              => l_new.inst_id
          , i_contract_id          => i_contract_id
          , i_customer_id          => i_customer_id
        );
    end loop;

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
          , i_entity_type          => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
          , i_object_id            => i_merchant_id
          , i_inst_id              => l_new.inst_id
          , i_customer_id          => i_customer_id
          , o_custom_event_id      => l_custom_event_id
          , o_is_active            => l_is_active
        );
    end loop;

    -- Processing merchant sub-merchants
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'MERCHANT'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    for i in 1..l_id_tab.count loop
        process_merchant(
            i_appl_data_id        => l_id_tab(i)
          , i_parent_appl_data_id => i_appl_data_id
          , i_contract_id         => i_contract_id
          , i_customer_id         => i_customer_id
        );
    end loop;
    
    -- Processing merchant sub-merchants
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'MERCHANT_CARD'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    for i in 1..l_id_tab.count loop
        process_merchant_card(
            i_appl_data_id => l_id_tab(i)
          , i_merchant_id  => i_merchant_id
        );
    end loop;

end change_objects;

procedure create_merchant(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
  , o_merchant_number         out        com_api_type_pkg.t_merchant_number
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_merchant: ';
    l_merchant             aap_api_type_pkg.t_merchant;
    l_merchant_number      com_api_type_pkg.t_name;
    l_split_hash           com_api_type_pkg.t_tiny_id;
    l_param_tab            com_api_type_pkg.t_param_tab;
    l_name_param_tab       com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_appl_data_id [' || i_appl_data_id || ']');

    get_appl_data(
        i_appl_data_id   =>  i_appl_data_id
      , i_parent_data_id =>  i_parent_appl_data_id
      , o_merchant       =>  l_merchant
    );

    if l_merchant.merchant_type is null then
        com_api_error_pkg.raise_error(
            i_error      => 'MERCHANT_TYPE_NOT_DEFINED'
        );
    end if;

    if l_merchant.mcc is null then
        com_api_error_pkg.raise_error(
            i_error      => 'MCC_NOT_DEFINED'
        );
    end if;

    check_merchant_tree(
        i_parent_id      => l_merchant.parent_id
      , i_merchant_type  => l_merchant.merchant_type
      , i_inst_id        => l_merchant.inst_id
      , i_appl_data_id   => i_appl_data_id
    );

    --if l_merchant.product_id is null then
    --    get_product_id(
    --        i_parent_id   => l_merchant.parent_id
    --      , o_product_id  => l_merchant.product_id
    --    );
    --    aap_api_product_pkg.get_appl_product_id(
    --        i_appl_data     =>  io_appl_data
    --      , io_product_id   =>  l_merchant.product_id
    --    );
    --end if;

    check_mcc(
        i_mcc               => l_merchant.mcc
      , i_appl_data_id      => i_appl_data_id
    );

    com_api_i18n_pkg.check_text_for_latin(
        i_text => l_merchant.merchant_name
    );

    --get_template(
    --    i_merchant_type     => l_merchant.merchant_type
    --  , i_mcc               => l_merchant.mcc
    --  , i_product_id        => l_merchant.product_id
    --  , o_merchant_template => l_merchant_template
    --);

    if l_merchant.id is null then
        l_merchant.id := get_merchant_id;
        trc_log_pkg.debug(LOG_PREFIX || 'new merchant_id [' || l_merchant.id || ']');
    end if;

    if l_merchant.merchant_number is null then
        -- Find rule name
        if rul_api_name_pkg.get_format_id(
               i_inst_id     => l_merchant.inst_id
             , i_entity_type => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
             , i_raise_error => com_api_type_pkg.FALSE
           ) is null
        then
            l_merchant.merchant_number := l_merchant.id;
        else
            l_name_param_tab('MERCHANT_ID') := l_merchant.id;
            l_name_param_tab('INST_ID')     := l_merchant.inst_id;

            l_merchant_number :=
                rul_api_name_pkg.get_name(
                    i_inst_id      => l_merchant.inst_id
                  , i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                  , i_param_tab    => l_name_param_tab
                );

            if length(l_merchant_number) > acq_api_const_pkg.MERCHANT_NUMBER_MAX_LENGTH then
                com_api_error_pkg.raise_error(
                    i_error      => 'MERCHANT_NUMBER_IS_TOO_LONG'
                  , i_env_param1 => l_merchant_number
                  , i_env_param2 => length(l_merchant_number)
                  , i_env_param3 => acq_api_const_pkg.MERCHANT_NUMBER_MAX_LENGTH
                );
            else
                l_merchant.merchant_number := l_merchant_number;
            end if;
        end if;

        check_merchant(
            i_merchant_number   => l_merchant.merchant_number
          , i_inst_id           => l_merchant.inst_id
          , i_appl_data_id      => i_appl_data_id
        );

        app_api_application_pkg.add_element(
            i_element_name      => 'MERCHANT_NUMBER'
          , i_parent_id         => i_appl_data_id
          , i_element_value     => l_merchant.merchant_number
        );

        trc_log_pkg.debug(LOG_PREFIX || 'new merchant_number [' || l_merchant.merchant_number || ']');
    end if;

    --  Processing merchant descriptions
    for i in 1..l_merchant.merchant_label.count loop
        trc_log_pkg.debug(LOG_PREFIX || 'label added, value [' || l_merchant.merchant_label(i).value
                                     || '], lang [' || l_merchant.merchant_label(i).lang || ']');
        com_api_i18n_pkg.add_text(
            i_table_name        => 'acq_merchant'
          , i_column_name       => 'label'
          , i_object_id         => l_merchant.id
          , i_text              => l_merchant.merchant_label(i).value
          , i_lang              => l_merchant.merchant_label(i).lang
        );
    end loop;

    for i in 1..l_merchant.merchant_desc.count loop
        com_api_i18n_pkg.add_text(
            i_table_name        => 'acq_merchant'
          , i_column_name       => 'description'
          , i_object_id         => l_merchant.id
          , i_text              => l_merchant.merchant_desc(i).value
          , i_lang              => l_merchant.merchant_desc(i).lang
        );
    end loop;

    --l_merchant.license_type     := nvl(l_merchant.license_type, l_merchant_template.license_type);
    --l_merchant.license_number   := nvl(l_merchant.license_number, l_merchant_template.license_number);
    l_merchant.status           := nvl(l_merchant.status, acq_api_const_pkg.MERCHANT_STATUS_ACTIVE);
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_merchant = {status [#1], merchant_type [#2], parent_id [#3], mcc [#4]}'
      , i_env_param1 => l_merchant.status
      , i_env_param2 => l_merchant.merchant_type
      , i_env_param3 => l_merchant.parent_id
      , i_env_param4 => l_merchant.mcc
    );

    if l_merchant.status = acq_api_const_pkg.MERCHANT_STATUS_CLOSED then
        com_api_error_pkg.raise_error(
            i_error      => 'INVALID_MERCHANT_STATUS'
          , i_env_param1 => l_merchant.status
        );
    end if;

    acq_api_merchant_pkg.add_merchant(
        o_merchant_id         => l_merchant.id
      , i_merchant_number     => l_merchant.merchant_number
      , i_merchant_type       => l_merchant.merchant_type
      , i_merchant_name       => l_merchant.merchant_name
      , i_parent_id           => l_merchant.parent_id
      , i_mcc                 => l_merchant.mcc
      , i_status              => acq_api_const_pkg.MERCHANT_STATUS_ACTIVE
      , i_contract_id         => i_contract_id
      , i_inst_id             => l_merchant.inst_id
      , i_description         => null
      , i_split_hash          => com_api_hash_pkg.get_split_hash(prd_api_const_pkg.ENTITY_TYPE_CONTRACT , i_contract_id)
      , i_partner_id_code     => l_merchant.partner_id_code
      , i_risk_indicator      => l_merchant.risk_indicator
      , i_mc_assigned_id      => l_merchant.mc_assigned_id
    );
    
    o_merchant_number := l_merchant.merchant_number;

    change_objects(
        i_appl_data_id         => i_appl_data_id
      , i_parent_appl_data_id  => i_parent_appl_data_id
      , i_merchant_id          => l_merchant.id
      , i_contract_id          => i_contract_id
      , i_inst_id              => l_merchant.inst_id
      , i_customer_id          => i_customer_id
      , i_address_is_mandatory => com_api_type_pkg.TRUE -- address with postal_code are mandatory for creating new merchant
    );

    l_split_hash := com_api_hash_pkg.get_split_hash(
        i_entity_type   =>  com_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id     =>  i_customer_id
    );
end create_merchant;

procedure change_merchant(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
) is
    l_new                  aap_api_type_pkg.t_merchant;
    l_old                  aap_api_type_pkg.t_merchant;
    l_old_contract_id      com_api_type_pkg.t_medium_id;
    l_split_hash           com_api_type_pkg.t_tiny_id;
    l_param_tab            com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug('aap_merchant_pkg.change_merchant: i_appl_data_id='||i_appl_data_id
                  ||', i_parent_appl_data_id='||i_parent_appl_data_id);

    get_appl_data(
        i_appl_data_id   => i_appl_data_id
      , i_parent_data_id => i_parent_appl_data_id
      , o_merchant       => l_new
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'MERCHANT_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_old.merchant_number
    );

    -- Getting old values for compare
    select m.id
         , m.merchant_name
         , m.merchant_type
         , m.parent_id
         , m.mcc
         , m.status
         , m.inst_id
         , m.contract_id
         , m.partner_id_code
         , m.risk_indicator
      into l_new.id
         , l_old.merchant_name
         , l_old.merchant_type
         , l_old.parent_id
         , l_old.mcc
         , l_old.status
         , l_old.inst_id
         , l_old_contract_id
         , l_old.partner_id_code
         , l_old.risk_indicator
      from acq_merchant m
     where m.merchant_number = l_old.merchant_number
       and m.inst_id         = l_new.inst_id;

    trc_log_pkg.debug('old merchant found, id = '||l_new.id);

    l_new.mcc := nvl(l_new.mcc, l_old.mcc);

    check_mcc(
        i_mcc           => l_new.mcc
      , i_appl_data_id  => i_appl_data_id
    );

    com_api_i18n_pkg.check_text_for_latin(
        i_text => l_new.merchant_name
    );

    l_new.status := nvl(l_new.status, acq_api_const_pkg.MERCHANT_STATUS_ACTIVE);

    -- Processing merchant descriptions
    for i in 1..l_new.merchant_label.count loop
        trc_log_pkg.debug('label added, value = ' || l_new.merchant_label(i).value
                                  || ', lang = ' || l_new.merchant_label(i).lang);
        com_api_i18n_pkg.add_text(
            i_table_name   => 'acq_merchant'
          , i_column_name  => 'label'
          , i_object_id    => l_new.id
          , i_text         => l_new.merchant_label(i).value
          , i_lang         => l_new.merchant_label(i).lang
        );
    end loop;

    for i in 1..l_new.merchant_desc.count loop
        trc_log_pkg.debug('desc added, value = ' || l_new.merchant_desc(i).value
                                 || ', lang = ' || l_new.merchant_desc(i).lang);
        com_api_i18n_pkg.add_text(
            i_table_name        => 'acq_merchant'
          , i_column_name       => 'description'
          , i_object_id         => l_new.id
          , i_text              => l_new.merchant_desc(i).value
          , i_lang              => l_new.merchant_desc(i).lang
        );
    end loop;

    if l_new.status is not null and (l_old.status is null or l_old.status != l_new.status) then
        evt_api_status_pkg.change_status(
            i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type    => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
          , i_object_id      => l_new.id
          , i_new_status     => l_new.status
          , i_eff_date       => com_api_sttl_day_pkg.get_sysdate()
          , i_reason         => l_new.status_reason
          , o_status         => l_new.status
          , i_raise_error    => com_api_const_pkg.TRUE
          , i_register_event => com_api_const_pkg.TRUE
          , i_params         => app_api_application_pkg.g_params
        );
    end if;

    acq_api_merchant_pkg.modify_merchant(
        i_merchant_id         => l_new.id
      , i_merchant_number     => l_new.merchant_number
      , i_merchant_name       => l_new.merchant_name
      , i_parent_id           => l_new.parent_id
      , i_mcc                 => l_new.mcc
      , i_status              => l_new.status
      , i_contract_id         => l_old_contract_id -- we ignore attemps of change contract_id for merchant
      , i_partner_id_code     => l_new.partner_id_code
      , i_risk_indicator      => l_new.risk_indicator
      , i_mc_assigned_id      => l_new.mc_assigned_id
    );

    change_objects(
        i_appl_data_id        => i_appl_data_id
      , i_parent_appl_data_id => i_parent_appl_data_id
      , i_merchant_id         => l_new.id
      , i_contract_id         => l_old_contract_id
      , i_inst_id             => l_old.inst_id
      , i_customer_id         => i_customer_id
    );

    l_split_hash := com_api_hash_pkg.get_split_hash(
        i_entity_type   =>  acq_api_const_pkg.ENTITY_TYPE_MERCHANT
      , i_object_id     =>  l_new.id
    );

    evt_api_event_pkg.register_event(
        i_event_type    => acq_api_const_pkg.EVENT_MERCHANT_CHANGE
      , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
      , i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
      , i_object_id     => l_new.id
      , i_inst_id       => l_new.inst_id
      , i_param_tab     => l_param_tab
      , i_split_hash    => l_split_hash
    );
end change_merchant;

procedure close_merchant(
    i_merchant_id          in            com_api_type_pkg.t_short_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
) is
    l_split_hash           com_api_type_pkg.t_tiny_id;
    l_param_tab            com_api_type_pkg.t_param_tab;
begin
    trc_log_pkg.debug(
        i_text          => 'aap_api_merchant_pkg.close_merchant [#1]'
      , i_env_param1    => i_merchant_id
    );

    evt_api_shared_data_pkg.set_param(
        i_name      => 'OBJECT_ID'
      , i_value     => i_merchant_id
    );
    evt_api_shared_data_pkg.set_param(
        i_name      => 'INST_ID'
      , i_value     => i_inst_id
    );

    acq_api_merchant_pkg.close_merchant; -- It uses evt_api_shared_data_pkg for passing parameters

    l_split_hash := com_api_hash_pkg.get_split_hash(
        i_entity_type   =>  acq_api_const_pkg.ENTITY_TYPE_MERCHANT
      , i_object_id     =>  i_merchant_id
    );

    evt_api_event_pkg.register_event(
        i_event_type    => acq_api_const_pkg.EVENT_MERCHANT_CLOSE
      , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
      , i_entity_type   => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
      , i_object_id     => i_merchant_id
      , i_inst_id       => i_inst_id
      , i_param_tab     => l_param_tab
      , i_split_hash    => l_split_hash
    );
end;

procedure process_merchant(
    i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_parent_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_contract_id          in            com_api_type_pkg.t_medium_id
  , i_customer_id          in            com_api_type_pkg.t_medium_id
) is
    LOG_PREFIX    constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_merchant: ';
    l_command              com_api_type_pkg.t_dict_value;
    l_inst_id              com_api_type_pkg.t_inst_id;
    l_merchant_inst_id     com_api_type_pkg.t_inst_id;
    l_merchant_number      com_api_type_pkg.t_merchant_number;
    l_merchant_id          com_api_type_pkg.t_short_id;
    l_status               com_api_type_pkg.t_dict_value;
    l_root_id              com_api_type_pkg.t_long_id;
    l_seqnum               com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_customer_id [' || i_customer_id
                                 || '], i_contract_id [' || i_contract_id
                                 || '], i_appl_data_id [' || i_appl_data_id
                                 || '], i_parent_appl_data_id [' || i_parent_appl_data_id || ']');

    cst_api_application_pkg.process_merchant_before (
        i_appl_data_id           => i_appl_data_id
        , i_parent_appl_data_id  => i_parent_appl_data_id
        , i_contract_id          => i_contract_id
        , i_customer_id          => i_customer_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'MERCHANT_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_merchant_number
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_root_id
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'INSTITUTION_ID'
      , i_parent_id      => l_root_id
      , o_element_value  => l_inst_id
    );
    trc_log_pkg.debug(LOG_PREFIX ||    'l_command [' || l_command
                                 || '], l_merchant_number [' || l_merchant_number
                                 || '], l_inst_id [' || l_inst_id || ']');

    -- Search for merchant
    if l_merchant_number is not null then
        begin
            select inst_id
                 , id
                 , status
              into l_merchant_inst_id
                 , l_merchant_id
                 , l_status
              from acq_merchant
             where inst_id = l_inst_id
               and merchant_number = l_merchant_number;
        exception
            when no_data_found then
                null;
            when too_many_rows then
                com_api_error_pkg.raise_error(
                    i_error      => 'MERCHANT_NUMBER_IS_NOT_UNIQUE'
                  , i_env_param1 => l_merchant_number
                  , i_env_param2 => l_inst_id
                );
        end;
    end if;
    trc_log_pkg.debug(LOG_PREFIX ||    'l_merchant_id [' || l_merchant_id
                                 || '], l_merchant_inst_id [' || l_merchant_inst_id
                                 || '], l_status [' || l_status || ']');

    if l_merchant_id is null then
        -- Merchant is NOT found
        if l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
            null;
        elsif l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
            com_api_error_pkg.raise_error(
                i_error      => 'MERCHANT_NOT_FOUND'
              , i_env_param2 => l_merchant_number
              , i_env_param3 => l_inst_id
            );
        else
            create_merchant(
                i_appl_data_id        => i_appl_data_id
              , i_parent_appl_data_id => i_parent_appl_data_id
              , i_contract_id         => i_contract_id
              , i_customer_id         => i_customer_id
              , o_merchant_number     => l_merchant_number
            );
        end if;
    else
        -- Merchant is found
        if l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error(
                i_error         => 'MERCHANT_ALREADY_EXIST'
              , i_env_param1    => l_merchant_number
            );
        elsif l_status = acq_api_const_pkg.MERCHANT_STATUS_CLOSED then
            com_api_error_pkg.raise_error(
                i_error         => 'CANNOT_CHANGE_CLOSED_MERCHANT'
              , i_env_param1    => l_merchant_number
            );
        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
        ) then
            change_merchant(
                i_appl_data_id        => i_appl_data_id
              , i_parent_appl_data_id => i_parent_appl_data_id
              , i_customer_id         => i_customer_id
            );
        elsif l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE then
            -- Close merchant, all its: sub-merchants, terminals, accounts, services
            close_merchant(
                i_merchant_id => l_merchant_id
              , i_inst_id     => l_inst_id
            );
        else
            change_objects(
                i_appl_data_id        => i_appl_data_id
              , i_parent_appl_data_id => i_parent_appl_data_id
              , i_merchant_id         => l_merchant_id
              , i_contract_id         => i_contract_id
              , i_inst_id             => l_inst_id
              , i_customer_id         => i_customer_id
            );
        end if;
    end if;

    -- Checking for double merchant number in one institute. This is reinsurance and must not be fire in normal case
    begin
        select id, seqnum
          into l_merchant_id, l_seqnum
          from acq_merchant
         where inst_id         = l_inst_id
           and merchant_number = l_merchant_number;
    exception
        when too_many_rows then
            com_api_error_pkg.raise_error(
                i_error      => 'MERCHANT_NUMBER_IS_NOT_UNIQUE'
              , i_env_param1 => l_merchant_number
              , i_env_param2 => l_inst_id
            );
    end;

    app_api_note_pkg.process_note(
        i_appl_data_id => i_appl_data_id
      , i_entity_type  => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
      , i_object_id    => l_merchant_id
    );

    cst_api_application_pkg.process_merchant_after (
        i_appl_data_id         => i_appl_data_id
      , i_parent_appl_data_id  => i_parent_appl_data_id
      , i_contract_id          => i_contract_id
      , i_customer_id          => i_customer_id
    );

    app_api_appl_object_pkg.add_object(
        i_appl_id           => app_api_application_pkg.get_appl_id
      , i_entity_type       => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
      , i_object_id         => l_merchant_id
      , i_seqnum            => l_seqnum
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');

exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id      => i_appl_data_id
          , i_element_name      => 'MERCHANT'
        );
end;

end;
/
