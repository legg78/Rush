create or replace package body cst_smt_prc_incoming_pkg as
/************************************************************
 * Processes for loading files <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com)  at 20.12.2018 <br />
 * Module: cst_smt_prc_incoming_pkg <br />
 * @headcom
 ***********************************************************/

procedure process_msstrxn
is
    LOG_PREFIX           constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_msstrxn: ';
    
    l_record_count_all_files      com_api_type_pkg.t_long_id := 0;
    l_record_count                com_api_type_pkg.t_long_id := 0;
    l_record_number               com_api_type_pkg.t_long_id := 0;
    l_processed_count             com_api_type_pkg.t_long_id := 0;
    l_excepted_count              com_api_type_pkg.t_long_id := 0;
    l_rejected_count              com_api_type_pkg.t_long_id := 0;
    l_rec                         com_api_type_pkg.t_text;
    
    l_load_date                   date := com_api_sttl_day_pkg.get_sysdate;
    l_eff_date                    date := l_load_date;
    l_input_file_name             com_api_type_pkg.t_name;
    l_original_file_name          com_api_type_pkg.t_name;
    l_msstrxn_map_tab             cst_smt_api_type_pkg.t_msstrxn_map_field_tab;
    l_index                       com_api_type_pkg.t_long_id := 0;
    l_detail_count                com_api_type_pkg.t_long_id := 0;
    l_event_id_tab                com_api_type_pkg.t_number_tab;
    l_oper_id_tab                 com_api_type_pkg.t_number_tab;
    l_msstrxn_id_tab              com_api_type_pkg.t_number_tab;
    
    l_params                      com_api_type_pkg.t_param_tab;
    
    cursor evt_object_cur is
        with opr as (
            select o.id        as event_id
                 , o.object_id as oper_id
                 , f.file_name
                 , a.external_auth_id
                 , oc.card_number
                 , op.oper_amount
                 , pr.auth_code
                 , op.host_date
              from evt_event_object o
                 , evt_event e
                 , prc_session_file f
                 , opr_operation op
                 , aut_auth a
                 , opr_participant pr
                 , opr_card oc
             where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_SMT_PRC_INCOMING_PKG.PROCESS_MSSTRXN'
               and o.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and o.eff_date      <= l_eff_date
               and e.id             = o.event_id
               and e.event_type     = cst_smt_api_const_pkg.MNO_OPER_UPLOADED_EVENT
               and f.file_name      = l_original_file_name
               and o.session_id     = f.session_id
               and op.id            = o.object_id
               and pr.oper_id       = op.id
               and pr.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and a.id                = op.id
               and oc.oper_id          = op.id
               and oc.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
          )
          select opr.event_id
               , opr.oper_id
               , m.id
            from opr
               , cst_smt_msstrxn_map_tmp m
           where opr.file_name         = m.original_file_name(+)
             and opr.external_auth_id  = m.external_auth_id(+)
             and opr.card_number       = m.card_number(+)
             and opr.oper_amount       = m.oper_amount(+)
             and opr.auth_code         = m.iss_auth_code(+)
             and opr.host_date         = m.host_date(+);
             
    cursor cu_records_count is
        select count(1)
          from prc_file_raw_data a
             , prc_session_file b
             , evt_event_object o
             , evt_event e
             , prc_session_file f
         where b.session_id      = prc_api_session_pkg.get_session_id
           and a.session_file_id = b.id
           and substr(a.raw_data, 1, 2) = 'FH'
           and decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_SMT_PRC_INCOMING_PKG.PROCESS_MSSTRXN'
           and o.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and o.eff_date      <= l_eff_date
           and e.id             = o.event_id
           and e.event_type     = cst_smt_api_const_pkg.MNO_OPER_UPLOADED_EVENT
           and f.file_name      = trim(substr(a.raw_data, 29, 35))
           and o.session_id     = f.session_id;
