create or replace package body cst_icc_prc_billing_pkg as

LEGAL_INTEREST_CHARGING             constant com_api_type_pkg.t_dict_value := 'EVNT5033';
FLAT_INTEREST_LEGAL_INTEREST        constant com_api_type_pkg.t_dict_value := 'ACIL5001';
CRD_LEGAL_INTEREST_RATE             constant com_api_type_pkg.t_dict_value := 'FETP5004';


procedure charge_legal(
    i_account_id        in      com_api_type_pkg.t_long_id
  , i_eff_date          in      date
  , i_period_date       in      date                                default null
  , i_split_hash        in      com_api_type_pkg.t_tiny_id          default null
) is
    l_interest_amount   com_api_type_pkg.t_money;
    l_total_amount      com_api_type_pkg.t_money    := 0;
    l_bunch_id          com_api_type_pkg.t_long_id;
    l_bunch_type_id     com_api_type_pkg.t_tiny_id;
    l_eff_date          date;
    l_currency          com_api_type_pkg.t_curr_code;
    l_service_id        com_api_type_pkg.t_short_id;
    l_param_tab         com_api_type_pkg.t_param_tab;
    l_account_number    com_api_type_pkg.t_account_number;
    l_macros_type_id    com_api_type_pkg.t_tiny_id;
    l_from_id           com_api_type_pkg.t_long_id;
    l_till_id           com_api_type_pkg.t_long_id;
    l_alg_calc_intr     com_api_type_pkg.t_dict_value;
    l_product_id        com_api_type_pkg.t_long_id;
    l_charge_needed     com_api_type_pkg.t_boolean;    
    l_inst_id           com_api_type_pkg.t_inst_id;

    l_fee_id            com_api_type_pkg.t_short_id;
    l_invoice_id        com_api_type_pkg.t_medium_id;
    l_aging_period      com_api_type_pkg.t_tiny_id;
    l_percent_rate      com_api_type_pkg.t_money     := 0;
