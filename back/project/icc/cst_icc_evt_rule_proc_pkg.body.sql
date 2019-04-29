create or replace package body cst_icc_evt_rule_proc_pkg is

procedure product_autochange
is
    FF_PRODUCT_AUTOCHANGE_EVENT constant com_api_type_pkg.t_name := 'CST_PRODUCT_AUTOCHANGE_EVENT';
    FF_COLLECTOR_NAME           constant com_api_type_pkg.t_name := 'CST_COLLECTOR_NAME';
    l_params                             com_api_type_pkg.t_param_tab;
    l_event_type                         com_api_type_pkg.t_dict_value;
    l_entity_type                        com_api_type_pkg.t_name;
    l_object_id                          com_api_type_pkg.t_long_id;
    l_inst_id                            com_api_type_pkg.t_inst_id;
    l_product_id                         com_api_type_pkg.t_short_id;
    l_new_product_id                     com_api_type_pkg.t_short_id;
    l_account_rec                        acc_api_type_pkg.t_account_rec;
    l_seqnum                             com_api_type_pkg.t_seqnum;
begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_object_id   := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_event_type  := rul_api_param_pkg.get_param_char('EVENT_TYPE', l_params);
    l_inst_id     := rul_api_param_pkg.get_param_num('INST_ID', l_params, com_api_type_pkg.TRUE);

    if l_entity_type != acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        trc_log_pkg.warn(
            i_text       => 'CST_ICC_AUTOCHANGE_PRODUCT_FOR_WRONG_ENTITY'
          , i_env_param1 => l_entity_type
          , i_env_param2 => l_object_id
        );
    else
        l_product_id := prd_api_product_pkg.get_product_id(
                            i_entity_type => l_entity_type
                          , i_object_id   => l_object_id
                          , i_inst_id     => l_inst_id
                        );
        -- Search among all child and parent products
        select min(p.id)
          into l_new_product_id
          from      prd_product        p
          left join com_flexible_data  d    on d.object_id = p.id
          left join com_flexible_field f    on f.id        = d.field_id
         where 7 = 7
           and p.id         != l_product_id
           and f.name        = FF_PRODUCT_AUTOCHANGE_EVENT
           and f.entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
           and d.field_value = l_event_type
       connect by prior p.id = parent_id
         start     with p.id = (select min(p.id) -- get the root product
                                  from prd_product p
                                 where connect_by_isleaf    = 1
                               connect by prior p.parent_id = p.id
                                 start     with p.id        = l_product_id)
        ;
        if l_new_product_id is null then
            trc_log_pkg.warn(
                i_text       => 'CST_ICC_PRODUCT_IS_NOT_FOUND_FOR_AUTOCHANGE'
              , i_env_param1 => l_product_id
              , i_env_param2 => l_event_type
            );
        else
            l_account_rec := acc_api_account_pkg.get_account(
                                 i_account_id  => l_object_id
                               , i_inst_id     => l_inst_id
                               , i_mask_error  => com_api_const_pkg.FALSE
                             );
            trc_log_pkg.debug(
                i_text => 'l_account_rec: contract_id [' || l_account_rec.contract_id
                       || '], customer_id [' || l_account_rec.customer_id || ']'
            );
            -- Change product on the contract
            l_seqnum := prd_api_contract_pkg.get_contract(
                            i_contract_id  => l_account_rec.contract_id
                          , i_raise_error  => com_api_type_pkg.TRUE
                        ).seqnum;
            trc_log_pkg.debug(
                i_text => 'l_seqnum  [' || l_seqnum || ']'
            );
            prd_api_contract_pkg.modify_contract(
                i_id           => l_account_rec.contract_id
              , io_seqnum      => l_seqnum
              , i_product_id   => l_new_product_id
              , i_end_date     => null
              , i_lang         => null
              , i_label        => null
              , i_description  => null
            );
            -- Save new product name as a value of custom flexible field (collector name)
            com_api_flexible_data_pkg.set_flexible_value(
                i_field_name   => FF_COLLECTOR_NAME
              , i_entity_type  => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
              , i_object_id    => l_account_rec.customer_id
              , i_field_value  => com_api_i18n_pkg.get_text(
                                      i_table_name   => 'prd_product'
                                    , i_column_name  => 'label'
                                    , i_object_id    => l_new_product_id
                                    , i_lang         => com_api_const_pkg.DEFAULT_LANGUAGE
                                  )
            );
        end if;
    end if;
