create or replace package body cst_bmed_crd_prc_billing_pkg as

function get_fee_amount(
    i_fee_type         com_api_type_pkg.t_dict_value
  , i_amount           com_api_type_pkg.t_money
  , i_account          acc_api_type_pkg.t_account_rec
  , i_product_id       com_api_type_pkg.t_short_id
  , i_service_id       com_api_type_pkg.t_short_id
  , i_param_tab        com_api_type_pkg.t_param_tab
  , i_eff_date         date
) return com_api_type_pkg.t_money is
    l_fee_id           com_api_type_pkg.t_short_id;
    l_fee_amount       com_api_type_pkg.t_money := 0;
    l_account          acc_api_type_pkg.t_account_rec;
begin
    trc_log_pkg.debug(
        i_text       => 'searching fee [' || i_fee_type || ']'
    );
    l_account := i_account;
        
    l_fee_id :=
        prd_api_product_pkg.get_fee_id(
            i_product_id    => i_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => l_account.account_id
          , i_fee_type      => i_fee_type
          , i_split_hash    => l_account.split_hash
          , i_service_id    => i_service_id
          , i_params        => i_param_tab
          , i_eff_date      => i_eff_date
          , i_inst_id       => l_account.inst_id
          , i_mask_error    => com_api_const_pkg.TRUE
        );
        
    if l_fee_id is not null then
        l_fee_amount :=
            fcl_api_fee_pkg.get_fee_amount(
                i_fee_id          => l_fee_id
              , i_base_amount     => i_amount
              , io_base_currency  => l_account.currency
              , i_entity_type     => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id       => l_account.account_id
              , i_eff_date        => i_eff_date
              , i_split_hash      => l_account.split_hash
            );
            
        trc_log_pkg.debug(
            i_text       => 'l_fee_amount [' || l_fee_amount || ']'
        );
    end if;
        
    return round(l_fee_amount, 4);
exception
    when com_api_error_pkg.e_application_error then
        return 0;
end;