begin

    trc_log_pkg.debug('charge_interest: i_account_id ['||i_account_id||'] i_eff_date ['||to_char(i_eff_date, 'dd.mm.yyyy hh24:mi:ss')||'] i_period_date ['||to_char(i_period_date, 'dd.mm.yyyy hh24:mi:ss')||']');

    begin
        select inst_id
          into l_inst_id
          from acc_account
         where id = i_account_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'ACCOUNT_NOT_FOUND'
                , i_env_param1  => i_account_id
            );
    end;
    
    l_eff_date := nvl(i_period_date, i_eff_date);

    -- get last invoice
    l_invoice_id := crd_invoice_pkg.get_last_invoice_id(
        i_account_id        => i_account_id
      , i_split_hash        => i_split_hash
      , i_mask_error        => com_api_const_pkg.FALSE
    );

    select aging_period
      into l_aging_period
      from crd_invoice 
     where id = l_invoice_id;

    trc_log_pkg.debug('l_aging_period= ' || l_aging_period);

    rul_api_param_pkg.set_param(
        i_value         => l_aging_period
      , i_name          => 'AGING_PERIOD'
      , io_params       => l_param_tab
    );
      
    l_service_id :=
        prd_api_service_pkg.get_active_service_id(
            i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id         => i_account_id
          , i_attr_name         => null
          , i_service_type_id   => crd_api_const_pkg.CREDIT_SERVICE_TYPE_ID
          , i_split_hash        => i_split_hash
          , i_eff_date          => i_eff_date
          , i_inst_id           => l_inst_id
        );

    l_product_id := prd_api_product_pkg.get_product_id(
        i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_object_id         => i_account_id
    );       

    l_fee_id :=
        prd_api_product_pkg.get_fee_id (
            i_product_id    => l_product_id
          , i_entity_type   => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
          , i_object_id     => i_account_id
          , i_fee_type      => cst_icc_prc_billing_pkg.CRD_LEGAL_INTEREST_RATE
          , i_split_hash    => i_split_hash
          , i_service_id    => l_service_id
          , i_params        => l_param_tab
          , i_eff_date      => l_eff_date
          , i_inst_id       => l_inst_id
        );

    trc_log_pkg.debug('Get l_fee_id= ' || l_fee_id);        
    
    -- get algorithm ACIL
    l_alg_calc_intr := cst_icc_prc_billing_pkg.FLAT_INTEREST_LEGAL_INTEREST;
    trc_log_pkg.debug('l_alg_calc_intr= ' || l_alg_calc_intr);        
    
    begin        
        select percent_rate    
          into l_percent_rate        
          from fcl_fee_tier     
         where fee_id = l_fee_id;
            
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error             => 'FEE_RATE_NOT_FOUND'
              , i_env_param1        => l_fee_id
              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
              , i_object_id         => i_account_id
            );
    end;
    trc_log_pkg.debug('l_percent_rate= ' || l_percent_rate);        
    
    for p in (
        select d.id debt_id
             , c.account_type
             , c.currency
             , c.account_number
             , c.inst_id
             , d.oper_id
          from crd_debt d
             , acc_account c
         where decode(d.status, 'DBTSACTV', d.account_id, null) = i_account_id
           and d.account_id = c.id
           and d.split_hash = i_split_hash
    ) loop
        trc_log_pkg.debug('debt_id= ' || p.debt_id);        
    
        l_charge_needed := crd_cst_interest_pkg.charge_interest_needed(
          i_debt_id         => p.debt_id
          , i_oper_id       => p.oper_id
          , i_account_id    => i_account_id
          , i_inst_id       => p.inst_id
          , i_split_hash    => i_split_hash
        );
        
        if l_charge_needed = com_api_const_pkg.FALSE then
            continue;
        end if;
        
        l_currency       := p.currency;
        l_account_number := p.account_number;
        l_from_id        := com_api_id_pkg.get_from_id_num(p.debt_id);
        l_till_id        := com_api_id_pkg.get_till_id_num(p.debt_id);

        crd_interest_pkg.set_interest(
            i_debt_id           => p.debt_id
          , i_eff_date          => l_eff_date
          , i_account_id        => i_account_id
          , i_service_id        => l_service_id
          , i_split_hash        => i_split_hash
          , i_is_forced         => com_api_const_pkg.TRUE
          , i_event_type        => cst_icc_prc_billing_pkg.LEGAL_INTEREST_CHARGING --crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE
        );

        crd_debt_pkg.load_debt_param (
            i_debt_id           => p.debt_id
          , i_split_hash        => i_split_hash
          , io_param_tab        => l_param_tab
        );

        for r in (
            select x.balance_type
                 , x.fee_id
                 , x.add_fee_id
                 , x.amount
                 , x.start_date
                 , x.end_date
                 , b.bunch_type_id
                 , x.id
                 , x.macros_type_id
                 , x.interest_amount
                 , x.debt_intr_id
                 , x.card_id
              from (
                    select a.id debt_intr_id
                         , a.balance_type
                         , a.fee_id
                         , a.add_fee_id
                         , a.amount
                         , a.balance_date start_date
                         , lead(a.balance_date) over (partition by a.balance_type order by a.posting_order, a.balance_date, a.id) end_date
                         , a.debt_id
                         , a.id
                         , d.inst_id
                         , d.macros_type_id
                         , a.interest_amount
                         , a.is_charged
                         , d.card_id
                      from crd_debt_interest a
                         , crd_debt d
                     where a.debt_id         = p.debt_id
                       and d.is_grace_enable = com_api_const_pkg.FALSE
                       and d.id              = a.debt_id
                       and a.split_hash      = i_split_hash
                       and a.id between l_from_id and l_till_id
                   ) x
                 , crd_event_bunch_type b
             where x.end_date        <= l_eff_date
               and b.event_type(+)    = cst_icc_prc_billing_pkg.LEGAL_INTEREST_CHARGING --crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE
               and x.is_charged       = com_api_const_pkg.FALSE
               and b.balance_type(+)  = x.balance_type
               and b.inst_id(+)       = x.inst_id
             order by bunch_type_id nulls first

        ) loop

            if r.bunch_type_id is not null then

                if l_bunch_type_id is null then
                    l_bunch_type_id := r.bunch_type_id;
                end if;

                l_macros_type_id := r.macros_type_id;

                if l_bunch_type_id != r.bunch_type_id then
                    
                    acc_api_entry_pkg.put_bunch (
                        o_bunch_id          => l_bunch_id
                      , i_bunch_type_id     => l_bunch_type_id
                      , i_macros_id         => p.debt_id
                      , i_amount            => round(l_total_amount)
                      , i_currency          => p.currency
                      , i_account_type      => p.account_type
                      , i_account_id        => i_account_id
                      , i_posting_date      => i_eff_date
                      , i_macros_type_id    => r.macros_type_id
                      , i_param_tab         => l_param_tab 
                    );

                    l_total_amount := 0;

                    l_bunch_type_id := r.bunch_type_id;
                end if;
                

                -- Calculate interest amount. 
                l_interest_amount := round(r.amount * l_percent_rate / 100, 4);                    
                
                l_total_amount := l_total_amount + l_interest_amount;

                trc_log_pkg.debug('Calulating interest amount base amount ['||r.amount||'] Fee Id ['||l_fee_id||'] l_interest_amount ['||l_interest_amount||']');

            else
                l_interest_amount := 0;
            end if;

            update crd_debt_interest
               set is_charged      = com_api_const_pkg.TRUE
                 , interest_amount = l_interest_amount
             where id              = r.id;
        end loop;

        if l_bunch_type_id is not null and l_total_amount > 0 then
            acc_api_entry_pkg.put_bunch (
                o_bunch_id          => l_bunch_id
              , i_bunch_type_id     => l_bunch_type_id
              , i_macros_id         => p.debt_id
              , i_amount            => l_total_amount
              , i_currency          => p.currency
              , i_account_type      => p.account_type
              , i_account_id        => i_account_id
              , i_posting_date      => i_eff_date
              , i_macros_type_id    => l_macros_type_id
              , i_param_tab         => l_param_tab 
            );
        end if;

        l_bunch_type_id := null;
        l_total_amount  := 0;

        acc_api_entry_pkg.flush_job;

        crd_debt_pkg.set_balance(
            i_debt_id           => p.debt_id
          , i_eff_date          => l_eff_date
          , i_account_id        => i_account_id
          , i_service_id        => l_service_id
          , i_inst_id           => p.inst_id
          , i_split_hash        => i_split_hash
        );

        crd_interest_pkg.set_interest(
            i_debt_id           => p.debt_id
          , i_eff_date          => l_eff_date
          , i_account_id        => i_account_id
          , i_service_id        => l_service_id
          , i_split_hash        => i_split_hash
          , i_event_type        => cst_icc_prc_billing_pkg.LEGAL_INTEREST_CHARGING --crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE
        );
        
        crd_debt_pkg.set_debt_paid(
            i_debt_id           => p.debt_id
        );

    end loop;