end product_autochange;

procedure stop_cycle_counter is
    l_params                             com_api_type_pkg.t_param_tab;
    l_event_type                         com_api_type_pkg.t_dict_value;
    l_entity_type                        com_api_type_pkg.t_name;
    l_object_id                          com_api_type_pkg.t_long_id;
    l_inst_id                            com_api_type_pkg.t_inst_id;
    l_count                              pls_integer := 0;
    l_account_rec                        acc_api_type_pkg.t_account_rec;
    l_balances                           com_api_type_pkg.t_amount_by_name_tab;
    l_is_null_balance                    com_api_type_pkg.t_boolean := com_api_type_pkg.TRUE;
    l_cycle_counter_tab                  com_api_type_pkg.t_number_tab;
    l_index                              com_api_type_pkg.t_dict_value;
begin
    l_params := evt_api_shared_data_pkg.g_params;

    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_object_id   := rul_api_param_pkg.get_param_num('OBJECT_ID',   l_params);
    l_event_type  := rul_api_param_pkg.get_param_char('EVENT_TYPE',  l_params);
    l_inst_id     := rul_api_param_pkg.get_param_num('INST_ID', l_params, com_api_type_pkg.TRUE);

    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then

        l_account_rec := acc_api_account_pkg.get_account(
                             i_account_id  => l_object_id
                           , i_inst_id     => l_inst_id
                           , i_mask_error  => com_api_const_pkg.FALSE
                         );
        -- check debts
        select count(1)
          into l_count
          from crd_debt d
         where d.status     != crd_api_const_pkg.DEBT_STATUS_PAID
           and d.account_id  = l_account_rec.account_id
           and d.split_hash  = l_account_rec.split_hash;

        trc_log_pkg.debug(
            i_text => 'l_count [' || l_count || ']'
        );

        if l_count = 1 then

            trc_log_pkg.debug(
                i_text => 'by account [' || l_account_rec.account_id || '] exists unpaid debts'
            );
            return;

        end if;

        -- check balances
        acc_api_balance_pkg.get_account_balances (
            i_account_id    => l_account_rec.account_id
            , o_balances    => l_balances
        );
        l_is_null_balance := com_api_type_pkg.TRUE;

        trc_log_pkg.debug(
            i_text => 'l_balances [' || l_balances.count || ']'
        );

        l_index  := l_balances.first;
        while l_index is not null loop

            if l_balances(l_index).amount != 0 then

                l_is_null_balance := com_api_const_pkg.FALSE;

                trc_log_pkg.debug(
                    i_text => 'balance [' || l_index || '] is not null'
                );
                exit;
            end if;

            l_index  := l_balances.next(l_index);
        end loop;

        if l_is_null_balance = com_api_type_pkg.FALSE then

            trc_log_pkg.debug(
                i_text => 'by account [' || l_account_rec.account_id || '] exists nonzero balances'
            );

            return;
        end if;

        -- stop all cycle counters
        if l_is_null_balance = com_api_type_pkg.TRUE and l_count = 0 then

            select id
              bulk collect into l_cycle_counter_tab
              from (
                select c.id
                  from fcl_cycle_counter c
                 where c.object_id   = l_account_rec.account_id
                   and c.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                   and c.split_hash  = l_account_rec.split_hash
                 union
                select t.id
                  from iss_card c
                     , fcl_cycle_counter t
                 where c.contract_id = l_account_rec.contract_id
                   and t.object_id   = c.id
                   and t.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and t.split_hash  = l_account_rec.split_hash
                 union
                select t.id
                  from prd_customer c
                     , fcl_cycle_counter t
                 where c.contract_id = l_account_rec.contract_id
                   and t.object_id   = c.id
                   and t.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                   and t.split_hash  = l_account_rec.split_hash
            );

            trc_log_pkg.debug(
                i_text => 'l_cycle_counter_tab.count [' || l_cycle_counter_tab.count || ']'
            );

            if l_cycle_counter_tab.count > 0 then
                forall i in l_cycle_counter_tab.first .. l_cycle_counter_tab.last
                    update fcl_cycle_counter
                       set prev_date = null
                         , next_date = null
                     where id = l_cycle_counter_tab(i);
            end if;

        end if;
    end if;