procedure charge_subsidy(
    i_account_id             com_api_type_pkg.t_medium_id
  , i_eff_date               date
  , i_split_hash             com_api_type_pkg.t_tiny_id
) is
    l_service_id             com_api_type_pkg.t_short_id;
    l_param_tab              com_api_type_pkg.t_param_tab;
    l_from_id                com_api_type_pkg.t_long_id;
    l_till_id                com_api_type_pkg.t_long_id;
    l_product_id             com_api_type_pkg.t_long_id;
    l_interest_amount        com_api_type_pkg.t_money;

    l_merchant_fee_amount    com_api_type_pkg.t_money;
    l_bank_fee_amount        com_api_type_pkg.t_money;
    
    l_merchant_money_tab     com_api_type_pkg.t_money_tab;
    
    l_idx                    com_api_type_pkg.t_medium_id;
    
    l_bank_money             com_api_type_pkg.t_money := 0;
    l_lang                   com_api_type_pkg.t_dict_value;
    l_account                acc_api_type_pkg.t_account_rec;
    
    procedure add_merchant_amount(
        i_merchant_id        com_api_type_pkg.t_long_id
      , i_amount             com_api_type_pkg.t_money
    ) is
    begin
        if l_merchant_money_tab.exists(i_merchant_id) then
            l_merchant_money_tab(i_merchant_id) := l_merchant_money_tab(i_merchant_id) + i_amount;
        else
            l_merchant_money_tab(i_merchant_id) := i_amount;
        end if;
    end;
    
    procedure create_operation(
        i_amount                 com_api_type_pkg.t_money
      , i_fee_type               com_api_type_pkg.t_dict_value
      , i_merchant_id            com_api_type_pkg.t_long_id    default null
    ) is
        l_oper_id                com_api_type_pkg.t_long_id;
        l_merchant_street        com_api_type_pkg.t_name;
        l_merchant_city          com_api_type_pkg.t_name;
        l_merchant_country       com_api_type_pkg.t_country_code;
        l_merchant_postcode      com_api_type_pkg.t_postal_code;
        l_address_id             com_api_type_pkg.t_long_id;
        l_merchant_name          com_api_type_pkg.t_name;
        l_merchant_number        com_api_type_pkg.t_merchant_number;
        l_acq_split_hash         com_api_type_pkg.t_tiny_id;
        l_acq_inst_id            com_api_type_pkg.t_inst_id;
    begin
        if i_merchant_id is not null then
            select m.merchant_name
                 , m.merchant_number
                 , m.split_hash
                 , m.inst_id
              into l_merchant_name
                 , l_merchant_number
                 , l_acq_split_hash
                 , l_acq_inst_id
              from acq_merchant m 
             where m.id = i_merchant_id;
              
            l_address_id := acq_api_merchant_pkg.get_merchant_address_id(i_merchant_id => i_merchant_id);
             
            for rec in (
                select a.street      as merchant_street
                     , a.city        as merchant_city
                     , a.country     as merchant_country
                     , a.postal_code as merchant_postcode
                  from com_address_vw a
                 where a.id   = l_address_id
                   and a.lang = l_lang
            )
            loop
                l_merchant_street   := rec.merchant_street;
                l_merchant_city     := rec.merchant_city;
                l_merchant_country  := rec.merchant_country;
                l_merchant_postcode := rec.merchant_postcode;
            end loop;
        end if;
    
        opr_api_create_pkg.create_operation(
            io_oper_id            => l_oper_id
          , i_status              => opr_api_const_pkg.OPERATION_STATUS_PROCESS_READY
          , i_sttl_type           => opr_api_const_pkg.SETTLEMENT_INTERNAL
          , i_msg_type            => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
          , i_oper_type           => opr_api_const_pkg.OPERATION_TYPE_PAYMENT
          , i_oper_amount         => i_amount
          , i_oper_currency       => l_account.currency
          , i_oper_request_amount => i_amount
          , i_is_reversal         => com_api_const_pkg.FALSE
          , i_oper_date           => i_eff_date
          , i_host_date           => i_eff_date
          , i_merchant_number     => l_merchant_number
          , i_merchant_name       => l_merchant_name
          , i_merchant_street     => l_merchant_street
          , i_merchant_city       => l_merchant_city
          , i_merchant_country    => l_merchant_country
          , i_merchant_postcode   => l_merchant_postcode
          , i_oper_reason         => i_fee_type
        );
        
        opr_api_create_pkg.add_participant(
            i_oper_id             => l_oper_id
          , i_msg_type            => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
          , i_oper_type           => opr_api_const_pkg.OPERATION_TYPE_PAYMENT
          , i_participant_type    => com_api_const_pkg.PARTICIPANT_ISSUER
          , i_host_date           => i_eff_date
          , i_account_id          => l_account.account_id
          , i_account_number      => l_account.account_number
          , i_account_currency    => l_account.currency
          , i_account_type        => l_account.account_type
          , i_without_checks      => com_api_const_pkg.TRUE
          , i_inst_id             => l_account.inst_id
          , i_network_id          => ost_api_institution_pkg.get_inst_network(i_inst_id => l_account.inst_id)
        );
        
        if i_merchant_id is not null then 
            opr_api_create_pkg.add_participant(
                i_oper_id             => l_oper_id
              , i_msg_type            => opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
              , i_oper_type           => opr_api_const_pkg.OPERATION_TYPE_PAYMENT
              , i_participant_type    => com_api_const_pkg.PARTICIPANT_ACQUIRER
              , i_host_date           => i_eff_date
              , i_merchant_id         => i_merchant_id
              , i_merchant_number     => l_merchant_number
              , i_without_checks      => com_api_const_pkg.TRUE
              , i_inst_id             => l_acq_inst_id
              , i_network_id          => ost_api_institution_pkg.get_inst_network(i_inst_id => l_acq_inst_id)
            );
        end if;
    end;