end;

procedure process(
    i_inst_id           in      com_api_type_pkg.t_inst_id
    , i_cycle_date_type in      com_api_type_pkg.t_dict_value    default fcl_api_const_pkg.DATE_TYPE_SYSTEM_DATE
) is
    l_sysdate           date;

    cursor cu_events_count is
        select count(1)
          from evt_event_object o
             , evt_event e
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_ICC_PRC_BILLING_PKG.PROCESS'
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
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_ICC_PRC_BILLING_PKG.PROCESS'
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
    l_prev_date         date;
    l_next_date         date;
    l_account_id_tpt    num_tab_tpt := num_tab_tpt(); -- nested table with identifiers of excepted accounts
    -- Identifier of processing account or account that is linked with some 
    -- subordinate entity object (that is depended from account, e.g. ENTTINVC)
    l_account_id        com_api_type_pkg.t_medium_id;
begin
    l_sysdate :=
        case i_cycle_date_type
            when fcl_api_const_pkg.DATE_TYPE_SETTLEMENT_DATE
            then com_api_sttl_day_pkg.get_open_sttl_date(i_inst_id => i_inst_id)
            else com_api_sttl_day_pkg.get_sysdate() -- fcl_api_const_pkg.DATE_TYPE_SYSTEM_DATE or NULL
        end;

    trc_log_pkg.debug(
        i_text       => 'Start credit billing: sysdate [#1][#2], thread_number [#3], inst_id [#4]'
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
        limit 1000;

        begin
            savepoint sp_crd_process;

            for i in 1..l_event_type_tab.count loop

                savepoint sp_crd_record;

                trc_log_pkg.debug('Credit billing: event type [' || l_event_type_tab(i) ||
                                  '], object ID [' || l_object_id_tab(i) || '] of entity type [' || l_entity_type_tab(i) ||
                                  '], eff date [' || com_api_type_pkg.convert_to_char(l_eff_date_tab(i)) || ']');
                begin
                    -- Processing account or subordinate entity object, so it is necessary to check
                    -- that account is not in the list of problem accounts <l_account_id_tpt>
                    l_account_id := l_object_id_tab(i);
                    
                    if l_account_id is not null and l_account_id member of l_account_id_tpt then
                        -- If account is in this list then event's processing should be skipped,
                        -- also event isn't added to <l_processed_tab>, i.e. it isn't marked as processed
                        trc_log_pkg.debug('Event [' || l_event_id_tab(i) || '] is skipping because one of previous events for account ['
                                          || l_account_id || '] was processed with an error');
                    else
                        if l_event_type_tab(i) = crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE then
                            trc_log_pkg.debug('Charge interest');
                                     
                            fcl_api_cycle_pkg.get_cycle_date(
                                i_cycle_type        => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
                              , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                              , i_object_id         => l_object_id_tab(i)
                              , i_split_hash        => l_split_hash_tab(i)
                              , o_prev_date         => l_prev_date
                              , o_next_date         => l_next_date
                            );
                                         
                            cst_icc_prc_billing_pkg.charge_legal(
                                i_account_id        => l_account_id 
                              , i_eff_date          => l_eff_date_tab(i)
                              , i_period_date       => l_next_date
                              , i_split_hash        => l_split_hash_tab(i)
                            );
                        else
                            trc_log_pkg.debug('Handler for event [' || l_event_id_tab(i) || '] is NOT defined, it is marked as processed');
                        end if;
                        
                        l_processed_tab(l_processed_tab.count+1) := l_event_id_tab(i);
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
        
        --rollback to sp_crd_process;
        
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