end stop_cycle_counter;

procedure get_loyalty_account_balance
is
    LOG_PREFIX                  constant com_api_type_pkg.t_name :=
        lower($$PLSQL_UNIT) || '.get_loyalty_account_balance: ';
    l_params                             com_api_type_pkg.t_param_tab;
    l_entity_type                        com_api_type_pkg.t_name;
    l_object_id                          com_api_type_pkg.t_long_id;
    l_inst_id                            com_api_type_pkg.t_inst_id;
    l_product_id                         com_api_type_pkg.t_short_id;
    l_service_id                         com_api_type_pkg.t_short_id;
    l_account_type                       com_api_type_pkg.t_dict_value;
    l_currency_code                      com_api_type_pkg.t_curr_code;
    l_account_rec                        acc_api_type_pkg.t_account_rec;
    l_result_amount                      com_api_type_pkg.t_amount_rec;
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ' START'
    );
    l_params      := evt_api_shared_data_pkg.g_params;
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_object_id   := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_inst_id     := rul_api_param_pkg.get_param_num('INST_ID', l_params, com_api_type_pkg.TRUE);

    -- Check if there is an active loyalty service for the entity
    l_service_id  := prd_api_service_pkg.get_active_service_id(
                         i_entity_type      => l_entity_type
                       , i_object_id        => l_object_id
                       , i_attr_name        => null
                       , i_service_type_id  => lty_api_const_pkg.LOYALTY_SERVICE_TYPE_ID
                       , i_eff_date         => null
                       , i_mask_error       => com_api_const_pkg.TRUE
                       , i_inst_id          => l_inst_id
                     );

    if l_service_id is null then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'active loyalty service is not found by entity [#1][#2][#3]'
          , i_env_param1 => l_entity_type
          , i_env_param2 => l_object_id
          , i_env_param3 => l_inst_id
        );
    else
        l_product_id := prd_api_product_pkg.get_product_id(
                            i_entity_type  => l_entity_type
                          , i_object_id    => l_object_id
                        );
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'active loyalty service ID [' || l_service_id
                                       || '], product ID [' || l_product_id || ']'
        );

        l_account_type  := prd_api_product_pkg.get_attr_value_char(
                               i_product_id   => l_product_id
                             , i_entity_type  => l_entity_type
                             , i_object_id    => l_object_id
                             , i_attr_name    => lty_api_const_pkg.LOYALTY_ATTR_ACC_TYPE
                             , i_params       => l_params
                             , i_service_id   => l_service_id
                             , i_inst_id      => l_inst_id
                           );
        l_currency_code := prd_api_product_pkg.get_attr_value_char(
                               i_product_id   => l_product_id
                             , i_entity_type  => l_entity_type
                             , i_object_id    => l_object_id
                             , i_attr_name    => lty_api_const_pkg.LOYALTY_ATTR_ACC_CURR
                             , i_params       => l_params
                             , i_service_id   => l_service_id
                             , i_inst_id      => l_inst_id
                           );
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'account type [#1], account currency [#2]'
          , i_env_param1 => l_account_type
          , i_env_param2 => l_currency_code
        );

        l_account_rec :=
            case l_entity_type
                when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
                    acc_api_account_pkg.get_account(
                        i_account_id    => l_object_id
                      , i_mask_error    => com_api_const_pkg.TRUE
                    )
                when com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
                    acc_api_account_pkg.get_account(
                        i_customer_id   => l_object_id
                      , i_account_type  => l_account_type
                      , i_currency      => l_currency_code
                      , i_mask_error    => com_api_const_pkg.TRUE
                    )
                else
                    acc_api_account_pkg.get_account(
                        i_entity_type   => l_entity_type
                      , i_object_id     => l_object_id
                      , i_account_type  => l_account_type
                      , i_currency      => l_currency_code
                      , i_mask_error    => com_api_const_pkg.TRUE
                    )
            end;

        -- Check for the case when enity type is account
        if  l_account_type  != l_account_rec.account_type
            or
            l_currency_code != l_account_rec.currency
        then
            trc_log_pkg.warn(
                i_text       => 'ENTITY_ACCOUNT_NOT_FOUND'
              , i_env_param1 => l_entity_type
              , i_env_param2 => l_object_id
              , i_env_param3 => l_account_type
              , i_env_param4 => l_currency_code
            );
        elsif l_account_rec.account_id is not null then
            -- Save found loyaty account
            evt_api_shared_data_pkg.set_account(
                i_name        => evt_api_shared_data_pkg.get_param_char('RESULT_ACCOUNT_NAME')
              , i_account_rec => l_account_rec
            );

            l_result_amount := acc_api_balance_pkg.get_aval_balance_amount(
                                   i_account_id  => l_account_rec.account_id
                                 , i_date        => com_api_sttl_day_pkg.get_sysdate
                                 , i_date_type   => com_api_const_pkg.DATE_PURPOSE_PROCESSING
                               );
            evt_api_shared_data_pkg.set_amount(
                i_name      => evt_api_shared_data_pkg.get_param_char('RESULT_AMOUNT_NAME')
              , i_amount    => l_result_amount.amount
              , i_currency  => l_result_amount.currency
            );
        end if;
    end if;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ' END'
    );
