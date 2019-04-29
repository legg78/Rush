create or replace package body bgn_prc_match_pkg as

procedure process_match(
    i_inst_id       in      com_api_type_pkg.t_inst_id
) is
    cursor l_match_cur is
        select auth.id
             , oper.id
          from opr_operation auth
             , opr_operation oper
             , opr_participant a_iss
             , opr_participant o_iss
             , opr_participant a_acq
             , opr_participant o_acq
             , opr_card a_card
             , opr_card o_card
             , bgn_fin fin
             , bgn_file f
         where decode(auth.match_status, opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH, auth.match_status, null) = opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH
           and auth.msg_type in  (opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                                , opr_api_const_pkg.MESSAGE_TYPE_PREAUTHORIZATION
                                , opr_api_const_pkg.MESSAGE_TYPE_COMPLETION)
           and a_iss.oper_id = auth.id
           and a_iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and auth.is_reversal = oper.is_reversal
           and a_acq.oper_id = auth.id
           and a_acq.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
           and a_acq.inst_id = i_inst_id 
           and a_card.oper_id = auth.id
           and a_card.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           
           and oper.msg_type = opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT
           and decode(oper.match_status, opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH, oper.match_status, null) = opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH
           and o_iss.oper_id = oper.id
           and o_iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           and o_acq.oper_id = oper.id
           and o_acq.participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER
           and o_acq.inst_id = i_inst_id 
           and o_card.oper_id = oper.id
           and o_card.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
           
           and oper.id = fin.id
           and fin.file_id = f.id
           and f.file_type = bgn_api_const_pkg.FILE_TYPE_BORICA_FO
           
           and o_iss.inst_id = bgn_api_const_pkg.BORICA_INST_ID
           and o_card.card_number = a_card.card_number
           and oper.terminal_number = auth.terminal_number
           and o_iss.auth_code = a_iss.auth_code
           and trunc(oper.oper_date) = trunc(auth.oper_date)
           and oper.oper_amount = auth.oper_amount
           and oper.oper_currency = auth.oper_currency;         
           
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    
    l_auth_tab              com_api_type_pkg.t_long_tab;
    l_oper_tab              com_api_type_pkg.t_long_tab;
    
    BULK_LIMIT              number := 400;
    
    procedure put_debug_matched is
    begin
        if trc_config_pkg.is_debug = com_api_type_pkg.TRUE then
            for i in 1 .. l_auth_tab.count loop
                trc_log_pkg.debug(
                    i_text          => 'AUTH [#1] matched with CLEARING [#2]'
                  , i_env_param1    => l_auth_tab(i)
                  , i_env_param2    => l_oper_tab(i)  
                );
                
            end loop;
            
        end if;    
            
    end put_debug_matched;
    
begin
    trc_log_pkg.debug(
        i_text          => 'bgn_prc_match_pkg.process_match'
    );
    
    savepoint process_matching_start;
    
    prc_api_stat_pkg.log_start;
    
    select count(1)
      into l_estimated_count
      from opr_operation oper
         , opr_participant o_iss
         , bgn_fin fin
         , bgn_file f
     where oper.id = o_iss.oper_id
       and decode(oper.match_status, opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH, oper.match_status, null) = opr_api_const_pkg.OPERATION_MATCH_REQ_MATCH
       and o_iss.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER    
       and o_iss.inst_id = bgn_api_const_pkg.BORICA_INST_ID   
       and oper.id = fin.id
       and fin.file_id = f.id
       and f.file_type = bgn_api_const_pkg.FILE_TYPE_BORICA_FO;
       
    prc_api_stat_pkg.log_estimation (
        i_estimated_count => l_estimated_count
    );

    trc_log_pkg.debug (
        i_text      => 'Match processing starting for inst_id ' || i_inst_id
    );  
    
    open l_match_cur;
    
    trc_log_pkg.debug (
        i_text      => 'Cursor opened'
    );
    
    loop
        fetch l_match_cur bulk collect into l_auth_tab, l_oper_tab limit BULK_LIMIT;
        
        forall i in 1 .. l_auth_tab.count
            update opr_operation
               set match_status = opr_api_const_pkg.OPERATION_MATCH_MATCHED 
                 , match_id = decode(id, l_auth_tab(i), l_oper_tab(i), l_auth_tab(i))
             where id in (l_auth_tab(i), l_oper_tab(i));    
        
        prc_api_stat_pkg.log_current (
            i_current_count     => l_processed_count
          , i_excepted_count    => l_excepted_count
        );
        
        put_debug_matched;
        
        exit when l_match_cur%notfound;
        
    end loop;
    
    close l_match_cur;
    
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
        if l_match_cur%isopen then 
            close   l_match_cur;
            
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
              
end;

end bgn_prc_match_pkg;
/
