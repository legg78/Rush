CREATE OR REPLACE package body itf_prc_bank_outgoing_pkg as

procedure process(
    i_inst_id           in      com_api_type_pkg.t_inst_id
) is
    l_timestamp         timestamp(6) := systimestamp;

    cursor cu_entries is
        select c.account_number   account_number
             , b.id               entry_id
             , e.id               operation_id
             , b.transaction_id   transaction_id
             , b.transaction_type transaction_type
             , round(b.amount)    amount
             , round(b.balance)   balance
             , b.currency         currency
             , e.oper_type        oper_type
             , e.oper_date        oper_date
             , d.amount_purpose   fee_type
             , b.sttl_day         sttl_day
             , e.terminal_number  terminal_number
             , e.merchant_number  merchant_number
             , e.merchant_name    merchant_name
             , e.merchant_country merchant_country
             , e.merchant_city    merchant_city
             , e.merchant_street  merchant_street
             , c.agent_id         agent_id
             , c.inst_id          inst_id
             , a.id               event_object_id
          from evt_event_object a
             , acc_entry        b
             , acc_account      c
             , acc_macros       d
             , opr_operation    e
         where a.procedure_name  = 'ITF_PRC_BANK_OUTGOING_PKG.PROCESS'
           and a.entity_type     = 'ENTTENTR'
           and a.eff_date        < l_timestamp
           and a.inst_id         = i_inst_id
           and a.object_id       = b.id
           and b.balance_type    = 'BLTPLDGR'
           and b.account_id      = c.id
           and b.macros_id       = d.id
           and d.object_id       = e.id
           and d.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and c.inst_id         = i_inst_id;

    cursor cu_entries_count is
        select count(1)
          from evt_event_object a
             , acc_entry        b
             , acc_account      c
             , acc_macros       d
             , opr_operation    e
         where a.procedure_name  = 'ITF_PRC_BANK_OUTGOING_PKG.PROCESS'
           and a.entity_type     = 'ENTTENTR'
           and a.eff_date        < l_timestamp
           and a.inst_id         = i_inst_id
           and a.object_id       = b.id
           and b.balance_type    = 'BLTPLDGR'
           and b.account_id      = c.id
           and b.macros_id       = d.id
           and d.object_id    = e.id
           and d.entity_type     = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and c.inst_id         = i_inst_id;

    l_account_number    com_api_type_pkg.t_account_number_tab;
    l_entry_id          com_api_type_pkg.t_number_tab;
    l_operation_id      com_api_type_pkg.t_number_tab;
    l_transaction_id    com_api_type_pkg.t_number_tab;
    l_transaction_type  com_api_type_pkg.t_dict_tab;
    l_amount            com_api_type_pkg.t_number_tab;
    l_balance           com_api_type_pkg.t_number_tab;
    l_currency          com_api_type_pkg.t_curr_code_tab;
    l_oper_type         com_api_type_pkg.t_dict_tab;
    l_oper_date         com_api_type_pkg.t_date_tab;
    l_fee_type          com_api_type_pkg.t_dict_tab;
    l_sttl_day          com_api_type_pkg.t_number_tab;
    l_terminal_number   com_api_type_pkg.t_terminal_number_tab;
    l_merchant_number   com_api_type_pkg.t_merchant_number_tab;
    l_merchant_name     com_api_type_pkg.t_name_tab;
    l_merchant_country  com_api_type_pkg.t_country_code_tab;
    l_merchant_city     com_api_type_pkg.t_name_tab;
    l_merchant_street   com_api_type_pkg.t_name_tab;
    l_agent_id          com_api_type_pkg.t_agent_id_tab;
    l_inst_id           com_api_type_pkg.t_inst_id_tab;

    l_event_object_id   com_api_type_pkg.t_number_tab;

    l_record            com_api_type_pkg.t_raw_tab;
    l_record_number     com_api_type_pkg.t_integer_tab;
    l_session_file_id   com_api_type_pkg.t_long_id;
    l_record_count      pls_integer                 := 0;
    l_total_amount      com_api_type_pkg.t_money;