end get_loyalty_account_balance;

procedure init_birthday_cycle_notif is
      
    l_params                        com_api_type_pkg.t_param_tab;
    l_object_id                     com_api_type_pkg.t_long_id;
    l_event_date                    date;
    l_product_id                    com_api_type_pkg.t_short_id;
    l_entity_type                   com_api_type_pkg.t_dict_value;
    l_split_hash                    com_api_type_pkg.t_tiny_id;
    l_next_date                     date;
    l_cycle_type                    com_api_type_pkg.t_dict_value;
    l_inst_id                       com_api_type_pkg.t_inst_id;
    l_test_mode                     com_api_type_pkg.t_dict_value;
    l_service_type_id               com_api_type_pkg.t_short_id;
    l_service_id                    com_api_type_pkg.t_short_id;
    l_birthdate                     date;
    l_cycle_start_date              date;
begin
    
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id   := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_event_date  := rul_api_param_pkg.get_param_date('EVENT_DATE', l_params);
    l_split_hash  := rul_api_param_pkg.get_param_num('SPLIT_HASH', l_params);
    l_cycle_type  := crd_cst_report_pkg.CUSTOMER_BIRTHDAY_CYCLE;
    l_inst_id     := rul_api_param_pkg.get_param_num('INST_ID', l_params, com_api_const_pkg.TRUE);
    
    if l_entity_type != acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
    then
        trc_log_pkg.warn(
            i_text       => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );
    else
        l_event_date := nvl(l_event_date, com_api_sttl_day_pkg.get_sysdate);
        l_test_mode := 
            evt_api_shared_data_pkg.get_param_char(
                i_name        => 'ATTR_MISS_TESTMODE'
              , i_mask_error  => com_api_const_pkg.TRUE
              , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
            );    
        l_test_mode := nvl(l_test_mode, fcl_api_const_pkg.ATTR_MISS_RISE_ERROR);
        
        begin
            
            select cp.birthday
              into l_birthdate
              from acc_account a
                 , prd_customer p
                 , com_person cp
             where a.id = l_object_id
               and p.id = a.customer_id
               and p.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
               and cp.id = p.object_id;
               
        exception
            when no_data_found then
                null;
        end;
        
        if l_birthdate is null
        then
                    
            trc_log_pkg.warn(
                i_text       => 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED'
              , i_env_param1 => 'BIRTHDATE'
        );
        
        else
            l_cycle_start_date :=
                to_date(to_char(l_birthdate, 'dd/mm/')||to_char(l_event_date, 'yyyy'), 'dd/mm/yyyy');
            if l_cycle_start_date < l_event_date
            then
                l_cycle_start_date :=
                    add_months(l_cycle_start_date, 12);
            end if;
            
            l_product_id := 
                prd_api_product_pkg.get_product_id (
                    i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id    => l_object_id
                );
                            
            select service_type_id
              into l_service_type_id
              from prd_attribute
             where object_type = l_cycle_type;
                                      
            l_service_id := 
                prd_api_service_pkg.get_active_service_id(
                    i_entity_type         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id           => l_object_id
                  , i_attr_name           => null
                  , i_service_type_id     => l_service_type_id
                  , i_split_hash          => l_split_hash
                  , i_eff_date            => l_event_date
                  , i_inst_id             => l_inst_id
                );
            
            fcl_api_cycle_pkg.switch_cycle(
                i_cycle_type       => l_cycle_type
              , i_product_id       => l_product_id
              , i_entity_type      => l_entity_type
              , i_object_id        => l_object_id
              , i_params           => l_params
              , i_start_date       => l_cycle_start_date
              , i_eff_date         => l_event_date
              , i_split_hash       => l_split_hash
              , i_inst_id          => l_inst_id
              , i_service_id       => l_service_id
              , o_new_finish_date  => l_next_date
              , i_test_mode        => l_test_mode
            );
            
        end if;
        
    end if;