begin
    trc_log_pkg.debug('charge_interest: i_account_id [' || i_account_id || '] i_eff_date [' || to_char(i_eff_date, 'dd.mm.yyyy hh24:mi:ss') || ']');

    acc_api_account_pkg.get_account_info(
        i_account_id          => i_account_id
      , o_account_rec         => l_account
      , i_mask_error          => com_api_type_pkg.FALSE
    );
    
    l_lang := com_ui_user_env_pkg.get_user_lang;

    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => null
          , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
          , i_split_hash        => l_account.split_hash
          , i_eff_date          => i_eff_date
          , i_inst_id           => l_account.inst_id
        );

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => l_account.account_id
        );
    
    for p in (
        select d.id debt_id
             , d.inst_id
             , d.oper_id
             , p.merchant_id
          from crd_debt d
             , opr_participant p
         where decode(d.status, 'DBTSACTV', d.account_id, null) = i_account_id
           and d.split_hash       = i_split_hash
           and d.oper_id          = p.oper_id
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
           and p.merchant_id is not null
    )
    loop
        l_from_id      := com_api_id_pkg.get_from_id_num(p.debt_id);
        l_till_id      := com_api_id_pkg.get_till_id_num(p.debt_id);
        
        select nvl(sum(i.interest_amount),0)
          into l_interest_amount
          from crd_debt_interest i
         where i.debt_id          = p.debt_id
           and i.split_hash       = i_split_hash
           and i.is_charged       = com_api_const_pkg.TRUE
           and i.invoice_id is null
           and i.interest_amount > 0
           and i.id between l_from_id and l_till_id;
           

        trc_log_pkg.debug(
            i_text       => 'charging subsidy for debt [' || p.debt_id || '], interest_amount [' || l_interest_amount || ']'
        );
        
        if l_interest_amount = 0 then
            continue;
        end if;
        
        crd_debt_pkg.load_debt_param(
            i_debt_id           => p.debt_id
          , i_split_hash        => i_split_hash
          , io_param_tab        => l_param_tab
        );
        
        l_merchant_fee_amount :=
            get_fee_amount(
                i_fee_type         => cst_bmed_crd_api_const_pkg.MERCHANT_SUBSIDY_FEE_TYPE
              , i_amount           => l_interest_amount
              , i_account          => l_account
              , i_product_id       => l_product_id
              , i_service_id       => l_service_id
              , i_param_tab        => l_param_tab
              , i_eff_date         => i_eff_date
            );
        
        if l_merchant_fee_amount > 0 then
            add_merchant_amount(
                i_merchant_id        => p.merchant_id
              , i_amount             => l_merchant_fee_amount
            );
        end if;
        
        l_bank_fee_amount :=
            get_fee_amount(
                i_fee_type         => cst_bmed_crd_api_const_pkg.BANK_SUBSIDY_FEE_TYPE
              , i_amount           => l_interest_amount
              , i_account          => l_account
              , i_product_id       => l_product_id
              , i_service_id       => l_service_id
              , i_param_tab        => l_param_tab
              , i_eff_date         => i_eff_date
            );

        l_bank_money := l_bank_money + l_bank_fee_amount;
    end loop;
    
    -- create operation for each merchant
    if l_merchant_money_tab.count > 0 then
        l_idx := l_merchant_money_tab.first;
        while l_idx is not null
        loop
            create_operation(
                i_amount      => l_merchant_money_tab(l_idx)
              , i_fee_type    => cst_bmed_crd_api_const_pkg.MERCHANT_SUBSIDY_FEE_TYPE
              , i_merchant_id => l_idx
            );
            l_idx := l_merchant_money_tab.next(l_idx);
        end loop;
    end if;
    
    if l_bank_money > 0 then
        create_operation(
            i_amount      => l_bank_money
          , i_fee_type    => cst_bmed_crd_api_const_pkg.BANK_SUBSIDY_FEE_TYPE
        );
    end if;
