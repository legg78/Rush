create or replace package body cst_bmed_prc_cmo_pkg is
/**********************************************************
 * Custom handlers for CMO-canal operations 
 * 
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 07.09.2016
 * Last changed by Gogolev I.(i.gogolev@bpcbt.com) at 
 * 07.09.2016 13:40:00
 *
 * Module: CST_BMED_PRC_CMO_PKG
 * @headcom
 **********************************************************/
procedure create_cmo_file(
    i_file_body_tab        in      cst_bmed_cmo_files_format_pkg.t_cmo_outg_file_body
  , i_call_prog            in      com_api_type_pkg.t_name
) is
    l_session_file_id      com_api_type_pkg.t_long_id;
    PROC_NAME              constant com_api_type_pkg.t_name := 'CREATE_CMO_FILE';
    
    l_file_content         clob;
begin
    
    trc_log_pkg.debug(
        i_text        => 'Subprocess [#1] is started'
      , i_env_param1  => i_call_prog||':'||PROC_NAME
    );
    
    prc_api_file_pkg.open_file(
        o_sess_file_id => l_session_file_id
    );
    
    trc_log_pkg.debug(
        i_text        => 'Subprocess [#1] open file success, file_id: [#2]'
      , i_env_param1  => i_call_prog||':'||PROC_NAME
      , i_env_param2  => to_char(l_session_file_id)
    );
    
    select  substr(
                p.file_name 
              , instr(p.file_name, '_', -1) + 1
              , instr(p.file_name, '.', -1) - (instr(p.file_name, '_', -1) + 1)
            )
    into    cst_bmed_cmo_files_format_pkg.g_cmo_outg_file_prc_data_rec.cmo_outg_file_id
    from    prc_session_file p
    where   p.id = l_session_file_id;
    
    trc_log_pkg.debug(
        i_text        => 'Subprocess [#1] get sequence part of the file name: [#2]'
      , i_env_param1  => i_call_prog||':'||PROC_NAME
      , i_env_param2  => to_char(cst_bmed_cmo_files_format_pkg.g_cmo_outg_file_prc_data_rec.cmo_outg_file_id)
    );
    
    cst_bmed_cmo_files_format_pkg.generate_cmo_outg_file(
        i_header         => cst_bmed_cmo_files_format_pkg.gen_header_cmo_out_file
      , i_body_tab       => i_file_body_tab
      , i_footer         => cst_bmed_cmo_files_format_pkg.gen_footer_cmo_out_file
      , o_file_content   => l_file_content
    );
    
    trc_log_pkg.debug(
        i_text        => 'Subprocess [#1] created content of the outgoing file, file_id: [#2]'
      , i_env_param1  => i_call_prog||':'||PROC_NAME
      , i_env_param2  => to_char(l_session_file_id)
    );
    
    prc_api_file_pkg.put_file(
        i_sess_file_id => l_session_file_id
      , i_clob_content => l_file_content
    );
    
    trc_log_pkg.debug(
        i_text        => 'Subprocess [#1] content put into file success, file_id: [#2]'
      , i_env_param1  => i_call_prog||':'||PROC_NAME
      , i_env_param2  => to_char(l_session_file_id)
    );
    
    prc_api_file_pkg.close_file(
        i_sess_file_id => l_session_file_id
      , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );
    
    trc_log_pkg.debug(
        i_text        => 'Subprocess [#1] file close success, file_id: [#2]'
      , i_env_param1  => i_call_prog||':'||PROC_NAME
      , i_env_param2  => to_char(l_session_file_id)
    );
    
exception
    when others then
       trc_log_pkg.debug(
            i_text        => 'Subprocess [#1] is finished with errors: [#2]'
          , i_env_param1  => i_call_prog||':'||PROC_NAME
          , i_env_param2  => sqlcode
        );
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
          then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
         
        raise;
end;

procedure unloading_cmo_file(
    i_network_id in        com_api_type_pkg.t_network_id
) is
    PROC_NAME              constant com_api_type_pkg.t_name := 'CST_BMED_PRC_CMO_PKG.UNLOADING_CMO_FILE';
    
    
    l_estimated_count      com_api_type_pkg.t_long_id    := 0;
    l_processed_count      com_api_type_pkg.t_long_id    := 0;
    l_excepted_count       com_api_type_pkg.t_long_id    := 0;
    l_rejected_count       com_api_type_pkg.t_long_id    := 0;
    
    l_file_body            cst_bmed_cmo_files_format_pkg.t_cmo_outg_file_body;