end init_birthday_cycle_notif;

procedure init_marriage_day_cycle_notif is
    
    FF_MARRIAGE_DATE constant com_api_type_pkg.t_name := 'CST_ICC_MARRIAGE_ANNIVERSARY';
    
    l_params                  com_api_type_pkg.t_param_tab;
    l_object_id               com_api_type_pkg.t_long_id;
    l_event_date              date;
    l_product_id              com_api_type_pkg.t_short_id;
    l_entity_type             com_api_type_pkg.t_dict_value;
    l_split_hash              com_api_type_pkg.t_tiny_id;
    l_next_date               date;
    l_cycle_type              com_api_type_pkg.t_dict_value;
    l_inst_id                 com_api_type_pkg.t_inst_id;
    l_test_mode               com_api_type_pkg.t_dict_value;
    l_service_type_id         com_api_type_pkg.t_short_id;
    l_service_id              com_api_type_pkg.t_short_id;
    l_marriage_date           date;
    l_cycle_start_date        date;
    
begin
    
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id   := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_entity_type := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);
    l_event_date  := rul_api_param_pkg.get_param_date('EVENT_DATE', l_params);
    l_split_hash  := rul_api_param_pkg.get_param_num('SPLIT_HASH', l_params);
    l_cycle_type  := crd_cst_report_pkg.CUSTOMER_MARRIAGE_DAY_CYCLE;
    l_inst_id     := rul_api_param_pkg.get_param_num('INST_ID', l_params, com_api_const_pkg.TRUE);
    
    if l_entity_type != acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
    then
        trc_log_pkg.warn(
            i_text       => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );
    else
        l_event_date := nvl(l_event_date, com_api_sttl_day_pkg.get_sysdate);
        l_test_mode := 
            evt_api_shared_data_pkg.get_param_char(
                i_name        => 'ATTR_MISS_TESTMODE'
              , i_mask_error  => com_api_const_pkg.TRUE
              , i_error_value => fcl_api_const_pkg.ATTR_MISS_RISE_ERROR
            );    
        l_test_mode := nvl(l_test_mode, fcl_api_const_pkg.ATTR_MISS_RISE_ERROR);
        
        begin
            
            select trunc(to_date(fd.field_value, ff.data_format), 'dd')
              into l_marriage_date
              from acc_account a
                 , prd_customer p
                 , com_person cp
                 , com_flexible_field ff
                 , com_flexible_data fd
             where a.id = l_object_id
               and p.id = a.customer_id
               and p.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
               and cp.id = p.object_id
               and ff.name = FF_MARRIAGE_DATE
               and ff.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
               and fd.field_id = ff.id
               and fd.object_id = cp.id;
               
        exception
            when no_data_found then
                null;
        end;
        
        if l_marriage_date is null
        then
                    
            trc_log_pkg.warn(
                i_text       => 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED'
              , i_env_param1 => 'MARRIAGE_DATE'
            );
        
        else
            l_cycle_start_date :=
                to_date(to_char(l_marriage_date, 'dd/mm/')||to_char(l_event_date, 'yyyy'), 'dd/mm/yyyy');
            if l_cycle_start_date < l_event_date
            then
                l_cycle_start_date :=
                    add_months(l_cycle_start_date, 12);
            end if;
            
            l_product_id := 
                prd_api_product_pkg.get_product_id (
                    i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id    => l_object_id
                );
                            
            select service_type_id
              into l_service_type_id
              from prd_attribute
             where object_type = l_cycle_type;
                                      
            l_service_id := 
                prd_api_service_pkg.get_active_service_id(
                    i_entity_type         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id           => l_object_id
                  , i_attr_name           => null
                  , i_service_type_id     => l_service_type_id
                  , i_split_hash          => l_split_hash
                  , i_eff_date            => l_event_date
                  , i_inst_id             => l_inst_id
                );
            
            fcl_api_cycle_pkg.switch_cycle(
                i_cycle_type       => l_cycle_type
              , i_product_id       => l_product_id
              , i_entity_type      => l_entity_type
              , i_object_id        => l_object_id
              , i_params           => l_params
              , i_start_date       => l_cycle_start_date
              , i_eff_date         => l_event_date
              , i_split_hash       => l_split_hash
              , i_inst_id          => l_inst_id
              , i_service_id       => l_service_id
              , o_new_finish_date  => l_next_date
              , i_test_mode        => l_test_mode
            );
            
        end if;
        
    end if;