end;

procedure process_subsidy(
    i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_cycle_date_type  in     com_api_type_pkg.t_dict_value    default fcl_api_const_pkg.DATE_TYPE_SYSTEM_DATE
) is
    DEFAULT_BULK_LIMIT   constant com_api_type_pkg.t_count := 2000;
    l_sysdate                     date;

    cursor cu_events_count is
        select count(1)
          from evt_event_object o
             , evt_event e
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_BMED_CRD_PRC_BILLING_PKG.PROCESS_SUBSIDY'
           and o.eff_date      <= l_sysdate
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and e.id             = o.event_id
           and (
                o.inst_id = i_inst_id
                or
                i_inst_id is null
                or
                i_inst_id = ost_api_const_pkg.DEFAULT_INST
               );

    cursor cu_events is
        select o.id
             , e.event_type
             , o.entity_type
             , o.object_id
             , o.eff_date
             , o.split_hash
          from evt_event_object o
             , evt_event e
             , evt_subscriber s
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_BMED_CRD_PRC_BILLING_PKG.PROCESS_SUBSIDY'
           and o.eff_date      <= l_sysdate
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and e.id             = o.event_id
           and (
                o.inst_id = i_inst_id
                or
                i_inst_id is null
                or
                i_inst_id = ost_api_const_pkg.DEFAULT_INST
               )
           and e.event_type     = s.event_type
           and o.procedure_name = s.procedure_name
         order by o.eff_date, s.priority;


    l_record_count      com_api_type_pkg.t_count := 0;
    l_excepted_count    com_api_type_pkg.t_count := 0;
    l_event_id_tab      com_api_type_pkg.t_number_tab;
    l_event_type_tab    com_api_type_pkg.t_dict_tab;
    l_entity_type_tab   com_api_type_pkg.t_dict_tab;
    l_object_id_tab     com_api_type_pkg.t_number_tab;
    l_eff_date_tab      com_api_type_pkg.t_date_tab;
    l_split_hash_tab    com_api_type_pkg.t_number_tab;
    l_processed_tab     com_api_type_pkg.t_number_tab;
    l_account_id_tpt    num_tab_tpt := num_tab_tpt(); -- nested table with identifiers of excepted accounts
    l_account_id        com_api_type_pkg.t_medium_id;