begin

    prc_api_stat_pkg.log_start;

    open cu_entries_count;
    fetch cu_entries_count into l_record_count;
    close cu_entries_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );

    if l_record_count > 0 then

        l_record_count := 0;

        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
        );

        l_record_count := l_record_count + 1;

        prc_api_file_pkg.put_line(
            i_sess_file_id  => l_session_file_id
          , i_raw_data      => lpad(nvl(i_inst_id, 0), 4, '0')                         || ' ' ||
                               rpad(nvl(to_char(sysdate, 'YYYYMMDDHH24MISS'), ' '), 14)
        );

        open cu_entries;

        loop
            fetch cu_entries bulk collect into
                l_account_number
              , l_entry_id
              , l_operation_id
              , l_transaction_id
              , l_transaction_type
              , l_amount
              , l_balance
              , l_currency
              , l_oper_type
              , l_oper_date
              , l_fee_type
              , l_sttl_day
              , l_terminal_number
              , l_merchant_number
              , l_merchant_name
              , l_merchant_country
              , l_merchant_city
              , l_merchant_street
              , l_agent_id
              , l_inst_id
              , l_event_object_id
            limit 1000;

            l_record.delete;
            l_record_number.delete;

            for i in 1..l_entry_id.count loop
                l_record(i) :=
                    lpad(nvl(l_inst_id(i), 0), 4, '0')                              || ' ' ||
                    lpad(nvl(l_agent_id(i), 0), 8, '0')                             || ' ' ||
                    rpad(nvl(l_account_number(i), ' '), 20)                         || ' ' ||
                    lpad(nvl(l_operation_id(i), 0), 16, '0')                        || ' ' ||
                    lpad(nvl(l_transaction_id(i), 0), 16, '0')                      || ' ' ||
                    lpad(nvl(l_entry_id(i), 0), 16, '0')                            || ' ' ||
                    lpad(nvl(l_amount(i), 0), 22, '0')                              || ' ' ||
                    lpad(nvl(l_balance(i), 0), 22, '0')                             || ' ' ||
                    rpad(nvl(l_currency(i), ' '), 3)                                || ' ' ||
                    rpad(nvl(to_char(l_oper_date(i), 'YYYYMMDDHH24MISS'), ' '), 14) || ' ' ||
                    rpad(nvl(l_fee_type(i), ' '), 8)                                || ' ' ||
                    rpad(nvl(l_transaction_type(i), ' '), 8)                        || ' ' ||
                    rpad(nvl(to_char(l_sttl_day(i)), ' '), 4)                       || ' ' ||
                    rpad(nvl(l_terminal_number(i), ' '), 16)                        || ' ' ||
                    rpad(nvl(l_merchant_number(i), ' '), 15)                        || ' ' ||
                    rpad(nvl(l_merchant_name(i), ' '), 30)                          || ' ' ||
                    rpad(nvl(l_merchant_country(i), ' '), 3)                        || ' ' ||
                    rpad(nvl(l_merchant_city(i), ' '), 20)                          || ' ' ||
                    rpad(nvl(l_merchant_street(i), ' '), 30);

                l_total_amount     := l_total_amount + l_amount(i);
                l_record_count     := l_record_count + 1;
                l_record_number(i) := l_record_count;

            end loop;

            prc_api_file_pkg.put_bulk(
                i_sess_file_id  => l_session_file_id
              , i_raw_tab       => l_record
              , i_num_tab       => l_record_number
            );

            forall i in 1..l_event_object_id.count
                delete from evt_event_object where id = l_event_object_id(i);

            prc_api_stat_pkg.increase_current (
                i_current_count       => l_entry_id.count
              , i_excepted_count      => 0
            );

            exit when cu_entries%notfound;
        end loop;

        close cu_entries;

        l_record_count := l_record_count + 1;

        prc_api_file_pkg.put_line(
            i_sess_file_id  => l_session_file_id
          , i_raw_data      => lpad(nvl(l_record_count, 0), 8, '0') || ' ' ||
                               lpad(nvl(l_total_amount, 0), 22, '0')
        );

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );

    end if;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        if cu_entries%isopen then
            close cu_entries;
        end if;

        if cu_entries_count%isopen then
            close cu_entries_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;
        
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
        
end;

end;
/