end init_marriage_day_cycle_notif;

procedure check_main_part_credit_limit is
    
    LOG_PREFIX                constant com_api_type_pkg.t_name :=
        lower($$PLSQL_UNIT) || '.check_main_part_credit_limit: ';
    
    l_params                  com_api_type_pkg.t_param_tab;
    l_object_id               com_api_type_pkg.t_long_id;
    l_event_type              com_api_type_pkg.t_dict_value;
    l_event_date              date;
    l_product_id              com_api_type_pkg.t_short_id;
    l_entity_type             com_api_type_pkg.t_dict_value;
    l_split_hash              com_api_type_pkg.t_tiny_id;
    l_next_date               date;
    l_inst_id                 com_api_type_pkg.t_inst_id;
    l_service_type_id         com_api_type_pkg.t_short_id;
    l_service_id              com_api_type_pkg.t_short_id;
    l_account_id              com_api_type_pkg.t_account_id;
    l_main_part_limit         com_api_type_pkg.t_byte_id;
    l_flag                    com_api_type_pkg.t_boolean;
begin
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ' START'
    );
    
    l_params := evt_api_shared_data_pkg.g_params;

    l_object_id   :=
        rul_api_param_pkg.get_param_num(
            i_name        => 'OBJECT_ID'
          , io_params     => l_params
        );
    l_entity_type :=
        rul_api_param_pkg.get_param_char(
            i_name        => 'ENTITY_TYPE'
          , io_params     => l_params
        );
    l_event_type  :=
        rul_api_param_pkg.get_param_char(
            i_name        => 'EVENT_TYPE'
          , io_params     => l_params
        );
    l_event_date  :=
        rul_api_param_pkg.get_param_date(
            i_name        => 'EVENT_DATE'
          , io_params     => l_params
        );
    l_inst_id     :=
        rul_api_param_pkg.get_param_num(
            i_name        => 'INST_ID'
          , io_params     => l_params
          , i_mask_error  => com_api_const_pkg.TRUE
        );
    
    if l_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
    then
        l_account_id := l_object_id;
    elsif l_entity_type = acc_api_const_pkg.ENTITY_TYPE_TRANSACTION
    then
        select a.account_id
          into l_account_id
          from acc_entry a
         where a.transaction_id = l_object_id
           and rownum < 2;
    else
        trc_log_pkg.warn(
            i_text       => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => l_entity_type
        );
        return;
    end if;
    
    begin
        select ab.split_hash
          into l_split_hash
          from acc_balance ab
         where ab.account_id = l_account_id
           and ab.balance_type = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
           and ab.balance > 0
           and ab.status = acc_api_const_pkg.BALANCE_STATUS_ACTIVE;
    exception
        when no_data_found then
            trc_log_pkg.warn(
                i_text       => 'BALANCE_NOT_FOUND'
              , i_env_param1 => l_account_id
              , i_env_param2 => crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
            );
            return;
    end;
    
    l_event_date := nvl(l_event_date, com_api_sttl_day_pkg.get_sysdate);
        
    l_product_id := 
        prd_api_product_pkg.get_product_id(
            i_entity_type  => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id    => l_account_id
        );
        
    l_service_id := 
        prd_api_service_pkg.get_active_service_id(
            i_entity_type         => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id           => l_account_id
          , i_attr_name           => ATTR_MAIN_PART_LIMIT_NOTIF
          , i_service_type_id     => null
          , i_split_hash          => l_split_hash
          , i_eff_date            => l_event_date
          , i_inst_id             => l_inst_id
        );
            
    l_main_part_limit :=
        prd_api_product_pkg.get_attr_value_number(
            i_product_id        => l_product_id
          , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => l_account_id
          , i_attr_name         => ATTR_MAIN_PART_LIMIT_NOTIF
          , i_params            => l_params
          , i_eff_date          => l_event_date
          , i_service_id        => l_service_id
          , i_split_hash        => l_split_hash
          , i_inst_id           => l_inst_id
        );
            
    if l_main_part_limit is null
       or l_main_part_limit = 0
    then
            
        trc_log_pkg.warn(
            i_text       => 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED'
          , i_env_param1 => 'MAIN_PART_LIMIT'
        );
            
    else
        
        begin
                
            select 1
              into l_flag
              from acc_ui_account_vs_aval_vw av
                 , acc_balance ab
             where av.id = l_account_id
               and ab.account_id = av.id
               and ab.balance_type = crd_api_const_pkg.BALANCE_TYPE_ASSIGNED_EXCEED
               and (1 - (av.balance / ab.balance)) * 100 >= l_main_part_limit;
                   
        exception
            when no_data_found then
                l_flag := 0;
        end;	
            
        if l_flag = 1
        then
            
            evt_api_event_pkg.register_event(
                i_event_type        => crd_cst_report_pkg.EXCEED_MAIN_PART_LIMIT_EVENT
              , i_eff_date          => l_event_date
              , i_param_tab         => l_params
              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => l_account_id
              , i_inst_id           => l_inst_id
              , i_split_hash        => l_split_hash
            );
                
        end if;                 
            
    end if;

end check_main_part_credit_limit;

end;
/