begin
    l_sysdate :=
        case i_cycle_date_type
            when fcl_api_const_pkg.DATE_TYPE_SETTLEMENT_DATE
            then com_api_sttl_day_pkg.get_open_sttl_date(i_inst_id => i_inst_id)
            else com_api_sttl_day_pkg.get_sysdate()
        end;

    trc_log_pkg.debug(
        i_text       => 'Start bankmed subsidizing interests process: sysdate [#1][#2], thread_number [#3], inst_id [#4]'
      , i_env_param1 => nvl(i_cycle_date_type, fcl_api_const_pkg.DATE_TYPE_SYSTEM_DATE)
      , i_env_param2 => to_char(l_sysdate, com_api_const_pkg.DATE_FORMAT)
      , i_env_param3 => prc_api_session_pkg.get_thread_number()
      , i_env_param4 => i_inst_id
    );

    prc_api_stat_pkg.log_start;

    open cu_events_count;
    fetch cu_events_count into l_record_count;
    close cu_events_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );

    l_record_count := 0;

    open cu_events;

    loop
        fetch cu_events bulk collect into
            l_event_id_tab
          , l_event_type_tab
          , l_entity_type_tab
          , l_object_id_tab
          , l_eff_date_tab
          , l_split_hash_tab
        limit DEFAULT_BULK_LIMIT;

        begin
            savepoint sp_crd_process;

            for i in 1..l_event_type_tab.count loop

                savepoint sp_crd_record;

                trc_log_pkg.debug('Credit billing:  Event [' || l_event_id_tab(i) || '], event type [' || l_event_type_tab(i) ||
                                  '], object ID [' || l_object_id_tab(i) || '] of entity type [' || l_entity_type_tab(i) ||
                                  '], eff date [' || com_api_type_pkg.convert_to_char(l_eff_date_tab(i)) || ']');
                begin
                    l_account_id := l_object_id_tab(i);
                    if l_account_id is not null and l_account_id member of l_account_id_tpt then
                        -- If account is in this list then event's processing should be skipped,
                        -- also event isn't added to <l_processed_tab>, i.e. it isn't marked as processed
                        trc_log_pkg.debug('Event [' || l_event_id_tab(i) || '] is skipping because one of previous events for account ['
                                          || l_account_id || '] was processed with an error');
                    else
                        if l_event_type_tab(i) = crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE then
                            trc_log_pkg.debug('Charge interest subsidy');
                            
                            charge_subsidy(
                                i_account_id        => l_account_id
                              , i_eff_date          => l_eff_date_tab(i)
                              , i_split_hash        => l_split_hash_tab(i)
                            );
                        else
                            trc_log_pkg.debug('Handler for event [' || l_event_id_tab(i) || '] is NOT defined, it is marked as processed');
                        end if;

                        l_processed_tab(l_processed_tab.count + 1) := l_event_id_tab(i);
                    end if;
                exception
                    when others then
                        rollback to sp_crd_record;
                        l_excepted_count := l_excepted_count + 1;

                        if com_api_error_pkg.is_fatal_error(SQLCODE) = com_api_const_pkg.TRUE then
                            raise;
                        elsif com_api_error_pkg.is_application_error(SQLCODE) = com_api_const_pkg.FALSE then
                            com_api_error_pkg.raise_fatal_error(
                                i_error         => 'UNHANDLED_EXCEPTION'
                              , i_env_param1    => SQLERRM
                            );
                        end if;

                        -- Save the problem account to exclude all its events from processing
                        if l_account_id is not null then
                            l_account_id_tpt.extend();
                            l_account_id_tpt(l_account_id_tpt.last) := l_account_id;
                            trc_log_pkg.debug('Event [' || l_event_id_tab(i) || '] is processed with error, '
                                              || 'all events for account [' || l_account_id || '] will be skipped');
                        end if;
                end;
            end loop;

            acc_api_entry_pkg.flush_job;

            l_record_count := l_record_count + l_event_id_tab.count;

            prc_api_stat_pkg.log_current(
                i_current_count     => l_record_count
              , i_excepted_count    => l_excepted_count
            );

            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab   => l_processed_tab
            );

            commit;

            l_processed_tab.delete;

            exit when cu_events%notfound;
        exception
            when others then
                rollback to sp_crd_process;

                if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                    raise;
                else
                    com_api_error_pkg.raise_fatal_error(
                        i_error         => 'UNHANDLED_EXCEPTION'
                      , i_env_param1    => sqlerrm
                    );
                end if;
        end;
    end loop;

    close cu_events;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        if cu_events_count%isopen then
            close cu_events_count;
        end if;

        if cu_events%isopen then
            close cu_events;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end;

