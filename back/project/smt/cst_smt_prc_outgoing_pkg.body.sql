create or replace package body cst_smt_prc_outgoing_pkg is
/************************************************************
 * Processes for unloading files <br />
 * Created by Gogolev I.(i.gogolev@bpcbt.com)  at 06.12.2018 <br />
 * Last changed by $Author: Gogolev I. $ <br />
 * $LastChangedDate:: #$ <br />
 * Revision: $LastChangedRevision:  $ <br />
 * Module: cst_smt_prc_outgoing_pkg <br />
 * @headcom
 ***********************************************************/

CRLF           constant  com_api_type_pkg.t_name := chr(13) || chr(10);

function create_detail_row_ptlf
return com_api_type_pkg.t_text
is
begin
    return 'DR'
        || '01'
        || opr_api_shared_data_pkg.g_iss_participant.network_id
        || opr_api_shared_data_pkg.g_iss_participant.inst_id
        || opr_api_shared_data_pkg.g_iss_participant.card_number
        || opr_api_shared_data_pkg.g_acq_participant.network_id
        || opr_api_shared_data_pkg.g_acq_participant.inst_id
        || lpad(opr_api_shared_data_pkg.g_operation.merchant_number, 19, ' ')
        || lpad(opr_api_shared_data_pkg.g_operation.terminal_number, 16, ' ')
        || lpad('0', 3, ' ')
        || case
               when nvl(opr_api_shared_data_pkg.g_auth.is_reversal, com_api_const_pkg.FALSE) =  com_api_const_pkg.TRUE
                   then '420'
               when nvl(opr_api_shared_data_pkg.g_auth.is_advice, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE
                   then '210'
               else
                   '220'
           end
        || case
               when opr_api_shared_data_pkg.g_iss_participant.network_id = cst_smt_api_const_pkg.LOCAL_INSTITUTION
                   then '1'
               else
                   '7'
           end
        || case
               when opr_api_shared_data_pkg.g_acq_participant.network_id = cst_smt_api_const_pkg.LOCAL_INSTITUTION
                   then '3'
               else
                   '7'
           end
        || to_char(opr_api_shared_data_pkg.g_operation.host_date, cst_smt_api_const_pkg.MSSTRXN_DATE)
        || to_char(opr_api_shared_data_pkg.g_operation.host_date, cst_smt_api_const_pkg.MSSTRXN_TIME_TRANSFORM) || '00'
        || lpad(
               aup_api_tag_pkg.get_tag_value(
                   i_auth_id        => opr_api_shared_data_pkg.g_auth.id
                 , i_tag_reference  => cst_smt_api_const_pkg.TAG_DEVICE_SEQ_NUMBER
               )
             , 12
             , ' '
           )
        || lpad(
               substr(
                   opr_api_shared_data_pkg.g_operation.merchant_name || opr_api_shared_data_pkg.g_operation.merchant_street
                 , 1
                 , 25
               )
             , 25
             , ' '
           )
        || lpad(
               substr(
                   com_api_flexible_data_pkg.get_flexible_value(
                       i_field_name  => cst_smt_api_const_pkg.FLX_ADDIT_INST_NAME_PTDF
                     , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                     , i_object_id   => opr_api_shared_data_pkg.g_acq_participant.inst_id
                   )
                 , 1
                 , 22
               )
             , 22
             , ' '
           )
        || lpad(opr_api_shared_data_pkg.g_operation.merchant_city, 13, ' ')
        || lpad(opr_api_shared_data_pkg.g_operation.merchant_region, 3, ' ')
        || lpad(opr_api_shared_data_pkg.g_operation.merchant_country, 2, ' ')
        || lpad(opr_api_shared_data_pkg.g_operation.mcc, 4, ' ')
        || lpad(
               com_api_array_pkg.conv_array_elem_v(
                   i_lov_id        => opr_api_const_pkg.LOV_ID_OPERATION_TYPES
                 , i_array_type_id => cst_smt_api_const_pkg.OPER_TYPE_ARRAY_TYPE
                 , i_array_id      => cst_smt_api_const_pkg.PTLF_OPER_TYPE_ARRAY
                 , i_elem_value    => opr_api_shared_data_pkg.g_operation.oper_type
                 , i_mask_error    => com_api_const_pkg.TRUE
               )
             , 2
             , ' '
           )
        || '  0'
        || lpad(opr_api_shared_data_pkg.g_operation.oper_request_amount, 19, ' ')
        || lpad(opr_api_shared_data_pkg.g_operation.oper_amount, 19, ' ')
        || to_char(opr_api_shared_data_pkg.g_iss_participant.card_expir_date, 'yymm')
        || rpad(
               aup_api_tag_pkg.get_tag_value(
                   i_auth_id       => opr_api_shared_data_pkg.g_auth.id
                 , i_tag_reference => cst_smt_api_const_pkg.TAG_INVOCE
               )
             , 10
             , ' '
           )
        || lpad(opr_api_shared_data_pkg.g_iss_participant.auth_code, 8, ' ')
        || case
               when
                   opr_api_shared_data_pkg.g_operation.oper_type in (
                       opr_api_const_pkg.OPERATION_TYPE_PURCHASE
                     , opr_api_const_pkg.OPERATION_TYPE_REFUND
                   )
                   then '1'
               else '0'
           end
        || case opr_api_shared_data_pkg.g_operation.status_reason
               when
                   'RESP0049'
                   then '08'
               else '00'
           end
        || opr_api_shared_data_pkg.g_operation.oper_currency
        || '0'
        || lpad('0', 16, '0')
        || rpad('!', 2, ' ')
        || rpad(' ', 166, ' ')
        || rpad('!', 2, ' ')
        || rpad(' ', 88, ' ')
        || rpad('!', 2, ' ')
        || rpad(' ', 28, ' ')
        || rpad('!', 2, ' ')
        || rpad(' ', 46, ' ')
        || rpad('!', 2, ' ')
        || rpad(' ', 34, ' ')
        || lpad(opr_api_shared_data_pkg.g_auth.external_auth_id, 12, ' ')
        || lpad('-1', 3, ' ')
        || lpad(' ', 100, ' ')
        || 'ER';
end create_detail_row_ptlf;

function create_detail_row_tlf
return com_api_type_pkg.t_text
is
begin
    return 'DR'
        || '01'
        || opr_api_shared_data_pkg.g_acq_participant.network_id
        || opr_api_shared_data_pkg.g_acq_participant.inst_id
        || lpad(opr_api_shared_data_pkg.g_operation.terminal_number, 16, ' ')
        || opr_api_shared_data_pkg.g_iss_participant.network_id
        || opr_api_shared_data_pkg.g_iss_participant.inst_id
        || opr_api_shared_data_pkg.g_iss_participant.card_number
        || case
               when nvl(opr_api_shared_data_pkg.g_auth.is_reversal, com_api_const_pkg.FALSE) =  com_api_const_pkg.TRUE
                   then '420'
               when nvl(opr_api_shared_data_pkg.g_auth.is_advice, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE
                   then '210'
               else
                   '220'
           end
        || case
               when opr_api_shared_data_pkg.g_iss_participant.network_id = cst_smt_api_const_pkg.LOCAL_INSTITUTION
                   then '1'
               else
                   '7'
           end
        || case
               when opr_api_shared_data_pkg.g_acq_participant.network_id = cst_smt_api_const_pkg.LOCAL_INSTITUTION
                   then '3'
               else
                   '7'
           end
        || to_char(opr_api_shared_data_pkg.g_operation.host_date, cst_smt_api_const_pkg.MSSTRXN_DATE)
        || to_char(opr_api_shared_data_pkg.g_operation.host_date, cst_smt_api_const_pkg.MSSTRXN_TIME_TRANSFORM) || '00'
        || lpad(
               aup_api_tag_pkg.get_tag_value(
                   i_auth_id        => opr_api_shared_data_pkg.g_auth.id
                 , i_tag_reference  => cst_smt_api_const_pkg.TAG_DEVICE_SEQ_NUMBER
               )
             , 12
             , ' '
           )
        || lpad(
               com_api_array_pkg.conv_array_elem_v(
                   i_lov_id        => opr_api_const_pkg.LOV_ID_OPERATION_TYPES
                 , i_array_type_id => cst_smt_api_const_pkg.OPER_TYPE_ARRAY_TYPE
                 , i_array_id      => cst_smt_api_const_pkg.TLF_OPER_TYPE_ARRAY
                 , i_elem_value    => opr_api_shared_data_pkg.g_operation.oper_type
                 , i_mask_error    => com_api_const_pkg.TRUE
               )
             , 2
             , ' '
           )
        || '  '
        || '  '
        || lpad(opr_api_shared_data_pkg.g_operation.oper_request_amount, 19, ' ')
        || lpad(opr_api_shared_data_pkg.g_operation.oper_amount, 19, ' ')
        || '0'
        || '00'
        || lpad(opr_api_shared_data_pkg.g_iss_participant.auth_code, 8, ' ')
        || to_char(opr_api_shared_data_pkg.g_iss_participant.card_expir_date, 'yymm')
        || lpad(
               substr(
                   opr_api_shared_data_pkg.g_operation.merchant_name || opr_api_shared_data_pkg.g_operation.merchant_street
                 , 1
                 , 25
               )
             , 25
             , ' '
           )
        || lpad(
               substr(
                   com_api_flexible_data_pkg.get_flexible_value(
                       i_field_name  => cst_smt_api_const_pkg.FLX_ADDIT_INST_NAME_PTDF
                     , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                     , i_object_id   => opr_api_shared_data_pkg.g_acq_participant.inst_id
                   )
                 , 1
                 , 22
               )
             , 22
             , ' '
           )
        || lpad(opr_api_shared_data_pkg.g_operation.merchant_city, 13, ' ')
        || lpad(opr_api_shared_data_pkg.g_operation.merchant_region, 3, ' ')
        || lpad(opr_api_shared_data_pkg.g_operation.merchant_country, 2, ' ')
        || opr_api_shared_data_pkg.g_operation.oper_currency
        || case opr_api_shared_data_pkg.g_operation.status_reason
               when
                   'RESP0049'
                   then '08'
               else '00'
           end
        || rpad('!', 2, ' ')
        || rpad(' ', 166, ' ')
        || rpad('!', 2, ' ')
        || rpad(' ', 88, ' ')
        || rpad('!', 2, ' ')
        || rpad(' ', 28, ' ')
        || rpad('!', 2, ' ')
        || rpad(' ', 46, ' ')
        || lpad(opr_api_shared_data_pkg.g_auth.external_auth_id, 12, ' ')
        || lpad('-1', 3, ' ')
        || lpad(' ', 100, ' ')
        || 'ER';
end create_detail_row_tlf;

procedure process_msstrxn(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_network_id            in     com_api_type_pkg.t_network_id
  , i_participant_type      in     com_api_type_pkg.t_dict_value     default com_api_const_pkg.PARTICIPANT_ISSUER
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_msstrxn: ';
    
    l_estimate_count       simple_integer := 0;
    l_expected_count       simple_integer := 0;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_file_name            com_api_type_pkg.t_name;
    l_record               com_api_type_pkg.t_text;
    l_container_id         com_api_type_pkg.t_long_id    :=  prc_api_session_pkg.get_container_id;
    l_params               com_api_type_pkg.t_param_tab;
    l_participant_type     com_api_type_pkg.t_dict_value := nvl(i_participant_type, com_api_const_pkg.PARTICIPANT_ISSUER);

    l_event_tab            com_api_type_pkg.t_number_tab;
    l_operation_id_tab     num_tab_tpt                   := num_tab_tpt();
    l_eff_date             date;
    l_total_count          com_api_type_pkg.t_medium_id  := 0;
    l_session_file_id      com_api_type_pkg.t_long_id;

    cursor evt_object_cur is
        select o.id
             , o.object_id
          from evt_event_object o
             , evt_event e
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_SMT_PRC_OUTGOING_PKG.PROCESS_MSSTRXN'
           and o.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and o.eff_date      <= l_eff_date
           and o.inst_id        = i_inst_id
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and e.id             = o.event_id
           and e.event_type     = cst_smt_api_const_pkg.MNO_OPERATION_EVENT
           and exists(select 1
                        from opr_participant p
                       where p.oper_id = o.object_id
                         and p.participant_type = l_participant_type
                         and p.network_id = i_network_id
               );

begin
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    l_eff_date      := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id);

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'inst_id=#1, network_id=#2, participant=#3, file_type=#4, l_container_id=#5, l_eff_date=#6'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_network_id
      , i_env_param3 => l_participant_type
      , i_env_param4 => l_file_type
      , i_env_param5 => l_container_id
      , i_env_param6 => l_eff_date
    );
    
    prc_api_stat_pkg.log_start;

    select count(*) as cnt
      into l_estimate_count
      from evt_event_object o
         , evt_event e
     where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_SMT_PRC_OUTGOING_PKG.PROCESS_MSSTRXN'
       and o.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and o.eff_date      <= l_eff_date
       and o.inst_id        = i_inst_id
       and o.split_hash    in (select split_hash from com_api_split_map_vw)
       and e.id             = o.event_id
       and e.event_type     = cst_smt_api_const_pkg.MNO_OPERATION_EVENT
       and exists(select 1
                    from opr_participant p
                   where p.oper_id = o.object_id
                     and p.participant_type = l_participant_type
                     and p.network_id = i_network_id
           );

    trc_log_pkg.debug('Estimate count = [' || l_estimate_count || ']');

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimate_count
    );
    
    prc_api_file_pkg.open_file (
        o_sess_file_id  => l_session_file_id
      , i_file_type     => l_file_type
      , io_params       => l_params
    );

    select  p.file_name
      into  l_file_name
      from  prc_session_file p
     where  p.id = l_session_file_id;
     
    l_record := 'FH'
             || to_date(l_eff_date, 'yymmdd')
             || to_char(systimestamp, 'hh24missff2')
             || i_network_id
             || 'PTLF'
             || lpad(l_file_name, 35, ' ')
             || 'EFH';
             
    prc_api_file_pkg.put_line(
        i_raw_data      => l_record
      , i_sess_file_id  => l_session_file_id
    );
    prc_api_file_pkg.put_file(
        i_sess_file_id   => l_session_file_id
      , i_clob_content   => l_record || CRLF
      , i_add_to         => com_api_const_pkg.TRUE
    );
    
    if l_estimate_count > 0 then

        l_params.delete;
        rul_api_param_pkg.set_param (
              i_name     => 'INST_ID'
            , i_value    => i_inst_id
            , io_params  => l_params
        );

        open evt_object_cur;
        fetch evt_object_cur 
         bulk collect 
         into l_event_tab
            , l_operation_id_tab;

        for i in 1 .. l_operation_id_tab.count loop
            opr_api_shared_data_pkg.g_operation       := null;
            opr_api_shared_data_pkg.g_iss_participant := null;
            opr_api_shared_data_pkg.g_acq_participant := null;
            opr_api_shared_data_pkg.g_auth            := null;
            
            opr_api_operation_pkg.get_operation(
                i_oper_id   => l_operation_id_tab(i)
              , o_operation => opr_api_shared_data_pkg.g_operation
            );
            
            opr_api_operation_pkg.get_participant(
                i_oper_id           => l_operation_id_tab(i)
              , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
              , o_participant       => opr_api_shared_data_pkg.g_iss_participant
            );
            
            opr_api_operation_pkg.get_participant(
                i_oper_id           => l_operation_id_tab(i)
              , i_participaint_type => com_api_const_pkg.PARTICIPANT_ACQUIRER
              , o_participant       => opr_api_shared_data_pkg.g_acq_participant
            );

            opr_api_shared_data_pkg.g_auth := aut_api_auth_pkg.get_auth(i_id => l_operation_id_tab(i));

            -- Checks
               -- 1. Check on MTI define
            if (nvl(opr_api_shared_data_pkg.g_auth.is_reversal, com_api_const_pkg.FALSE) =  com_api_const_pkg.TRUE 
                or (opr_api_shared_data_pkg.g_operation.msg_type = opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                    and nvl(opr_api_shared_data_pkg.g_auth.is_advice, com_api_const_pkg.FALSE) in (com_api_const_pkg.TRUE, com_api_const_pkg.FALSE)
                   )
               )
            then
                -- 2. Check of Device Sequence Number tag
                if aup_api_tag_pkg.get_tag_value(
                       i_auth_id        => opr_api_shared_data_pkg.g_auth.id
                     , i_tag_reference  => cst_smt_api_const_pkg.TAG_DEVICE_SEQ_NUMBER
                   ) is not null
                then
                    -- 3. Check of flexible field: CST_ADDITIONAL_NAME_PTDF
                    if com_api_flexible_data_pkg.get_flexible_value(
                        i_field_name  => cst_smt_api_const_pkg.FLX_ADDIT_INST_NAME_PTDF
                      , i_entity_type => ost_api_const_pkg.ENTITY_TYPE_INSTITUTION
                      , i_object_id   => opr_api_shared_data_pkg.g_acq_participant.inst_id
                    ) is not null
                    then
                        l_record := create_detail_row_ptlf;
                    else
                        com_api_error_pkg.raise_error(
                            i_error      => 'WRONG_STRUCTURE_FIN_MESSAGE'
                          , i_env_param1 => 'flexible field: ' || cst_smt_api_const_pkg.FLX_ADDIT_INST_NAME_PTDF || ' is absent'
                        );
                    end if;
                else
                    com_api_error_pkg.raise_error(
                        i_error      => 'WRONG_STRUCTURE_FIN_MESSAGE'
                      , i_env_param1 => 'tag: ' || cst_smt_api_const_pkg.TAG_DEVICE_SEQ_NUMBER || ' is absent'
                    );
                end if;        
            else
                com_api_error_pkg.raise_error(
                    i_error      => 'WRONG_STRUCTURE_FIN_MESSAGE'
                  , i_env_param1 => 'msg_type = ' || opr_api_shared_data_pkg.g_operation.msg_type || ' '
                                 || 'is_advise = ' || opr_api_shared_data_pkg.g_auth.is_advice || ' '
                                 || 'is_reversal = ' || opr_api_shared_data_pkg.g_auth.is_reversal
                );
            end if;            
                    
            prc_api_file_pkg.put_line(
                i_raw_data      => l_record
              , i_sess_file_id  => l_session_file_id
            );
            prc_api_file_pkg.put_file(
                i_sess_file_id   => l_session_file_id
              , i_clob_content   => l_record || CRLF
              , i_add_to         => com_api_const_pkg.TRUE
            );

            l_total_count := l_total_count + 1;
            evt_api_event_pkg.register_event(
                i_event_type  => cst_smt_api_const_pkg.MNO_OPER_UPLOADED_EVENT
              , i_eff_date    => l_eff_date
              , i_entity_type => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id   => opr_api_shared_data_pkg.g_operation.id
              , i_inst_id     => i_inst_id
              , i_split_hash  => com_api_hash_pkg.get_split_hash(
                                     i_entity_type    => opr_api_const_pkg.ENTITY_TYPE_OPERATION 
                                   , i_object_id      => opr_api_shared_data_pkg.g_operation.id
                                   , i_mask_error     => com_api_const_pkg.TRUE
                                 )
              , i_param_tab   => l_params
            );
        end loop;

        trc_log_pkg.debug('events were processed, cnt = ' || l_event_tab.count);

        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_event_tab
        );

        close evt_object_cur;

    end if;  -- l_estimate_count > 0

    l_record := 'FT'
             || 'PTLF'
             || lpad(l_file_name, 35, ' ')
             || lpad(to_char(l_total_count), 10, '0')
             || 'EFT';
             
    prc_api_file_pkg.put_line(
        i_raw_data      => l_record
      , i_sess_file_id  => l_session_file_id
    );
    prc_api_file_pkg.put_file(
        i_sess_file_id   => l_session_file_id
      , i_clob_content   => l_record
      , i_add_to         => com_api_const_pkg.TRUE
    );
    
    prc_api_stat_pkg.log_end(
        i_processed_total  => l_total_count
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
end process_msstrxn;

procedure process_ptlf(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_network_id            in     com_api_type_pkg.t_network_id
  , i_participant_type      in     com_api_type_pkg.t_dict_value     default com_api_const_pkg.PARTICIPANT_ISSUER
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_ptlf: ';
    
    l_estimate_count       simple_integer := 0;
    l_expected_count       simple_integer := 0;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_file_name            com_api_type_pkg.t_name;
    l_record               com_api_type_pkg.t_text;
    l_container_id         com_api_type_pkg.t_long_id    :=  prc_api_session_pkg.get_container_id;
    l_params               com_api_type_pkg.t_param_tab;
    l_participant_type     com_api_type_pkg.t_dict_value := nvl(i_participant_type, com_api_const_pkg.PARTICIPANT_ISSUER);

    l_event_tab            com_api_type_pkg.t_number_tab;
    l_operation_id_tab     num_tab_tpt                   := num_tab_tpt();
    l_eff_date             date;
    l_total_count          com_api_type_pkg.t_medium_id  := 0;
    l_session_file_id      com_api_type_pkg.t_long_id;

    cursor evt_object_cur is
        select o.id
             , o.object_id
          from evt_event_object o
             , evt_event e
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_SMT_PRC_OUTGOING_PKG.PROCESS_PTLF'
           and o.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and o.eff_date      <= l_eff_date
           and o.inst_id        = i_inst_id
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and e.id             = o.event_id
           and exists(select 1
                        from opr_participant p
                       where p.oper_id = o.object_id
                         and p.participant_type = l_participant_type
                         and p.network_id = i_network_id
               );

begin
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    l_eff_date      := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id);

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'inst_id=#1, network_id=#2, participant=#3, file_type=#4, l_container_id=#5, l_eff_date=#6'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_network_id
      , i_env_param3 => l_participant_type
      , i_env_param4 => l_file_type
      , i_env_param5 => l_container_id
      , i_env_param6 => l_eff_date
    );
    
    prc_api_stat_pkg.log_start;

    select count(*) as cnt
      into l_estimate_count
      from evt_event_object o
         , evt_event e
     where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_SMT_PRC_OUTGOING_PKG.PROCESS_PTLF'
       and o.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and o.eff_date      <= l_eff_date
       and o.inst_id        = i_inst_id
       and o.split_hash    in (select split_hash from com_api_split_map_vw)
       and e.id             = o.event_id
       and exists(select 1
                    from opr_participant p
                   where p.oper_id = o.object_id
                     and p.participant_type = l_participant_type
                     and p.network_id = i_network_id
           );

    trc_log_pkg.debug('Estimate count = [' || l_estimate_count || ']');

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimate_count
    );
    
    prc_api_file_pkg.open_file (
        o_sess_file_id  => l_session_file_id
      , i_file_type     => l_file_type
      , io_params       => l_params
    );

    select  p.file_name
      into  l_file_name
      from  prc_session_file p
     where  p.id = l_session_file_id;
     
    l_record := 'FH'
             || to_date(l_eff_date, 'yymmdd')
             || to_char(systimestamp, 'hh24missff2')
             || i_network_id
             || 'PTLF'
             || lpad(l_file_name, 35, ' ')
             || 'EFH';
             
    prc_api_file_pkg.put_line(
        i_raw_data      => l_record
      , i_sess_file_id  => l_session_file_id
    );
    prc_api_file_pkg.put_file(
        i_sess_file_id   => l_session_file_id
      , i_clob_content   => l_record || CRLF
      , i_add_to         => com_api_const_pkg.TRUE
    );
    
    if l_estimate_count > 0 then

        l_params.delete;
        rul_api_param_pkg.set_param (
              i_name     => 'INST_ID'
            , i_value    => i_inst_id
            , io_params  => l_params
        );

        open evt_object_cur;
        fetch evt_object_cur 
         bulk collect 
         into l_event_tab
            , l_operation_id_tab;

        for i in 1 .. l_operation_id_tab.count loop
            opr_api_shared_data_pkg.g_operation       := null;
            opr_api_shared_data_pkg.g_iss_participant := null;
            opr_api_shared_data_pkg.g_acq_participant := null;
            opr_api_shared_data_pkg.g_auth            := null;
            
            opr_api_operation_pkg.get_operation(
                i_oper_id   => l_operation_id_tab(i)
              , o_operation => opr_api_shared_data_pkg.g_operation
            );
            
            opr_api_operation_pkg.get_participant(
                i_oper_id           => l_operation_id_tab(i)
              , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
              , o_participant       => opr_api_shared_data_pkg.g_iss_participant
            );
            
            opr_api_operation_pkg.get_participant(
                i_oper_id           => l_operation_id_tab(i)
              , i_participaint_type => com_api_const_pkg.PARTICIPANT_ACQUIRER
              , o_participant       => opr_api_shared_data_pkg.g_acq_participant
            );

            opr_api_shared_data_pkg.g_auth := aut_api_auth_pkg.get_auth(i_id => l_operation_id_tab(i));

            l_record := create_detail_row_ptlf;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record
              , i_sess_file_id  => l_session_file_id
            );
            prc_api_file_pkg.put_file(
                i_sess_file_id   => l_session_file_id
              , i_clob_content   => l_record || CRLF
              , i_add_to         => com_api_const_pkg.TRUE
            );

            l_total_count := l_total_count + 1;
        end loop;

        trc_log_pkg.debug('events were processed, cnt = ' || l_event_tab.count);

        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_event_tab
        );

        close evt_object_cur;

    end if;  -- l_estimate_count > 0

    l_record := 'FT'
             || 'PTLF'
             || lpad(l_file_name, 35, ' ')
             || lpad(to_char(l_total_count), 10, '0')
             || 'EFT';
             
    prc_api_file_pkg.put_line(
        i_raw_data      => l_record
      , i_sess_file_id  => l_session_file_id
    );
    prc_api_file_pkg.put_file(
        i_sess_file_id   => l_session_file_id
      , i_clob_content   => l_record
      , i_add_to         => com_api_const_pkg.TRUE
    );
    
    prc_api_stat_pkg.log_end(
        i_processed_total  => l_total_count
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
end process_ptlf;

procedure process_tlf(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_network_id            in     com_api_type_pkg.t_network_id
  , i_participant_type      in     com_api_type_pkg.t_dict_value     default com_api_const_pkg.PARTICIPANT_ISSUER
) is
    LOG_PREFIX             constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_tlf: ';
    
    l_estimate_count       simple_integer := 0;
    l_expected_count       simple_integer := 0;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_file_name            com_api_type_pkg.t_name;
    l_record               com_api_type_pkg.t_text;
    l_container_id         com_api_type_pkg.t_long_id    :=  prc_api_session_pkg.get_container_id;
    l_params               com_api_type_pkg.t_param_tab;
    l_participant_type     com_api_type_pkg.t_dict_value := nvl(i_participant_type, com_api_const_pkg.PARTICIPANT_ISSUER);

    l_event_tab            com_api_type_pkg.t_number_tab;
    l_operation_id_tab     num_tab_tpt                   := num_tab_tpt();
    l_eff_date             date;
    l_total_count          com_api_type_pkg.t_medium_id  := 0;
    l_session_file_id      com_api_type_pkg.t_long_id;

    cursor evt_object_cur is
        select o.id
             , o.object_id
          from evt_event_object o
             , evt_event e
         where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_SMT_PRC_OUTGOING_PKG.PROCESS_TLF'
           and o.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
           and o.eff_date      <= l_eff_date
           and o.inst_id        = i_inst_id
           and o.split_hash    in (select split_hash from com_api_split_map_vw)
           and e.id             = o.event_id
           and exists(select 1
                        from opr_participant p
                       where p.oper_id = o.object_id
                         and p.participant_type = l_participant_type
                         and p.network_id = i_network_id
               );

begin
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    l_eff_date      := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id);

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'inst_id=#1, network_id=#2, participant=#3, file_type=#4, l_container_id=#5, l_eff_date=#6'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_network_id
      , i_env_param3 => l_participant_type
      , i_env_param4 => l_file_type
      , i_env_param5 => l_container_id
      , i_env_param6 => l_eff_date
    );
    
    prc_api_stat_pkg.log_start;

    select count(*) as cnt
      into l_estimate_count
      from evt_event_object o
         , evt_event e
     where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_SMT_PRC_OUTGOING_PKG.PROCESS_PTLF'
       and o.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
       and o.eff_date      <= l_eff_date
       and o.inst_id        = i_inst_id
       and o.split_hash    in (select split_hash from com_api_split_map_vw)
       and e.id             = o.event_id
       and exists(select 1
                    from opr_participant p
                   where p.oper_id = o.object_id
                     and p.participant_type = l_participant_type
                     and p.network_id = i_network_id
           );

    trc_log_pkg.debug('Estimate count = [' || l_estimate_count || ']');

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimate_count
    );
    
    prc_api_file_pkg.open_file (
        o_sess_file_id  => l_session_file_id
      , i_file_type     => l_file_type
      , io_params       => l_params
    );

    select  p.file_name
      into  l_file_name
      from  prc_session_file p
     where  p.id = l_session_file_id;
     
    l_record := 'FH'
             || to_date(l_eff_date, 'yymmdd')
             || to_char(systimestamp, 'hh24missff2')
             || i_network_id
             || 'TLF'
             || lpad(l_file_name, 35, ' ')
             || 'EFH';
             
    prc_api_file_pkg.put_line(
        i_raw_data      => l_record
      , i_sess_file_id  => l_session_file_id
    );
    prc_api_file_pkg.put_file(
        i_sess_file_id   => l_session_file_id
      , i_clob_content   => l_record || CRLF
      , i_add_to         => com_api_const_pkg.TRUE
    );
    
    if l_estimate_count > 0 then

        l_params.delete;
        rul_api_param_pkg.set_param (
              i_name     => 'INST_ID'
            , i_value    => i_inst_id
            , io_params  => l_params
        );

        open evt_object_cur;
        fetch evt_object_cur 
         bulk collect 
         into l_event_tab
            , l_operation_id_tab;

        for i in 1 .. l_operation_id_tab.count loop
            opr_api_shared_data_pkg.g_operation       := null;
            opr_api_shared_data_pkg.g_iss_participant := null;
            opr_api_shared_data_pkg.g_acq_participant := null;
            opr_api_shared_data_pkg.g_auth            := null;
            
            opr_api_operation_pkg.get_operation(
                i_oper_id   => l_operation_id_tab(i)
              , o_operation => opr_api_shared_data_pkg.g_operation
            );
            
            opr_api_operation_pkg.get_participant(
                i_oper_id           => l_operation_id_tab(i)
              , i_participaint_type => com_api_const_pkg.PARTICIPANT_ISSUER
              , o_participant       => opr_api_shared_data_pkg.g_iss_participant
            );
            
            opr_api_operation_pkg.get_participant(
                i_oper_id           => l_operation_id_tab(i)
              , i_participaint_type => com_api_const_pkg.PARTICIPANT_ACQUIRER
              , o_participant       => opr_api_shared_data_pkg.g_acq_participant
            );

            opr_api_shared_data_pkg.g_auth := aut_api_auth_pkg.get_auth(i_id => l_operation_id_tab(i));

            l_record := create_detail_row_tlf;

            prc_api_file_pkg.put_line(
                i_raw_data      => l_record
              , i_sess_file_id  => l_session_file_id
            );
            prc_api_file_pkg.put_file(
                i_sess_file_id   => l_session_file_id
              , i_clob_content   => l_record || CRLF
              , i_add_to         => com_api_const_pkg.TRUE
            );

            l_total_count := l_total_count + 1;
        end loop;

        trc_log_pkg.debug('events were processed, cnt = ' || l_event_tab.count);

        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_event_tab
        );

        close evt_object_cur;

    end if;  -- l_estimate_count > 0

    l_record := 'FT'
             || 'TLF'
             || lpad(l_file_name, 35, ' ')
             || lpad(to_char(l_total_count), 10, '0')
             || 'EFT';
             
    prc_api_file_pkg.put_line(
        i_raw_data      => l_record
      , i_sess_file_id  => l_session_file_id
    );
    prc_api_file_pkg.put_file(
        i_sess_file_id   => l_session_file_id
      , i_clob_content   => l_record
      , i_add_to         => com_api_const_pkg.TRUE
    );
    
    prc_api_stat_pkg.log_end(
        i_processed_total  => l_total_count
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
end process_tlf;

end;
/
