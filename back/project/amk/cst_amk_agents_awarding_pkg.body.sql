create or replace package body cst_amk_agents_awarding_pkg as

procedure calculate_awarding(
    i_start_date        in     date
  , i_end_date          in     date 
  , i_dest_curr         in     com_api_type_pkg.t_curr_code      default '116'
) is
    l_eff_date                date := com_api_sttl_day_pkg.get_sysdate;
    l_eff_date_tab            com_api_type_pkg.t_date_tab;
    l_acc_agents              com_api_type_pkg.t_account_number_tab;
    l_acc_sub_agents          com_api_type_pkg.t_account_number_tab;
    l_accounts_sub_agents     com_api_type_pkg.t_account_number_tab;
    l_accounts_count          com_api_type_pkg.t_number_tab;
    l_event_object_id_tab     com_api_type_pkg.t_number_tab;
    l_account_id_tab          com_api_type_pkg.t_number_tab;
    l_params                  com_api_type_pkg.t_param_tab;
    l_agent_account_id        com_api_type_pkg.t_account_id;
    l_sub_agent_account_id    com_api_type_pkg.t_account_id;
    l_agent_id                com_api_type_pkg.t_account_number;
    l_sub_agent_id            com_api_type_pkg.t_account_number;
    l_agent_fee_type          com_api_type_pkg.t_dict_value := 'FETP5109';
    l_sub_agent_fee_type      com_api_type_pkg.t_dict_value := 'FETP5110';
    l_agent_inst_id           com_api_type_pkg.t_inst_id;
    l_sub_agent_inst_id       com_api_type_pkg.t_inst_id;
    l_agent_currency          com_api_type_pkg.t_curr_code;
    l_sub_agent_currency      com_api_type_pkg.t_curr_code;
    l_agent_product_id        com_api_type_pkg.t_short_id;
    l_sub_agent_product_id    com_api_type_pkg.t_short_id;
    l_agent_fee_id            com_api_type_pkg.t_short_id;
    l_sub_agent_fee_id        com_api_type_pkg.t_short_id;
    l_agent_fee_amount        com_api_type_pkg.t_money;
    l_sub_agent_fee_amount    com_api_type_pkg.t_money;
    l_prev_amount             com_api_type_pkg.t_money;
    l_prev_count              com_api_type_pkg.t_medium_id;
    l_agent_customer_id       com_api_type_pkg.t_medium_id;
    l_sub_agent_customer_id   com_api_type_pkg.t_medium_id;
    l_agent_customer_name     com_api_type_pkg.t_name;
    l_sub_agent_customer_name com_api_type_pkg.t_name;
    l_agent_split_hash        com_api_type_pkg.t_tiny_id;
    l_sub_agent_split_hash    com_api_type_pkg.t_tiny_id;
    l_merchant_id             com_api_type_pkg.t_short_id;
    l_lang                    com_api_type_pkg.t_dict_value := com_ui_user_env_pkg.get_user_lang();
    l_event_objects_tab       com_api_type_pkg.t_number_tab;

    cursor cu_event_objects is
        select eo.id as event_object_id
          from acc_account a
             , evt_event_object eo
         where a.id = eo.object_id
           and eo.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_AMK_AGENTS_AWARDING_PKG.CALCULATE_AWARDING';

    cursor cu_agents is
        select com_api_flexible_data_pkg.get_flexible_value (
                   i_field_name    => 'CST_ACC_AGENT_ID'
                 , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 , i_object_id     => a.id
               ) as acc_agent_id
             , count(a.id) as accounts_count
          from acc_account a
             , evt_event_object eo
         where a.id = eo.object_id
           and eo.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_AMK_AGENTS_AWARDING_PKG.CALCULATE_AWARDING'
      group by com_api_flexible_data_pkg.get_flexible_value (
                    i_field_name        => 'CST_ACC_AGENT_ID'
                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id         => a.id
               );

    cursor cu_sub_agents(i_agent_id in com_api_type_pkg.t_account_number) is
       select com_api_flexible_data_pkg.get_flexible_value (
                   i_field_name     => 'CST_ACC_SUB_AGENT_ID'
                 , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 , i_object_id      => a.id
              ) as acc_sub_agent_id
            , eo.id as event_object_id
            , a.id as account_id
            , a.account_number
            , eo.eff_date
         from acc_account a
            , evt_event_object eo
        where a.id = eo.object_id
          and eo.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_AMK_AGENTS_AWARDING_PKG.CALCULATE_AWARDING'
          and com_api_flexible_data_pkg.get_flexible_value (
                  i_field_name      => 'CST_ACC_AGENT_ID'
                , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                , i_object_id       => a.id
              ) = i_agent_id
     order by eo.eff_date desc;
