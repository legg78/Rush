create or replace package body cup_prc_match_pkg as

procedure process_match(
    i_inst_id       in      com_api_type_pkg.t_inst_id
) is
    cursor l_match_fin_cur is
        select cf.id
             , min(cm.id)
             , min(cf.fee_type)
          from cup_fin_message cm
             , cup_fee cf
         where cf.match_status          in (opr_api_const_pkg.OPERATION_MATCH_NOT_MATCHED
                                          , opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH)
           and cf.fee_type               = cup_api_const_pkg.FT_INTERCHANGE
           and cf.inst_id                = i_inst_id
           and cm.acquirer_iin           = cf.acquirer_iin
           and cm.forwarding_iin         = cf.forwarding_iin
           and cm.sys_trace_num          = cf.sys_trace_num
           and cm.transmission_date_time = cf.transmission_date_time
           and cm.is_reversal            = cf.is_reversal
           and cm.inst_id                = i_inst_id
           and (cm.trans_code           != cup_api_const_pkg.TC_DISPUTE
                or cf.trans_type_id      = cup_api_const_pkg.TRANS_TYPE_DISPUTE_MANUAL)
         group by cf.id;         
           
    cursor l_match_oper_cur is
        select cf.id
             , min(o.id)
             , min(cf.fee_type)
          from aut_auth a
             , opr_operation o
             , opr_participant pi
             , opr_participant pa
             , cup_fee cf
         where cf.match_status            in (opr_api_const_pkg.OPERATION_MATCH_NOT_MATCHED
                                            , opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH)
           and cf.fee_type                 = cup_api_const_pkg.FT_INTERCHANGE
           and cf.inst_id                  = i_inst_id
           and a.system_trace_audit_number = cf.sys_trace_num
           and o.oper_date                 = cf.transmission_date_time
           and o.is_reversal               = cf.is_reversal
           and a.id                        = o.id
           and pi.oper_id                  = o.id
           and pi.participant_type         = com_api_const_pkg.PARTICIPANT_ISSUER
           and pa.oper_id                  = o.id
           and pa.participant_type         = com_api_const_pkg.PARTICIPANT_ACQUIRER
           and o.terminal_type             = acq_api_const_pkg.TERMINAL_TYPE_ATM
         group by cf.id;

    l_count                 com_api_type_pkg.t_long_id := 0;
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    
    l_fee_tab               com_api_type_pkg.t_long_tab;
    l_fin_mess_tab          com_api_type_pkg.t_long_tab;
    l_fee_type_tab          com_api_type_pkg.t_dict_tab;
    
    l_trace_conf            trc_config_pkg.trace_conf;
    
    BULK_LIMIT              number := 400;
    
    procedure put_debug_matched is
    begin
        if l_trace_conf.trace_level >= trc_config_pkg.DEBUG then
            for i in 1 .. l_fee_tab.count loop
                trc_log_pkg.debug(
                    i_text          => 'FEE [#1] matched with FINANCIAL MESSAGE [#2], fee type [#3]'
                  , i_env_param1    => l_fee_tab(i)
                  , i_env_param2    => l_fin_mess_tab(i)  
                  , i_env_param3    => l_fee_type_tab(i)  
                );
                
            end loop;
            
        end if;    
            
    end put_debug_matched;
    
