create or replace package body cst_smic_prc_outgoing_pkg is
/*********************************************************
*  SMIC custom outgoing proceses <br />
*  Created by Gogolev I. (i.gogolev@bpcbt.com) at 01.03.2019 <br />
*  Module: CST_SMIC_PRC_OUTGOING_PKG <br />
*  @headcom
**********************************************************/

CRLF           constant  com_api_type_pkg.t_name := chr(13) || chr(10);

procedure uploading_rtgs(
    i_sttl_day                      in  com_api_type_pkg.t_short_id
  , i_account_type                  in  com_api_type_pkg.t_dict_value   default null
) is
    type t_entries_data_rec is record(
        inst_id         com_api_type_pkg.t_inst_id
      , account_num     com_api_type_pkg.t_name
      , balance_sum     com_api_type_pkg.t_money
    );
    type t_entries_data_tab is table of t_entries_data_rec index by binary_integer;
    
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.uploading_rtgs: ';
    
    l_estimate_count       simple_integer := 0;
    l_expected_count       simple_integer := 0;
    l_processed_count      simple_integer := 0;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_file_name            com_api_type_pkg.t_name;
    l_record               com_api_type_pkg.t_text;
    l_container_id         com_api_type_pkg.t_long_id    :=  prc_api_session_pkg.get_container_id;
    l_params               com_api_type_pkg.t_param_tab;
    
    l_event_tab            com_api_type_pkg.t_number_tab;
    l_entries_data_tab     t_entries_data_tab;
    
    l_sttl_curr_name       com_api_type_pkg.t_curr_name;
    l_sttl_currency        com_api_type_pkg.t_curr_code;
    l_sender_identifier    com_api_type_pkg.t_attr_name;
    l_reciever_identifier  com_api_type_pkg.t_attr_name;
    l_tran_ttc_data        com_api_type_pkg.t_attr_name;
    
    l_eff_date             date;
    l_total_sum            com_api_type_pkg.t_long_id := 0;
    l_session_file_id      com_api_type_pkg.t_long_id;
    l_session_id           com_api_type_pkg.t_long_id;

    cursor evt_object_cur is
        select o.id
          from evt_event_object o
             , evt_event e
             , acc_entry ae
             , acc_gl_account_mvw gl
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_SMIC_PRC_OUTGOING_PKG.UPLOADING_RTGS'
           and o.entity_type      = acc_api_const_pkg.ENTITY_TYPE_ENTRY
           and o.eff_date        <= l_eff_date
           and e.id               = o.event_id
           and e.event_type       = acc_api_const_pkg.EVENT_ENTRY_POSTING
           and ae.id              = o.object_id
           and ae.currency        = l_sttl_currency
           and ae.sttl_day        = i_sttl_day
           and gl.entity_id       = o.inst_id
           and gl.entity_type     = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
           and gl.account_type   in (cst_smic_api_const_pkg.INSTITUTE_GL_TRN_ACCOUNT, cst_smic_api_const_pkg.INSTITUTE_GL_FEE_ACCOUNT)
           and gl.currency        = ae.currency
           and gl.account_type    = nvl(i_account_type, gl.account_type);
           
    cursor entries_cur is
        select o.inst_id
             , set_ui_value_pkg.get_inst_param_v(
                   i_param_name => cst_smic_api_const_pkg.BIC_INST_PARAM
                 , i_inst_id    => o.inst_id
               )
            || '/'
            || set_ui_value_pkg.get_inst_param_v(
                   i_param_name => cst_smic_api_const_pkg.ACH_ACCOUNT_INST_PARAM
                 , i_inst_id    => o.inst_id
               ) as inst_gl_account
             , sum(ae.balance) as balance
          from evt_event_object o
             , evt_event e
             , acc_entry ae
             , acc_gl_account_mvw gl
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_SMIC_PRC_OUTGOING_PKG.UPLOADING_RTGS'
           and o.entity_type      = acc_api_const_pkg.ENTITY_TYPE_ENTRY
           and o.eff_date        <= l_eff_date
           and e.id               = o.event_id
           and e.event_type       = acc_api_const_pkg.EVENT_ENTRY_POSTING
           and ae.id              = o.object_id
           and ae.currency        = l_sttl_currency
           and ae.sttl_day        = i_sttl_day
           and ae.balance_impact in (com_api_const_pkg.DEBIT, com_api_const_pkg.CREDIT)
           and ae.status         <> acc_api_const_pkg.ENTRY_STATUS_CANCELED
           and gl.entity_id       = o.inst_id
           and gl.entity_type     = ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
           and gl.account_type   in (cst_smic_api_const_pkg.INSTITUTE_GL_TRN_ACCOUNT, cst_smic_api_const_pkg.INSTITUTE_GL_FEE_ACCOUNT)
           and gl.currency        = ae.currency
           and gl.account_type    = nvl(i_account_type, gl.account_type)
         group by
               o.inst_id
         order by
               o.inst_id;