begin
    open cu_event_objects;
    fetch cu_event_objects bulk collect into l_event_objects_tab;

    open cu_agents;
    fetch cu_agents bulk collect into l_acc_agents, l_accounts_count;
    
    for i in 1..l_acc_agents.count loop
        l_prev_amount          := 0;
            
        begin
            select a.account_number
                 , a.id
                 , a.inst_id
                 , a.currency
                 , a.customer_id
                 , a.split_hash
                 , m.id as merchant_id
              into l_agent_id
                 , l_agent_account_id
                 , l_agent_inst_id
                 , l_agent_currency
                 , l_agent_customer_id
                 , l_agent_split_hash
                 , l_merchant_id
              from acc_account a
                 , acc_account_object ao
                 , acq_merchant m
             where a.id = ao.account_id
               and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
               and ao.object_id = m.id
               and m.merchant_number = trim(l_acc_agents(i))
               and a.currency = nvl(i_dest_curr, '116')
               and ao.usage_order in (select min(aoc.usage_order)
                                        from acc_account ac
                                           , acc_account_object aoc
                                           , acq_merchant mc
                                       where ac.id = aoc.account_id
                                         and aoc.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                         and aoc.object_id = mc.id
                                         and mc.merchant_number = trim(l_acc_agents(i))
                                         and ac.currency = nvl(i_dest_curr, '116'));
                 
            select com_api_i18n_pkg.get_text(
                       i_table_name  => 'COM_COMPANY'
                     , i_column_name => 'LABEL'
                     , i_object_id   => object_id
                     , i_lang        => l_lang
                   )
              into l_agent_customer_name
              from prd_customer
             where id = l_agent_customer_id
               and entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY;
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text       => 'Agent [#1] not found'
                  , i_env_param1 => l_acc_agents(i)
                );
                l_agent_id := null;
                l_agent_account_id := null;
                l_merchant_id := null;
        end;
        l_agent_product_id     := 
            prd_api_product_pkg.get_product_id (
                i_entity_type    => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
              , i_object_id      => l_merchant_id
            );
        if l_agent_product_id is not null then
            l_agent_fee_amount := 0;
            l_prev_count := l_accounts_count(i);
            open cu_sub_agents(l_acc_agents(i));
            fetch cu_sub_agents bulk collect into l_acc_sub_agents, l_event_object_id_tab, l_account_id_tab, l_accounts_sub_agents, l_eff_date_tab;

            for j in 1..l_acc_sub_agents.count loop
                l_sub_agent_fee_amount := 0;
                if l_agent_fee_amount != l_prev_amount and l_agent_fee_amount != 0 then
                    l_prev_amount := l_agent_fee_amount;
                    l_prev_count := l_accounts_count(i)-(j-1);
                end if;

                rul_api_param_pkg.set_param(
                    i_name      => 'ACCOUNT_NUMBER'
                  , i_value     => l_accounts_sub_agents(j)
                  , io_params   => l_params
                );
                l_agent_fee_id         :=
                    prd_api_product_pkg.get_fee_id (
                        i_product_id     => l_agent_product_id
                      , i_entity_type    => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                      , i_object_id      => l_merchant_id
                      , i_fee_type       => l_agent_fee_type
                      , i_params         => l_params
                      , i_eff_date       => l_eff_date
                      , i_split_hash     => l_agent_split_hash
                      , i_inst_id        => l_agent_inst_id
                      , i_mask_error     => com_api_const_pkg.TRUE
                    );

                if l_agent_fee_id is not null then
                    l_agent_fee_amount :=
                        round(
                            fcl_api_fee_pkg.get_fee_amount (
                                i_fee_id            => l_agent_fee_id
                                , i_base_amount     => 0
                                , io_base_currency  => l_agent_currency
                                , i_entity_type     => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                , i_object_id       => l_merchant_id
                                , i_tier_count      => l_prev_count
                            )
                        );

                    if l_acc_sub_agents(j) is not null then
                        begin
                            select a.id
                                 , a.account_number
                                 , a.inst_id
                                 , a.currency
                                 , a.customer_id
                                 , a.split_hash
                              into l_sub_agent_account_id
                                 , l_sub_agent_id
                                 , l_sub_agent_inst_id
                                 , l_sub_agent_currency
                                 , l_sub_agent_customer_id
                                 , l_sub_agent_split_hash
                              from acc_account a
                                 , acc_account_object ao
                             where a.id = ao.account_id
                               and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                               and ao.object_id = iss_api_card_pkg.get_card_id(i_card_number => iss_api_token_pkg.decode_card_number(i_card_number => l_acc_sub_agents(j)));

                            select case 
                                       when entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                                       then com_ui_person_pkg.get_person_name(
                                                i_person_id   => object_id
                                              , i_lang        => l_lang
                                            )
                                       when entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY
                                       then com_api_i18n_pkg.get_text(
                                                i_table_name  => 'COM_COMPANY'
                                              , i_column_name => 'LABEL'
                                              , i_object_id   => object_id
                                              , i_lang        => l_lang
                                            )
                                       else null
                                   end
                              into l_sub_agent_customer_name
                              from prd_customer
                             where id = l_sub_agent_customer_id;
                        exception
                            when no_data_found then
                                trc_log_pkg.debug(
                                    i_text       => 'Sub-Agent [#1] not found'
                                  , i_env_param1 => l_acc_sub_agents(j)
                                );
                                l_sub_agent_id := null;
                                l_sub_agent_account_id := null;
                        end;

                        l_sub_agent_product_id  := prd_api_product_pkg.get_product_id (
                            i_entity_type  => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                            , i_object_id  => l_sub_agent_customer_id
                        );
                        rul_api_param_pkg.set_param(
                            i_name      => 'ACCOUNT_NUMBER'
                          , i_value     => l_accounts_sub_agents(j)
                          , io_params   => l_params
                        );
                        l_sub_agent_fee_id :=
                            prd_api_product_pkg.get_fee_id (
                                i_product_id     => l_sub_agent_product_id
                                , i_entity_type  => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                , i_object_id    => l_sub_agent_customer_id
                                , i_fee_type     => l_sub_agent_fee_type
                                , i_params       => l_params
                                , i_eff_date     => l_eff_date
                                , i_split_hash   => l_sub_agent_split_hash
                                , i_inst_id      => l_sub_agent_inst_id
                            );
                        if l_sub_agent_fee_id is not null then
                            l_sub_agent_fee_amount :=
                                round(
                                    fcl_api_fee_pkg.get_fee_amount (
                                        i_fee_id            => l_sub_agent_fee_id
                                        , i_base_amount     => 0
                                        , io_base_currency  => l_sub_agent_currency
                                        , i_entity_type     => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                                        , i_object_id       => l_sub_agent_customer_id
                                        , i_tier_count      => l_prev_count
                                    )
                                );
                        end if;
                    end if;
                        
                    -- Insert agent's awarding
                    insert into cst_amk_agents (
                        id
                      , split_hash
                      , agent_type
                      , agent_account_number
                      , inst_id
                      , agent_id 
                      , agent_name
                      , currency
                      , awarding_amount
                      , open_date 
                      , account_id
                    ) values (
                        cst_amk_agents_seq.nextval
                      , l_agent_split_hash
                      , 'SAP'
                      , l_agent_id
                      , l_agent_inst_id
                      , l_acc_agents(i)
                      , l_agent_customer_name
                      , l_agent_currency
                      , l_agent_fee_amount
                      , l_eff_date_tab(j)
                      , l_account_id_tab(j)
                    ); 

                    if nvl(l_sub_agent_fee_amount, 0) != 0 then
                        -- Insert sub-agent's awarding
                        insert into cst_amk_agents (
                            id
                          , split_hash
                          , agent_type
                          , agent_account_number
                          , inst_id
                          , agent_id 
                          , agent_name
                          , currency
                          , awarding_amount
                          , open_date 
                          , account_id
                        ) values (
                            cst_amk_agents_seq.nextval
                          , l_sub_agent_split_hash
                          , 'SSAP'
                          , l_sub_agent_id
                          , l_sub_agent_inst_id
                          , l_acc_sub_agents(j)
                          , l_sub_agent_customer_name
                          , l_sub_agent_currency
                          , l_sub_agent_fee_amount
                          , l_eff_date_tab(j)
                          , l_account_id_tab(j)
                        ); 
                    end if;
                end if;
            end loop; 
            close cu_sub_agents;
        end if;
    end loop;
    
    close cu_agents;
    
    evt_api_event_pkg.process_event_object(
        i_event_object_id_tab    => l_event_objects_tab
    );
    
    close cu_event_objects;
    
