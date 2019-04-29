create or replace package body app_api_contract_pkg as
/*********************************************************
*  Application - contract <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 26.01.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_API_CONTRACT_PKG <br />
*  @headcom
**********************************************************/

procedure search_contract_by_entities (
    i_appl_data_id  in      com_api_type_pkg.t_long_id
  , i_inst_id       in      com_api_type_pkg.t_inst_id
  , i_customer_id   in      com_api_type_pkg.t_medium_id
  , o_contract_id   out     com_api_type_pkg.t_medium_id
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
    l_tmp_contract_id       com_api_type_pkg.t_medium_id;
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.search_contract_by_entities: ';
begin
    trc_log_pkg.debug(LOG_PREFIX || 'Start. i_customer_id = ['||i_customer_id||']');

    select min(id)
         , count(id)
      into l_tmp_contract_id
         , l_count
      from prd_contract
     where customer_id = i_customer_id;

    if l_count = 1 then
    
        o_contract_id := l_tmp_contract_id;
        trc_log_pkg.debug(LOG_PREFIX || 'contract_id [' || o_contract_id || '] found  by customer');
        
    elsif l_count > 1 or l_count = 0 then 
    
        app_api_application_pkg.get_appl_data_id(
            i_element_name  => 'CARD'
          , i_parent_id     => i_appl_data_id
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
                        
                        o_contract_id := l_card.contract_id;
                        trc_log_pkg.debug(LOG_PREFIX || 'contract_id [' || o_contract_id || '] found by card');
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
                        o_contract_id := l_card.contract_id;
                        trc_log_pkg.debug(
                            i_text => LOG_PREFIX || 'contract_id [' || o_contract_id || '] found by card uid'
                        );
                        return;                      
                    end if;                                   
                end if;
            end loop;
        end if;
        
        app_api_application_pkg.get_appl_data_id(
            i_element_name  => 'ACCOUNT'
          , i_parent_id     => i_appl_data_id
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
                        
                        o_contract_id := l_account.contract_id;
                        trc_log_pkg.debug(LOG_PREFIX || 'contract_id [' || o_contract_id || '] found by account');
                        return;
                        
                    end if;
                end if;
            end loop;
        end if;
        
        if nvl(l_id_tab.count, 0) > 0 and app_api_error_pkg.g_app_errors.count = 0 then
            app_api_application_pkg.get_appl_data_id(
                i_element_name  => 'MERCHANT'
              , i_parent_id     => i_appl_data_id
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
                    
                        select contract_id
                          into o_contract_id
                          from acq_merchant
                         where id = l_merchant_id;
                         
                        trc_log_pkg.debug(LOG_PREFIX || 'contract_id [' || o_contract_id || '] found by merchant');
                        return;
                    end if;
                end if;
            end loop;
        end if;
        
        if nvl(l_id_tab.count, 0) > 0 and app_api_error_pkg.g_app_errors.count = 0 then
        
            app_api_application_pkg.get_appl_data_id(
                i_element_name  => 'TERMINAL'
              , i_parent_id     => i_appl_data_id
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
                        select contract_id
                          into o_contract_id 
                          from acq_terminal
                         where decode(nvl(is_template, 0), 0, terminal_number) = l_terminal_number
                           and inst_id = i_inst_id;
                        
                        trc_log_pkg.debug(LOG_PREFIX || 'contract_id [' || o_contract_id || '] found by terminal');
                        return;   
                    exception 
                        when no_data_found then
                            o_contract_id := null;
                    end;
                end if;
            end loop;
            
        end if;
        
        -- since not found by card, account or merchant, return one of them
        o_contract_id := l_tmp_contract_id;
        
        trc_log_pkg.debug(LOG_PREFIX || 'End. Contract not found by card, account or merchant, return by customer, id=' || o_contract_id);
    end if;
end;

procedure entity_service_customer(
    i_customer_id    in      com_api_type_pkg.t_medium_id
  , i_contract_id    in      com_api_type_pkg.t_medium_id
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.entity_service_customer: ';
    l_customer_number        com_api_type_pkg.t_name;  
    l_customer_data_id       com_api_type_pkg.t_long_id;
    l_root_id                com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_customer_id [' || i_customer_id || '], i_contract_id [' || i_contract_id || ']');

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
        
    l_customer_number := prd_api_customer_pkg.get_customer_number(i_customer_id => i_customer_id);

    rul_api_param_pkg.set_param (
        i_value   => i_contract_id
      , i_name    => 'CONTRACT_ID'
      , io_params => app_api_application_pkg.g_params
    );
    
    rul_api_param_pkg.set_param (
        i_value   => l_customer_number
      , i_name    => 'CUSTOMER_NUMBER'
      , io_params => app_api_application_pkg.g_params
    );

    trc_log_pkg.debug(LOG_PREFIX || 'l_root_id [' || l_root_id 
                                 || '], l_customer_data_id [' || l_customer_data_id
                                 || '], l_customer_number [' || l_customer_number || ']');

    app_api_service_pkg.process_entity_service(
        i_appl_data_id  => l_customer_data_id
      , i_element_name  => 'CUSTOMER'
      , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
      , i_object_id     => i_customer_id
      , i_contract_id   => i_contract_id
      , io_params       => app_api_application_pkg.g_params
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end entity_service_customer;

procedure create_contract(
    i_contract       in out  prd_api_type_pkg.t_contract
  , i_inst_id        in      com_api_type_pkg.t_inst_id
  , i_agent_id       in      com_api_type_pkg.t_short_id
  , i_customer_id    in      com_api_type_pkg.t_medium_id
  , i_appl_data_id   in      com_api_type_pkg.t_long_id
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.create_contract: ';
    l_root_id                com_api_type_pkg.t_long_id;
    l_service_id_tab         com_api_type_pkg.t_number_tab;
    l_service_value_tab      com_api_type_pkg.t_number_tab;
    l_count                  pls_integer;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START');

    app_api_application_pkg.get_appl_data_id(
        i_element_name  =>  'APPLICATION'
      , i_parent_id     =>  null
      , o_appl_data_id  =>  l_root_id
    );

    app_api_application_pkg.get_appl_id_value(
        i_element_name   => 'SERVICE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_service_value_tab
      , o_appl_data_id   => l_service_id_tab
    );

    -- check for mandatory services, defined in the product
    for rec in (
        select ps.service_id, ps.min_count
          from prd_product_service ps
         where ps.product_id = i_contract.product_id
           and nvl(ps.min_count, 0) > 0
    )  loop
        trc_log_pkg.debug(
            i_text       => 'looking for mandatory service_id [#1] with minimum of occurrences [#2]'
          , i_env_param1 => rec.service_id
          , i_env_param2 => rec.min_count
        );

        l_count := 0;
        for i in 1 .. nvl(l_service_value_tab.count, 0) loop
            trc_log_pkg.debug(
                i_text       => 'source l_service_value_tab(i) [#1]'
              , i_env_param1 => l_service_value_tab(i)
            );

            if l_service_value_tab(i) = rec.service_id then
                l_count := l_count + 1;
            end if;
        end loop;

        if l_count < rec.min_count then
            com_api_error_pkg.raise_error(
                i_error         => 'MANDATORY_SERVICE_NOT_INCLUDED'
              , i_env_param1    => com_api_i18n_pkg.get_text('prd_service', 'label', rec.service_id)
              , i_env_param2    => prd_ui_product_pkg.get_product_name(i_contract.product_id)
              , i_env_param3    => rec.min_count
            );
        end if;
    end loop;

    prd_api_contract_pkg.add_contract(
        o_id               => i_contract.id
      , o_seqnum           => i_contract.seqnum
      , i_product_id       => i_contract.product_id
      , i_start_date       => i_contract.start_date
      , i_end_date         => i_contract.end_date
      , io_contract_number => i_contract.contract_number
      , i_contract_type    => i_contract.contract_type
      , i_inst_id          => i_inst_id
      , i_agent_id         => i_agent_id
      , i_customer_id      => i_customer_id
      , i_lang             => com_ui_user_env_pkg.get_user_lang
      , i_label            => null
      , i_description      => null
    );

    app_api_application_pkg.modify_element(
        i_appl_data_id      => i_appl_data_id
      , i_element_value     => i_contract.id
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end create_contract;

procedure reconnect_merchant_cards(
    i_account_id_tab      in   com_api_type_pkg.t_medium_tab
  , i_customer_id         in   com_api_type_pkg.t_medium_id
  , i_inst_id             in   com_api_type_pkg.t_inst_id
  , i_agent_id            in   com_api_type_pkg.t_agent_id
) as
    l_account_object_id        com_api_type_pkg.t_long_id;
    l_contract_id              com_api_type_pkg.t_medium_id;
    l_contract_seqnum          com_api_type_pkg.t_tiny_id;
    l_contract_number          com_api_type_pkg.t_name;
    l_split_hash               com_api_type_pkg.t_tiny_id;
begin
    if aap_api_merchant_pkg.g_merchant_card_tab.count = 0 then
        return;
    end if;
    
    for i in aap_api_merchant_pkg.g_merchant_card_tab.first .. aap_api_merchant_pkg.g_merchant_card_tab.last loop
        begin
            select c.id
              into l_contract_id
              from prd_contract c
             where c.customer_id   = i_customer_id
               and c.contract_type = aap_api_merchant_pkg.g_merchant_card_tab(i).card_contract_type
               and c.product_id    = aap_api_merchant_pkg.g_merchant_card_tab(i).card_product_id
               and rownum <= 1;
        exception
            when no_data_found then
                l_contract_id := null;
        end;
        
        if l_contract_id is null then
            prd_api_contract_pkg.add_contract(
                o_id                  => l_contract_id
              , o_seqnum              => l_contract_seqnum
              , i_product_id          => aap_api_merchant_pkg.g_merchant_card_tab(i).card_product_id
              , i_start_date          => null
              , i_end_date            => null
              , io_contract_number    => l_contract_number
              , i_contract_type       => aap_api_merchant_pkg.g_merchant_card_tab(i).card_contract_type
              , i_inst_id             => i_inst_id
              , i_agent_id            => i_agent_id
              , i_customer_id         => i_customer_id
              , i_lang                => com_ui_user_env_pkg.get_user_lang
              , i_label               => null
              , i_description         => null
            );
        end if;
        
        iss_api_card_pkg.reconnect_card(
            i_card_id                      => aap_api_merchant_pkg.g_merchant_card_tab(i).card_id
          , i_customer_id                  => i_customer_id
          , i_contract_id                  => l_contract_id
          , i_cardholder_id                => null
          , i_cardholder_photo_file_name   => null
          , i_cardholder_sign_file_name    => null
          , i_expir_date                   => null
        );
        
        l_split_hash := 
            com_api_hash_pkg.get_split_hash(
                i_entity_type   => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
              , i_object_id     => i_customer_id
            );
        
        for j in i_account_id_tab.first .. i_account_id_tab.last loop
            acc_api_account_pkg.add_account_object(
                i_account_id         => i_account_id_tab(j)
              , i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id          => aap_api_merchant_pkg.g_merchant_card_tab(i).card_id
              , o_account_object_id  => l_account_object_id
            );
        end loop;
    end loop;

end reconnect_merchant_cards;

procedure change_objects(
    i_appl_data_id  in      com_api_type_pkg.t_long_id
  , i_contract_id   in      com_api_type_pkg.t_medium_id
  , i_customer_id   in      com_api_type_pkg.t_medium_id
  , i_inst_id       in      com_api_type_pkg.t_inst_id
  , i_agent_id      in      com_api_type_pkg.t_agent_id
  , i_product_id    in      com_api_type_pkg.t_short_id
  , i_pool_number   in      com_api_type_pkg.t_short_id   default 1
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name        := lower($$PLSQL_UNIT) || '.change_objects: ';
    l_id_tab                com_api_type_pkg.t_number_tab;
    l_agent_id              com_api_type_pkg.t_agent_id    := app_api_application_pkg.get_app_agent_id;
    l_customer_id           com_api_type_pkg.t_medium_id   := i_customer_id;
    l_merchant_id           com_api_type_pkg.t_short_id;
    l_corp_appl_data_id     com_api_type_pkg.t_long_id;
    l_card_id_tab           com_api_type_pkg.t_medium_tab;
    l_account_id_tab        com_api_type_pkg.t_medium_tab;
    l_card_exists           com_api_type_pkg.t_boolean;
    l_is_instant_card       com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_appl_data_id [' || i_appl_data_id || '], i_contract_id [' || i_contract_id || ']');

    -- process card
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'CARD'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    app_api_flexible_field_pkg.process_flexible_fields(
        i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CONTRACT
      , i_object_type   => null
      , i_object_id     => i_contract_id
      , i_inst_id       => i_inst_id
      , i_appl_data_id  => i_appl_data_id
    );

    if nvl(l_id_tab.count, 0) > 0 and app_api_error_pkg.g_app_errors.count = 0 then
        for i in 1..nvl(l_id_tab.count, 0) loop
            iap_api_card_pkg.process_card(
                i_appl_data_id  => l_id_tab(i)
              , i_customer_id   => i_customer_id
              , i_contract_id   => i_contract_id
              , i_inst_id       => i_inst_id
              , i_agent_id      => i_agent_id
              , i_product_id    => i_product_id
              , o_card_id       => l_card_id_tab(i)
            );
        end loop;
    end if;

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'MERCHANT'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    for i in 1..nvl(l_id_tab.count, 0) loop
        aap_api_merchant_pkg.process_merchant(
            i_appl_data_id         => l_id_tab(i)
          , i_parent_appl_data_id  => i_appl_data_id
          , i_contract_id          => i_contract_id
          , i_customer_id          => i_customer_id
        );
    end loop;

    -- Processing of terminals which are not linked to merchants
    app_api_application_pkg.get_appl_data_id(
        i_element_name  =>  'TERMINAL'
      , i_parent_id     =>  i_appl_data_id
      , o_appl_data_id  =>  l_id_tab
    );
    trc_log_pkg.debug(LOG_PREFIX || 'blocks <terminal> have been read: ' || l_id_tab.count());

    if nvl(l_id_tab.count, 0) > 0 then
        if l_customer_id is null then
            begin
                select cu.id
                  into l_customer_id
                  from prd_customer cu
                     , prd_contract c
                 where cu.inst_id     = i_inst_id
                   and c.id           = cu.contract_id
                   and c.agent_id     = l_agent_id
                   and c.id           = i_contract_id
                   and cu.entity_type = ost_api_const_pkg.ENTITY_TYPE_AGENT;
            exception
                when no_data_found then
                    com_api_error_pkg.raise_error(
                        i_error      => 'BANK_CUSTOMER_NOT_FOUND'
                      , i_env_param1 => i_inst_id
                      , i_env_param2 => l_agent_id
                    );
                when too_many_rows then
                    com_api_error_pkg.raise_error(
                        i_error      => 'TOO_MANY_BANK_CUSTOMER'
                      , i_env_param1 => i_inst_id
                      , i_env_param2 => l_agent_id
                    );
            end;
        end if;

        begin
            select m.id
              into l_merchant_id
              from acq_merchant m
                 , prd_contract c
             where m.inst_id     = i_inst_id
               and m.contract_id = c.id
               and c.agent_id    = l_agent_id
               and c.id            = i_contract_id
               and m.merchant_type = acq_api_const_pkg.MERCHANT_TYPE_BANK;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error      => 'BANK_MERCHANT_NOT_FOUND'
                  , i_env_param1 => i_inst_id
                  , i_env_param2 => l_agent_id
                );
            when too_many_rows then
                com_api_error_pkg.raise_error(
                    i_error      => 'TOO_MANY_BANK_MERCHANT'
                  , i_env_param1 => i_inst_id
                  , i_env_param2 => l_agent_id
                );
        end;

        for i in 1..nvl(l_id_tab.count, 0) loop
            aap_api_terminal_pkg.process_terminal(
                i_appl_data_id        => l_id_tab(i)
              , i_parent_appl_data_id => i_appl_data_id
              , i_merchant_id         => l_merchant_id
              , i_inst_id             => i_inst_id
              , i_contract_id         => i_contract_id
              , i_customer_id         => l_customer_id
            );
        end loop;
    end if;

    -- process account
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'ACCOUNT'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );
    trc_log_pkg.debug(LOG_PREFIX || 'blocks <account> have been read: ' || l_id_tab.count());

    if nvl(l_id_tab.count, 0) > 0
       and app_api_error_pkg.g_app_errors.count = 0
    then

        for i in 1..nvl(l_id_tab.count, 0) loop
            app_api_account_pkg.process_account(
                i_appl_data_id  => l_id_tab(i)
              , i_inst_id       => i_inst_id
              , i_agent_id      => app_api_application_pkg.get_app_agent_id
              , i_customer_id   => i_customer_id
              , i_contract_id   => i_contract_id
              , o_account_id    => l_account_id_tab(i)
            );
        end loop;
        trc_log_pkg.debug(LOG_PREFIX || 'blocks <account> have been processed');

        -- Check processed accounts for duplicated POS/ATM flags
        if nvl(l_account_id_tab.count, 0) > 0
           and app_api_error_pkg.g_app_errors.count = 0
        then
            for i in 1..nvl(l_account_id_tab.count, 0) loop
                app_api_account_pkg.check_default_values(
                    i_account_id  => l_account_id_tab(i)
                );
            end loop;
        end if;
    end if;
    
    if aap_api_merchant_pkg.g_merchant_card_tab.count > 0 then
        reconnect_merchant_cards(
            i_account_id_tab   => l_account_id_tab
          , i_customer_id      => i_customer_id
          , i_inst_id          => i_inst_id
          , i_agent_id         => i_agent_id
        );
    end if;

    -- child element CORPORATION
    app_api_application_pkg.get_appl_data_id(
        i_element_name      => 'CORPORATION'
      , i_parent_id         => i_appl_data_id
      , o_appl_data_id      => l_corp_appl_data_id
    );

    trc_log_pkg.debug(LOG_PREFIX || 'l_corporation_branch_id [' || l_corp_appl_data_id || ']');

    if l_corp_appl_data_id is not null and app_api_error_pkg.g_app_errors.count = 0 then
        app_api_application_pkg.get_appl_data_id(
            i_element_name      => 'DEPARTMENT'
          , i_parent_id         => l_corp_appl_data_id
          , o_appl_data_id      => l_id_tab
        );
        trc_log_pkg.debug(LOG_PREFIX || 'blocks <department> have been read: ' || l_id_tab.count());

        for i in 1..nvl(l_id_tab.count, 0) loop
            trc_log_pkg.info('appl_data_id [' || l_id_tab(i) || '], parent_data_id [' || l_corp_appl_data_id || ']');

            app_api_department_pkg.process_department(
                i_appl_data_id          => l_id_tab(i)
              , i_parent_appl_data_id   => l_corp_appl_data_id
              , i_contract_id           => i_contract_id
              , i_customer_id           => i_customer_id
            );
        end loop;
    end if;

    app_api_service_pkg.process_entity_service(
        i_appl_data_id  => i_appl_data_id
      , i_element_name  => 'CONTRACT'
      , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_CONTRACT
      , i_object_id     => i_contract_id
      , i_contract_id   => i_contract_id
      , io_params       => app_api_application_pkg.g_params
    );

    -- update document link
    app_api_report_pkg.process_report(
        i_appl_data_id        => i_appl_data_id
      , i_entity_type         => prd_api_const_pkg.ENTITY_TYPE_CONTRACT
      , i_object_id           => i_contract_id
    );

    -- check contract type
    l_is_instant_card := iss_api_card_pkg.is_instant_card(
                             i_contract_id  =>  i_contract_id
                           , i_customer_id  =>  i_customer_id
                         );

    -- check links between processed cards and any accounts
    if nvl(l_card_id_tab.count, 0) > 0
       and app_api_error_pkg.g_app_errors.count = 0
       and l_is_instant_card = com_api_const_pkg.FALSE
       and iap_api_card_pkg.get_app_merchant_service_count(app_api_application_pkg.get_appl_id) = 0
    then
        for i in 1..nvl(l_card_id_tab.count, 0) loop
            begin
                select 1
                  into l_card_exists
                  from iss_card c
                 where c.id = l_card_id_tab(i)
                   and exists (
                           select 1
                             from acc_account_object ao
                            where ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                              and ao.object_id   = c.id
                       );

            exception when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'ACCOUNT_IS_NOT_LINKED_WITH_OBJECT'
                  , i_env_param1    => null
                  , i_env_param2    => iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_env_param3    => l_card_id_tab(i)
                );

            end;
        end loop;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'END');
end change_objects;

/**************************************************
* Element PRODUCT_NUMBER is considered as an alternative for element PRODUCT_ID.
* So if PRODUCT_ID is not defined then it's necessary to try to determine its value using PRODUCT_NUMBER.
* Also if both elements are presented then they must point to a one product.
* Otherwise an error will be raised.
*
* @param i_appl_data_id  Id of parent element in application's structure (i.e. id of <CONTRACT>).
* @param io_appl_data    Application's structure, that could be modified if PRODUCT_ID will be
                         determined by PRODUCT_NUMBER.
* @param io_product_id   If this parameter is NULL then value of PRODUCT_ID is determined by
                         PRODUCT_NUMBER will be assigned with it.
***************************************************/
procedure process_product_number(
    i_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_inst_id       in            com_api_type_pkg.t_inst_id
  , io_product_id   in out        com_api_type_pkg.t_short_id
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_product_number: ';
    l_product_number              com_api_type_pkg.t_name;
    l_product_id                  com_api_type_pkg.t_short_id;
begin
    app_api_application_pkg.get_element_value(
        i_element_name   => 'PRODUCT_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_product_number
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'l_product_number [#1]'
      , i_env_param1 => l_product_number
    );

    if l_product_number is not null then
        l_product_id:= prd_api_product_pkg.get_product_id(
                           i_product_number => l_product_number
                         , i_inst_id        => i_inst_id
                       );
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'l_product_id [#1], io_product_id [#2]'
          , i_env_param1 => l_product_id
          , i_env_param2 => io_product_id
        );

        -- the value of PRODUCT_ID that is determined by PRODUCT_NUMBER should be saved
        -- in application data structure (table APP_DATA) so that additional changes wouldn't be needed
        if io_product_id is null then
            app_api_application_pkg.add_element(
                i_element_name   => 'PRODUCT_ID'
              , i_parent_id      => i_appl_data_id
              , i_element_value  => l_product_id
            );
            io_product_id := l_product_id;

        -- if tags PRODUCT_NUMBER and PRODUCT_ID are defined together then they must point to a one product
        elsif io_product_id != nvl(l_product_id, io_product_id) then
            com_api_error_pkg.raise_error(
                i_error         => 'PRODUCT_NUMBER_DOESNT_CORRELATE_WITH_PRODUCT_ID'
              , i_env_param1    => l_product_number
              , i_env_param2    => i_inst_id
              , i_env_param3    => io_product_id
            );
        end if;
    end if;
end process_product_number;

/**************************************************
* Element SERVICE_NUMBER is considered as an alternative for attribute ID of parent element SERVICE (SERVICE_ID).
* So if SERVICE_ID is not defined then it's necessary to try to determine its value using SERVICE_NUMBER.
* Also if both elements are presented then they must point to a one service.
* Otherwise an error will be raised.
*
* @param i_appl_data_id  Id of parent element in application's structure (i.e. id of <CONTRACT>).
* @param io_appl_data    Application's structure, that could be modified if SERVICE_IDs will be
                         determined by SERVICE_NUMBERs.
***************************************************/
procedure process_service_number(
    i_appl_data_id  in            com_api_type_pkg.t_long_id
  , i_inst_id       in            com_api_type_pkg.t_inst_id
) is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_service_number: ';
    l_service_value_tab           com_api_type_pkg.t_number_tab;
    l_service_id_tab              com_api_type_pkg.t_number_tab;
    l_service_number              com_api_type_pkg.t_name;
    l_service_id                  com_api_type_pkg.t_short_id;
begin
    app_api_application_pkg.get_appl_id_value(
        i_element_name   => 'SERVICE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_service_value_tab
      , o_appl_data_id   => l_service_id_tab
    );
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '[#1] services have been found in application''s structure '
                                   || 'in block with i_appl_data_id [#2]'
      , i_env_param1 => nvl(l_service_id_tab.count, 0)
      , i_env_param2 => i_appl_data_id
    );

    if nvl(l_service_id_tab.count, 0) > 0 then
        for i in l_service_id_tab.first .. l_service_id_tab.last loop
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'processing service with id [#1] and appl_data_id [#2]'
              , i_env_param1 => l_service_value_tab(i)
              , i_env_param2 => l_service_id_tab(i)
            );

            app_api_application_pkg.get_element_value(
                i_element_name   => 'SERVICE_NUMBER'
              , i_parent_id      => l_service_id_tab(i)
              , o_element_value  => l_service_number
            );
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'l_service_number [#1]'
              , i_env_param1 => l_service_number
            );

            if l_service_number is not null then
                l_service_id:= prd_api_service_pkg.get_service_id(
                                    i_service_number => l_service_number
                                  , i_inst_id        => i_inst_id
                               );
                trc_log_pkg.debug(
                    i_text       => LOG_PREFIX || 'l_service_id [#1] has been determined by l_service_number'
                  , i_env_param1 => l_service_id
                );

                -- the value of SERVICE_ID that is determined by SERVICE_NUMBER should be saved
                -- in application data structure (table APP_DATA) so that additional changes wouldn't be needed
                if l_service_value_tab(i) is null then
                    app_api_application_pkg.modify_element(
                        i_appl_data_id   => l_service_id_tab(i)
                      , i_element_value  => l_service_id
                    );
                    trc_log_pkg.debug(
                        i_text       => LOG_PREFIX || 'l_service_id [#1] has been saved in application structure'
                      , i_env_param1 => l_service_id
                    );

                -- if tags SERVICE_NUMBER and attribute ID of element SERVICE are defined together
                -- then they must point to a one service
                elsif l_service_value_tab(i) != nvl(l_service_id, l_service_value_tab(i)) then
                    com_api_error_pkg.raise_error(
                        i_error         => 'SERVICE_NUMBER_DOESNT_CORRELATE_WITH_SERVICE_ID'
                      , i_env_param1    => l_service_number
                      , i_env_param2    => i_inst_id
                      , i_env_param3    => l_service_value_tab(i)
                    );
                end if;
            end if;
        end loop;
    end if;
end process_service_number;

procedure process_contract(
    i_appl_data_id  in      com_api_type_pkg.t_long_id
  , i_inst_id       in      com_api_type_pkg.t_inst_id
  , i_agent_id      in      com_api_type_pkg.t_short_id
  , i_customer_id   in      com_api_type_pkg.t_medium_id
  , o_contract_id      out  com_api_type_pkg.t_medium_id
  , i_pool_number   in      com_api_type_pkg.t_short_id   default 1
) is
    LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_contract: ';
    l_command               com_api_type_pkg.t_dict_value;
    l_contract              prd_api_type_pkg.t_contract;
    l_appl_data_id          com_api_type_pkg.t_long_id;
    l_root_id               com_api_type_pkg.t_long_id;
    l_customer_ext_type     com_api_type_pkg.t_dict_value;
    l_contract_number       com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'i_appl_data_id [' || i_appl_data_id 
                                 || '], i_agent_id [' || i_agent_id
                                 || '], i_customer_id [' || i_customer_id || ']'
                                 || '], i_pool_number [' || i_pool_number || ']');

    cst_api_application_pkg.process_contract_before(
        i_appl_data_id   => i_appl_data_id
        , i_inst_id      => i_inst_id
        , i_agent_id     => i_agent_id
        , i_customer_id  => i_customer_id
        , o_contract_id  => o_contract_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CONTRACT_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_contract.contract_number
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'o_contract_id [' || o_contract_id || '], '
                             || 'l_contract.contract_number [' || l_contract.contract_number || ']'
    );

    -- search contract by entities
    if o_contract_id is null 
        and l_contract.contract_number is null
        and l_command not in (app_api_const_pkg.COMMAND_CREATE_OR_PROCEED, app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT) then

        search_contract_by_entities (
            i_appl_data_id  => i_appl_data_id
          , i_inst_id       => i_inst_id
          , i_customer_id   => i_customer_id
          , o_contract_id   => o_contract_id
        );

    end if;

    -- Check that contract belongs to customer <i_customer_id>.
    -- At first we try to seach a contract by l_contract.contract_number, then we try with o_contract_id
    l_contract_number := coalesce(
                             l_contract.contract_number
                           , prd_api_contract_pkg.get_contract_number(i_contract_id => o_contract_id)
                         );
    if l_contract_number is not null
       and 
       i_customer_id != nvl(
                            prd_api_contract_pkg.get_contract(
                                i_contract_number => l_contract_number
                              , i_inst_id         => i_inst_id
                              , i_contract_id     => null -- do not use it because it is primary parameter for searching
                            ).customer_id
                          , i_customer_id
                        )
    then
        com_api_error_pkg.raise_error(
            i_error      => 'CONTRACT_DOES_NOT_BELONG_TO_CUSTOMER'
          , i_env_param1 => l_contract_number
          , i_env_param2 => i_customer_id
        );
    end if;

    app_api_application_pkg.get_element_value(
        i_element_name   => 'CONTRACT_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_contract.contract_type
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'START_DATE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_contract.start_date
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'END_DATE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_contract.end_date
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'PRODUCT_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_contract.product_id
    );

    -- PRODUCT_NUMBER is considered as an alternative for PRODUCT_ID
    process_product_number(
        i_appl_data_id   => i_appl_data_id
      , i_inst_id        => i_inst_id
      , io_product_id    => l_contract.product_id
    );

    -- SERVICE_NUMBER is considered as an alternative for attribute ID of element SERVICE (field service_id)
    process_service_number(
        i_appl_data_id   => i_appl_data_id
      , i_inst_id        => i_inst_id
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'APPLICATION'
      , i_parent_id      => null
      , o_appl_data_id   => l_root_id
    );
    app_api_application_pkg.get_appl_data_id(
        i_element_name   => 'CUSTOMER'
      , i_parent_id      => l_root_id
      , o_appl_data_id   => l_root_id
    );
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CUSTOMER_EXT_TYPE'
      , i_parent_id      => l_root_id
      , o_element_value  => l_customer_ext_type
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'contract_type [#1], customer_ext_type [#2], product_id [#3]'
      , i_env_param1 => l_contract.contract_type
      , i_env_param2 => l_customer_ext_type
      , i_env_param3 => l_contract.product_id
    );

    if  l_customer_ext_type = ost_api_const_pkg.ENTITY_TYPE_AGENT
        and l_contract.contract_type = prd_api_const_pkg.CONTRACT_TYPE_INSTANT_CARD
    then
        select id
             , contract_number
             , product_id
          into l_contract.id
             , l_contract.contract_number
             , l_contract.product_id
          from prd_contract
         where customer_id = i_customer_id
           and contract_type = prd_api_const_pkg.CONTRACT_TYPE_INSTANT_CARD;

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'searching contract by customer_id [' || i_customer_id || ']'
        );
        
        app_api_application_pkg.get_appl_data_id(
            i_element_name      => 'CONTRACT_NUMBER'
          , i_parent_id         => i_appl_data_id
          , o_appl_data_id      => l_appl_data_id
        );

        if l_appl_data_id is null then
            app_api_application_pkg.add_element(
                i_element_name   => 'CONTRACT_NUMBER'
              , i_parent_id      => i_appl_data_id
              , i_element_value  => l_contract.contract_number
            );
        else
            app_api_application_pkg.modify_element(
                i_appl_data_id   => l_appl_data_id
              , i_element_value  => l_contract.contract_number
            );
        end if;

        app_api_application_pkg.get_appl_data_id(
            i_element_name      => 'PRODUCT_ID'
          , i_parent_id         => i_appl_data_id
          , o_appl_data_id      => l_appl_data_id
        );

        if l_appl_data_id is null then
            app_api_application_pkg.add_element(
                i_element_name   => 'PRODUCT_ID'
              , i_parent_id      => i_appl_data_id
              , i_element_value  => l_contract.product_id
            );
        else
            app_api_application_pkg.modify_element(
                i_appl_data_id   => l_appl_data_id
              , i_element_value  => l_contract.product_id
            );
        end if;
    end if;

    -- check date
    if l_contract.start_date is not null 
        and l_contract.end_date is not null
        and l_contract.start_date > l_contract.end_date
    then
        com_api_error_pkg.raise_error(
            i_error => 'INCONSISTENT_DATE'
        );
    end if;

    if l_contract.contract_number is not null then
        select min(id)
             , min(seqnum)
             , nvl(l_contract.product_id, min(product_id))
          into l_contract.id
             , l_contract.seqnum
             , l_contract.product_id
          from prd_contract_vw
         where contract_number = upper(l_contract.contract_number)
           and inst_id = i_inst_id;
    else
        if o_contract_id is not null then
            trc_log_pkg.debug('o_contract_id [' || o_contract_id || '], searching contract_number...');
            select min(id)
                 , min(seqnum)
                 , min(contract_number)
                 , nvl(l_contract.product_id, min(product_id))
              into l_contract.id
                 , l_contract.seqnum
                 , l_contract.contract_number
                 , l_contract.product_id
              from prd_contract_vw
             where id = o_contract_id;
             trc_log_pkg.debug('l_contract.contract_number [' || l_contract.contract_number || ']');
        end if;
    end if;

    if l_contract.product_id is not null then
        rul_api_param_pkg.set_param(
            i_value          => l_contract.product_id
          , i_name           => 'PRODUCT_ID'
          , io_params        => app_api_application_pkg.g_params
        );
    end if;

    trc_log_pkg.debug(LOG_PREFIX || 'processing contract_id [' || l_contract.id || '] with command [' || l_command || ']');

    if l_contract.id is not null then
        -- process service for customer
        entity_service_customer(
            i_customer_id    => i_customer_id
          , i_contract_id    => l_contract.id
        );
            
        if l_command = app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
        or l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED then            
            change_objects(
                i_appl_data_id  => i_appl_data_id
              , i_contract_id   => l_contract.id
              , i_customer_id   => i_customer_id
              , i_inst_id       => i_inst_id
              , i_agent_id      => i_agent_id
              , i_product_id    => l_contract.product_id
              , i_pool_number   => i_pool_number
            );
        elsif l_command = app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT then
            com_api_error_pkg.raise_error(
                i_error         => 'CONTRACT_ALREADY_EXIST'
              , i_env_param1    => l_contract.contract_number
              , i_env_param2    => i_inst_id
            );

        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
        ) then
            prd_api_contract_pkg.modify_contract(
                i_id              => l_contract.id
              , io_seqnum         => l_contract.seqnum
              , i_product_id      => l_contract.product_id
              , i_end_date        => l_contract.end_date
              , i_contract_number => l_contract.contract_number
              , i_lang            => com_ui_user_env_pkg.get_user_lang
              , i_label           => null
              , i_description     => null
              , i_agent_id        => i_agent_id
            );
            change_objects(
                i_appl_data_id    => i_appl_data_id
              , i_contract_id     => l_contract.id
              , i_customer_id     => i_customer_id
              , i_inst_id         => i_inst_id
              , i_agent_id        => i_agent_id
              , i_product_id      => l_contract.product_id
              , i_pool_number     => i_pool_number
            );
        elsif l_command = app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE then
            prd_api_contract_pkg.close_contract(
                i_contract_id     => l_contract.id
              , i_inst_id         => i_inst_id
              , i_end_date        => l_contract.end_date
              , i_params          => app_api_application_pkg.g_params
            );
        end if;
    else -- if contract is not found then...
        if l_command = app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE then
            change_objects(
                i_appl_data_id    => i_appl_data_id
              , i_contract_id     => l_contract.id
              , i_customer_id     => i_customer_id
              , i_inst_id         => i_inst_id
              , i_agent_id        => i_agent_id
              , i_product_id      => l_contract.product_id
              , i_pool_number     => i_pool_number
            );
        elsif l_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
            com_api_error_pkg.raise_error(
                i_error         => 'CONTRACT_NOT_FOUND'
              , i_env_param1    => l_contract.contract_number
              , i_env_param2    => i_inst_id
            );
        elsif l_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
          , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
          , app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
        ) then
            create_contract(
                i_contract      => l_contract
              , i_inst_id       => i_inst_id
              , i_agent_id      => i_agent_id
              , i_customer_id   => i_customer_id
              , i_appl_data_id  => i_appl_data_id
            );
            
            -- process service for customer
            entity_service_customer(
              i_customer_id      => i_customer_id
              , i_contract_id    => l_contract.id
            );
            
            change_objects(
                i_appl_data_id    => i_appl_data_id
              , i_contract_id     => l_contract.id
              , i_customer_id     => i_customer_id
              , i_inst_id         => i_inst_id
              , i_agent_id        => i_agent_id
              , i_product_id      => l_contract.product_id
              , i_pool_number     => i_pool_number
            );
        end if;

        if l_contract.contract_number is not null 
        and i_pool_number = app_api_customer_pkg.get_customer_count then
            -- Save contract number into application
            app_api_application_pkg.get_appl_data_id(
                i_element_name      => 'CONTRACT_NUMBER'
              , i_parent_id         => i_appl_data_id
              , o_appl_data_id      => l_appl_data_id
            );

            if l_appl_data_id is null then
                app_api_application_pkg.add_element(
                    i_element_name      => 'CONTRACT_NUMBER'
                  , i_parent_id         => i_appl_data_id
                  , i_element_value     => l_contract.contract_number
                );
            end if;
        end if;
    end if;

    o_contract_id := l_contract.id;

    app_api_note_pkg.process_note(
        i_appl_data_id => i_appl_data_id
      , i_entity_type  => prd_api_const_pkg.ENTITY_TYPE_CONTRACT
      , i_object_id    => o_contract_id
    );

    app_api_appl_object_pkg.add_object(
        i_appl_id           => app_api_application_pkg.get_appl_id
      , i_entity_type       => prd_api_const_pkg.ENTITY_TYPE_CONTRACT
      , i_object_id         => o_contract_id
      , i_seqnum            => l_contract.seqnum
    );

    cst_api_application_pkg.process_contract_after(
        i_appl_data_id    => i_appl_data_id
        , i_inst_id       => i_inst_id
        , i_agent_id      => i_agent_id
        , i_customer_id   => i_customer_id
        , io_contract_id  => o_contract_id
    );

    trc_log_pkg.debug(LOG_PREFIX || 'contract with id [' || o_contract_id || '] has been processed');
exception
    when com_api_error_pkg.e_application_error then
        app_api_error_pkg.intercept_error(
            i_appl_data_id  => i_appl_data_id
          , i_element_name  => 'CONTRACT'
        );
end process_contract;

end app_api_contract_pkg;
/