begin
    trc_log_pkg.debug(
        i_text          => 'cup_prc_match_pkg.process_match'
    );
    
    l_trace_conf    := trc_config_pkg.get_trace_conf();
    
    savepoint process_matching_start;
    
    prc_api_stat_pkg.log_start;
    
    select count(1)
      into l_count
      from cup_fee cf
     where cf.match_status in (opr_api_const_pkg.OPERATION_MATCH_NOT_MATCHED
                             , opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH)
       and cf.fee_type      = cup_api_const_pkg.FT_INTERCHANGE
       and cf.inst_id       = i_inst_id
       and exists (select 1 
                     from aut_auth a
                        , opr_operation o
                        , opr_participant pi
                        , opr_participant pa
                    where a.system_trace_audit_number = cf.sys_trace_num
                      and o.oper_date                 = cf.transmission_date_time
                      and o.is_reversal               = cf.is_reversal
                      and a.id                        = o.id
                      and pi.oper_id                  = o.id
                      and pi.participant_type         = com_api_const_pkg.PARTICIPANT_ISSUER
                      and pa.oper_id                  = o.id
                      and pa.participant_type         = com_api_const_pkg.PARTICIPANT_ACQUIRER
                      and o.terminal_type             = acq_api_const_pkg.TERMINAL_TYPE_ATM);
       
    select count(1)
      into l_estimated_count
      from cup_fee cf
     where cf.match_status in (opr_api_const_pkg.OPERATION_MATCH_NOT_MATCHED
                             , opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH)
       and cf.fee_type      = cup_api_const_pkg.FT_INTERCHANGE
       and cf.inst_id       = i_inst_id
       and exists (select 1 
                     from cup_fin_message cm
                    where cm.acquirer_iin           = cf.acquirer_iin
                      and cm.forwarding_iin         = cf.forwarding_iin
                      and cm.sys_trace_num          = cf.sys_trace_num
                      and cm.transmission_date_time = cf.transmission_date_time
                      and cm.is_reversal            = cf.is_reversal
                      and (cm.trans_code           != cup_api_const_pkg.TC_DISPUTE
                           or cf.trans_type_id      = cup_api_const_pkg.TRANS_TYPE_DISPUTE_MANUAL)
                      and cm.inst_id                = i_inst_id);
       
    l_estimated_count := l_estimated_count + l_count;
    
    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_estimated_count
    );

    trc_log_pkg.debug (
        i_text      => 'Match processing starting for inst_id ' || i_inst_id
    );  
    
    open l_match_fin_cur;
    
    trc_log_pkg.debug (
        i_text      => 'Cursor fin messages opened'
    );
    
    loop
        fetch l_match_fin_cur bulk collect into l_fee_tab, l_fin_mess_tab, l_fee_type_tab limit BULK_LIMIT;

        trc_log_pkg.debug (
            i_text              => 'Step 1. l_fee_tab.count [#1]'
          , i_env_param1        => l_fee_tab.count
        );
        
        put_debug_matched;
        
        forall i in 1 .. l_fee_tab.count
            update cup_fee
               set match_status = opr_api_const_pkg.OPERATION_MATCH_MATCHED 
                 , fin_msg_id   = l_fin_mess_tab(i)
             where id in (l_fee_tab(i));    

        for i in 1 .. l_fee_tab.count loop
            cup_api_fin_message_pkg.create_fee_oper_stage(
                i_match_status  => opr_api_const_pkg.OPERATION_MATCH_MATCHED
              , i_fin_msg_id    => l_fin_mess_tab(i)
              , i_fee_type      => l_fee_type_tab(i)
            );
        end loop;

        l_processed_count := l_processed_count + l_fee_tab.count;
        
        prc_api_stat_pkg.log_current (
            i_current_count     => l_processed_count
          , i_excepted_count    => l_excepted_count
        );
        
        exit when l_match_fin_cur%notfound;
        
    end loop;
    
    close l_match_fin_cur;
    
    open l_match_oper_cur;

    trc_log_pkg.debug (
        i_text      => 'Cursor ATM transactions opened'
    );
    
    loop
        fetch l_match_oper_cur bulk collect into l_fee_tab, l_fin_mess_tab, l_fee_type_tab limit BULK_LIMIT;

        trc_log_pkg.debug (
            i_text              => 'Step 2. l_fee_tab.count [#1]'
          , i_env_param1        => l_fee_tab.count
        );
        
        put_debug_matched;
        
        forall i in 1 .. l_fee_tab.count
            update cup_fee
               set match_status = opr_api_const_pkg.OPERATION_MATCH_MATCHED 
                 , fin_msg_id = l_fin_mess_tab(i)
             where id in (l_fee_tab(i));    

        for i in 1 .. l_fee_tab.count loop
            cup_api_fin_message_pkg.create_fee_oper_stage(
                i_match_status  => opr_api_const_pkg.OPERATION_MATCH_MATCHED
              , i_fin_msg_id    => l_fin_mess_tab(i)
              , i_fee_type      => l_fee_type_tab(i)
            );
        end loop;

        l_processed_count := l_processed_count + l_fee_tab.count;
        
        prc_api_stat_pkg.log_current (
            i_current_count     => l_processed_count
          , i_excepted_count    => l_excepted_count
        );
        
        exit when l_match_oper_cur%notfound;
        
    end loop;
    
    close l_match_oper_cur;
    
    prc_api_stat_pkg.log_end (
        i_excepted_total     => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
    trc_log_pkg.debug(
        i_text          => 'Match finished'
    );
    
exception
    when others then
        rollback to savepoint process_matching_start;
        if l_match_fin_cur%isopen then 
            close   l_match_fin_cur;
            
        end if;

        if l_match_oper_cur%isopen then 
            close   l_match_oper_cur;
            
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
            
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
            
        end if;
        
        raise;
              
end process_match;

end cup_prc_match_pkg;
/