procedure charge_sharing(
    i_account_id          in     com_api_type_pkg.t_medium_id
  , i_eff_date            in     date
  , i_split_hash          in     com_api_type_pkg.t_tiny_id
  , i_mrch_bunch_type_id  in     com_api_type_pkg.t_tiny_id
  , i_bank_bunch_type_id  in     com_api_type_pkg.t_tiny_id
) is
    l_service_id            com_api_type_pkg.t_short_id;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_from_id               com_api_type_pkg.t_long_id;
    l_till_id               com_api_type_pkg.t_long_id;
    l_product_id            com_api_type_pkg.t_long_id;
    l_interest_amount       com_api_type_pkg.t_money;

    l_merchant_fee_amount   com_api_type_pkg.t_money;
    l_bank_fee_amount       com_api_type_pkg.t_money;
    
    l_account               acc_api_type_pkg.t_account_rec;
    l_merchant_account      acc_api_type_pkg.t_account_rec;
    l_invoice_rec           crd_api_type_pkg.t_invoice_rec;
    l_bunch_id              com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug('charge_sharing: i_account_id ['||i_account_id||'] i_eff_date ['||to_char(i_eff_date, 'dd.mm.yyyy hh24:mi:ss')||']');

    acc_api_account_pkg.get_account_info(
        i_account_id          => i_account_id
      , o_account_rec         => l_account
      , i_mask_error          => com_api_type_pkg.FALSE
    );

    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => null
          , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
          , i_split_hash        => l_account.split_hash
          , i_eff_date          => i_eff_date
          , i_inst_id           => l_account.inst_id
        );

    l_product_id :=
        prd_api_product_pkg.get_product_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => l_account.account_id
        );
        
    l_invoice_rec := 
        crd_invoice_pkg.get_last_invoice(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => l_account.account_id
          , i_split_hash        => l_account.split_hash
          , i_mask_error        => com_api_const_pkg.TRUE
        );
        
    for p in (
        select d.id debt_id
             , d.inst_id
             , d.oper_id
             , p.merchant_id
          from crd_debt d
             , opr_participant p
         where decode(d.status, 'DBTSACTV', d.account_id, null) = i_account_id
           and d.split_hash       = i_split_hash
           and d.oper_id          = p.oper_id
           and p.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
           and p.merchant_id is not null
    )
    loop
        l_from_id      := com_api_id_pkg.get_from_id_num(p.debt_id);
        l_till_id      := com_api_id_pkg.get_till_id_num(p.debt_id);
        
        select nvl(sum(i.interest_amount),0)
          into l_interest_amount
          from crd_debt_interest i
         where i.debt_id          = p.debt_id
           and i.split_hash       = i_split_hash
           and i.is_charged       = com_api_const_pkg.TRUE
           and i.invoice_id       = l_invoice_rec.id
           and i.interest_amount > 0
           and i.id between l_from_id and l_till_id;
           
        trc_log_pkg.debug(
            i_text       => 'Interest sharing for debt [' || p.debt_id || '], interest_amount [' || l_interest_amount || ']'
        );
        
        if l_interest_amount = 0 then
            continue;
        end if;
        
        crd_debt_pkg.load_debt_param(
            i_debt_id           => p.debt_id
          , i_split_hash        => i_split_hash
          , io_param_tab        => l_param_tab
        );
        
        l_merchant_fee_amount :=
            get_fee_amount(
                i_fee_type         => cst_bmed_crd_api_const_pkg.MERCHANT_INTEREST_FEE_TYPE
              , i_amount           => l_interest_amount
              , i_account          => l_account
              , i_product_id       => l_product_id
              , i_service_id       => l_service_id
              , i_param_tab        => l_param_tab
              , i_eff_date         => i_eff_date
            );
        
        if l_merchant_fee_amount > 0 then
            acc_api_account_pkg.get_account_info(
                i_account_id          => acq_api_merchant_pkg.get_merchant_account_id(i_merchant_id => p.merchant_id)
              , o_account_rec         => l_merchant_account
              , i_mask_error          => com_api_type_pkg.FALSE
            );
            
            acc_api_entry_pkg.put_bunch (
                o_bunch_id          => l_bunch_id
              , i_bunch_type_id     => i_mrch_bunch_type_id
              , i_macros_id         => p.debt_id
              , i_amount            => l_merchant_fee_amount
              , i_currency          => l_merchant_account.currency
              , i_account_type      => l_merchant_account.account_type
              , i_account_id        => l_merchant_account.account_id
              , i_posting_date      => i_eff_date
              , i_param_tab         => l_param_tab 
            );
        end if;
        
        l_bank_fee_amount :=
            get_fee_amount(
                i_fee_type         => cst_bmed_crd_api_const_pkg.BANK_INTEREST_FEE_TYPE
              , i_amount           => l_interest_amount
              , i_account          => l_account
              , i_product_id       => l_product_id
              , i_service_id       => l_service_id
              , i_param_tab        => l_param_tab
              , i_eff_date         => i_eff_date
            );
        
        if l_bank_fee_amount > 0 then
            acc_api_entry_pkg.put_bunch (
                o_bunch_id          => l_bunch_id
              , i_bunch_type_id     => i_bank_bunch_type_id
              , i_macros_id         => p.debt_id
              , i_amount            => l_bank_fee_amount
              , i_currency          => l_account.currency
              , i_account_type      => l_account.account_type
              , i_account_id        => l_account.account_id
              , i_posting_date      => i_eff_date
              , i_param_tab         => l_param_tab 
            );
        end if;
    end loop;