begin
    prc_api_stat_pkg.log_start;

    open cu_records_count;
    fetch cu_records_count into l_record_count_all_files;
    close cu_records_count;
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_record_count_all_files
    );
    
    for p in (
        select id session_file_id
             , record_count
             , file_name
          from prc_session_file
         where session_id = prc_api_session_pkg.get_session_id
         order by id
    ) 
    loop
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'Processing session_file_id [' || p.session_file_id 
                   || '], record_count [' || p.record_count 
                   || '], file_name [' || p.file_name || ']'
        );
        
        l_input_file_name := p.file_name;
        l_index := null;
        if l_msstrxn_map_tab.count > 0 then
            l_msstrxn_map_tab.delete;
        end if;
        
        begin
            begin
                for r in (
                    select record_number
                         , raw_data
                      from prc_file_raw_data
                     where session_file_id = p.session_file_id
                     order by record_number
                )
                loop
                    l_record_number := r.record_number;
                    l_rec := r.raw_data;
                    if substr(l_rec, 1, 2) = 'FH' then
                        l_original_file_name := trim(substr(l_rec, 29, 35));
                    elsif substr(l_rec, 1, 2) = 'DR' then
                        if l_index is null then
                            l_index := 1;
                        else
                            l_index := l_msstrxn_map_tab.last + 1;
                        end if;
                        l_msstrxn_map_tab(l_index).card_number := trim(substr(l_rec, 13, 19));
                        l_msstrxn_map_tab(l_index).oper_amount := to_number(trim(substr(l_rec, 203, 19)));
                        l_msstrxn_map_tab(l_index).iss_auth_code := trim(substr(l_rec, 236, 8));
                        l_msstrxn_map_tab(l_index).trans_date := trim(substr(l_rec, 84, 6));
                        l_msstrxn_map_tab(l_index).trans_time := trim(substr(l_rec, 90, 8));
                        l_msstrxn_map_tab(l_index).external_auth_id := trim(substr(l_rec, 639, 12));
                    elsif substr(l_rec, 1, 2) = 'FT' then
                        l_detail_count := to_number(trim(substr(l_rec, 46, 10)));
                    elsif substr(l_rec, 1, 2) = chr(13) || chr(10) then
                        null;
                    else
                        com_api_error_pkg.raise_error(
                            i_error        => 'WRONG_STRUCTURE_FIN_MESSAGE'
                          , i_env_param1   => 'WRONG VALUE RECORD TYPE PARAMETER - ' || substr(l_rec, 1, 2)
                        );
                    end if;
                end loop;
                
                prc_api_file_pkg.close_file(
                    i_sess_file_id          => p.session_file_id
                  , i_status                => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                );
            exception
                when others then
                    prc_api_file_pkg.close_file(
                        i_sess_file_id          => p.session_file_id
                      , i_status                => prc_api_const_pkg.FILE_STATUS_REJECTED
                    );
                    com_api_error_pkg.raise_fatal_error(
                        i_error      => 'WRONG_STRUCTURE_FIN_MESSAGE'
                      , i_env_param1 => 'INVALID FILE - ' || l_input_file_name
                    ); 
            end;
            
            if l_msstrxn_map_tab.count > 0 then
                trc_log_pkg.debug(
                    i_text       => LOG_PREFIX || 'All detail record in file [#1], put detail record in collection [#2]'
                  , i_env_param1 => l_detail_count
                  , i_env_param2 => l_msstrxn_map_tab.count
                );
                
                cst_smt_api_process_pkg.insert_into_msstrxn_map(
                    i_input_file_name    => l_input_file_name
                  , i_original_file_name => l_original_file_name
                  , i_load_date          => l_load_date
                  , i_msstrxn_map_tab    => l_msstrxn_map_tab
                );
                
                open evt_object_cur;
                fetch evt_object_cur
                 bulk collect
                 into l_event_id_tab
                    , l_oper_id_tab
                    , l_msstrxn_id_tab;
                close evt_object_cur;
                
                if l_event_id_tab.count > 0 then

                    for i in l_oper_id_tab.first .. l_oper_id_tab.last
                    loop
                        opr_api_operation_pkg.get_operation(
                            i_oper_id   => l_oper_id_tab(i)
                          , o_operation => opr_api_shared_data_pkg.g_operation
                        );
                        
                        opr_api_operation_pkg.get_participant(
                            i_oper_id           => l_oper_id_tab(i)
                          , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
                          , o_participant       => opr_api_shared_data_pkg.g_iss_participant
                        );
                        
                        opr_api_operation_pkg.get_participant(
                            i_oper_id           => l_oper_id_tab(i)
                          , i_participaint_type => com_api_const_pkg.PARTICIPANT_ACQUIRER
                          , o_participant       => opr_api_shared_data_pkg.g_acq_participant
                        );

                        opr_api_shared_data_pkg.g_auth := aut_api_auth_pkg.get_auth(i_id => l_oper_id_tab(i));

                        evt_api_shared_data_pkg.set_param(
                            i_name  => 'IS_REVERSAL'
                          , i_value => case
                                           when l_msstrxn_id_tab(i) is not null
                                               then com_api_const_pkg.TRUE
                                           else com_api_const_pkg.FALSE
                                       end
                        );
                        
                        evt_api_event_pkg.register_event(
                            i_event_type  => cst_smt_api_const_pkg.MNO_OPER_AGREED_EVENT
                          , i_eff_date    => l_eff_date
                          , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                          , i_object_id   => l_oper_id_tab(i)
                          , i_inst_id     => opr_api_shared_data_pkg.g_iss_participant.inst_id
                          , i_split_hash  => com_api_hash_pkg.get_split_hash(
                                                 i_entity_type    => opr_api_const_pkg.ENTITY_TYPE_OPERATION 
                                               , i_object_id      => l_oper_id_tab(i)
                                               , i_mask_error     => com_api_const_pkg.TRUE
                                             )
                          , i_param_tab   => l_params
                        );
                        
                        l_processed_count := l_processed_count + 1;
                        l_record_count    := l_record_count + 1;
                    end loop;
                    
                    evt_api_event_pkg.process_event_object(
                        i_event_object_id_tab => l_event_id_tab
                    );
                    
                    cst_smt_api_process_pkg.delete_msstrxn_map(
                        i_input_file_name => l_input_file_name
                      , i_load_date       => l_load_date
                      , i_id_tab          => l_msstrxn_id_tab
                    );
                end if;
            else
                    com_api_error_pkg.raise_error(
                        i_error        => 'WRONG_STRUCTURE_FIN_MESSAGE'
                      , i_env_param1   => 'ABSENT DETAIL RECORDS - ' || l_msstrxn_map_tab.count
                    );
            end if;
                    
        exception
            when com_api_error_pkg.e_application_error then
                l_record_count    := l_record_count + 1;
                l_excepted_count  := l_excepted_count + 1;
                prc_api_stat_pkg.log_current(
                        i_current_count  => l_record_count
                      , i_excepted_count => l_excepted_count
                );
                raise;
        end;
    end loop;
    
    prc_api_stat_pkg.log_end(
        i_processed_total  => l_processed_count
      , i_excepted_total   => l_excepted_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');
exception
    when others then
        if cu_records_count%isopen then
            close cu_records_count;
        end if;

        prc_api_stat_pkg.log_end(
            i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'FAILED with l_record_number [#1] l_rec [#2]' 
              , i_env_param1 => l_record_number
              , i_env_param2 => l_rec
            );
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end process_msstrxn;

end cst_smt_prc_incoming_pkg;
/
