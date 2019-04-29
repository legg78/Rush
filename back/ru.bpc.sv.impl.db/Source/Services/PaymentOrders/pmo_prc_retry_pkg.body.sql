create or replace package body pmo_prc_retry_pkg is

procedure process(
    i_inst_id                     in      com_api_type_pkg.t_inst_id
)
 is
    l_sysdate           date;

    cursor cu_events_count is
        select count(1)
          from evt_event_object o
             , evt_event e
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'PMO_PRC_RETRY_PKG.PROCESS'
           and o.eff_date      <= l_sysdate
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and e.id             = o.event_id
           and o.entity_type    = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
           and (
                o.inst_id = i_inst_id
                or
                i_inst_id is null
                or
                i_inst_id = ost_api_const_pkg.DEFAULT_INST
               )
           ;

    cursor cu_events is
        select o.id
             , e.event_type
             , o.entity_type
             , o.object_id
             , o.eff_date
             , o.split_hash
             , ps.attempt_limit
             , ps.amount_algorithm
          from evt_event_object o
             , evt_event e
             , pmo_order po
             , pmo_schedule ps
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'PMO_PRC_RETRY_PKG.PROCESS'
           and o.eff_date      <= l_sysdate
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and e.id             = o.event_id
           and o.object_id      = po.id
           and o.entity_type    = pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER
           and e.event_type     = ps.event_type
           and po.entity_type   = ps.entity_type
           and po.object_id     = ps.object_id
           and (
                o.inst_id = i_inst_id
                or
                i_inst_id is null
                or
                i_inst_id = ost_api_const_pkg.DEFAULT_INST
               )

         order by o.eff_date;

    l_record_count      com_api_type_pkg.t_count := 0;
    l_excepted_count    com_api_type_pkg.t_count := 0;

    l_event_id_tab      com_api_type_pkg.t_number_tab;
    l_event_type_tab    com_api_type_pkg.t_dict_tab;
    l_entity_type_tab   com_api_type_pkg.t_dict_tab;
    l_object_id_tab     com_api_type_pkg.t_number_tab;
    l_eff_date_tab      com_api_type_pkg.t_date_tab;
    l_split_hash_tab    com_api_type_pkg.t_number_tab;
    l_amount_alg_tab    com_api_type_pkg.t_dict_tab;
    l_attempt_count_tab com_api_type_pkg.t_number_tab;

    l_processed_tab     com_api_type_pkg.t_number_tab;
    l_param_tab         com_api_type_pkg.t_param_tab;

    l_order             pmo_api_type_pkg.t_payment_order_rec;
    l_amount_rec        com_api_type_pkg.t_amount_rec;
    
    l_service_id        com_api_type_pkg.t_short_id;
    l_invoice_id        com_api_type_pkg.t_medium_id;
    l_cycle_id          com_api_type_pkg.t_short_id;
    l_product_id        com_api_type_pkg.t_short_id;
    l_next_date         date;