end calculate_awarding;

procedure calculate_pilot_bonus(
    i_dest_curr         in     com_api_type_pkg.t_curr_code      default '116'
) is
    l_start_date              date;
    l_end_date                date;
    l_eff_date                date := com_api_sttl_day_pkg.get_sysdate;
    l_agent_fee_type          com_api_type_pkg.t_dict_value := 'FETP5111';
    l_sub_agent_fee_type      com_api_type_pkg.t_dict_value := 'FETP5113';
    l_agent_cycle_type        com_api_type_pkg.t_dict_value := 'CYTP5111';
    l_sub_agent_cycle_type    com_api_type_pkg.t_dict_value := 'CYTP5113';
    l_agent_id                com_api_type_pkg.t_account_number;
    l_sub_agent_id            com_api_type_pkg.t_account_number;
    l_agent_account_id        com_api_type_pkg.t_account_id;
    l_sub_agent_account_id    com_api_type_pkg.t_account_id;
    l_agent_inst_id           com_api_type_pkg.t_inst_id;
    l_sub_agent_inst_id       com_api_type_pkg.t_inst_id;
    l_agent_currency          com_api_type_pkg.t_curr_code;
    l_sub_agent_currency      com_api_type_pkg.t_curr_code;
    l_agent_product_id        com_api_type_pkg.t_short_id;
    l_sub_agent_product_id    com_api_type_pkg.t_short_id;
    l_agent_fee_id            com_api_type_pkg.t_short_id;
    l_sub_agent_fee_id        com_api_type_pkg.t_short_id;
    l_agent_fee_amount        com_api_type_pkg.t_money;
    l_sub_agent_fee_amount    com_api_type_pkg.t_money;
    l_agent_cycle_id          com_api_type_pkg.t_short_id;          
    l_sub_agent_cycle_id      com_api_type_pkg.t_short_id;
    l_agent_customer_name     com_api_type_pkg.t_name;
    l_sub_agent_customer_name com_api_type_pkg.t_name;
    l_agent_split_hash        com_api_type_pkg.t_tiny_id;
    l_sub_agent_split_hash    com_api_type_pkg.t_tiny_id;
    l_accounts_count          com_api_type_pkg.t_medium_id;
    l_aval_balance            com_api_type_pkg.t_money;
    l_agent_customer_id       com_api_type_pkg.t_medium_id;

    l_merchant_id_tab         com_api_type_pkg.t_short_tab;
    l_merchant_number_tab     com_api_type_pkg.t_merchant_number_tab;
    l_customer_id_tab         com_api_type_pkg.t_medium_tab;
    l_card_number_tab         com_api_type_pkg.t_card_number_tab;
    l_params                  com_api_type_pkg.t_param_tab;
    l_event_object_id_tab     com_api_type_pkg.t_number_tab;

    l_lang                    com_api_type_pkg.t_dict_value := com_ui_user_env_pkg.get_user_lang();

    cursor cu_agents is
        select m.id
             , m.merchant_number
             , eo.id
          from acq_merchant m
             , evt_event_object eo
         where m.id = eo.object_id
           and eo.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
           and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_AMK_AGENTS_AWARDING_PKG.CALCULATE_PILOT_BONUS';

    cursor cu_agents_accounts(i_merchant_number in com_api_type_pkg.t_merchant_number) is
        select count(a.id) as accounts
             , nvl(sum(
                       case
                           when a.currency = nvl(i_dest_curr, '116')
                           then acc_api_balance_pkg.get_aval_balance_amount_only(i_account_id => a.id)
                           else com_api_rate_pkg.convert_amount(
                                    acc_api_balance_pkg.get_aval_balance_amount_only(i_account_id => a.id)
                                  , a.currency
                                  , nvl(i_dest_curr, '116')
                                  , 'RTTPCUST'
                                  , a.inst_id
                                  , l_eff_date)
                       end
                   ), 0) balance
          from acc_account a
             , acc_balance b
         where a.id = b.account_id
           and b.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
           and b.open_date between l_start_date and l_end_date
           and com_api_flexible_data_pkg.get_flexible_value (
                   i_field_name    => 'CST_ACC_AGENT_ID'
                 , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 , i_object_id     => a.id
               ) = i_merchant_number;

    cursor cu_sub_agents is
        select c.id
             , fd.card_number
             , eo.id
          from prd_customer c
             , evt_event_object eo
             , iss_card ic
             , (select fd.field_value as card_number
                     , row_number() over (partition by fd.field_value order by fd.id) as rn
                  from com_flexible_field ff
                     , com_flexible_data fd
                 where ff.name = 'CST_ACC_SUB_AGENT_ID'
                   and ff.id = fd.field_id
                   and ff.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
               ) fd
         where ic.customer_id = c.id
           and ic.id = iss_api_card_pkg.get_card_id(i_card_number => iss_api_token_pkg.decode_card_number(i_card_number => fd.card_number))
           and fd.rn = 1
           and c.id = eo.object_id
           and eo.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
           and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_AMK_AGENTS_AWARDING_PKG.CALCULATE_PILOT_BONUS';

    cursor cu_sub_agents_accounts(i_card_number in com_api_type_pkg.t_card_number) is
        select count(a.id) as accounts
             , nvl(sum(
                       case
                           when a.currency = nvl(i_dest_curr, '116')
                           then acc_api_balance_pkg.get_aval_balance_amount_only(i_account_id => a.id)
                           else com_api_rate_pkg.convert_amount(
                                    acc_api_balance_pkg.get_aval_balance_amount_only(i_account_id => a.id)
                                  , a.currency
                                  , nvl(i_dest_curr, '116')
                                  , 'RTTPCUST'
                                  , a.inst_id
                                  , l_eff_date)
                       end
                   ), 0) balance
          from acc_account a
             , acc_balance b
         where a.id = b.account_id
           and b.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
           and b.open_date between l_start_date and l_end_date
           and com_api_flexible_data_pkg.get_flexible_value (
                   i_field_name    => 'CST_ACC_SUB_AGENT_ID'
                 , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 , i_object_id     => a.id
               ) = i_card_number;
