create or replace package body rus_prc_bank_order_pkg as

procedure process is

    l_sysdate               date;
    l_record_count          pls_integer;
    l_excepted_count        pls_integer;
    l_report_id             com_api_type_pkg.t_short_id;
    l_report_template_id    com_api_type_pkg.t_short_id;
    l_param_tab             com_api_type_pkg.t_param_tab;
    l_param_map             com_param_map_tpt := com_param_map_tpt(null);
    l_sess_file_id          com_api_type_pkg.t_long_id;
    l_file_type             com_api_type_pkg.t_dict_value;

    l_event_id_tab          com_api_type_pkg.t_number_tab;
    l_entity_type_tab       com_api_type_pkg.t_dict_tab;
    l_object_id_tab         com_api_type_pkg.t_number_tab;
    l_split_hash_tab        com_api_type_pkg.t_number_tab;
    l_inst_id_tab           com_api_type_pkg.t_number_tab;
    l_transaction_type_tab  com_api_type_pkg.t_dict_tab;
    
    l_run_id                com_api_type_pkg.t_long_id;
    l_is_deterministic      com_api_type_pkg.t_boolean;
    l_is_first_run          com_api_type_pkg.t_boolean;
    l_file_name             com_api_type_pkg.t_name;
    l_save_path             com_api_type_pkg.t_name;
    l_resultset             sys_refcursor;
    l_xml                   clob;

    
    cursor cu_trans_count is
        select count(1)
          from evt_event_object
         where procedure_name = 'RUS_PRC_BANK_ORDER_PKG.PROCESS'
           and eff_date < l_sysdate;
           
    cursor cu_trans is
        select a.id
             , a.entity_type
             , a.object_id
             , a.inst_id
             , a.split_hash
             , b.transaction_type
          from evt_event_object a
             , acc_entry b
         where procedure_name = 'RUS_PRC_BANK_ORDER_PKG.PROCESS'
           and eff_date < l_sysdate
           and b.transaction_id(+) = a.object_id
           and b.balance_impact(+) = 1;

begin
    l_sysdate       := com_api_sttl_day_pkg.get_sysdate;

    prc_api_stat_pkg.log_start;

    open cu_trans_count;
    fetch cu_trans_count into l_record_count;
    close cu_trans_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );

    l_record_count := 0;

    savepoint sp_order_process;
    
    l_param_map.extend;
    
    open cu_trans;

    loop
        fetch cu_trans bulk collect into
            l_event_id_tab
          , l_entity_type_tab
          , l_object_id_tab
          , l_split_hash_tab
          , l_inst_id_tab
          , l_transaction_type_tab
        limit 1000;
        
        for i in 1..l_event_id_tab.count loop
        
            begin 
                savepoint sp_order_record;
                
                l_file_type := 
                    case l_transaction_type_tab(i) 
                        when 'TRNT0002' then 'FLTP5001'     -- banking order (transfer between accounts)
                        when 'TRNT0003' then 'FLTP5002'     -- banking order (fee charging)
                        when 'TRNT5001' then 'FLTP5003'     -- memorial order (rate difference)
                        when 'TRNT0004' then 'FLTP5004'     -- memorial order (fee adjustment)
                        when 'TRNT0006' then 'FLTP5005'     -- payment order (external transfer)
                        else null
                    end;
                    
                
                if l_file_type is not null then
                
                    l_param_tab.delete;
                    
                    prc_api_file_pkg.open_file (
                        o_sess_file_id          => l_sess_file_id
                      , i_file_name             => 'noname'
                      , i_file_type             => l_file_type
                      , io_params               => l_param_tab
                      , o_report_id             => l_report_id
                      , o_report_template_id    => l_report_template_id
                    );                
                    
                    l_param_map(1) := com_param_map_tpr('I_OBJECT_ID', null, l_object_id_tab(i), null, null);
                
                    rpt_ui_run_pkg.report_start(
                        i_report_id         => l_report_id
                      , i_parameters        => l_param_map
                      , i_template_id       => l_report_template_id
                      , o_run_id            => l_run_id
                      , o_is_deterministic  => l_is_deterministic
                      , o_is_first_run      => l_is_first_run
                      , o_file_name         => l_file_name
                      , o_save_path         => l_save_path
                      , o_resultset         => l_resultset
                      , o_xml               => l_xml
                    );
                    
                    if l_is_deterministic = com_api_const_pkg.FALSE or l_is_first_run = com_api_const_pkg.TRUE then
                    
                        prc_api_file_pkg.put_file (
                            i_sess_file_id      => l_sess_file_id
                          , i_clob_content      => l_xml
                          , i_add_to            => com_api_const_pkg.FALSE
                        );
                        
                        update prc_session_file
                           set file_name = nvl(l_save_path, l_file_name)
                         where id = l_sess_file_id;
                    else
                        delete from prc_session_file
                         where id = l_sess_file_id;
                    end if;
                end if;
                    
            exception
                when others then
                    rollback to sp_order_record;
                    l_excepted_count := l_excepted_count + 1;
                    if com_api_error_pkg.is_fatal_error(SQLCODE) = com_api_const_pkg.TRUE then
                        raise;
                    elsif com_api_error_pkg.is_application_error(SQLCODE) = com_api_const_pkg.FALSE then
                        com_api_error_pkg.raise_fatal_error(
                            i_error         => 'UNHANDLED_EXCEPTION'
                          , i_env_param1    => SQLERRM
                        );
                    end if;
            end;
            
        end loop;

        l_record_count := l_record_count + l_event_id_tab.count;

        prc_api_stat_pkg.log_current(
            i_current_count     => l_record_count
          , i_excepted_count    => l_excepted_count
        );

        forall i in 1..l_event_id_tab.count
            delete from evt_event_object
             where id = l_event_id_tab(i);

        exit when cu_trans%notfound;
    end loop;

    close cu_trans;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then

        rollback to sp_order_process;

        if cu_trans_count%isopen then
            close cu_trans_count;
        end if;

        if cu_trans%isopen then
            close cu_trans;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(SQLCODE) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(SQLCODE) = com_api_const_pkg.TRUE then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => SQLERRM
            );
        end if;
end;

end;
/