begin
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    l_eff_date      := com_api_sttl_day_pkg.get_calc_date;
    
    l_file_name     := 'SMT201_' || i_sttl_day || '_' || to_char(l_eff_date, 'ddmmyyyy_hh24miss');
    
    l_sttl_curr_name := set_ui_value_pkg.get_system_param_v(
                            i_param_name => cst_smic_api_const_pkg.CURRENCY_CHAR_SYSTEM_PARAM
                        );
    l_sttl_currency :=
        com_api_currency_pkg.get_currency_code(
            i_curr_name => set_ui_value_pkg.get_system_param_v(
                               i_param_name => cst_smic_api_const_pkg.CURRENCY_CHAR_SYSTEM_PARAM
                           )
        );
    l_sender_identifier   := set_ui_value_pkg.get_system_param_v(
                                 i_param_name => cst_smic_api_const_pkg.SENDER_IDN_SYSTEM_PARAM
                             );
    l_reciever_identifier := set_ui_value_pkg.get_system_param_v(
                                 i_param_name => cst_smic_api_const_pkg.RECIEVER_IDN_SYSTEM_PARAM
                             );
    l_tran_ttc_data       := set_ui_value_pkg.get_system_param_v(
                                 i_param_name => cst_smic_api_const_pkg.TRAN_TTC_SYSTEM_PARAM
                             );
    l_session_id          := get_session_id;
                          
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'settlement_currency=#1, '
                             || 'sender_identifier=#2, '
                             || 'reciever_identifier=#3, '
                             || 'Specific RTGS for tag 72=#4, account type =#5, '
                             || 'l_session_id=' || l_session_id || ', '
                             || 'setlement_day=' || i_sttl_day || ', '
                             || 'l_eff_date=#6, '
                             || 'file name=' || l_file_name
      , i_env_param1 => l_sttl_currency
      , i_env_param2 => l_sender_identifier
      , i_env_param3 => l_reciever_identifier
      , i_env_param4 => l_tran_ttc_data
      , i_env_param5 => nvl(i_account_type, cst_smic_api_const_pkg.INSTITUTE_GL_TRN_ACCOUNT || ' and ' || cst_smic_api_const_pkg.INSTITUTE_GL_FEE_ACCOUNT)
      , i_env_param6 => l_eff_date
    );
    
    prc_api_stat_pkg.log_start;

    open evt_object_cur;
    
    fetch evt_object_cur 
     bulk collect 
     into l_event_tab;
     
    close evt_object_cur;
     
    l_estimate_count := l_event_tab.count;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimate_count
    );
    
    open entries_cur;
        
    fetch entries_cur
     bulk collect
     into l_entries_data_tab;
         
    close entries_cur;
        
    for i in 1 .. l_entries_data_tab.count
    loop
        l_total_sum := l_total_sum + abs(l_entries_data_tab(i).balance_sum);
    end loop;
        
    prc_api_file_pkg.open_file (
        o_sess_file_id  => l_session_file_id
      , i_file_name     => l_file_name
      , i_file_type     => l_file_type
      , io_params       => l_params
    );
         
    l_record := '{1:F01'
             || rpad(l_reciever_identifier, 12, 'X')
             || i_sttl_day
             || substr(to_char(l_session_id),-10)
             || '}{2:O298'
             || to_char(l_eff_date, 'hh24miyymmdd')
             || rpad(l_sender_identifier, 12, 'X')
             || substr(to_char(l_session_id),-10)
             || to_char(l_eff_date, 'yymmddhh24mi')
             || 'N}{4:'
             || CRLF
             || ':20:'
             || to_char(l_eff_date, 'yymmdd')
             || substr(to_char(l_session_id),1, 6)
             || CRLF
             || ':12:201'
             || CRLF
             || ':77E:'
             || CRLF
             || ':M01:'
             || to_char(l_eff_date, 'yymmdd')
             || l_sttl_curr_name
             || com_api_currency_pkg.get_amount_str(
                    i_amount         => l_total_sum
                  , i_curr_code      => l_sttl_currency
                  , i_mask_curr_code => com_api_const_pkg.TRUE
                )
    ;
                 
    prc_api_file_pkg.put_line(
        i_raw_data      => l_record
      , i_sess_file_id  => l_session_file_id
    );
    prc_api_file_pkg.put_file(
        i_sess_file_id   => l_session_file_id
      , i_clob_content   => l_record || CRLF
      , i_add_to         => com_api_const_pkg.TRUE
    );
        
    for i in 1 .. l_entries_data_tab.count
    loop
        l_record := ':16R:RSN'
                 || CRLF
                 || case
                        when l_entries_data_tab(i).balance_sum >= 0
                            then ':M2C:'
                        else ':M2D:'
                    end
                 || com_api_currency_pkg.get_amount_str(
                        i_amount         => abs(l_entries_data_tab(i).balance_sum)
                      , i_curr_code      => l_sttl_currency
                      , i_mask_curr_code => com_api_const_pkg.TRUE
                    )
                 || CRLF
                 || ':M03:' || l_entries_data_tab(i).account_num
                 || CRLF
                 || ':16S:RSN'
        ;
            
        prc_api_file_pkg.put_line(
            i_raw_data      => l_record
          , i_sess_file_id  => l_session_file_id
        );
        prc_api_file_pkg.put_file(
            i_sess_file_id   => l_session_file_id
          , i_clob_content   => l_record || CRLF
          , i_add_to         => com_api_const_pkg.TRUE
        );
    end loop;

    l_record := ':72:/TTC/' || l_tran_ttc_data
             || CRLF
             || '-}'
    ;
             
    prc_api_file_pkg.put_line(
        i_raw_data      => l_record
      , i_sess_file_id  => l_session_file_id
    );
    prc_api_file_pkg.put_file(
        i_sess_file_id   => l_session_file_id
      , i_clob_content   => l_record
      , i_add_to         => com_api_const_pkg.TRUE
    );
    
    prc_api_file_pkg.close_file(
        i_sess_file_id => l_session_file_id
      , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
    );
    
    evt_api_event_pkg.process_event_object(
        i_event_object_id_tab => l_event_tab
    );
    l_processed_count := l_estimate_count;
    
    prc_api_stat_pkg.log_end(
        i_processed_total  => l_processed_count
      , i_excepted_total   => l_expected_count
      , i_rejected_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug(LOG_PREFIX || 'END');

exception
    when others then
        prc_api_stat_pkg.log_end(
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
end uploading_rtgs;

end cst_smic_prc_outgoing_pkg;
/