begin
    open cu_agents;
    fetch cu_agents bulk collect into l_merchant_id_tab, l_merchant_number_tab, l_event_object_id_tab;

    for i in 1..l_merchant_id_tab.count loop
        begin
            select a.account_number
                 , a.id
                 , a.inst_id
                 , a.currency
                 , a.customer_id
                 , a.split_hash
              into l_agent_id
                 , l_agent_account_id
                 , l_agent_inst_id
                 , l_agent_currency
                 , l_agent_customer_id
                 , l_agent_split_hash
              from acc_account a
                 , acc_account_object ao
             where a.id = ao.account_id
               and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
               and ao.object_id = l_merchant_id_tab(i)
               and a.currency = nvl(i_dest_curr, '116')
               and ao.usage_order in (select min(aoc.usage_order)
                                        from acc_account ac
                                           , acc_account_object aoc
                                           , acq_merchant mc
                                       where ac.id = aoc.account_id
                                         and aoc.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                         and aoc.object_id = l_merchant_id_tab(i)
                                         and ac.currency = nvl(i_dest_curr, '116'));
                 
            select com_api_i18n_pkg.get_text(
                       i_table_name  => 'COM_COMPANY'
                     , i_column_name => 'LABEL'
                     , i_object_id   => object_id
                     , i_lang        => l_lang
                   )
              into l_agent_customer_name
              from prd_customer
             where id = l_agent_customer_id
               and entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY;
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text       => 'Agent [#1] not found'
                  , i_env_param1 => l_merchant_number_tab(i)
                );
                l_agent_id := null;
                l_agent_account_id := null;
        end;
        l_agent_product_id     := 
            prd_api_product_pkg.get_product_id (
                i_entity_type    => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
              , i_object_id      => l_merchant_id_tab(i)
            );

        if l_agent_product_id is not null then
            fcl_api_cycle_pkg.get_cycle_date(
                i_cycle_type         => l_agent_cycle_type
              , i_entity_type        => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
              , i_object_id          => l_merchant_id_tab(i)
              , i_split_hash         => l_agent_split_hash
              , i_add_counter        => com_api_type_pkg.FALSE
              , o_prev_date          => l_start_date
              , o_next_date          => l_end_date
            );
            
            l_end_date             := trunc(l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
            
            l_agent_cycle_id       :=
                prd_api_product_pkg.get_cycle_id (
                    i_product_id     => l_agent_product_id
                  , i_entity_type    => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                  , i_object_id      => l_merchant_id_tab(i)
                  , i_cycle_type     => l_agent_cycle_type
                  , i_params         => l_params
                );

            fcl_api_cycle_pkg.calc_next_date(
                i_cycle_id             => l_agent_cycle_id
              , i_start_date           => l_start_date
              , i_forward              => com_api_type_pkg.FALSE
              , o_next_date            => l_start_date
              , i_cycle_calc_date_type => null
            );
            
            open cu_agents_accounts(l_merchant_number_tab(i));
            fetch cu_agents_accounts into l_accounts_count, l_aval_balance;
            
            l_agent_fee_id         :=
                prd_api_product_pkg.get_fee_id (
                    i_product_id     => l_agent_product_id
                  , i_entity_type    => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                  , i_object_id      => l_merchant_id_tab(i)
                  , i_fee_type       => l_agent_fee_type
                  , i_params         => l_params
                  , i_eff_date       => l_eff_date
                  , i_split_hash     => l_agent_split_hash
                  , i_inst_id        => l_agent_inst_id
                  , i_mask_error     => com_api_const_pkg.TRUE
                );
            if l_agent_fee_id is not null then
                l_agent_fee_amount :=
                    round(
                        fcl_api_fee_pkg.get_fee_amount (
                            i_fee_id            => l_agent_fee_id
                            , i_base_amount     => 0
                            , io_base_currency  => l_agent_currency
                            , i_entity_type     => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                            , i_object_id       => l_merchant_id_tab(i)
                            , i_tier_amount     => l_aval_balance
                            , i_tier_count      => l_accounts_count
                        )
                    );
                -- Insert agent's pilot bonus
                insert into cst_amk_agents (
                    id
                  , split_hash
                  , agent_type
                  , agent_account_number
                  , inst_id
                  , agent_id 
                  , agent_name
                  , currency
                  , awarding_amount
                  , open_date 
                  , account_id
                  , accounts_count
                  , accounts_balances
                  , bonus
                ) values (
                    cst_amk_agents_seq.nextval
                  , l_agent_split_hash
                  , 'SAP'
                  , l_agent_id
                  , l_agent_inst_id
                  , l_merchant_id_tab(i)
                  , l_agent_customer_name
                  , l_agent_currency
                  , null
                  , l_eff_date
                  , null
                  , l_accounts_count
                  , l_aval_balance
                  , l_agent_fee_amount
                ); 
            end if;
            close cu_agents_accounts;
        end if;
    end loop;

    evt_api_event_pkg.process_event_object(
        i_event_object_id_tab    => l_event_object_id_tab
    );
    close cu_agents;

    open cu_sub_agents;
    fetch cu_sub_agents bulk collect into l_customer_id_tab, l_card_number_tab, l_event_object_id_tab;

    for i in 1..l_customer_id_tab.count loop
        begin
            select a.id
                 , a.account_number
                 , a.inst_id
                 , a.currency
                 , a.split_hash
              into l_sub_agent_account_id
                 , l_sub_agent_id
                 , l_sub_agent_inst_id
                 , l_sub_agent_currency
                 , l_sub_agent_split_hash
              from acc_account a
                 , acc_account_object ao
             where a.id = ao.account_id
               and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and ao.object_id = iss_api_card_pkg.get_card_id(i_card_number => iss_api_token_pkg.decode_card_number(i_card_number => l_card_number_tab(i)));

            select com_ui_person_pkg.get_person_name
                       (i_person_id   => object_id
                      , i_lang        => l_lang)
              into l_sub_agent_customer_name
              from prd_customer
             where id = l_customer_id_tab(i)
               and entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON;
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text       => 'Sub-Agent [#1] not found'
                  , i_env_param1 => l_customer_id_tab(i)
                );
                l_sub_agent_id := null;
                l_sub_agent_account_id := null;
        end;
        l_sub_agent_product_id  := prd_api_product_pkg.get_product_id (
            i_entity_type  => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
            , i_object_id  => l_customer_id_tab(i)
        );

        if l_sub_agent_product_id is not null then
            fcl_api_cycle_pkg.get_cycle_date(
                i_cycle_type         => l_sub_agent_cycle_type
              , i_entity_type        => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
              , i_object_id          => l_customer_id_tab(i)
              , i_split_hash         => l_sub_agent_split_hash
              , i_add_counter        => com_api_type_pkg.FALSE
              , o_prev_date          => l_start_date
              , o_next_date          => l_end_date
            );

            l_end_date             := trunc(l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
            
            l_sub_agent_cycle_id       :=
                prd_api_product_pkg.get_cycle_id (
                    i_product_id     => l_sub_agent_product_id
                  , i_entity_type    => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                  , i_object_id      => l_customer_id_tab(i)
                  , i_cycle_type     => l_sub_agent_cycle_type
                  , i_params         => l_params
                );

            fcl_api_cycle_pkg.calc_next_date(
                i_cycle_id             => l_sub_agent_cycle_id
              , i_start_date           => l_start_date
              , i_forward              => com_api_type_pkg.FALSE
              , o_next_date            => l_start_date
              , i_cycle_calc_date_type => null
            );
            
            open cu_sub_agents_accounts(l_card_number_tab(i));
            fetch cu_sub_agents_accounts into l_accounts_count, l_aval_balance;
            
            l_sub_agent_fee_id     :=
                prd_api_product_pkg.get_fee_id (
                    i_product_id     => l_sub_agent_product_id
                  , i_entity_type    => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                  , i_object_id      => l_customer_id_tab(i)
                  , i_fee_type       => l_sub_agent_fee_type
                  , i_params         => l_params
                  , i_eff_date       => l_eff_date
                  , i_split_hash     => l_sub_agent_split_hash
                  , i_inst_id        => l_sub_agent_inst_id
                  , i_mask_error     => com_api_const_pkg.TRUE
                );

            if l_sub_agent_fee_id is not null then
                l_sub_agent_fee_amount :=
                    round(
                        fcl_api_fee_pkg.get_fee_amount (
                            i_fee_id            => l_sub_agent_fee_id
                            , i_base_amount     => 0
                            , io_base_currency  => l_sub_agent_currency
                            , i_entity_type     => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                            , i_object_id       => l_customer_id_tab(i)
                            , i_tier_amount     => l_aval_balance
                            , i_tier_count      => l_accounts_count
                        )
                    );
                -- Insert sub-agent's pilot bonus
                insert into cst_amk_agents (
                    id
                  , split_hash
                  , agent_type
                  , agent_account_number
                  , inst_id
                  , agent_id 
                  , agent_name
                  , currency
                  , awarding_amount
                  , open_date 
                  , account_id
                  , accounts_count
                  , accounts_balances
                  , bonus
                ) values (
                    cst_amk_agents_seq.nextval
                  , l_sub_agent_split_hash
                  , 'SSAP'
                  , l_sub_agent_id
                  , l_sub_agent_inst_id
                  , l_customer_id_tab(i)
                  , l_sub_agent_customer_name
                  , l_sub_agent_currency
                  , null
                  , l_eff_date
                  , null
                  , l_accounts_count
                  , l_aval_balance
                  , l_sub_agent_fee_amount
                ); 
            end if;
            close cu_sub_agents_accounts;
        end if;
    end loop;

    evt_api_event_pkg.process_event_object(
        i_event_object_id_tab    => l_event_object_id_tab
    );
    close cu_sub_agents;

end calculate_pilot_bonus;

procedure calculate_periodic_bonus(
    i_dest_curr         in     com_api_type_pkg.t_curr_code      default '116'
) is
    l_start_date              date;
    l_end_date                date;
    l_eff_date                date := com_api_sttl_day_pkg.get_sysdate;
    l_agent_fee_type          com_api_type_pkg.t_dict_value := 'FETP5112';
    l_sub_agent_fee_type      com_api_type_pkg.t_dict_value := 'FETP5114';
    l_agent_cycle_type        com_api_type_pkg.t_dict_value := 'CYTP5112';
    l_sub_agent_cycle_type    com_api_type_pkg.t_dict_value := 'CYTP5114';
    l_agent_id                com_api_type_pkg.t_account_number;
    l_sub_agent_id            com_api_type_pkg.t_account_number;
    l_agent_account_id        com_api_type_pkg.t_account_id;
    l_sub_agent_account_id    com_api_type_pkg.t_account_id;
    l_agent_inst_id           com_api_type_pkg.t_inst_id;
    l_sub_agent_inst_id       com_api_type_pkg.t_inst_id;
    l_agent_currency          com_api_type_pkg.t_curr_code;
    l_sub_agent_currency      com_api_type_pkg.t_curr_code;
    l_agent_product_id        com_api_type_pkg.t_short_id;
    l_sub_agent_product_id    com_api_type_pkg.t_short_id;
    l_agent_fee_id            com_api_type_pkg.t_short_id;
    l_sub_agent_fee_id        com_api_type_pkg.t_short_id;
    l_agent_fee_amount        com_api_type_pkg.t_money;
    l_sub_agent_fee_amount    com_api_type_pkg.t_money;
    l_agent_cycle_id          com_api_type_pkg.t_short_id;          
    l_sub_agent_cycle_id      com_api_type_pkg.t_short_id;
    l_agent_customer_name     com_api_type_pkg.t_name;
    l_sub_agent_customer_name com_api_type_pkg.t_name;
    l_agent_split_hash        com_api_type_pkg.t_tiny_id;
    l_sub_agent_split_hash    com_api_type_pkg.t_tiny_id;
    l_aval_balance            com_api_type_pkg.t_money;
    l_agent_customer_id       com_api_type_pkg.t_medium_id;

    l_merchant_id_tab         com_api_type_pkg.t_short_tab;
    l_merchant_number_tab     com_api_type_pkg.t_merchant_number_tab;
    l_customer_id_tab         com_api_type_pkg.t_medium_tab;
    l_card_number_tab         com_api_type_pkg.t_card_number_tab;
    l_params                  com_api_type_pkg.t_param_tab;
    l_event_object_id_tab     com_api_type_pkg.t_number_tab;

    l_lang                    com_api_type_pkg.t_dict_value := com_ui_user_env_pkg.get_user_lang();

    cursor cu_agents is
        select m.id
             , m.merchant_number
             , eo.id
          from acq_merchant m
             , evt_event_object eo
         where m.id = eo.object_id
           and eo.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
           and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_AMK_AGENTS_AWARDING_PKG.CALCULATE_PERIODIC_BONUS';

    cursor cu_agents_accounts(i_merchant_number in com_api_type_pkg.t_merchant_number) is
        select nvl(sum(
                       case
                           when a.currency = nvl(i_dest_curr, '116')
                           then acc_api_balance_pkg.get_aval_balance_amount_only(i_account_id => a.id)
                           else com_api_rate_pkg.convert_amount(
                                    acc_api_balance_pkg.get_aval_balance_amount_only(i_account_id => a.id)
                                  , a.currency
                                  , nvl(i_dest_curr, '116')
                                  , 'RTTPCUST'
                                  , a.inst_id
                                  , l_eff_date)
                       end
                   ), 0) balance
          from acc_account a
             , acc_balance b
         where a.id = b.account_id
           and b.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
           and b.open_date between l_start_date and l_end_date
           and com_api_flexible_data_pkg.get_flexible_value (
                   i_field_name    => 'CST_ACC_AGENT_ID'
                 , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 , i_object_id     => a.id
               ) = i_merchant_number;

    cursor cu_sub_agents is
        select c.id
             , fd.card_number
             , eo.id
          from prd_customer c
             , evt_event_object eo
             , iss_card ic
             , (select fd.field_value as card_number
                     , row_number() over (partition by fd.field_value order by fd.id) as rn
                  from com_flexible_field ff
                     , com_flexible_data fd
                 where ff.name = 'CST_ACC_SUB_AGENT_ID'
                   and ff.id = fd.field_id
                   and ff.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
               ) fd
         where ic.customer_id = c.id
           and ic.id = iss_api_card_pkg.get_card_id(i_card_number => iss_api_token_pkg.decode_card_number(i_card_number => fd.card_number))
           and fd.rn = 1
           and c.id = eo.object_id
           and eo.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
           and decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'CST_AMK_AGENTS_AWARDING_PKG.CALCULATE_PERIODIC_BONUS';

    cursor cu_sub_agents_accounts(i_card_number in com_api_type_pkg.t_card_number) is
        select nvl(sum(
                       case
                           when a.currency = nvl(i_dest_curr, '116')
                           then acc_api_balance_pkg.get_aval_balance_amount_only(i_account_id => a.id)
                           else com_api_rate_pkg.convert_amount(
                                    acc_api_balance_pkg.get_aval_balance_amount_only(i_account_id => a.id)
                                  , a.currency
                                  , nvl(i_dest_curr, '116')
                                  , 'RTTPCUST'
                                  , a.inst_id
                                  , l_eff_date)
                       end
                   ), 0) balance
          from acc_account a
             , acc_balance b
         where a.id = b.account_id
           and b.balance_type = acc_api_const_pkg.BALANCE_TYPE_LEDGER
           and b.open_date between l_start_date and l_end_date
           and com_api_flexible_data_pkg.get_flexible_value (
                   i_field_name    => 'CST_ACC_SUB_AGENT_ID'
                 , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                 , i_object_id     => a.id
               ) = i_card_number;
begin
    open cu_agents;
    fetch cu_agents bulk collect into l_merchant_id_tab, l_merchant_number_tab, l_event_object_id_tab;

    for i in 1..l_merchant_id_tab.count loop
        begin
            select a.account_number
                 , a.id
                 , a.inst_id
                 , a.currency
                 , a.customer_id
                 , a.split_hash
              into l_agent_id
                 , l_agent_account_id
                 , l_agent_inst_id
                 , l_agent_currency
                 , l_agent_customer_id
                 , l_agent_split_hash
              from acc_account a
                 , acc_account_object ao
             where a.id = ao.account_id
               and ao.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
               and ao.object_id = l_merchant_id_tab(i)
               and a.currency = nvl(i_dest_curr, '116')
               and ao.usage_order in (select min(aoc.usage_order)
                                        from acc_account ac
                                           , acc_account_object aoc
                                           , acq_merchant mc
                                       where ac.id = aoc.account_id
                                         and aoc.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                         and aoc.object_id = l_merchant_id_tab(i)
                                         and ac.currency = nvl(i_dest_curr, '116'));
                 
            select com_api_i18n_pkg.get_text(
                       i_table_name  => 'COM_COMPANY'
                     , i_column_name => 'LABEL'
                     , i_object_id   => object_id
                     , i_lang        => l_lang
                   )
              into l_agent_customer_name
              from prd_customer
             where id = l_agent_customer_id
               and entity_type = com_api_const_pkg.ENTITY_TYPE_COMPANY;
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text       => 'Agent [#1] not found'
                  , i_env_param1 => l_merchant_number_tab(i)
                );
                l_agent_id := null;
                l_agent_account_id := null;
        end;
        l_agent_product_id     := 
            prd_api_product_pkg.get_product_id (
                i_entity_type    => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
              , i_object_id      => l_merchant_id_tab(i)
            );

        if l_agent_product_id is not null then
            fcl_api_cycle_pkg.get_cycle_date(
                i_cycle_type         => l_agent_cycle_type
              , i_entity_type        => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
              , i_object_id          => l_merchant_id_tab(i)
              , i_split_hash         => l_agent_split_hash
              , i_add_counter        => com_api_type_pkg.FALSE
              , o_prev_date          => l_start_date
              , o_next_date          => l_end_date
            );
            
            l_end_date             := trunc(l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
            
            l_agent_cycle_id       :=
                prd_api_product_pkg.get_cycle_id (
                    i_product_id     => l_agent_product_id
                  , i_entity_type    => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                  , i_object_id      => l_merchant_id_tab(i)
                  , i_cycle_type     => l_agent_cycle_type
                  , i_params         => l_params
                );

            fcl_api_cycle_pkg.calc_next_date(
                i_cycle_id             => l_agent_cycle_id
              , i_start_date           => l_start_date
              , i_forward              => com_api_type_pkg.FALSE
              , o_next_date            => l_start_date
              , i_cycle_calc_date_type => null
            );
            
            open cu_agents_accounts(l_merchant_number_tab(i));
            fetch cu_agents_accounts into l_aval_balance;
            
            l_agent_fee_id         :=
                prd_api_product_pkg.get_fee_id (
                    i_product_id     => l_agent_product_id
                  , i_entity_type    => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                  , i_object_id      => l_merchant_id_tab(i)
                  , i_fee_type       => l_agent_fee_type
                  , i_params         => l_params
                  , i_eff_date       => l_eff_date
                  , i_split_hash     => l_agent_split_hash
                  , i_inst_id        => l_agent_inst_id
                  , i_mask_error     => com_api_const_pkg.TRUE
                );
            if l_agent_fee_id is not null then
                l_agent_fee_amount :=
                    round(
                        fcl_api_fee_pkg.get_fee_amount (
                            i_fee_id            => l_agent_fee_id
                            , i_base_amount     => 0
                            , io_base_currency  => l_agent_currency
                            , i_entity_type     => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                            , i_object_id       => l_merchant_id_tab(i)
                            , i_tier_amount     => l_aval_balance
                        )
                    );
                -- Insert agent's periodic bonus
                insert into cst_amk_agents (
                    id
                  , split_hash
                  , agent_type
                  , agent_account_number
                  , inst_id
                  , agent_id 
                  , agent_name
                  , currency
                  , awarding_amount
                  , open_date 
                  , account_id
                  , accounts_count
                  , accounts_balances
                  , bonus
                ) values (
                    cst_amk_agents_seq.nextval
                  , l_agent_split_hash
                  , 'SAP'
                  , l_agent_id
                  , l_agent_inst_id
                  , l_merchant_id_tab(i)
                  , l_agent_customer_name
                  , l_agent_currency
                  , null
                  , l_eff_date
                  , null
                  , null
                  , l_aval_balance
                  , l_agent_fee_amount
                ); 
            end if;
            close cu_agents_accounts;
        end if;
    end loop;

    evt_api_event_pkg.process_event_object(
        i_event_object_id_tab    => l_event_object_id_tab
    );
    close cu_agents;

    open cu_sub_agents;
    fetch cu_sub_agents bulk collect into l_customer_id_tab, l_card_number_tab, l_event_object_id_tab;

    for i in 1..l_customer_id_tab.count loop
        begin
            select a.id
                 , a.account_number
                 , a.inst_id
                 , a.currency
                 , a.split_hash
              into l_sub_agent_account_id
                 , l_sub_agent_id
                 , l_sub_agent_inst_id
                 , l_sub_agent_currency
                 , l_sub_agent_split_hash
              from acc_account a
                 , acc_account_object ao
             where a.id = ao.account_id
               and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and ao.object_id = iss_api_card_pkg.get_card_id(i_card_number => iss_api_token_pkg.decode_card_number(i_card_number => l_card_number_tab(i)));

            select com_ui_person_pkg.get_person_name
                       (i_person_id   => object_id
                      , i_lang        => l_lang)
              into l_sub_agent_customer_name
              from prd_customer
             where id = l_customer_id_tab(i)
               and entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON;
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text       => 'Sub-Agent [#1] not found'
                  , i_env_param1 => l_customer_id_tab(i)
                );
                l_sub_agent_id := null;
                l_sub_agent_account_id := null;
        end;
        l_sub_agent_product_id  := prd_api_product_pkg.get_product_id (
            i_entity_type  => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
            , i_object_id  => l_customer_id_tab(i)
        );

        if l_sub_agent_product_id is not null then
            fcl_api_cycle_pkg.get_cycle_date(
                i_cycle_type         => l_sub_agent_cycle_type
              , i_entity_type        => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
              , i_object_id          => l_customer_id_tab(i)
              , i_split_hash         => l_sub_agent_split_hash
              , i_add_counter        => com_api_type_pkg.FALSE
              , o_prev_date          => l_start_date
              , o_next_date          => l_end_date
            );

            l_end_date             := trunc(l_start_date) + 1 - com_api_const_pkg.ONE_SECOND;
            
            l_sub_agent_cycle_id       :=
                prd_api_product_pkg.get_cycle_id (
                    i_product_id     => l_sub_agent_product_id
                  , i_entity_type    => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                  , i_object_id      => l_customer_id_tab(i)
                  , i_cycle_type     => l_sub_agent_cycle_type
                  , i_params         => l_params
                );

            fcl_api_cycle_pkg.calc_next_date(
                i_cycle_id             => l_sub_agent_cycle_id
              , i_start_date           => l_start_date
              , i_forward              => com_api_type_pkg.FALSE
              , o_next_date            => l_start_date
              , i_cycle_calc_date_type => null
            );
            
            open cu_sub_agents_accounts(l_card_number_tab(i));
            fetch cu_sub_agents_accounts into l_aval_balance;
            
            l_sub_agent_fee_id     :=
                prd_api_product_pkg.get_fee_id (
                    i_product_id     => l_sub_agent_product_id
                  , i_entity_type    => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                  , i_object_id      => l_customer_id_tab(i)
                  , i_fee_type       => l_sub_agent_fee_type
                  , i_params         => l_params
                  , i_eff_date       => l_eff_date
                  , i_split_hash     => l_sub_agent_split_hash
                  , i_inst_id        => l_sub_agent_inst_id
                  , i_mask_error     => com_api_const_pkg.TRUE
                );

            if l_sub_agent_fee_id is not null then
                l_sub_agent_fee_amount :=
                    round(
                        fcl_api_fee_pkg.get_fee_amount (
                            i_fee_id            => l_sub_agent_fee_id
                            , i_base_amount     => 0
                            , io_base_currency  => l_sub_agent_currency
                            , i_entity_type     => com_api_const_pkg.ENTITY_TYPE_CUSTOMER
                            , i_object_id       => l_customer_id_tab(i)
                            , i_tier_amount     => l_aval_balance
                        )
                    );
                -- Insert sub-agent's periodic bonus
                insert into cst_amk_agents (
                    id
                  , split_hash
                  , agent_type
                  , agent_account_number
                  , inst_id
                  , agent_id 
                  , agent_name
                  , currency
                  , awarding_amount
                  , open_date 
                  , account_id
                  , accounts_count
                  , accounts_balances
                  , bonus
                ) values (
                    cst_amk_agents_seq.nextval
                  , l_sub_agent_split_hash
                  , 'SSAP'
                  , l_sub_agent_id
                  , l_sub_agent_inst_id
                  , l_customer_id_tab(i)
                  , l_sub_agent_customer_name
                  , l_sub_agent_currency
                  , null
                  , l_eff_date
                  , null
                  , null
                  , l_aval_balance
                  , l_sub_agent_fee_amount
                ); 
            end if;
            close cu_sub_agents_accounts;
        end if;
    end loop;

    evt_api_event_pkg.process_event_object(
        i_event_object_id_tab    => l_event_object_id_tab
    );
    close cu_sub_agents;

end calculate_periodic_bonus;

end;
/
