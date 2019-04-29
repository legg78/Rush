create or replace package body crd_prc_billing_pkg as

procedure process(
    i_inst_id                     in      com_api_type_pkg.t_inst_id
  , i_cycle_date_type             in      com_api_type_pkg.t_dict_value  default fcl_api_const_pkg.DATE_TYPE_SYSTEM_DATE
  , i_calculate_apr               in      com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_detailed_entities_array_id  in      com_api_type_pkg.t_short_id    default null
) is
    l_sysdate           date;

    cursor cu_events_count is
        select count(1)
          from evt_event_object o
             , evt_event e
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CRD_PRC_BILLING_PKG.PROCESS'
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
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CRD_PRC_BILLING_PKG.PROCESS'
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
    l_param_tab         com_api_type_pkg.t_param_tab;
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

    if i_detailed_entities_array_id is not null then
       crd_debt_pkg.set_detailed_entity_types(
           i_detailed_entities_array_id => i_detailed_entities_array_id
       );
    end if;

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

                trc_log_pkg.debug(
                    i_text      => 'Credit billing: event type [#1], entity [#2][#3], eff. date [#4]'
                  , i_env_param1 => l_event_type_tab(i)
                  , i_env_param2 => l_entity_type_tab(i)
                  , i_env_param3 => l_object_id_tab(i)
                  , i_env_param4 => com_api_type_pkg.convert_to_char(l_eff_date_tab(i))
                );
                begin
                    if l_entity_type_tab(i) = com_api_const_pkg.ENTITY_TYPE_CONTRACT then
                        if l_event_type_tab(i) = prd_api_const_pkg.EVENT_PRODUCT_CHANGE then
                            trc_log_pkg.debug('Change product');

                            crd_debt_pkg.product_change(
                                i_contract_id       => l_object_id_tab(i)
                              , i_eff_date          => l_eff_date_tab(i)
                              , i_split_hash        => l_split_hash_tab(i)
                            );
                        end if;
                        l_processed_tab(l_processed_tab.count + 1) := l_event_id_tab(i);

                    elsif l_entity_type_tab(i) = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                      and l_event_type_tab(i) in (
                              prd_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_PRODUCT
                            , prd_api_const_pkg.EVENT_PRODUCT_ATTR_END_CHANGE
                          )
                    then
                        crd_interest_pkg.change_interest_rate(
                            i_product_id  => l_object_id_tab(i)
                          , i_eff_date    => l_eff_date_tab(i)
                          , i_event_type  => l_event_type_tab(i)
                        );

                        l_processed_tab(l_processed_tab.count + 1) := l_event_id_tab(i);

                    elsif l_entity_type_tab(i) = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                      and l_event_type_tab(i) in (
                              acc_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_ACCOUNT
                            , acc_api_const_pkg.EVENT_ACCOUNT_ATTR_END_CHANGE
                          )
                    then
                        crd_interest_pkg.change_interest_rate(
                            i_account_id  => l_object_id_tab(i)
                          , i_eff_date    => l_eff_date_tab(i)
                          , i_split_hash  => l_split_hash_tab(i)
                          , i_event_type  => l_event_type_tab(i)
                          , i_inst_id     => i_inst_id
                        );

                        l_processed_tab(l_processed_tab.count + 1) := l_event_id_tab(i);

                    else
                        -- Processing account or subordinate entity object, so it is necessary to check
                        -- that account is not in the list of problem accounts <l_account_id_tpt>
                        l_account_id := case l_entity_type_tab(i)
                                            when crd_api_const_pkg.ENTITY_TYPE_INVOICE then
                                                crd_invoice_pkg.get_account_id(
                                                    i_invoice_id => l_object_id_tab(i)
                                                  , i_mask_error => com_api_type_pkg.FALSE
                                                )
                                            when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
                                                l_object_id_tab(i)
                                        end;
                        if l_account_id is not null and l_account_id member of l_account_id_tpt then
                            -- If account is in this list then event's processing should be skipped,
                            -- also event isn't added to <l_processed_tab>, i.e. it isn't marked as processed
                            trc_log_pkg.debug('Event [' || l_event_id_tab(i) || '] is skipping because one of previous events for account ['
                                              || l_account_id || '] was processed with an error');
                        else
                            if l_event_type_tab(i) = crd_api_const_pkg.FORCE_INT_CHARGE_CYCLE_TYPE then
                                trc_log_pkg.debug('Charge force interest');

                                crd_interest_pkg.charge_interest(
                                    i_account_id        => l_account_id --l_object_id_tab(i)
                                  , i_eff_date          => l_eff_date_tab(i)
                                  , i_split_hash        => l_split_hash_tab(i)
                                  , i_event_type        => l_event_type_tab(i)
                                );
                            elsif l_event_type_tab(i) = crd_api_const_pkg.PERIODIC_INTEREST_CHARGE then
                                trc_log_pkg.debug('Periodic charge interest');

                                crd_interest_pkg.charge_interest(
                                    i_account_id        => l_account_id
                                  , i_eff_date          => l_eff_date_tab(i)
                                  , i_split_hash        => l_split_hash_tab(i)
                                  , i_event_type        => l_event_type_tab(i)
                                );
                            elsif l_event_type_tab(i) = crd_api_const_pkg.INTEREST_CHARGE_CYCLE_TYPE then
                                trc_log_pkg.debug('Charge interest');

                                fcl_api_cycle_pkg.get_cycle_date(
                                    i_cycle_type        => crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
                                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                  , i_object_id         => l_object_id_tab(i)
                                  , i_split_hash        => l_split_hash_tab(i)
                                  , o_prev_date         => l_prev_date
                                  , o_next_date         => l_next_date
                                );
                                crd_interest_pkg.charge_interest(
                                    i_account_id        => l_account_id
                                  , i_eff_date          => l_eff_date_tab(i)
                                  , i_period_date       => l_next_date
                                  , i_split_hash        => l_split_hash_tab(i)
                                );
                            elsif l_event_type_tab(i) = crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE then
                                crd_invoice_pkg.create_invoice(
                                    i_account_id        => l_account_id
                                  , i_eff_date          => l_eff_date_tab(i)
                                  , i_split_hash        => l_split_hash_tab(i)
                                  , i_calculate_apr     => i_calculate_apr
                                );
                                crd_payment_pkg.apply_payments(
                                    i_account_id        => l_account_id
                                  , i_eff_date          => l_eff_date_tab(i)
                                  , i_split_hash        => l_split_hash_tab(i)
                                );
                            elsif l_event_type_tab(i) = crd_api_const_pkg.GRACE_PERIOD_CYCLE_TYPE then
                                crd_interest_pkg.grace_period(
                                    i_invoice_id        => l_object_id_tab(i)
                                  , i_eff_date          => l_eff_date_tab(i)
                                  , i_split_hash        => l_split_hash_tab(i)
                                );
                            elsif l_event_type_tab(i) = crd_api_const_pkg.DUE_DATE_CYCLE_TYPE then
                                null;
                            elsif l_event_type_tab(i) = crd_api_const_pkg.OVERDUE_DATE_CYCLE_TYPE then
                                crd_overdue_pkg.check_overdue(
                                    i_account_id        => l_account_id
                                  , i_eff_date          => l_eff_date_tab(i)
                                  , i_split_hash        => l_split_hash_tab(i)
                                );
                            elsif l_event_type_tab(i) = crd_api_const_pkg.PENALTY_PERIOD_CYCLE_TYPE then
                                crd_overdue_pkg.collect_penalty(
                                    i_account_id        => l_account_id
                                  , i_eff_date          => l_eff_date_tab(i)
                                  , i_split_hash        => l_split_hash_tab(i)
                                );
                            elsif l_event_type_tab(i) = crd_api_const_pkg.WAIVE_INTEREST_CYCLE_TYPE then
                                crd_interest_pkg.waive_interest(
                                    i_account_id        => l_account_id
                                  , i_eff_date          => l_eff_date_tab(i)
                                  , i_split_hash        => l_split_hash_tab(i)
                                );
                            elsif l_event_type_tab(i) = crd_api_const_pkg.ZERO_PERIOD_CYCLE then
                                -- Registering Aging events history
                                evt_api_event_pkg.register_event(
                                    i_event_type        => crd_api_const_pkg.AGING_0_EVENT -- EVNT1030
                                  , i_eff_date          => l_eff_date_tab(i)
                                  , i_entity_type       => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                  , i_object_id         => l_account_id
                                  , i_inst_id           => i_inst_id
                                  , i_split_hash        => l_split_hash_tab(i)
                                  , i_param_tab         => l_param_tab
                                );
                            elsif l_event_type_tab(i) = crd_api_const_pkg.INCREASE_CREDIT_LIMIT_PERIOD then
                                crd_overdue_pkg.reduce_credit_limit(
                                    i_account_id        => l_account_id
                                  , i_eff_date          => l_eff_date_tab(i)
                                  , i_shift_fee_date    => 1
                                );
                            elsif l_event_type_tab(i) = crd_api_const_pkg.AGING_PERIOD_CYCLE_TYPE then
                                crd_invoice_pkg.switch_aging_cycle(
                                    i_account_id        => l_account_id
                                  , i_eff_date          => l_eff_date_tab(i)
                                  , i_split_hash        => l_split_hash_tab(i)
                                );
                            elsif l_event_type_tab(i) = crd_api_const_pkg.PROMOTIONAL_PERIOD_CYCLE_TYPE then
                                crd_interest_pkg.interest_change(
                                    i_account_id        => l_account_id
                                  , i_eff_date          => l_eff_date_tab(i)
                                  , i_split_hash        => l_split_hash_tab(i)
                                );
                            else
                                trc_log_pkg.debug('Handler for event [' || l_event_id_tab(i) || '] is NOT defined, it is marked as processed');
                            end if;

                            l_processed_tab(l_processed_tab.count + 1) := l_event_id_tab(i);
                        end if;
                    end if;
                exception
                    when others then
                        rollback to sp_crd_record;
                        l_excepted_count := l_excepted_count + 1;

                        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                            raise;
                        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                            com_api_error_pkg.raise_fatal_error(
                                i_error         => 'UNHANDLED_EXCEPTION'
                              , i_env_param1    => sqlerrm
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
end process;

procedure process_interest_posting(
    i_inst_id                     in     com_api_type_pkg.t_dict_value
  , i_eff_date                    in     date                            default null
  , i_truncation_type             in     com_api_type_pkg.t_dict_value
  , i_in_due_macros_type          in     com_api_type_pkg.t_tiny_id
  , i_overdue_macros_type         in     com_api_type_pkg.t_tiny_id
  , i_start_date                  in     date                            default null
  , i_end_date                    in     date                            default null
) is
    BULK_LIMIT             constant simple_integer       := 2000;

    type t_event_rec is record (
        event_object_id    com_api_type_pkg.t_long_id
      , gl_account_id      com_api_type_pkg.t_account_id
      , entity_type        com_api_type_pkg.t_dict_value
      , object_id          com_api_type_pkg.t_long_id
      , macros_type_id     com_api_type_pkg.t_tiny_id
      , amount             com_api_type_pkg.t_money
      , currency           com_api_type_pkg.t_curr_code
      , account_type       com_api_type_pkg.t_dict_value
    );
    type t_event_tab is table of t_event_rec index by binary_integer;

    l_event_tab            t_event_tab;

    l_estimated_count      com_api_type_pkg.t_count := 0;
    l_processed_count      com_api_type_pkg.t_count := 0;
    l_excepted_count       com_api_type_pkg.t_count := 0;
    l_param_tab            com_api_type_pkg.t_param_tab;
    l_macros_id            com_api_type_pkg.t_long_id;
    l_bunch_id             com_api_type_pkg.t_long_id;
    l_eff_date             date;
    l_start_date           date;
    l_end_date             date;
    l_from_id              com_api_type_pkg.t_long_id;
    l_till_id              com_api_type_pkg.t_long_id;
    l_start_posting_date   date;
    l_end_posting_date     date;

    l_prev_event           t_event_rec;
    l_total_amount         com_api_type_pkg.t_money;
    l_event_object_id_tab  com_api_type_pkg.t_number_tab;

    cursor evt_object_cur is
        select o.id   as event_object_id
             , gl.id  as gl_account_id
             , m.entity_type
             , m.object_id
             , ae.macros_type_id
             , (ae.balance_impact * ae.amount) as amount
             , gl.currency
             , gl.account_type
          from evt_event_object o
             , evt_event e
             , (
                   select entr.account_id
                        , entr.macros_id
                        , entr.balance_type
                        , entr.status
                        , entr.balance_impact
                        , entr.amount
                        , entr.currency
                        , entr.posting_date
                        , decode(
                              entr.balance_type
                            , crd_api_const_pkg.BALANCE_TYPE_INTEREST,         i_in_due_macros_type
                            , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST, i_overdue_macros_type
                          ) as macros_type_id
                     from acc_entry entr
               ) ae
             , acc_macros m
             , acc_entry_tpl t
             , acc_gl_account_mvw gl
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CRD_PRC_BILLING_PKG.PROCESS_INTEREST_POSTING'
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and o.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and i_inst_id       in (o.inst_id, ost_api_const_pkg.DEFAULT_INST)
           and e.id             = o.event_id
           and e.event_type     = crd_api_const_pkg.INVOICING_PERIOD_CYCLE_TYPE
           and ae.account_id    = o.object_id
           and ae.balance_type in (crd_api_const_pkg.BALANCE_TYPE_INTEREST
                                 , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST)
           and ae.posting_date    between l_start_posting_date and l_end_posting_date
           and ae.status        = acc_api_const_pkg.ENTRY_STATUS_POSTED
           and m.id             = ae.macros_id
           and t.bunch_type_id  = ae.macros_type_id
           and gl.account_type  = t.dest_account_type
           and not exists (select 1
                             from acc_entry x
                            where x.account_id   = ae.account_id
                              and x.balance_type = ae.balance_type
                              and x.currency     = ae.currency
                              and x.status       = acc_api_const_pkg.ENTRY_STATUS_POSTED
                              and x.posting_date between l_start_posting_date and l_end_posting_date
                          )
         order by
               gl.id           -- Correct sorting is needed for calculate "sum(amount)"
             , m.entity_type
             , m.object_id
             , ae.macros_type_id;

    procedure put_macros is
    begin
        if l_prev_event.gl_account_id is not null then
            acc_api_entry_pkg.put_macros(
                o_macros_id        => l_macros_id
              , o_bunch_id         => l_bunch_id
              , i_entity_type      => l_prev_event.entity_type
              , i_object_id        => l_prev_event.object_id
              , i_macros_type_id   => l_prev_event.macros_type_id
              , i_amount           => l_prev_event.amount
              , i_currency         => l_prev_event.currency
              , i_account_type     => l_prev_event.account_type
              , i_account_id       => l_prev_event.gl_account_id
              , i_posting_date     => l_eff_date
              , i_amount_name      => com_api_const_pkg.AMOUNT_PURPOSE_MACROS
              , i_account_name     => com_api_const_pkg.ACCOUNT_PURPOSE_MACROS 
              , i_date_name        => acc_api_const_pkg.DEFAULT_DATE_NAME
              , i_amount_purpose   => com_api_const_pkg.AMOUNT_PURPOSE_MACROS
              , i_fee_id           => null
              , i_fee_tier_id      => null
              , i_fee_mod_id       => null
              , i_details_data     => null
              , i_conversion_rate  => null
              , i_param_tab        => l_param_tab
            );
        end if;
    end put_macros;

begin
    savepoint sp_process;

    prc_api_stat_pkg.log_start;
    prc_api_stat_pkg.log_estimation(i_estimated_count => 0);

    l_processed_count    := 0;
    l_excepted_count     := 0;

    if i_truncation_type = crd_api_const_pkg.TRUNCATION_TYPE_MONHTLY then

        l_eff_date           := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id);
        l_start_posting_date := add_months(trunc(l_eff_date, 'MM'), -1);
        l_end_posting_date   := trunc(l_eff_date) + 1 - com_api_const_pkg.ONE_SECOND;

        open evt_object_cur;

        loop
            savepoint sp_crd_process;

            begin
                fetch evt_object_cur
                    bulk collect into l_event_tab
                    limit BULK_LIMIT;

                l_estimated_count := l_estimated_count + l_event_tab.count;

                prc_api_stat_pkg.log_estimation(i_estimated_count => l_estimated_count);

                trc_log_pkg.debug(i_text  => 'Estimated count = ' || l_estimated_count);

                l_event_object_id_tab.delete;

                for i in 1 .. l_event_tab.count loop

                    savepoint sp_crd_record;

                    begin
                        l_event_object_id_tab(i) := l_event_tab(i).event_object_id;

                        if l_prev_event.gl_account_id      = l_event_tab(i).gl_account_id
                           and l_prev_event.entity_type    = l_event_tab(i).entity_type
                           and l_prev_event.object_id      = l_event_tab(i).object_id
                           and l_prev_event.macros_type_id = l_event_tab(i).macros_type_id
                        then
                            -- Calculate "sum(amount)"
                            l_total_amount := l_total_amount + l_event_tab(i).amount;
                        else
                            -- It is not first record
                            put_macros;

                            -- Save previous key values
                            l_prev_event   := l_event_tab(i);
                            l_total_amount := l_event_tab(i).amount;
                        end if;

                        l_processed_count := l_processed_count + 1;

                        if mod(l_processed_count, 100) = 0 then
                            prc_api_stat_pkg.log_current(
                                i_current_count  => l_processed_count
                              , i_excepted_count => l_excepted_count
                            );
                        end if;

                    exception
                        when others then
                            rollback to sp_crd_record;

                            l_excepted_count := l_excepted_count + 1;

                            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                                raise;
                            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                                com_api_error_pkg.raise_fatal_error(
                                    i_error         => 'UNHANDLED_EXCEPTION'
                                  , i_env_param1    => sqlerrm
                                );
                            end if;

                            trc_log_pkg.debug(
                                i_text       => 'Event_object_id [#1], error [#2]'
                              , i_env_param1 => l_event_tab(i).event_object_id
                              , i_env_param2 => sqlerrm
                            );
                    end;
                end loop;

                put_macros;

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab  => l_event_object_id_tab
                );

                exit when evt_object_cur%notfound;

            exception
                when others then
                    rollback to sp_crd_process;

                    l_excepted_count := l_excepted_count + 1;

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

    elsif i_truncation_type = crd_api_const_pkg.TRUNCATION_TYPE_DUE_DATE_2 then

        l_eff_date           := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);
        l_start_posting_date := trunc(l_eff_date, 'MM');
        l_end_posting_date   := add_months(trunc(l_eff_date, 'MM'), 1) - com_api_const_pkg.ONE_SECOND;

        l_start_date := trunc(coalesce(i_start_date, com_api_sttl_day_pkg.get_sysdate));
        l_end_date   := trunc(coalesce(i_end_date,   l_start_date)) + 1 - com_api_const_pkg.ONE_SECOND;

        l_from_id    := com_api_id_pkg.get_from_id(i_date => l_start_date);
        l_till_id    := com_api_id_pkg.get_till_id(i_date => l_end_date);

        for rec in (
            select gl.id gl_account_id
                 , gl.split_hash
                 , gl.account_type
                 , gl.account_number
                 , gl.currency
                 , gl.inst_id
                 , gl.agent_id
                 , gl.customer_id
                 , gl.contract_id
                 , gl.status
                 , m.entity_type
                 , m.object_id
                 , sum(e.balance_impact * e.amount) as amount
                 , decode(e.balance_type
                        , crd_api_const_pkg.BALANCE_TYPE_INTEREST,         i_in_due_macros_type
                        , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST, i_overdue_macros_type
                        ) as macros_type_id
                 , count(1) over() cnt
                 , row_number() over(order by gl.id) rn
              from acc_gl_account_mvw gl
                 , acc_entry e
                 , acc_macros m
             where e.account_id    = gl.id
               and e.macros_id     = m.id
               and e.balance_type in (crd_api_const_pkg.BALANCE_TYPE_INTEREST
                                    , crd_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST
                                     )
               and e.status        = acc_api_const_pkg.ENTRY_STATUS_POSTED
               and e.posting_date between l_start_date and l_end_date
               and e.id           between l_from_id    and l_till_id
               and i_inst_id      in (gl.inst_id, ost_api_const_pkg.DEFAULT_INST)
               and not exists (select 1
                                 from acc_entry x
                                where x.account_id   = e.account_id
                                  and x.balance_type = e.balance_type
                                  and x.currency     = e.currency
                                  and x.status       = acc_api_const_pkg.ENTRY_STATUS_POSTED
                                  and x.posting_date between l_start_posting_date and l_end_posting_date
                              )
          group by gl.id
                 , gl.split_hash
                 , gl.account_type
                 , gl.account_number
                 , gl.currency
                 , gl.inst_id
                 , gl.agent_id
                 , gl.customer_id
                 , gl.contract_id
                 , gl.status
                 , m.entity_type
                 , m.object_id
                 , e.balance_type
          order by gl.id
        ) loop
            if rec.rn = 1 then
                prc_api_stat_pkg.log_estimation(i_estimated_count => rec.cnt);

                trc_log_pkg.debug (i_text => 'estimation record = ' || rec.cnt );
            end if;

            savepoint sp_record;

            begin
                acc_api_entry_pkg.put_macros (
                    o_macros_id         => l_macros_id
                  , o_bunch_id          => l_bunch_id
                  , i_entity_type       => rec.entity_type
                  , i_object_id         => rec.object_id
                  , i_macros_type_id    => rec.macros_type_id
                  , i_amount            => rec.amount
                  , i_currency          => rec.currency
                  , i_account_type      => rec.account_type
                  , i_account_id        => rec.gl_account_id
                  , i_posting_date      => l_eff_date
                  , i_amount_name       => com_api_const_pkg.AMOUNT_PURPOSE_MACROS
                  , i_account_name      => com_api_const_pkg.ACCOUNT_PURPOSE_MACROS 
                  , i_date_name         => acc_api_const_pkg.DEFAULT_DATE_NAME
                  , i_amount_purpose    => com_api_const_pkg.AMOUNT_PURPOSE_MACROS
                  , i_fee_id            => null
                  , i_fee_tier_id       => null
                  , i_fee_mod_id        => null
                  , i_details_data      => null
                  , i_conversion_rate   => null
                  , i_param_tab         => l_param_tab
                );
                l_processed_count := l_processed_count + 1;

                if mod(l_processed_count, 100) = 0 then
                    prc_api_stat_pkg.log_current(
                        i_current_count  => l_processed_count
                      , i_excepted_count => l_excepted_count
                    );
                end if;

            exception
                when others then
                    rollback to sp_record;
                    l_excepted_count := l_excepted_count + 1;

                    if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                        raise;
                    elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                        com_api_error_pkg.raise_fatal_error(
                            i_error         => 'UNHANDLED_EXCEPTION'
                          , i_env_param1    => sqlerrm
                        );
                    end if;
                    trc_log_pkg.debug(
                        i_text       => 'Account_id=[#1], error: [#2]'
                      , i_env_param1 => rec.gl_account_id
                      , i_env_param2 => sqlerrm
                    );
            end;
    
        end loop;
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_processed_count
      , i_excepted_total    => l_excepted_count
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to sp_process;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;

end process_interest_posting;

end;
/