begin
    l_sysdate := com_api_sttl_day_pkg.get_sysdate();

    trc_log_pkg.debug(
        i_text       => 'Payment order retry started'
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
          , l_attempt_count_tab
          , l_amount_alg_tab
        limit 1000;

        begin
            savepoint sp_pmo_process;

            for i in 1..l_event_type_tab.count loop

                savepoint sp_pmo_process;
                trc_log_pkg.debug(
                    i_text      => 'event type [#1], object [#2], eff. date [#3]'
                  , i_env_param1 => l_event_type_tab(i)
                  , i_env_param2 => l_object_id_tab(i)
                  , i_env_param3 => com_api_type_pkg.convert_to_char(l_eff_date_tab(i))
                );
                
                l_param_tab.delete;
                
                begin
                    l_order := pmo_api_order_pkg.get_order(i_order_id => l_object_id_tab(i));
                    
                    pmo_api_order_pkg.calc_order_amount(
                        i_amount_algorithm      => l_amount_alg_tab(i)
                      , i_entity_type           => l_order.entity_type
                      , i_object_id             => l_order.object_id
                      , i_eff_date              => l_eff_date_tab(i)
                      , i_template_id           => l_order.template_id
                      , i_split_hash            => l_split_hash_tab(i)
                      , i_order_id              => l_order.id
                      , io_amount               => l_amount_rec
                    );
                    
                    trc_log_pkg.debug(
                        i_text       => 'attempt_count [#1]; attempt_count_limit [#2]; expiration_date [#3]; pmo_amount [#4]'
                      , i_env_param1 => l_order.attempt_count
                      , i_env_param2 => l_attempt_count_tab(i)
                      , i_env_param3 => l_order.expiration_date
                      , i_env_param4 => l_amount_rec.amount
                    );
                    
                    if l_order.attempt_count > nvl(l_attempt_count_tab(i), l_order.attempt_count)
                    or l_eff_date_tab(i)     > nvl(l_order.expiration_date, l_order.expiration_date)
                    or l_amount_rec.amount  <= 0
                    then
                        fcl_api_cycle_pkg.remove_cycle_counter(
                            i_cycle_type  => l_event_type_tab(i)
                          , i_entity_type => l_order.entity_type
                          , i_object_id   => l_order.object_id
                          , i_split_hash  => l_split_hash_tab(i)
                        );
                        continue;
                    end if;
                    
                    rul_api_shared_data_pkg.load_payment_order_params(
                        i_payment_order_id => l_order.id
                      , io_params          => l_param_tab
                    );
                    
                    if l_order.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
                        l_service_id :=
                            crd_api_service_pkg.get_active_service(
                                i_account_id => l_order.object_id
                              , i_eff_date   => l_eff_date_tab(i)
                              , i_split_hash => l_split_hash_tab(i)
                              , i_mask_error => com_api_const_pkg.TRUE
                            );
                            
                        trc_log_pkg.debug(
                            i_text       => 'load_invoice_params; credit service [#1] for account [#2]'
                          , i_env_param1 => l_service_id
                          , i_env_param2 => l_order.object_id
                        );
                        
                        if l_service_id is not null then
                            l_invoice_id :=
                                crd_invoice_pkg.get_last_invoice(
                                    i_entity_type => l_order.entity_type
                                  , i_object_id   => l_order.object_id
                                  , i_split_hash  => l_split_hash_tab(i)
                                  , i_mask_error  => com_api_const_pkg.TRUE
                                ).id;
                        end if;
                    
                        if l_invoice_id is not null then
                            rul_api_shared_data_pkg.load_invoice_params(
                                i_invoice_id => l_invoice_id
                              , io_params    => l_param_tab
                            );
                        end if;
                    end if;

                    rul_api_param_pkg.set_param(
                        i_name    => 'EVENT_DATE'
                      , i_value   => l_eff_date_tab(i)
                      , io_params => l_param_tab
                    );

                    l_product_id :=
                        prd_api_product_pkg.get_product_id(
                            i_entity_type => l_order.entity_type
                          , i_object_id   => l_order.object_id
                          , i_eff_date    => l_eff_date_tab(i)
                          , i_inst_id     => i_inst_id
                        );

                    l_cycle_id :=
                        prd_api_product_pkg.get_attr_value_number(
                            i_product_id        => l_product_id
                          , i_entity_type       => l_order.entity_type
                          , i_object_id         => l_order.object_id
                          , i_attr_name         => prd_api_attribute_pkg.get_attr_name(i_object_type => l_event_type_tab(i))
                          , i_params            => l_param_tab
                          , i_eff_date          => l_eff_date_tab(i)
                          , i_split_hash        => l_split_hash_tab(i)
                          , i_inst_id           => i_inst_id
                          , i_use_default_value => com_api_const_pkg.TRUE
                          , i_default_value     => null
                        );

                    if l_cycle_id is not null then
                        fcl_api_cycle_pkg.switch_cycle(
                            i_cycle_type        => l_event_type_tab(i)
                          , i_product_id        => l_product_id
                          , i_entity_type       => l_entity_type_tab(i)
                          , i_object_id         => l_object_id_tab(i)
                          , i_params            => l_param_tab
                          , i_start_date        => l_eff_date_tab(i)
                          , i_eff_date          => l_eff_date_tab(i)
                          , i_split_hash        => l_split_hash_tab(i)
                          , i_inst_id           => i_inst_id
                          , o_new_finish_date   => l_next_date
                          , i_test_mode         => fcl_api_const_pkg.ATTR_MISS_IGNORE
                          , i_cycle_id          => l_cycle_id
                        );
                    end if;

                    trc_log_pkg.debug(
                        i_text       => 'l_cycle_id [#1]; l_next_date [#2]'
                      , i_env_param1 => l_cycle_id
                      , i_env_param2 => l_next_date
                    );
                    
                    if l_next_date is null then
                        fcl_api_cycle_pkg.remove_cycle_counter(
                            i_cycle_type  => l_event_type_tab(i)
                          , i_entity_type => l_entity_type_tab(i)
                          , i_object_id   => l_object_id_tab(i)
                          , i_split_hash  => l_split_hash_tab(i)
                        );
                    else
                        update pmo_order o
                           set o.amount = l_amount_rec.amount
                             , o.status = pmo_api_const_pkg.PMO_STATUS_AWAITINGPROC
                         where id = l_order.id;
                    end if;
                    
                    l_processed_tab(l_processed_tab.count + 1) := l_event_id_tab(i);
                exception
                    when others then
                        rollback to sp_pmo_process;
                        l_excepted_count := l_excepted_count + 1;

                        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                            raise;
                        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                            com_api_error_pkg.raise_fatal_error(
                                i_error         => 'UNHANDLED_EXCEPTION'
                              , i_env_param1    => sqlerrm
                            );
                        end if;
                end;
            end loop;

            l_record_count := l_record_count + l_event_id_tab.count;

            prc_api_stat_pkg.log_current(
                i_current_count     => l_record_count
              , i_excepted_count    => l_excepted_count
            );

            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab   => l_processed_tab
            );

            l_processed_tab.delete;

            exit when cu_events%notfound;
        exception
            when others then
                rollback to sp_pmo_process;

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
end process;

end pmo_prc_retry_pkg;
/