end;

procedure process_sharing(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_mrch_bunch_type_id  in     com_api_type_pkg.t_tiny_id
  , i_bank_bunch_type_id  in     com_api_type_pkg.t_tiny_id
) is
    DEFAULT_BULK_LIMIT   constant com_api_type_pkg.t_count := 2000;
    l_sysdate                     date;

    cursor cu_events_count is
        select count(1)
          from evt_event_object o
             , evt_event e
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_BMED_CRD_PRC_BILLING_PKG.PROCESS_SHARING'
           and o.eff_date      <= l_sysdate
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and e.id             = o.event_id
           and (
                o.inst_id = i_inst_id
                or
                i_inst_id is null
                or
                i_inst_id = ost_api_const_pkg.DEFAULT_INST
               );

    cursor cu_events is
        select o.id
             , e.event_type
             , o.entity_type
             , o.object_id
             , o.eff_date
             , o.split_hash
          from evt_event_object o
             , evt_event e
             , evt_subscriber s
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_BMED_CRD_PRC_BILLING_PKG.PROCESS_SHARING'
           and o.eff_date      <= l_sysdate
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and e.id             = o.event_id
           and (
                o.inst_id = i_inst_id
                or
                i_inst_id is null
                or
                i_inst_id = ost_api_const_pkg.DEFAULT_INST
               )
           and e.event_type     = s.event_type
           and o.procedure_name = s.procedure_name
         order by o.eff_date, s.priority;


    l_record_count      com_api_type_pkg.t_count := 0;
    l_excepted_count    com_api_type_pkg.t_count := 0;
    l_event_id_tab      com_api_type_pkg.t_number_tab;
    l_event_type_tab    com_api_type_pkg.t_dict_tab;
    l_entity_type_tab   com_api_type_pkg.t_dict_tab;
    l_object_id_tab     com_api_type_pkg.t_number_tab;
    l_eff_date_tab      com_api_type_pkg.t_date_tab;
    l_split_hash_tab    com_api_type_pkg.t_number_tab;
    l_processed_tab     com_api_type_pkg.t_number_tab;
    l_account_id_tpt    num_tab_tpt := num_tab_tpt(); -- nested table with identifiers of excepted accounts
    l_account_id        com_api_type_pkg.t_medium_id;
