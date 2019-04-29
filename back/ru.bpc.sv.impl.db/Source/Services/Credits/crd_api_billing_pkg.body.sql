create or replace package body crd_api_billing_pkg as

procedure process(
    i_inst_id                     in      com_api_type_pkg.t_inst_id
) is
    l_sysdate           date;

    cursor cu_events_count is
        select count(1)
          from evt_event_object o
             , evt_event e
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CRD_API_BILLING_PKG.PROCESS'
           and o.eff_date      <= l_sysdate
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and e.id             = o.event_id
           and com_api_array_pkg.is_element_in_array(
                   i_array_id          => crd_api_const_pkg.EVENT_TYPE_ARRAY_ID
                 , i_elem_value        => e.event_type
               ) = com_api_const_pkg.TRUE
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
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CRD_API_BILLING_PKG.PROCESS'
           and o.eff_date      <= l_sysdate
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and e.id             = o.event_id
           and com_api_array_pkg.is_element_in_array(
                   i_array_id          => crd_api_const_pkg.EVENT_TYPE_ARRAY_ID
                 , i_elem_value        => e.event_type
               ) = com_api_const_pkg.TRUE
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
    l_param_tab         com_api_type_pkg.t_param_tab;

    l_last_invoice_id   com_api_type_pkg.t_medium_id;
    l_inst_id           com_api_type_pkg.t_inst_id;
    l_bunch_id          com_api_type_pkg.t_long_id;
    l_gl_account_number com_api_type_pkg.t_account_number;
    l_gl_account_id     com_api_type_pkg.t_medium_id;
    l_gl_account_type   com_api_type_pkg.t_dict_value;

begin
    l_sysdate  := com_api_sttl_day_pkg.get_sysdate();
    l_inst_id  := coalesce(i_inst_id, ost_api_const_pkg.DEFAULT_INST);

    trc_log_pkg.debug(
        i_text       => 'Start credit billing: sysdate [#1][#2], thread_number [#3], inst_id [#4]'
      , i_env_param1 => i_inst_id
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
            savepoint sp_api_process;

            for i in 1..l_event_type_tab.count loop

                savepoint sp_crd_record;

                l_last_invoice_id := crd_invoice_pkg.get_last_invoice_id(
                                         i_account_id       => l_object_id_tab(i)
                                       , i_split_hash       => l_split_hash_tab(i)
                                       , i_mask_error       => com_api_const_pkg.TRUE
                                       , i_eff_date         => null
                                     );
                for r in (
                    select b.id debt_balance_id
                         , o.oper_reason
                         , e.amount
                         , e.currency
                         , e.macros_id
                         , b.bunch_type_id
                      from crd_debt d
                         , opr_operation o
                         , acc_entry e
                         , acc_macros m
                         , crd_event_bunch_type b
                     where d.id in (select debt_id from crd_invoice_debt where invoice_id = l_last_invoice_id and split_hash = l_split_hash_tab(i))
                       and d.oper_id          = o.id
                       and o.id               = m.object_id
                       and m.entity_type      = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                       and m.id               = e.macros_id
                       and m.cancel_indicator = acc_api_const_pkg.ENTRY_STATUS_POSTED
                       and m.amount_purpose   = o.oper_reason
                       and b.inst_id          = l_inst_id
                       and b.event_type       = l_event_type_tab(i)
                       and b.balance_type     = e.balance_type
                       and e.balance_type    in (acc_api_const_pkg.BALANCE_TYPE_OVERDUE, acc_api_const_pkg.BALANCE_TYPE_OVERDUE_INTEREST)
                       and com_api_array_pkg.is_element_in_array(
                               i_array_id          => crd_api_const_pkg.FEE_TYPE_ARRAY_ID
                             , i_elem_value        => o.oper_reason
                           ) = com_api_const_pkg.TRUE
                ) loop
                    begin
                        select a.account_number
                          into l_gl_account_number
                          from acc_gl_account_mvw a
                         where a.entity_id    = l_inst_id
                           and a.entity_type  = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION;

                        trc_log_pkg.debug (
                            i_text          => 'Found GL account [#1]'
                          , i_env_param1    => l_gl_account_number
                        );

                        select a.id
                             , a.account_type
                          into l_gl_account_id
                             , l_gl_account_type
                          from acc_account a
                         where a.account_number = l_gl_account_number
                           and a.inst_id        = l_inst_id;

                        trc_log_pkg.debug (
                            i_text          => 'Found account_id [#1]'
                            , i_env_param1  => l_gl_account_id
                        );

                    exception
                        when no_data_found then
                            com_api_error_pkg.raise_error(
                                i_error             => 'ACCOUNT_NOT_FOUND'
                              , i_env_param1        => l_inst_id
                              , i_env_param2        => l_gl_account_number
                            );
                    end;
                    --
                    if r.bunch_type_id is not null then
                        acc_api_entry_pkg.put_bunch (
                            o_bunch_id          => l_bunch_id
                          , i_bunch_type_id     => r.bunch_type_id
                          , i_macros_id         => r.macros_id
                          , i_amount            => r.amount
                          , i_currency          => r.currency
                          , i_account_type      => l_gl_account_type
                          , i_account_id        => l_gl_account_id
                          , i_posting_date      => l_sysdate
                          , i_param_tab         => l_param_tab
                        );
                    end if;
                end loop;

            end loop;

            acc_api_entry_pkg.flush_job;

            l_record_count := l_record_count + l_event_id_tab.count;

            prc_api_stat_pkg.log_current(
                i_current_count     => l_record_count
              , i_excepted_count    => l_excepted_count
            );

            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab   => l_event_id_tab
            );

            exit when cu_events%notfound;
        exception
            when others then
                rollback to sp_api_process;

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

        --rollback to sp_api_process;

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

end;
/