begin
    
    prc_api_stat_pkg.log_start;
        
    trc_log_pkg.debug(
        i_text        => 'Process [#1] is started'
      , i_env_param1  => PROC_NAME
    );
    
    select  cst_bmed_cmo_files_format_pkg.gen_body_row_cmo_out_file(
                cst_bmed_cmo_files_format_pkg.BODY_ROW_FILE_OUTG_MARK
              , merchant_number
              , merchant_name
              , terminal_number
              , oper_date
              , card_number
              , oper_currency
              , sign_oper
              , oper_amount
              , cst_bmed_cmo_files_format_pkg.TRS_TYPE_FILE_OUTG_MARK
              , sign_oper
              , commis
              , auth_code
              , acq_inst_bin
              , ev_id
            )
     bulk collect
     into   l_file_body
     from
            (
                select eo.id as ev_id,
                       oo.merchant_number,
                       oo.merchant_name,
                       oo.terminal_number,
                       oo.oper_date,
                       oc.card_number,
                       oo.oper_currency,
                       decode(
                           oo.is_reversal
                         , 0, cst_bmed_cmo_files_format_pkg.TRS_DIRECT
                         , 1, cst_bmed_cmo_files_format_pkg.TRS_REVERSAL
                         , null
                       ) as sign_oper,
                       oo.oper_amount,
                       sum(case 
                               when am.amount_purpose like cst_bmed_cmo_files_format_pkg.CONDITION_SEARCH_FEE 
                                   then am.amount 
                               else 0 
                           end
                       ) as commis,
                       opr.auth_code,
                       oo.acq_inst_bin
                 from  evt_event_object eo,
                       opr_operation oo,
                       opr_card oc,
                       opr_participant opr,
                       acc_macros am
                where  decode(eo.status, evt_api_const_pkg.EVENT_STATUS_READY, eo.procedure_name, null) = PROC_NAME
                   and oo.id = eo.object_id
                   and oc.oper_id = oo.id
                   and oc.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                   and opr.oper_id = oo.id
                   and opr.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                   and opr.network_id = i_network_id
                   and opr.oper_id = am.object_id(+)
                   and opr.account_id = am.account_id(+)
             group by  eo.id, oo.merchant_number, oo.merchant_name,
                       oo.terminal_number, oo.oper_date, oc.card_number,
                       oo.oper_currency, oo.is_reversal, oo.oper_amount,
                       opr.auth_code, oo.acq_inst_bin
            );
    
    l_estimated_count := nvl(cst_bmed_cmo_files_format_pkg.g_cmo_outg_file_prc_data_rec.count_oper, 0);
    
    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_estimated_count
    );
    
    if l_estimated_count > 0
    then
        create_cmo_file(
            i_file_body_tab     => l_file_body
          , i_call_prog         => PROC_NAME
        );
    end if;
    
    l_processed_count := nvl(cst_bmed_cmo_files_format_pkg.g_cmo_outg_file_prc_data_rec.count_oper, 0);
    
    if cst_bmed_cmo_files_format_pkg.g_cmo_outg_file_prc_data_rec.evnt_id_tab.count > 0
    then
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => cst_bmed_cmo_files_format_pkg.g_cmo_outg_file_prc_data_rec.evnt_id_tab
        );
        trc_log_pkg.debug(
            i_text        => 'Process [#1]: processed success [#2] event records'
          , i_env_param1  => PROC_NAME
          , i_env_param2  => cst_bmed_cmo_files_format_pkg.g_cmo_outg_file_prc_data_rec.evnt_id_tab.count
        );
    end if;
    
    trc_log_pkg.debug(
        i_text        => 'Process [#1] is finished success'
      , i_env_param1  => PROC_NAME
    );

    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    
exception
    when others then
       trc_log_pkg.debug(
            i_text        => 'Process [#1] is finished with errors: [#2]'
          , i_env_param1  => PROC_NAME
          , i_env_param2  => sqlcode
        );
        
        l_excepted_count := nvl(cst_bmed_cmo_files_format_pkg.g_cmo_outg_file_prc_data_rec.count_oper, 0);
        
        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE
          then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
         
        raise;
end;
end;
/