begin
    l_sysdate := com_api_sttl_day_pkg.get_sysdate();

    trc_log_pkg.debug(
        i_text       => 'Start bankmed interest sharing process: sysdate [#2], thread_number [#3], inst_id [#4]'
      , i_env_param2 => to_char(l_sysdate, com_api_const_pkg.DATE_FORMAT)
      , i_env_param3 => prc_api_session_pkg.get_thread_number()
      , i_env_param4 => i_inst_id
    );

    prc_api_stat_pkg.log_start;

    open cu_events_count;
    fetch cu_events_count into l_record_count;
    close cu_events_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );

    l_record_count := 0;

    open cu_events;

    loop
        fetch cu_events bulk collect into
            l_event_id_tab
          , l_event_type_tab
          , l_entity_type_tab
          , l_object_id_tab
          , l_eff_date_tab
          , l_split_hash_tab
        limit DEFAULT_BULK_LIMIT;

        begin
            savepoint sp_crd_process;

            for i in 1..l_event_type_tab.count loop

                savepoint sp_crd_record;

                trc_log_pkg.debug('Credit billing: Event [' || l_event_id_tab(i) || '], event type [' || l_event_type_tab(i) ||
                                  '], object ID [' || l_object_id_tab(i) || '] of entity type [' || l_entity_type_tab(i) ||
                                  '], eff date [' || com_api_type_pkg.convert_to_char(l_eff_date_tab(i)) || ']');
                begin
                    l_account_id := l_object_id_tab(i);
                    if l_account_id is not null and l_account_id member of l_account_id_tpt then
                        -- If account is in this list then event's processing should be skipped,
                        -- also event isn't added to <l_processed_tab>, i.e. it isn't marked as processed
                        trc_log_pkg.debug('Event [' || l_event_id_tab(i) || '] is skipping because one of previous events for account ['
                                          || l_account_id || '] was processed with an error');
                    else
                        if l_event_type_tab(i) = crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE then
                            trc_log_pkg.debug('Charge interest subsidy');

                            charge_sharing(
                                i_account_id           => l_account_id
                              , i_eff_date             => l_eff_date_tab(i)
                              , i_split_hash           => l_split_hash_tab(i)
                              , i_mrch_bunch_type_id   => i_mrch_bunch_type_id
                              , i_bank_bunch_type_id   => i_bank_bunch_type_id
                            );
                        else
                            trc_log_pkg.debug('Handler for event [' || l_event_id_tab(i) || '] is NOT defined, it is marked as processed');
                        end if;

                        l_processed_tab(l_processed_tab.count + 1) := l_event_id_tab(i);
                    end if;
                exception
                    when others then
                        rollback to sp_crd_record;
                        l_excepted_count := l_excepted_count + 1;

                        if com_api_error_pkg.is_fatal_error(SQLCODE) = com_api_const_pkg.TRUE then
                            raise;
                        elsif com_api_error_pkg.is_application_error(SQLCODE) = com_api_const_pkg.FALSE then
                            com_api_error_pkg.raise_fatal_error(
                                i_error         => 'UNHANDLED_EXCEPTION'
                              , i_env_param1    => SQLERRM
                            );
                        end if;

                        -- Save the problem account to exclude all its events from processing
                        if l_account_id is not null then
                            l_account_id_tpt.extend();
                            l_account_id_tpt(l_account_id_tpt.last) := l_account_id;
                            trc_log_pkg.debug('Event [' || l_event_id_tab(i) || '] is processed with error, '
                                              || 'all events for account [' || l_account_id || '] will be skipped');
                        end if;
                end;
            end loop;

            acc_api_entry_pkg.flush_job;

            l_record_count := l_record_count + l_event_id_tab.count;

            prc_api_stat_pkg.log_current(
                i_current_count     => l_record_count
              , i_excepted_count    => l_excepted_count
            );

            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab   => l_processed_tab
            );

            commit;

            l_processed_tab.delete;

            exit when cu_events%notfound;
        exception
            when others then
                rollback to sp_crd_process;

                if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                    raise;
                else
                    com_api_error_pkg.raise_fatal_error(
                        i_error         => 'UNHANDLED_EXCEPTION'
                      , i_env_param1    => sqlerrm
                    );
                end if;
        end;
    end loop;

    close cu_events;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        if cu_events_count%isopen then
            close cu_events_count;
        end if;

        if cu_events%isopen then
            close cu_events;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
end;

end;
/
